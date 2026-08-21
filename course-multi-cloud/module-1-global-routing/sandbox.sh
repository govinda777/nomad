#!/usr/bin/env bash
set -euo pipefail

# Module 1 Sandbox Manager
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
        log "Starting Module 1 Sandbox (Global Routing)..."
        docker compose -f "$COMPOSE_FILE" up -d --build
        log "Sandbox is up and running!"
        log "Endpoints:"
        log "  - GTM/Edge DNS: http://localhost:8080"
        log "  - AWS Server (Direct): http://localhost:8081"
        log "  - GCP Server (Direct): http://localhost:8082"
        ;;
    down)
        log "Stopping and cleaning up Module 1 Sandbox..."
        docker compose -f "$COMPOSE_FILE" down -v
        log "Sandbox stopped."
        ;;
    test)
        log "Running automated validation tests for Module 1..."
        
        # Check if running
        if ! docker ps --format '{{.Names}}' | grep -q "gtm-edge-dns"; then
            error "Containers are not running. Run './sandbox.sh up' first."
            exit 1
        fi
        
        # Test AWS availability
        log "Testing direct access to AWS (8081)..."
        aws_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 || echo "000")
        if [ "$aws_status" -ne 200 ]; then
            error "AWS endpoint is down (HTTP $aws_status)"
            exit 1
        fi
        log "AWS is OK!"

        # Test GCP availability
        log "Testing direct access to GCP (8082)..."
        gcp_status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8082 || echo "000")
        if [ "$gcp_status" -ne 200 ]; then
            error "GCP endpoint is down (HTTP $gcp_status)"
            exit 1
        fi
        log "GCP is OK!"

        # Test GTM Routing - AWS should be active
        log "Testing GTM Edge DNS (8080) routing..."
        gtm_res=$(curl -s http://localhost:8080)
        if echo "$gtm_res" | grep -q "AWS"; then
            log "SUCCESS: GTM is correctly routing to AWS (Primary)"
        else
            error "GTM failed to route to AWS. Got response: $gtm_res"
            exit 1
        fi

        # Inject Failure (Stop AWS)
        log "Simulating desaster: stopping AWS container..."
        docker stop lb-mock-aws > /dev/null

        # Give HAProxy 4 seconds to failover (health checks run every 1s)
        sleep 4

        log "Testing GTM Edge DNS (8080) after AWS failure..."
        gtm_failover_res=$(curl -s http://localhost:8080)
        if echo "$gtm_failover_res" | grep -q "GCP"; then
            log "SUCCESS: Auto-Failover to GCP (Backup) completed successfully!"
        else
            error "Failover failed! Got response: $gtm_failover_res"
            # Bring container back up before exit
            docker start lb-mock-aws > /dev/null
            exit 1
        fi

        # Heal (Start AWS)
        log "Simulating recovery: starting AWS container again..."
        docker start lb-mock-aws > /dev/null
        sleep 2

        log "Testing GTM Edge DNS (8080) after AWS recovery..."
        gtm_recovery_res=$(curl -s http://localhost:8080)
        if echo "$gtm_recovery_res" | grep -q "AWS"; then
            log "SUCCESS: GTM reverted back to AWS (Primary)!"
        else
            error "Revert failed! Got response: $gtm_recovery_res"
            exit 1
        fi

        log "ALL TESTS PASSED SUCCESSFULLY!"
        ;;
    *)
        echo "Usage: $0 {up|down|test}"
        exit 1
        ;;
esac
