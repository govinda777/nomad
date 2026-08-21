#!/usr/bin/env bash
set -euo pipefail

# Module 3 Sandbox Manager
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
        log "Starting Module 3 Sandbox (Nomad Multi-Region Federation)..."
        docker compose -f "$COMPOSE_FILE" up -d
        log "Waiting for Nomad servers to initialize..."
        sleep 5

        log "Federating Nomad clusters (AWS <-> GCP)..."
        # Join GCP server to AWS server via Serf WAN (4648)
        docker exec -t nomad-server-gcp nomad server join nomad-server-aws:4648 || true
        
        log "Sandbox is up and running!"
        log "Nomad AWS HTTP: http://localhost:4646"
        log "Nomad GCP HTTP: http://localhost:4647"
        ;;
    down)
        log "Stopping and cleaning up Module 3 Sandbox..."
        docker compose -f "$COMPOSE_FILE" down -v
        log "Sandbox stopped."
        ;;
    test)
        log "Running automated validation tests for Module 3..."

        if ! docker ps --format '{{.Names}}' | grep -q "nomad-server-aws"; then
            error "Nomad AWS Server is not running. Run './sandbox.sh up' first."
            exit 1
        fi

        log "Verifying Nomad server federation..."
        members=$(docker exec -t nomad-server-aws nomad server members || echo "")
        echo "$members"

        if echo "$members" | grep -q "us-east" && echo "$members" | grep -q "us-west"; then
            log "SUCCESS: Nomad Servers are federated across regions!"
        else
            error "Federation failed. Regions are not connected."
            exit 1
        fi

        log "Submitting multi-region job to the federated cluster..."
        # Submit the job using piped stdin
        docker exec -i nomad-server-aws nomad job run - < "$DIR/base/jobs/global-nginx.nomad.hcl"

        log "Waiting for job evaluation..."
        sleep 4

        log "Checking job status..."
        job_status=$(docker exec -t nomad-server-aws nomad job status global-nginx || echo "")
        echo "$job_status"

        if echo "$job_status" | grep -q "Status.*running"; then
            log "SUCCESS: Multi-region job 'global-nginx' is running successfully!"
        else
            error "Job submission failed or job is not running."
            exit 1
        fi

        log "ALL TESTS PASSED SUCCESSFULLY!"
        ;;
    *)
        echo "Usage: $0 {up|down|test}"
        exit 1
        ;;
esac
