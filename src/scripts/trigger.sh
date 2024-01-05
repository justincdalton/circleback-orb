#!/bin/bash
# This example uses envsubst to support variable substitution in the string parameter type.
# https://circleci.com/docs/orbs-best-practices/#accepting-parameters-as-strings-or-environment-variables

CIRCLE_TOKEN=${!PARAM_CIRCLECI_API_KEY}
PARAMETERS="{\"circleback-orb-pipeline-id\":\"$PARAM_PIPELINE_ID\"}"

# merge PARAM_PARAMETERS into PARAMETERS if it exists
if [ -n "$PARAM_PARAMETERS" ]; then
  PARAMETERS=$(jq -n --argjson json1 "$PARAMETERS" --argjson json2 "$PARAM_PARAMETERS" '$json1 + $json2')
fi

TRIGGERED_PIPELINE=$(
  curl --request POST \
    --url "https://circleci.com/api/v2/project/$PARAM_PROJECT/pipeline" \
    --header "Circle-Token: $CIRCLE_TOKEN" \
    --header "content-type: application/json" \
    --data "{\"branch\":\"$PARAM_BRANCH\",\"parameters\": \"$PARAMETERS\"}" |
    jq -r '.id'
)

echo "Triggered pipeline $TRIGGERED_PIPELINE"
echo "$TRIGGERED_PIPELINE" >CIRCLEBACK_ORB_PIPELINE_ID
