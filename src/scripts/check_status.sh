#!/bin/bash
# This example uses envsubst to support variable substitution in the string parameter type.
# https://circleci.com/docs/orbs-best-practices/#accepting-parameters-as-strings-or-environment-variables

# Check if the key variable is set
if [ -z "${!PARAM_CIRCLECI_API_KEY}" ]; then
  echo "CircleCI API key not set"
fi

CIRCLE_TOKEN="${!PARAM_CIRCLECI_API_KEY}"
CIRCLE_WORKFLOW_ID="${!PARAM_CIRCLE_WORKFLOW_ID}"
PIPELINE_ID=$(cat ~/circleback_workspace/CIRCLEBACK_ORB_PIPELINE)

API_RESPONSE=$(
  curl --request GET \
    --url "https://circleci.com/api/v2/pipeline/$PIPELINE_ID/workflow" \
    --header "Circle-Token: $CIRCLE_TOKEN" \
    --header "content-type: application/json"
)

echo "API Response: $API_RESPONSE"

# TRIGGERED_PIPELINE=$(echo "$API_RESPONSE" | jq -r '.id')

# if [ -z "$TRIGGERED_PIPELINE" ]; then
#   echo "Failed to trigger pipeline"
#   echo "API Response: $API_RESPONSE"
#   exit 1
# fi

# echo "Triggered pipeline $TRIGGERED_PIPELINE"
# mkdir -p ~/circleback_workspace
# echo "$TRIGGERED_PIPELINE" >~/circleback_workspace/CIRCLEBACK_ORB_PIPELINE
