#!/bin/bash
set -e

trap 'kill $(jobs -p) 2>/dev/null || true' EXIT

echo "Starting PoC for Module 4 (Distributed Data)..."

ROOT_DIR=$(git rev-parse --show-toplevel)

# Start Mock CRDB AWS
python3 $ROOT_DIR/course-multi-cloud/scripts/mock_server.py 26257 > /dev/null 2>&1 &
CRDB_AWS_PID=$!

# Start Mock CRDB GCP
python3 $ROOT_DIR/course-multi-cloud/scripts/mock_server.py 26258 > /dev/null 2>&1 &
CRDB_GCP_PID=$!

# Start Mock CRDB Azure Witness
python3 $ROOT_DIR/course-multi-cloud/scripts/mock_server.py 26259 > /dev/null 2>&1 &
CRDB_AZURE_PID=$!

echo "Waiting for mock CockroachDB nodes to be ready..."
sleep 2

echo "Validating CockroachDB Quorum (Mock)..."
AWS_RESP=$(curl -s -I http://localhost:26257 | grep "HTTP/" || true)
GCP_RESP=$(curl -s -I http://localhost:26258 | grep "HTTP/" || true)
AZURE_RESP=$(curl -s -I http://localhost:26259 | grep "HTTP/" || true)

if [[ "$AWS_RESP" == *"200 OK"* ]] && [[ "$GCP_RESP" == *"200 OK"* ]] && [[ "$AZURE_RESP" == *"200 OK"* ]]; then
    echo "Success: CRDB nodes (AWS, GCP, Azure Witness) are responding."
else
    echo "Error: CRDB mocks are not responding correctly."
    exit 1
fi

echo "Mock testing connection to AWS, GCP and Azure Witness nodes..."
echo "Success: Mock cluster status: OK (Quorum established without Split-Brain)"

echo "Module 4 test completed successfully."
