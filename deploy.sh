#!/usr/bin/env bash
set -e

# Log in to Docker Hub.
echo "$DOCKER_HUB_PASSWORD" | docker login --username "$DOCKER_HUB_LOGIN" --password-stdin

# Push the images.
docker push ${DOCKER_HUB_REPO}/ftp-server:latest
docker push ${DOCKER_HUB_REPO}/ftp-server:${COMMIT}
