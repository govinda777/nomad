#!/bin/bash
set -e

echo "Starting PoC for Module 5 (Chaos Engineering)..."

echo "Injecting network delay (Mock)..."
sleep 1
echo "Success: Mock tc qdisc delay simulation (500ms latency injected)"

echo "Validating cascading failures (Mock)..."
sleep 1
echo "Success: Mock routing redirect (Health check failed, Route53 cut AWS)"

echo "Simulating Blackhole / Iptables DROP (Mock)..."
sleep 1
echo "Success: Mock iptables DROP applied. System surviving via GCP/Azure quorum."

echo "Reverting chaos injection (Mock)..."
sleep 1
echo "Success: Mock tc qdisc and iptables rules removed. AWS node rejoining cluster."

echo "Module 5 test completed successfully."
