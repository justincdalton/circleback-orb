#!/bin/bash
# This example uses envsubst to support variable substitution in the string parameter type.
# https://circleci.com/docs/orbs-best-practices/#accepting-parameters-as-strings-or-environment-variables

# Check if the key variable is set
if [ -z "${!PARAM_CIRCLECI_API_KEY}" ]; then
  echo "CircleCI API key not set"
fi

CIRCLE_TOKEN="${!PARAM_CIRCLECI_API_KEY}"
PIPELINE_ID=$(cat circleback_workspace/CIRCLEBACK_ORB_PIPELINE)

fetch_status() {
  API_RESPONSE=$(
    curl --request GET \
      --url "https://circleci.com/api/v2/pipeline/$PIPELINE_ID/workflow" \
      --header "Circle-Token: $CIRCLE_TOKEN" \
      --header "content-type: application/json"
  )

  echo "API Response: $API_RESPONSE"

  WORKFLOWS=$(echo "$API_RESPONSE" | jq -c '.items[]')

  if [ -z "$WORKFLOWS" ]; then
    echo "Failed to fetch workflows."
    exit 1
  fi

  for workflow in $WORKFLOWS; do
    status=$(echo "$workflow" | jq -r '.status')
    name=$(echo "$workflow" | jq -r '.name')
    # Check if the status equals "RUNNING"
    if [ "$status" == "running" ]; then
      echo "Triggered pipeline is still running. Workflow $name is $status."

      if [ "$PARAM_POLL" == "false" ]; then
        echo "Polling disabled, exiting."
        exit 1
      fi

      sleep 20
      fetch_status
      break
    elif [ "$status" != "success" ]; then
      echo "Triggered pipeline did not succeed. Workflow $name failed with status $status."
      exit 1
    fi
  done

  echo "Pipeline finished, continuing."
}

fetch_status
