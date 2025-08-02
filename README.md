# is-app-docker
DB作成コード、docker-compose.ymlなど、アプリをDockerで動かすために必要なリソースを管理

[アプリケーションをdockerで動かすまでの手順]
1.initdbディレクトリの中のdocker-compose.ymlをプロジェクト配下に移動させ、プロジェクト配下のフォルダ構成に以下が含まれていることを確認する
  is-app-frontend
  is-app-backend
  initdb
  docker-compose.yml
2.コマンドプロンプト(macの場合はターミナル)を開き、プロジェクト配下の階層に移動する
3.プロジェクト配下で以下コマンドを実行する(Docker イメージのビルド・コンテナの作成・コンテナの起動)
  docker compose up --build

