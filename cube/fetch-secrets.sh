#!/usr/bin/env bash
set -euo pipefail

#SECRET_ARN="arn:aws:secretsmanager:eu-west-1:814382091013:secret:cubecloud_user-6fVIVb"
SECRET_ARN="arn:aws:secretsmanager:eu-west-1:445416880558:secret:cubecloud-accessor-credentials-EHSW6V"
AWS_PROFILE_NAME="data"
REGION="eu-west-1"

cd "$(dirname "$0")"

secret_json=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --profile "$AWS_PROFILE_NAME" \
  --region "$REGION" \
  --query SecretString \
  --output text)

access_key=$(jq -r '.access_key_id' <<<"$secret_json")
secret_key=$(jq -r '.secret_access_key' <<<"$secret_json")

cat > .env.runtime <<EOF
CUBEJS_AWS_KEY=$access_key
CUBEJS_AWS_SECRET=$secret_key
EOF

echo "Wrote .env.runtime from $SECRET_ARN"