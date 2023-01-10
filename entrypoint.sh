#!/bin/sh
set -o errexit
set -o nounset
set -o pipefail

export PLANTON_CLOUD_SERVICE_CLI_ENV=${1}
export PLANTON_CLOUD_SERVICE_CLIENT_ID=${2}
export PLANTON_CLOUD_SERVICE_CLIENT_SECRET=${3}
export PLANTON_CLOUD_ARTIFACT_STORE_ID=${4}
export ARTIFACT_STORE_DOCKER_REPO_HOSTNAME=${5}
export CONTAINER_IMAGE_NAME=${6}
export CONTAINER_IMAGE_VERSION=${7}

export artifact_writer_key_json_file=artifact-writer-key.json
echo "logging into planton cloud service using client credentials"
planton auth machine login --client-id $PLANTON_CLOUD_SERVICE_CLIENT_ID --client-secret $PLANTON_CLOUD_SERVICE_CLIENT_SECRET
echo "logged into planton cloud service using client credentials"
echo "fetching artifact writer key from planton cloud service"
planton product artifact-store secrets get-writer-key --output-file ${artifact_writer_key_json_file} --artifact-store-id ${PLANTON_CLOUD_ARTIFACT_STORE_ID}
echo "fetched artifact writer key from planton cloud service"
docker login -u _json_key -p "$(cat $artifact_writer_key_json_file)" https://${ARTIFACT_STORE_DOCKER_REPO_HOSTNAME}
echo "building container image"
export CONTAINER_IMAGE_REFERENCE=${CONTAINER_IMAGE_NAME}:${CONTAINER_IMAGE_VERSION}
docker build -t $CONTAINER_IMAGE_REFERENCE .
echo "built container image"
echo "pushing container image"
docker push $CONTAINER_IMAGE_REFERENCE
