#!/bin/bash
set -e

# Automatically clean up background processes on exit
trap 'kill $(jobs -p) 2>/dev/null || true' EXIT

echo "Starting PoC for Module 1 (Global Routing)..."

# Get absolute path to repo root
ROOT_DIR=$(git rev-parse --show-toplevel)

# Start mock AWS server
python3 $ROOT_DIR/course-multi-cloud/scripts/mock_server.py 8081 > /dev/null 2>&1 &
AWS_PID=$!

# Start mock GCP server
python3 $ROOT_DIR/course-multi-cloud/scripts/mock_server.py 8082 > /dev/null 2>&1 &
GCP_PID=$!

echo "Waiting for mock servers to be ready..."
sleep 2

echo "Testing traffic distribution (Mock AWS)..."
AWS_RESP=$(curl -s -I http://localhost:8081 | grep "HTTP/" || true)
echo "AWS Server Response: $AWS_RESP"

echo "Testing traffic distribution (Mock GCP)..."
GCP_RESP=$(curl -s -I http://localhost:8082 | grep "HTTP/" || true)
echo "GCP Server Response: $GCP_RESP"

if [[ "$AWS_RESP" == *"200 OK"* ]] && [[ "$GCP_RESP" == *"200 OK"* ]]; then
    echo "Success: Both endpoints are up."
else
    echo "Error: Endpoints are not responding correctly."
    exit 1
fi

echo "Simulating failure on AWS..."
kill $AWS_PID
sleep 1

echo "Testing failover (Mock GCP should still respond)..."
GCP_RESP=$(curl -s -I http://localhost:8082 | grep "HTTP/" || true)
if [[ "$GCP_RESP" == *"200 OK"* ]]; then
    echo "Success: Failover simulated successfully. GCP is serving traffic."
else
    echo "Error: GCP endpoint failed during failover test."
    exit 1
fi

echo "Module 1 test completed successfully."
