#!/bin/bash
set -e
cd "$(dirname "$0")/.."
cd terraform
terraform destroy -auto-approve
