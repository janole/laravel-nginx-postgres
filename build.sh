#!/bin/sh
set -e

IMAGE=janole/laravel-nginx-postgres
VERSION=1.0.7

if git fetch && test "`git rev-parse --abbrev-ref HEAD`" = "master" && git diff-index --quiet HEAD; then

    TARGET="${IMAGE}:${VERSION}"

else

    TARGET="${IMAGE}:${VERSION}-dev"

fi

echo "*** Build ${TARGET} based on master ..."

docker build --pull -t "${TARGET}" .

echo "*** Build images dependent on ${TARGET} ..."

docker build -f unoconv/Dockerfile --build-arg "FROM=${TARGET}" -t "${TARGET}-unoconv" .

echo "*** Push images ..."

docker push "${TARGET}" && docker push "${TARGET}-unoconv"
