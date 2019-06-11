#!/bin/bash

if [ $# -ne 1 ]; then #引数が一つではなかった場合
  echo "実行するコマンドが違います" 1>&2
  echo "githubのurlをコマンドライン引数として設定してください" 1>&2
  echo "ex) './CheckBookers.sh https://github.com/NoharaMasato/RspecBookers2'"
  exit 1
fi

readonly GITHUB_URL=$1

dir_name=BookersRspecTest

cd .. #このリポジトリから抜ける
rm -rf $dirname #同じ名前のディレクトリを強制消去
git clone $GITHUB_URL $dir_name

cd $dir_name

#ここでGemfile.lockがあれば消す
if [ -e Gemfile ]; then 
  rm Gemfile.lock
fi

if [ -e Gemfile ]; then
  if [ -e spec ]; then 
    sed -i -e '/ruby.*/d' Gemfile # Gemfileのrubyのバージョンを変更
    bundle install
    rails db:migrate:reset RAILS_ENV=test
    bundle exec rspec spec/ --format documentation
  else
    echo "git clone したディレクトリにspecディレクトリがありません"
    exit 1;
  fi
else
  echo "git clone したディレクトリにGemfileがありません"
  exit 1;
fi
