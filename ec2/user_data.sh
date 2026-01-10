#!/bin/bash
set -euxo pipefail

# --- Configuration ---
# This is the standard AWS Instance Metadata Service (IMDS) endpoint
METADATA_IP="169.254.169.254"

# --- Infrastructure Setup ---
dnf update -y
dnf install -y httpd jq
systemctl enable --now httpd

# --- Metadata Retrieval (IMDSv2) ---
# 1. Get a session token (valid for 6 hours)
TOKEN=$(curl -X PUT "http://$METADATA_IP/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# 2. Use the token to get the Instance ID
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s "http://$METADATA_IP/latest/meta-data/instance-id")

HOSTNAME=$(hostname -f)

# --- Web Content Generation ---
cat >/var/www/html/index.html <<EOF
<html>
<head><title>EC2 Status</title></head>
<body>
  <h1>Hello from ${HOSTNAME}</h1>
  <p><strong>Instance ID:</strong> ${INSTANCE_ID}</p>
  <hr>
  <p>Data fetched from Metadata Service at: ${METADATA_IP}</p>
</body>
</html>
EOF