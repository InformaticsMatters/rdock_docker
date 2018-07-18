#!/bin/bash

set -e

echo "Starting docker container and executing buildah to build the rdock-mini image"
docker run -it -v $PWD:$PWD:Z -v /var/lib/containers:/var/lib/containers --privileged -w $PWD --rm informaticsmatters/rdock-buildah sh -c ./buildah-build.sh

echo "Pushing to local Docker image"
buildah push informaticsmatters/rdock-mini:latest docker-daemon:informaticsmatters/rdock-mini:latest
echo "Created image informaticsmatters/rdock-mini:latest"
