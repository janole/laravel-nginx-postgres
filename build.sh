#!/bin/sh
set -e

#
IMAGE=janole/laravel-nginx-postgres
VERSION=`cat version`

# Branch or Tag ...
if [ -n "${GITHUB_REF}" ]; then
    BRANCH=`echo ${GITHUB_REF} | sed 's=.*/==' | grep -v "^master$"`;
else
    BRANCH=`(git rev-parse --abbrev-ref HEAD 2>/dev/null) | grep -v "^master$"`;
fi

if [ -n "${BRANCH}" ]; then
    BRANCH=-${BRANCH};
fi

#
COUNT=`git rev-list HEAD --count 2>/dev/null`
VERSION=${VERSION}.${COUNT}${BRANCH}

# Create hierarchical versions (1.2.3 => "1.2" and "1")
VERSION1=`sed "s/\(^[0-9]*\.[0-9]*\).*/\1/" version`${BRANCH}
VERSION0=`sed "s/\(^[0-9]*\).*/\1/" version`${BRANCH}

#
TARGET=${IMAGE}:${VERSION}

#
echo "*** Build ${TARGET} based on master ..."

docker build --pull -t "${TARGET}" -t "${IMAGE}:${VERSION1}" -t "${IMAGE}:${VERSION0}" -t "${IMAGE}:latest" .

#
echo "*** Build images dependent on ${TARGET} ..."

docker build -f unoconv/Dockerfile --build-arg "FROM=${TARGET}" -t "${IMAGE}:${VERSION}-unoconv" -t "${IMAGE}:${VERSION1}-unoconv" -t "${IMAGE}:${VERSION0}-unoconv" .

echo "*** Push images ..."

docker push "${TARGET}" 

docker push "${IMAGE}/unoconv:${VERSION}"
