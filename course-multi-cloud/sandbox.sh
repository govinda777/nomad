#!/usr/bin/env bash
set -euo pipefail

# Global Course Sandbox Manager
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() {
    echo -e "\033[1;34m[GLOBAL]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

MODULES=(
    "module-1-global-routing"
    "module-2-mesh-network"
    "module-3-nomad-federation"
    "module-4-distributed-data"
    "module-5-chaos-engineering"
)

usage() {
    echo "Usage: $0 {up|down|test} [module_number (1-5)]"
    echo "Examples:"
    echo "  $0 up 1       # Starts module 1"
    echo "  $0 test 3     # Runs tests for module 3"
    echo "  $0 down       # Stops all module sandboxes"
    exit 1
}

ACTION="${1:-}"
MOD_NUM="${2:-}"

if [[ -z "$ACTION" ]]; then
    usage
fi

run_module_action() {
    local mod_dir="$1"
    local action="$2"
    if [[ -f "$mod_dir/sandbox.sh" ]]; then
        log "Running '$action' inside $mod_dir..."
        (cd "$mod_dir" && ./sandbox.sh "$action")
    else
        error "No sandbox.sh found in $mod_dir"
    fi
}

if [[ -n "$MOD_NUM" ]]; then
    if [[ "$MOD_NUM" -ge 1 && "$MOD_NUM" -le 5 ]]; then
        target_mod="${MODULES[$((MOD_NUM-1))]}"
        run_module_action "$DIR/$target_mod" "$ACTION"
    else
        error "Invalid module number: $MOD_NUM (must be 1-5)"
        usage
    fi
else
    # Run for all modules if no specific module is provided
    for mod in "${MODULES[@]}"; do
        run_module_action "$DIR/$mod" "$ACTION"
    done
fi
