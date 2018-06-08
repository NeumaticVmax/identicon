# Jenkinsフリースタイルプロジェクトのビルドスクリプト

# DockerHubの認証情報ファイルを読み込む。
. /var/jenkins_home/.docker/config

# 変数
APP="identicon"
APP_VER="1.0"
COMPOSE_ARGS_CI="-f ci/docker-compose-ci.yml -p digi"

# npmモジュールをインストールする
yarn install

# Docker Hub にログオンする
sudo docker login -u ${DOCKER_HUB_USER} -p ${DOCKER_HUB_PASS}

# (念の為)前回ビルド時に作成されたコンテナを停止、削除する。
sudo docker-compose ${COMPOSE_ARGS_CI} stop
sudo docker-compose ${COMPOSE_ARGS_CI} rm --force -v

# Docker Image を作成する
echo "${APP}のDockerイメージを作成します。"
sudo docker-compose ${COMPOSE_ARGS_CI} build --no-cache

# ユニットテストを実行する
echo "ユニットテストを実行します。"
sudo docker-compose ${COMPOSE_ARGS_CI} \
    run --no-deps --rm -e ENV=UNIT ${APP}

# 製品用DockerイメージをDockerHubにプッシュする。
echo "作成した${APP}のDockerイメージをDockerHubにプッシュします。"
sudo docker tag "digi_${APP}" "${DOCKER_HUB_USER}/${APP}:${APP_VER}" \
  && sudo docker push "${DOCKER_HUB_USER}/${APP}:${APP_VER}"
