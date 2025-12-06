#!/bin/bash
set -e
cd "$(dirname "$0")/.."
cd terraform
ALB=$(terraform output -raw alb_dns)
echo "ALB DNS: $ALB"
echo "Checking /health..."
curl -sS "http://${ALB}/health" || { echo "health failed" ; exit 1; }
echo "Checking /"
curl -sS "http://${ALB}/" || { echo "root failed"; exit 1; }
echo "Tests passed"
