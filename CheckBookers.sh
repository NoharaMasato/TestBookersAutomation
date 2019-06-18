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

# もし見本のspecフォルダがなかったら教材からダウンロードして解凍する
if [ ! -e RspecBookers1 ]; then
  wget https://wals.s3.amazonaws.com/uploads/bookers1/spec.zip -O RspecBookers1.zip
  unzip RspecBookers1.zip
  rm RspecBookers1.zip
  mv spec RspecBookers1
fi

if [ ! -e RspecBookers2 ]; then
  wget https://wals.s3.amazonaws.com/uploads/bookers2/spec.zip -O RspecBookers2.zip
  unzip RspecBookers2.zip
  rm RspecBookers2.zip
  mv spec RspecBookers2
fi

rm -rf $dir_name #同じ名前のディレクトリを強制消去
git clone $GITHUB_URL $dir_name

cd $dir_name #チェックしたいディレクトリに移動する

if [ ! -f Gemfile ]; then
  echo "git clone したディレクトリにGemfileがありません"
  exit 1;
fi

if [ ! -e spec ]; then 
  echo "git clone したディレクトリにspecディレクトリがありません"
  exit 1;
fi

#ここでGemfile.lockがあれば消す
if [ -f Gemfile.lock ]; then 
  rm Gemfile.lock
fi

#specフォルダ置き換える
if [ -e spec/support ]; then # supportがあったらbookers2
  rm -rf spec/
  cp -r ../RspecBookers2 ./spec
else
  rm -rf spec/
  cp -r ../RspecBookers1 ./spec
fi

sed -i -e '/ruby.*/d' Gemfile # Gemfileのrubyのバージョンを消す

bundle install
rails db:migrate:reset RAILS_ENV=test
bundle exec rspec spec/ --format documentation

