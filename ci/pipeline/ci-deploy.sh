#!/bin/bash
CMD_NAME=`basename $0`
DIR_NAME=`dirname $0`

source $DIR_NAME/ci.env
source $DH_CONF
#------------------------------------------------------------------------------#
function main () {
  local ret=$RET_OK

  # アプリケーションサービスをAWSにデプロイする
  deployServices; ret=$?

  return $ret
}
#------------------------------------------------------------------------------#
function deployServices () {
  local ret=$RET_OK

  # AWS上にDockerEngineのインスタンスを構築する。
  aswCreateInstance; ret=$?

  # セキュリティグループにインバウンドの設定を追加する。
  isOk $ret && { awsSecGrpConfig; ret=$?; }

  # AWS上でサービス(Dockerコンテナ)を開始する。
  isOk $ret && { awsStartContainer; ret=$?; }

  return $ret
}
#------------------------------------------------------------------------------#
function aswCreateInstance () {
  local ret=$RET_OK

  # AWS上にDockerEngineのインスタンスを構築する。
  cmd="aws ec2 describe-instances --filters Name=tag:Name,Values=$EC2_NAME \
  --query 'Reservations[*].Instances[*].Tags[*]'"
  if eval $cmd | grep -q "$EC2_NAME"; then
    # $EC2_NAME という名前のインスタンスが存在している場合
    echo "DockerEngine($EC2_NAME)はAWS上に構築済みです。"
    stat=`aws ec2 describe-instances --filters Name=tag:Name,Values=$EC2_NAME \
    | jq -r '.Reservations[].Instances[].State.Name'`
    if [ "${stat}" = "stopped" ]; then
      # 停止している場合は起動する
      echo "AWS上のDockerEngine($EC2_NAME)を起動します。"
      id=`aws ec2 describe-instances --filters Name=tag:Name,Values=$EC2_NAME \
      | jq -r '.Reservations[].Instances[].InstanceId'`
      aws ec2 start-instances --instance-ids $id; ret=$?

      # Dockerエンジンの起動を待つ
      awsWaitInstanceUp; ret=$?
    fi
  else
    # $EC2_NAME という名前のインスタンスが存在していない場合
    echo "AWS上にDockerEngine($EC2_NAME)を作成します。"
    docker-machine create \
    --driver amazonec2 \
    --amazonec2-region ap-northeast-1 \
    --amazonec2-instance-type t2.micro \
    $EC2_NAME; ret=$?
  fi

  return $ret
}
#------------------------------------------------------------------------------#
function awsSecGrpConfig () {
  local ret=$RET_OK

  # セキュリティグループにインバウンドの設定を追加する。
  cmd="aws ec2 describe-security-groups --group-names docker-machine \
  | jq -r '.SecurityGroups[].IpPermissions[]' | jq '.ToPort'"
  if eval $cmd | grep -q '^3000$'; then
    echo "セキュリティポートの設定は完了済みです。"; ret=$RET_OK
  else
    echo "AWS上のセキュリティグループにインバウンドの設定を追加します"
    aws ec2 authorize-security-group-ingress \
    --group-name docker-machine \
    --protocol tcp \
    --port 3000 \
    --cidr 0.0.0.0/0; ret=$?
  fi

  return $ret
}
#------------------------------------------------------------------------------#
function awsStartContainer () {
  local ret=$RET_OK

  # AWS上でサービス(Dockerコンテナ)を開始する。
  echo "AWS上でサービスを開始します"

  # Dockerエンジンの起動を待つ
  awsWaitInstanceUp; ret=$?

  if [ ${ret} -eq $RET_OK ]; then
    # ElasticIPを与えていないインスタンスの場合、
    # 再起動後、IPアドレスが変わってしまうので、認証ファイルの再作成が必要。
    echo "認証ファイルを再作成します。"
    docker-machine regenerate-certs ${EC2_NAME} -f

    eval "$(docker-machine env $EC2_NAME --shell /bin/bash)"
    docker-compose ${COMPOSE_ARGS_AWS} stop
    docker-compose ${COMPOSE_ARGS_AWS} rm --force -v
    # Dockerイメージは一旦削除して再ダウンロードする。
    docker image rm "${DOCKER_HUB_USER}/${APP}:${APP_VER}"
    docker-compose ${COMPOSE_ARGS_AWS} up -d; ret=$?
    eval $(docker-machine env -u --shell /bin/bash)
    echo [URL] http://`docker-machine ip $EC2_NAME`:3000
  else
    echo "EE)Unable start $EC2_NAME"
  fi

  return $ret
}
#------------------------------------------------------------------------------#
function awsWaitInstanceUp () {
  local ret=$RET_NG
  local stat="unknown"
  local i
  local max_count=12
  local wait=10

  # AWS上のDockerコンテナが起動するまで待つ。
  for ((i=0; i<${max_count}; i++)); do
    stat=`aws ec2 describe-instances --filters Name=tag:Name,Values=$EC2_NAME \
    | jq -r '.Reservations[].Instances[].State.Name'`
    if [ "${stat}" = "running" ]; then
      ret=$RET_OK
      echo "$EC2_NAME is $stat"
      break
    else
      ret=$RET_NG
      echo "$EC2_NAME is still $stat ... please wait."
      sleep ${wait}
    fi
  done
}
#------------------------------------------------------------------------------#
main "$@"
exit $?
