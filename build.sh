#!/bin/sh
set -e

#
IMAGE=janole/laravel-nginx-postgres
VERSION=`cat version`

# Branch or Tag ...
if [ -n ${GITHUB_REF} ]; then
    BRANCH=`echo ${GITHUB_REF} | sed 's=.*/=/='`;
else
    BRANCH=`(git rev-parse --abbrev-ref HEAD 2>/dev/null) | grep -v "^master$" | sed 's=^=/='`;
fi

IMAGE=${IMAGE}${BRANCH}${COUNT}

COUNT=`git rev-list HEAD --count 2>/dev/null`
VERSION=${VERSION}.${COUNT}

# Create hierarchical versions (1.2.3 => "1.2" and "1")
VERSION1=`sed "s/\(^[0-9]*\.[0-9]*\).*/\1/" version`
VERSION0=`sed "s/\(^[0-9]*\).*/\1/" version`

#
TARGET=${IMAGE}:${VERSION}

#
echo "*** Build ${TARGET} based on master ..."

docker build --pull -t "${TARGET}" -t "${IMAGE}:${VERSION1}" -t "${IMAGE}:${VERSION0}" -t "${IMAGE}:latest" .

#
echo "*** Build images dependent on ${TARGET} ..."

docker build -f unoconv/Dockerfile --build-arg "FROM=${TARGET}" -t "${IMAGE}/unoconv:${VERSION}" -t "${IMAGE}/unoconv:${VERSION1}" -t "${IMAGE}/unoconv:${VERSION0}" -t "${IMAGE}/unoconv:latest" .

echo "*** Push images ..."

docker push "${TARGET}" 

docker push "${IMAGE}/unoconv:${VERSION}"
