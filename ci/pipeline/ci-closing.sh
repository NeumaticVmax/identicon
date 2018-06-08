#!/bin/bash
source `dirname $0`/ci.env

# テスト用に作成&使用したコンテナを停止、削除する。
sudo docker-compose $COMPOSE_ARGS_CI stop
sudo docker-compose $COMPOSE_ARGS_CI rm --force -v
