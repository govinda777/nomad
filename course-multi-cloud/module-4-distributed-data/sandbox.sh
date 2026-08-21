#!/usr/bin/env bash
set -euo pipefail

# Module 4 Sandbox Manager
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
        log "Starting Module 4 Sandbox (CockroachDB Multi-Cloud Quorum)..."
        docker compose -f "$COMPOSE_FILE" up -d
        log "Waiting for CockroachDB containers to start..."
        sleep 5
        log "Initializing CockroachDB cluster..."
        docker exec -t crdb-aws cockroach init --insecure || true
        log "Waiting for cluster initialization..."
        sleep 3
        log "Sandbox is up and running!"
        log "CockroachDB AWS Console: http://localhost:8083"
        log "CockroachDB GCP Console: http://localhost:8084"
        log "CockroachDB Azure Console: http://localhost:8085"
        ;;
    down)
        log "Stopping and cleaning up Module 4 Sandbox..."
        docker compose -f "$COMPOSE_FILE" down -v
        log "Sandbox stopped."
        ;;
    test)
        log "Running automated validation tests for Module 4..."

        if ! docker ps --format '{{.Names}}' | grep -q "crdb-aws"; then
            error "CockroachDB AWS container is not running. Run './sandbox.sh up' first."
            exit 1
        fi

        log "Step 1: Inserting data into AWS node (localhost:26257)..."
        docker exec -i crdb-aws cockroach sql --insecure -e "
            CREATE DATABASE IF NOT EXISTS school;
            CREATE TABLE IF NOT EXISTS school.students (id INT PRIMARY KEY, name VARCHAR(50));
            INSERT INTO school.students (id, name) VALUES (1, 'Govinda - Multi-Cloud Architect') ON CONFLICT (id) DO NOTHING;
        "

        log "Step 2: Simulating region crash: stopping AWS database node..."
        docker stop crdb-aws > /dev/null
        # Wait for Raft to discover the loss of AWS and keep serving via GCP + Azure Witness
        sleep 3

        log "Step 3: Querying GCP node (localhost:26258) for the inserted data..."
        query_result=$(docker exec -i crdb-gcp cockroach sql --insecure -e "SELECT name FROM school.students WHERE id = 1;" || echo "FAILED")
        
        echo "$query_result"

        if echo "$query_result" | grep -q "Govinda - Multi-Cloud Architect"; then
            log "SUCCESS: GCP node read the data successfully! Quorum maintained with Azure Witness."
        else
            error "Quorum failed or data was lost!"
            docker start crdb-aws > /dev/null
            exit 1
        fi

        log "Step 4: Restoring AWS node..."
        docker start crdb-aws > /dev/null
        sleep 3
        log "AWS node recovered."

        log "ALL TESTS PASSED SUCCESSFULLY!"
        ;;
    *)
        echo "Usage: $0 {up|down|test}"
        exit 1
        ;;
esac
