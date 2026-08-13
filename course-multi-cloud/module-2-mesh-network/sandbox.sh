#!/usr/bin/env bash
set -euo pipefail

# Module 2 Sandbox Manager
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$DIR/base/docker-compose.yml"

log() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

case "${1:-}" in
    up)
        log "Starting Module 2 Sandbox (Mesh Network Federation)..."
        docker compose -f "$COMPOSE_FILE" up -d
        log "Waiting for Consul servers to boot and federate..."
        sleep 5
        log "Sandbox is up and running!"
        log "Consul AWS Web UI: http://localhost:8500"
        log "Consul GCP Web UI: http://localhost:8501"
        ;;
    down)
        log "Stopping and cleaning up Module 2 Sandbox..."
        docker compose -f "$COMPOSE_FILE" down -v
        log "Sandbox stopped."
        ;;
    test)
        log "Running automated validation tests for Module 2..."

        if ! docker ps --format '{{.Names}}' | grep -q "consul-aws"; then
            error "Consul AWS container is not running. Run './sandbox.sh up' first."
            exit 1
        fi

        log "Checking Consul WAN members federation state..."
        wan_members=$(docker exec -t consul-aws consul members -wan || echo "")
        
        echo "$wan_members"

        if echo "$wan_members" | grep -q "dc-aws" && echo "$wan_members" | grep -q "dc-gcp"; then
            log "SUCCESS: Consul AWS (dc-aws) and Consul GCP (dc-gcp) are successfully federated over WAN!"
        else
            error "Federation verification failed! GCP and AWS are not communicating via WAN."
            exit 1
        fi

        log "ALL TESTS PASSED SUCCESSFULLY!"
        ;;
    *)
        echo "Usage: $0 {up|down|test}"
        exit 1
        ;;
esac
