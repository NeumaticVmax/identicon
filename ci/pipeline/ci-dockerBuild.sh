#!/bin/bash
CMD_NAME=`basename $0`
DIR_NAME=`dirname $0`

source $DIR_NAME/ci.env
#------------------------------------------------------------------------------#
function main () {
  local ret=$RET_OK

  # 初期処理
  initProc; ret=$?

  # 製品用のDockerイメージを作成する
  isOk $ret && { dockerImageBuild; ret=$?; }

  return $ret
}
#------------------------------------------------------------------------------#
function initProc () {
  local ret=$RET_OK

  # npmモジュールをインストールする
  npm install; ret=$?

  return $ret
}
#------------------------------------------------------------------------------#
# dockerImageBuild
# 製品版のDockerイメージを作成する。
function dockerImageBuild () {
  local ret=$RET_OK

  # (念の為)前回ビルド時に作成されたコンテナを停止、削除する。
  sudo docker-compose $COMPOSE_ARGS_CI stop
  sudo docker-compose $COMPOSE_ARGS_CI rm --force -v

  # 製品用Dockerイメージをビルドする
  echo "製品用Dockerイメージをビルドします。"
  sudo docker-compose $COMPOSE_ARGS_CI build --no-cache; ret=$?

  return $ret
}
#------------------------------------------------------------------------------#
main "$@"
exit $?
