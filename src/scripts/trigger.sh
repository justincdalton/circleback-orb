#!/bin/bash
# This example uses envsubst to support variable substitution in the string parameter type.
# https://circleci.com/docs/orbs-best-practices/#accepting-parameters-as-strings-or-environment-variables

echo $PARAM_CIRCLECI_API_KEY
echo $CIRCLECI_API_KEY

# Check if the key variable is set
if [ -z "${!PARAM_CIRCLECI_API_KEY}" ]; then
  echo "CircleCI API key not set"
fi

CIRCLE_TOKEN="${!PARAM_CIRCLECI_API_KEY}"
CIRCLE_WORKFLOW_ID="${!PARAM_CIRCLE_WORKFLOW_ID}"
PARAMETERS="{\"circleback_orb_workflow_id\":\"$CIRCLE_WORKFLOW_ID\"}"

echo $CIRCLE_TOKEN

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
echo "$TRIGGERED_PIPELINE" >CIRCLEBACK_ORB_PIPELINE
