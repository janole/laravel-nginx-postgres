#!/bin/sh
set -e

IMAGE=janole/laravel-nginx-postgres

if [ -z "$(git status --porcelain)" ]; then

    echo "*** Build LATEST based on master ..."

    git checkout master && docker build -t "${IMAGE}:latest" . && docker push "${IMAGE}:latest"

    echo "*** Build images dependent on LATEST ..."

    sed "s#FROM janole.*#FROM ${IMAGE}:latest#" unoconv/Dockerfile | docker build -f - -t "${IMAGE}:unoconv" .
    docker push "${IMAGE}:unoconv"

else

    echo "*** Build DEV images based on current dirty working directory ..."

    docker build -t "${IMAGE}:dev" . && docker push "${IMAGE}:dev"

    echo "*** Build images dependent on DEV ..."

    sed "s#FROM janole.*#FROM ${IMAGE}:dev#" unoconv/Dockerfile | docker build -f - -t "${IMAGE}:dev-unoconv" .
    docker push "${IMAGE}:dev-unoconv"

fi
