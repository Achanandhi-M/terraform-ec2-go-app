
#!/bin/bash
set -e

# Always run inside the directory of this script
cd "$(dirname "$0")"

BUCKET=${S3_BUCKET:-devops-assignment-7}
KEY=${S3_KEY:-assignment-app}
REGION=${AWS_REGION:-ap-south-1}

echo "Building Go binary..."

CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o assignment-app main.go

echo "Uploading to s3://${BUCKET}/${KEY} ..."
aws s3 cp assignment-app "s3://${BUCKET}/${KEY}" --region "${REGION}"

echo "Done. Uploaded key=${KEY} in bucket=${BUCKET}"
