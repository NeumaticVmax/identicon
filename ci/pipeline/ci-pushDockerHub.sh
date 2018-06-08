#!/bin/bash

source `dirname $0`/ci.env
source $DH_CONF

# 製品用DockerイメージをDockerHubにプッシュする。
echo "DockerイメージをDockerHubにプッシュします。"
sudo docker tag "digi_${APP}" "${DOCKER_HUB_USER}/${APP}:${APP_VER}" \
  && sudo docker login -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASS} \
  && sudo docker push "${DOCKER_HUB_USER}/${APP}:${APP_VER}"
ret=$?

exit $ret
