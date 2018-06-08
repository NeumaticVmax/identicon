#!/bin/bash
CMD_NAME=`basename $0`
DIR_NAME=`dirname $0`

source $DIR_NAME/ci.env
#------------------------------------------------------------------------------#
function main () {
  local ret=$RET_OK

  # 製品用Dockerイメージのユニットテストを実施する。
  echo "製品用Dockerイメージのユニットテストを実行します。"
  sudo docker-compose $COMPOSE_ARGS_CI \
    run --no-deps --rm -e ENV=UNIT ${APP}
  ret=$?

  return $ret
}
#------------------------------------------------------------------------------#
main "$@"
exit $?
