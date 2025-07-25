#!/usr/bin/env zsh

# zsh-tkube - Enhanced Teleport kubectl wrapper with auto-authentication for Zsh
# Based on fish-tkube by lidin10

# Default configuration - can be overridden in user's zshrc
typeset -ga TKUBE_ENVS
typeset -g TKUBE_AUTO_LOGIN

# Set defaults if not already configured
if [[ -z "${TKUBE_ENVS[@]}" ]]; then
    TKUBE_ENVS=(
        prod teleport.prod.env:443
        test teleport.test.env:443
    )
fi

if [[ -z "$TKUBE_AUTO_LOGIN" ]]; then
    TKUBE_AUTO_LOGIN=true
fi

# Main tkube function
tkube() {
    local env="$1"
    local cluster="$2"

    # Handle help and special commands
    case "$env" in
        help|--help|-h)
            _tkube_help
            return 0
            ;;
        version|--version|-v)
            _tkube_version
            return 0
            ;;
        status|--status)
            _tkube_status
            return 0
            ;;
    esac

    # Validate arguments
    if [[ -z "$env" ]]; then
        echo "❌ Missing environment name"
        echo ""
        _tkube_usage
        return 1
    fi

    # Check if environment exists in the array
    local proxy=""
    local i
    for ((i=1; i<=${#TKUBE_ENVS[@]}; i+=2)); do
        if [[ "${TKUBE_ENVS[$i]}" == "$env" ]]; then
            proxy="${TKUBE_ENVS[$((i+1))]}"
            break
        fi
    done

    if [[ -z "$proxy" ]]; then
        echo "❌ Unknown environment '$env'"
        echo ""
        _tkube_status
        return 1
    fi

    # Check if cluster name is provided
    if [[ -z "$cluster" ]]; then
        echo "❌ Missing cluster name"
        echo ""
        _tkube_usage
        return 1
    fi

    # Check Teleport authentication status for this proxy
    if ! _tkube_is_authenticated "$proxy"; then
        if [[ "$TKUBE_AUTO_LOGIN" == "true" ]]; then
            echo "🔐 Not authenticated to $proxy, logging in..."
            if ! tsh login --proxy="$proxy"; then
                echo "❌ Failed to authenticate to $proxy"
                return 1
            fi
            echo "✅ Successfully authenticated to $proxy"
        else
            echo "❌ Not authenticated to $proxy"
            echo "Please run: tsh login --proxy=$proxy"
            echo "Or enable auto-login: TKUBE_AUTO_LOGIN=true"
            return 1
        fi
    fi

    # Login to Kubernetes cluster
    echo "🚀 Connecting to cluster '$cluster' in '$env' environment..."
    tsh --proxy="$proxy" kube login "$cluster"
}

# Helper function to check if user is authenticated to a specific proxy
_tkube_is_authenticated() {
    local proxy="$1"
    
    # Get current tsh status and check if authenticated to the specific proxy
    local status_output
    if status_output=$(tsh status --proxy="$proxy" 2>/dev/null); then
        # Check if the output contains "logged in" or similar indicators
        echo "$status_output" | grep -q "logged in\|Valid until"
        return $?
    fi
    
    return 1
}

# Display usage information
_tkube_usage() {
    echo "Usage: tkube <environment> <cluster>"
    echo ""
    echo "Examples:"
    echo "  tkube prod my-cluster         Connect to my-cluster in prod environment"
    echo "  tkube test dev-cluster        Connect to dev-cluster in test environment"
    echo ""
    echo "Run 'tkube help' for more information"
}

# Display help information
_tkube_help() {
    echo "\033[1;34m🚀 zsh-tkube - Teleport kubectl wrapper\033[0m"
    echo ""
    echo "A Zsh shell plugin for quickly logging into Kubernetes clusters via Teleport"
    echo "with intelligent autocompletion and environment-based configuration."
    echo ""
    echo "\033[1;33mUSAGE:\033[0m"
    echo "  tkube <environment> <cluster>     Login to a Kubernetes cluster"
    echo "  tkube help                        Show this help message"
    echo "  tkube status                      Show environments and authentication status"
    echo "  tkube version                     Show version information"
    echo ""
    echo "\033[1;33mEXAMPLES:\033[0m"
    echo "  tkube prod my-cluster             Connect to my-cluster in prod environment"
    echo "  tkube test development            Connect to development in test environment"
    echo "  tkube dev local-cluster           Connect to local-cluster in dev environment"
    echo ""
    echo "\033[1;33mCONFIGURATION:\033[0m"
    echo "  Configure environments in your ~/.zshrc:"
    echo ""
    echo "    TKUBE_ENVS=("
    echo "        prod teleport.prod.company.com:443"
    echo "        test teleport.test.company.com:443"
    echo "        dev teleport.dev.company.com:443"
    echo "    )"
    echo ""
    echo "  Auto-login configuration:"
    echo "    TKUBE_AUTO_LOGIN=true      # Enable automatic login (default)"
    echo "    TKUBE_AUTO_LOGIN=false     # Disable automatic login"
    echo ""
    echo "\033[1;33mFEATURES:\033[0m"
    echo "  🚀 Quick login with tkube <env> <cluster>"
    echo "  🔐 Automatic Teleport authentication"
    echo "  🔍 Smart autocompletion for environments and clusters"
    echo "  ⚙️  Simple array configuration"
    echo "  🎯 Clear error messages and usage hints"
    echo ""
    echo "\033[1;33mAUTOCOMPLETION:\033[0m"
    echo "  - Type 'tkube ' and press Tab to see available environments"
    echo "  - Type 'tkube prod ' and press Tab to see clusters in prod environment"
    echo ""
    echo "\033[1;33mREQUIREMENTS:\033[0m"
    echo "  - Zsh shell"
    echo "  - Teleport CLI (tsh)"
    echo "  - jq (for cluster name autocompletion)"
    echo ""
    echo "\033[1;32mFor more information, visit: https://github.com/lidin10/zsh-tkube\033[0m"
}

# Display version information
_tkube_version() {
    echo "zsh-tkube version 1.0.0"
    echo "A Zsh shell plugin for Teleport kubectl integration"
    echo ""
    echo "Dependencies:"
    if command -v tsh >/dev/null 2>&1; then
        local tsh_version=$(tsh version --client 2>/dev/null | head -n1 || echo "installed")
        echo "  ✅ tsh: $tsh_version"
    else
        echo "  ❌ tsh: not found"
    fi
    if command -v jq >/dev/null 2>&1; then
        local jq_version=$(jq --version 2>/dev/null || echo "installed")
        echo "  ✅ jq: $jq_version"
    else
        echo "  ⚠️  jq: not found (autocompletion may not work)"
    fi
    if command -v kubectl >/dev/null 2>&1; then
        local kubectl_version=$(kubectl version --client --short 2>/dev/null | cut -d' ' -f3 || echo "installed")
        echo "  ✅ kubectl: $kubectl_version"
    else
        echo "  ⚠️  kubectl: not found"
    fi
}

# Show authentication status and available environments
_tkube_status() {
    if [[ ${#TKUBE_ENVS[@]} -eq 0 ]]; then
        echo "❌ No environments configured"
        echo ""
        echo "Configure environments in your ~/.zshrc:"
        echo ""
        echo "  TKUBE_ENVS=("
        echo "      prod teleport.prod.company.com:443"
        echo "      test teleport.test.company.com:443"
        echo "  )"
        return 1
    fi
    
    echo "Available environments and authentication status:"
    echo ""
    
    local i
    for ((i=1; i<=${#TKUBE_ENVS[@]}; i+=2)); do
        local env_name="${TKUBE_ENVS[$i]}"
        local proxy_addr="${TKUBE_ENVS[$((i+1))]}"
        
        if _tkube_is_authenticated "$proxy_addr"; then
            echo "  \033[32m✅ $env_name → $proxy_addr (authenticated)\033[0m"
        else
            echo "  \033[31m❌ $env_name → $proxy_addr (not authenticated)\033[0m"
        fi
    done
    echo ""
    if [[ "$TKUBE_AUTO_LOGIN" == "true" ]]; then
        echo "Auto-login: enabled"
    else
        echo "Auto-login: disabled"
    fi
    echo ""
    echo "Run 'tkube <env> <cluster>' to connect to a cluster"
}

# Helper functions for autocompletion
_tkube_environments() {
    local i
    for ((i=1; i<=${#TKUBE_ENVS[@]}; i+=2)); do
        echo "${TKUBE_ENVS[$i]}"
    done
}

_tkube_clusters() {
    local env="$1"
    local proxy=""
    local i
    
    # Find proxy for this environment
    for ((i=1; i<=${#TKUBE_ENVS[@]}; i+=2)); do
        if [[ "${TKUBE_ENVS[$i]}" == "$env" ]]; then
            proxy="${TKUBE_ENVS[$((i+1))]}"
            break
        fi
    done
    
    if [[ -n "$proxy" ]]; then
        tsh --proxy="$proxy" kube ls --format=json 2>/dev/null | jq -r '.[].kube_cluster_name' 2>/dev/null
    fi
} 