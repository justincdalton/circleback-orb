#!/bin/bash
# This example uses envsubst to support variable substitution in the string parameter type.
# https://circleci.com/docs/orbs-best-practices/#accepting-parameters-as-strings-or-environment-variables

# Check if the key variable is set
if [ -z "${!PARAM_CIRCLECI_API_KEY}" ]; then
  echo "CircleCI API key not set"
fi

CIRCLE_TOKEN="${!PARAM_CIRCLECI_API_KEY}"
PARAMETERS="{}"

# Check if CIRCLE_WORKFLOW_ID is set and add to parameters
if [ -n "$PARAM_WORKFLOW_ID" ]; then
  PARAMETERS="{\"circleback_workflow_id\":\"$PARAM_WORKFLOW_ID\"}"
fi

# merge PARAM_PARAMETERS into PARAMETERS if it exists
if [ -n "$PARAM_PARAMETERS" ]; then
  PARAMETERS=$(jq -nc --argjson json1 "$PARAMETERS" --argjson json2 "$PARAM_PARAMETERS" '$json1 + $json2')
fi

API_RESPONSE=$(
  curl --request POST \
    --url "https://circleci.com/api/v2/project/$PARAM_PROJECT/pipeline" \
    --header "Circle-Token: $CIRCLE_TOKEN" \
    --header "content-type: application/json" \
    --data "{\"branch\":\"$PARAM_BRANCH\",\"parameters\": $PARAMETERS}"
)

TRIGGERED_PIPELINE=$(echo "$API_RESPONSE" | jq -r '.id')

if [ -z "$TRIGGERED_PIPELINE" ]; then
  echo "Failed to trigger pipeline"
  echo "API Response: $API_RESPONSE"
  exit 1
fi

echo "Triggered pipeline $TRIGGERED_PIPELINE"
mkdir -p circleback_workspace
echo "$TRIGGERED_PIPELINE" >circleback_workspace/CIRCLEBACK_ORB_PIPELINE
