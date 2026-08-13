#!/usr/bin/env bash
set -euo pipefail

# Module 5 Sandbox Manager
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
        log "Starting Module 5 Sandbox (Chaos Engineering)..."
        docker compose -f "$COMPOSE_FILE" up -d
        log "Waiting for containers to boot and install dependencies (apk add)..."
        sleep 8
        log "Sandbox is up and running!"
        ;;
    down)
        log "Stopping and cleaning up Module 5 Sandbox..."
        docker compose -f "$COMPOSE_FILE" down -v
        log "Sandbox stopped."
        ;;
    test)
        log "Running automated validation tests for Module 5..."

        if ! docker ps --format '{{.Names}}' | grep -q "chaos-aws"; then
            error "Chaos AWS container is not running. Run './sandbox.sh up' first."
            exit 1
        fi

        log "Step 1: Testing initial ping between chaos-aws and chaos-gcp..."
        if docker exec -t chaos-aws ping -c 3 chaos-gcp > /dev/null; then
            log "SUCCESS: Initial network connection is healthy and low-latency."
        else
            error "Initial connectivity failed!"
            exit 1
        fi

        log "Step 2: Injecting 500ms network delay in chaos-aws..."
        docker exec -t chaos-aws tc qdisc add dev eth0 root netem delay 500ms

        log "Measuring round trip time (should see ~500ms latency)..."
        ping_res=$(docker exec -t chaos-aws ping -c 3 chaos-gcp)
        echo "$ping_res"
        
        avg_latency=$(echo "$ping_res" | grep rtt | cut -d'/' -f5 | cut -d'.' -f1 || echo "0")
        log "Average Latency: ${avg_latency}ms"

        if [ "$avg_latency" -ge 480 ]; then
            log "SUCCESS: Latency injection verified!"
        else
            error "Latency injection failed. Latency is only ${avg_latency}ms."
            # Attempt to clean up
            docker exec -t chaos-aws tc qdisc del dev eth0 root || true
            exit 1
        fi

        log "Curing network latency..."
        docker exec -t chaos-aws tc qdisc del dev eth0 root
        log "Latency cured!"

        log "Step 3: Injecting Network Partition (Blackhole) via iptables on chaos-aws..."
        # Block outgoing ping requests
        docker exec -t chaos-aws iptables -A OUTPUT -p icmp -j DROP

        log "Testing ping again (should fail)..."
        if docker exec -t chaos-aws ping -c 2 -W 1 chaos-gcp > /dev/null 2>&1; then
            error "Blackhole injection failed! Ping still succeeded."
            docker exec -t chaos-aws iptables -F || true
            exit 1
        else
            log "SUCCESS: Blackhole injection verified! Network partition is active."
        fi

        log "Curing network partition (Flushing iptables)..."
        docker exec -t chaos-aws iptables -F
        log "Network partition cured!"

        log "Step 4: Verifying network is fully restored..."
        if docker exec -t chaos-aws ping -c 2 chaos-gcp > /dev/null; then
            log "SUCCESS: Network fully restored and operational!"
        else
            error "Network restoration failed!"
            exit 1
        fi

        log "ALL TESTS PASSED SUCCESSFULLY!"
        ;;
    *)
        echo "Usage: $0 {up|down|test}"
        exit 1
        ;;
esac
