---
title: GraphQLサーバをオレオレ構築するまで
date: 2022-12-12
tags: 
publish: true
feed: show
---
sqlcとHasuraを用いたboilerplateレポジトリを作成しましたので公開します

https://github.com/tk42/bbff

利用方法は
 1. ```schema.sql```と```queries.sql```を書きます
 2. ```docker compose -f docker-compose.autogen.yml up```でSQLからGolangのクエリ関数を自動生成
 3. ```docker compose up```で，GraphQLサーバ（Hasura）を立ち上げる
 4. 連携させるテーブルを"Track"する

ちなみにDBテーブルに対してはtblsを用いてドキュメント自動生成をしています．

---
# 前提とモチベ
 - GraphQL が大体どんなものかは知っている
   - スキーマファイルがschema.graphqlであることは知っている
 - 本番利用を検討している
 - GraphQLサーバを自前で構築する？DBaaSを利用する？それぞれ選択肢がありすぎィ…
 - 自前で構築する場合
   - DBは？ライブラリは？リレーションシップ増えても大丈夫そ？
 - HeadlessCMSなどのDBaaS利用する場合
   - サービス間の比較(安いほうがいい)
   - OSSないの？

2022/12現在のこの辺の状況を雑多にまとめていきます．

なお，個人的に好みの技術スタックとしては
 - フロントエンド：NextJS(Typescript)
 - バックエンド：Golang, Python
 - クラウド：GCP
 - 技術ポリシー：
   - コンテナ駆動開発
   - スキーマ駆動開発（コード自動生成）
   - 自動化（CI/CD）
   - RDBMS > NoSQL

を選択することが多いです．
個人的な意見や感想も多く含まれるため，何卒ご了承ください．

---
# DBaaS を利用するべきかどうか
ここでは大きく2つに分かれると思います
 - AppSync
 - HeadlessCMS勢

AppSync はAWS上で利用できるマネジメントGraphQLサーバです（後述）

HeadlessCMS ッテナンデスカ？って人はMicroCMSの[ヘッドレスCMSとは何か？従来CMSとの違いやメリデメを解説！](https://blog.microcms.io/what-is-headlesscms/)を先に一読されることをオススメします．

めちゃくちゃ雑に言うと，フロントなしの(Headless)のCMS(Wordpressのようなもの)で，管理者画面付きのバックエンドサーバと思ってもらって良いです．

## AppSync
> AppSync は一般的な GraphQL としての機能の他に，「Cognito を利用した認可」や，「Subscription クエリによるリアルタイム通信」などを容易に実現することができ，複雑な要件に対応することができる非常に便利な AWS サービスとして知られています．

[[入門] AppSyncとVTL開発](https://zenn.dev/nagi_katagiri/articles/2022-09-18_appsync-evaluation-mapping-template)

他にも優れた記事がたくさんあるので，そちらもご覧ください．
[AppSync & GraphQL 入門](https://qiita.com/umamichi/items/43e8ca7c86e937e4bf54)

以下，個人的な所感です．
AppSyncはGraphQLサーバ以外の用途もあるため単純な比較はできないのですが，AWSでの本番利用を想定しているならばとりあえず選択肢になります．
AppSyncでのスキーマ作成体験はhygraph同様画面ポチポチでできるためストレスレスでした．

しかし，次の2点の問題が浮上しました．
 - 標準的なgraphqlファイルを生成するのに一苦労する
   これはAppSyncがAmplifyCLIから利用を前提としているためかもしれません．
![](https://storage.googleapis.com/zenn-user-upload/e9a1c5641638-20221212.png)
[AmplifyによるGraphQL API開発 / GraphQL Development Using Amplify @Serverless Meetup#19](https://speakerdeck.com/jaguar_imo/graphql-development-using-amplify-at-serverless-meetup-number-19?slide=11)
このようにgraphqlファイルは2種類あり，そのうち画面ポチポチから生成されたschema.graphqlファイルではGraphQLTransformer独自のディレクティブが付与され，これはAmplifyCLIでの利用を前提としているものです．そのためこれを例えば別のGraphQLサーバに組み込んでも動作しません．
そこでリバースエンジニアリング的に，一度生成したAppSyncサーバに対してgraphqlファイルを生成する方法があるようです．興味がある人は[AWS AppSyncのGraphQLスキーマからTypeScriptの型を生成](https://www.grandream.jp/blog/generate-appsync-graphql-schema/)をご覧ください
 - DB がほぼDynamoDB固定
  DBはほぼ自動的にDynamoDBとなるようです．DynamoDBは基本的には高速ですが，インデックスの貼り方で差が出てくるため，場合によっては固有のチューニングが必要になります．

これら2点からAppSyncは割と癖が強くクラウドベンダーロックインの傾向があります．そのため他のクラウドベンダーでの利用を想定している場合はあまりメリットがありません．
AWSやDynamoDBでの稼働を積極的に検討している場合選択すると良いと思います．今回は見送りました．

## GraphQLが利用できるHeadlessCMS
 - hygraph (旧GraphCMS)
 - Contentful
 - Strapi

### hygraph
> Hygraphは2022年7月にGraphCMSから名称が変わりました。こちらもドイツの企業発のヘッドレスCMSです。Meta社が開発したGraphQLの活用に特化しており、豊富なフィルターオプションやバッチ処理などが充実しています。
|利用料金|月額$299～（無料プランあり）|
|導入企業例|SAMSUNG、SHURE、PHILIPSなど|

[ヘッドレスCMSとは？従来のCMSとの違い、注目される理由を解説](https://seeds-create.co.jp/column/headless-cms/#Hygraph%EF%BC%88GraphCMS%EF%BC%89)


ブラウザ上で，画面ポチポチでスキーマ作成，リレーションシップ作成できるので直感的な上に楽チンです．
![](https://storage.googleapis.com/zenn-user-upload/8d054598f847-20221212.png)

実際の画面からの利用方法などは[HeadlessCMSのGraphCMSを使ってみる](https://zenn.dev/s7/articles/8e2fdf01abaa0c)などが画像付きで参考になります．

API操作で実際に使ってみると，権限周りで詰まりました．サポートに問い合わせましたが，ドキュメントをよく読むと書いていました．
CRUD操作それぞれに前提となる権限が存在するだけでなく，その操作も前提となります．
例えば，Delete権限を有効にするためにはRead権限とUnpublish権限の2つが有効でなければなりませんが，Delete操作を実行する際にも「Unpublish」してから「Delete」しなければなりません．
詳細は[Permissions](https://hygraph.com/docs/api-reference/basics/permissions#actions)をご覧ください．

その他は特に問題なく，NextJS側からpages/api以下に配置したサーバ側スクリプトによるHTTPリクエストでバシバシデータ取得できました．

### Contentful
> Contentfulはドイツの企業発のヘッドレスCMSであり、最もよく知られたサービスの一つです。APIベースのクラウドサービスであるため、サーバー管理の必要がありません。デスクトップやモバイル向けのWebページだけでなく、デジタルサイネージやスマートウォッチなどのプラットフォームへのコンテンツ配信も可能なAPIが用意されています。GoogleやGitHubなどのアカウントから簡単に登録できます。
|利用料金|月額$489～（無料プランあり）|
|導入企業例|資生堂、asics、EQUINOXなど|

[ヘッドレスCMSとは？従来のCMSとの違い、注目される理由を解説](https://seeds-create.co.jp/column/headless-cms/#Contentful)

下記にドキュメントがあるのでGraphQLを公式にサポートしているようです
[GraphQL Content API](https://www.contentful.com/developers/docs/references/graphql/)

（試しませんでした）

### Strapi
> StrapiはオープンソースのヘッドレスCMSであり、クラウドサービスではなくNode.jsで動作します。GitHubからソースを入手すれば誰でも簡単に利用可能です。開発環境を1行で簡単に構築できるクイックスタートに対応している点が特徴です。デフォルトでは最低限の機能のみとなっており、必要な機能はプラグインで追加する形になりますが、非常に拡張性が高いヘッドレスCMSとなっています。
|利用料金|無料|
|導入企業例|TOYOTA、IBM、Walmartなど|

[ヘッドレスCMSとは？従来のCMSとの違い、注目される理由を解説](https://seeds-create.co.jp/column/headless-cms/#Strapi)

HeadlessCMSのOSSなんてものがあるんですね！ナンテコッタ！検討事項が増えた！
しかし当初は自前の構築も検討していたので，HeadlessCMSのOSSで管理画面などの構築が省ければ一石二鳥です．
というわけで，OSSなHeadlessCMSを調べてみて，導入を試してみます．

---

# Open Source Headless CMS

[The Best 10+ Open Source Headless CMS 2022](https://dev.to/theme_selection/the-best-10-open-source-headless-cms-40hf)のうちGraphQL対応のものを列挙すると，次の3つに絞られました
 - [strapi](https://github.com/strapi/strapi)
 - [keystone](https://github.com/keystonejs/keystone)
 - [webiny](https://github.com/webiny/webiny-js)
 

## [strapi](https://github.com/strapi/strapi)

先程も見たStrapiです．2022/12時点でGithubスター数 50.3kで圧倒的です．また，100% Javascript らしいです．期待値が高まります．


https://www.youtube.com/watch?v=h9vETeRiulY



## [keytone](https://github.com/keystonejs/keystone)

2022/12時点でGithubスター数 7.2k．Typescript と React で書かれたHeadlessCMSだそうです．


## [webiny](https://github.com/webiny/webiny-js)

2022/12時点でGithubスター数 6.2k．こちらもほぼTypescript．AWSにデプロイしやすいのが売りらしいです．



## 結論
Strapi の導入一択

# Strapi 導入奮闘記
  - dockerで導入を試みます．しかし，[dockerhub](https://hub.docker.com/r/strapi/strapi)に上がっているのは1年以上前のもので実際pullしてみると，バージョンは3.6.8でした（2022/12現在4.5.3)

 - [公式ドキュメント](https://docs.strapi.io/developer-docs/latest/setup-deployment-guides/installation/docker.html)にDockerでのインストールドキュメントがありますが，記載の通りコピペしてDockerfileを作成してビルドすると，M1Mac上では

```
[2022-12-02 09:07:24.894] debug: ⛔️ Server wasn't able to start properly.
[2022-12-02 09:07:24.896] error: Could not load js config file /opt/app/node_modules/@strapi/plugin-upload/strapi-server.js:
Something went wrong installing the "sharp" module

Cannot find module '../build/Release/sharp-linuxmusl-arm64v8.node'
```
のようになり，ビルドが停止します．原因調査中…

----

# Strapi 導入を諦める

Strapiの導入に完全に頓挫してしまいました．コンテナでの導入がうまくいかなければやる気が起きません...

そこでいよいよ自前でのGraphQLサーバ構築の検討をはじめます．先頭記事にあるようにPython実装とGolang実装のそれぞれで調べました．

# GraphQLサーバの構築
## strawberry (Python)
最近急激にスター数を伸ばしているWebフレームワークFastAPIの[GraphQLの公式ページ](https://fastapi.tiangolo.com/advanced/graphql)で強くオススメされていたstrawberryを試してみます．

> If you need or want to work with GraphQL, Strawberry is the recommended library as it has the design closest to FastAPI's design, it's all based on type annotations.
Depending on your use case, you might prefer to use a different library, but if you asked me, I would probably suggest you try Strawberry.

とあり，サンプルコードもstrawberryのみで他のAriadne, Tartiflette, Grapheneなどは紹介にとどまっています．

そこで実際にstrawberryで，ORMはSQLAlchemy，DBはPostgresで書き始めてみました．
Dataclassによるモデル構造の記述，これは本当に良い体験でした．
しかし，その後リゾルバの実装で，**外部キー参照が面倒くさい・汚い**と思い始めました．

例えば，次はstrawberryのGithub上の[サンプルコード](https://github.com/strawberry-graphql/examples/blob/main/fastapi-sqlalchemy/main/models.py)ですが
```python
def get_movies(db: Session, limit: int = 250):
    query = (
        select(Movie)
        .options(joinedload(Movie.director))
        .order_by(Movie.imdb_rating.desc())
        .limit(limit)
    )

    result = db.execute(query).unique()
    return result.scalars()
```
Dataclassを使って記述したModelにForeignKeyの記述があるにも関わらず，これをリゾルバで手動で解決していくことになりそうです．
モデルが多い場合，これでは手作業が増えミスを誘発し，そして何より面倒です．

[jokull/python-ts-graphql-demo](https://github.com/jokull/python-ts-graphql-demo)なども同様です．[こちらのコード](https://github.com/jokull/python-ts-graphql-demo/blob/main/app.py)はSQLAlchemyのORMオブジェクトを利用してはいますが，手作業で外部キー参照を解決しています．
```python
    @strawberry.mutation
    async def add_location(self, name: str) -> AddLocationResponse:
        async with models.get_session() as s:
            sql = select(models.Location).where(models.Location.name == name)
            existing_db_location = (await s.execute(sql)).first()
            if existing_db_location is not None:
                return LocationExists()
            db_location = models.Location(name=name)
            s.add(db_location)
            await s.commit()
        return Location.marshal(db_location)
```

Tutorialでの開発体験は良かっただけに，**手作業は面倒なので**残念ですが見送りました．


## gqlgen (Golang)
(```go generate```など)コード自動生成を言語思想レベルで持ち合わせているGolangではどうでしょうか？
GolangではGraphQLサーバの実装ではgqlgenライブラリが有力で，genの名の通り自動生成があるようなので期待を込めて試してみます．

gqlgen はschema.graphqlからデータモデルやリゾルバのGoファイルを自動生成してくれるライブラリです．そのためschema.graphqlの存在が前提となるため，データ設計は別の箇所でおこないます．

### データ設計(schema.graphql)を得るまで
画面ポチポチでのデータ設計がとても楽だったので，例えばHeadlessCMSでGraphQLサーバを作成し，エンドポイントに対してschema.graphqlをぶっこ抜くなどの方法がとれます．

ちょっと調べてみると，get-graphql-schema というツールがあるようです．
```
npm install -g get-graphql-schema
```
でインストールし，
```
get-graphql-schema {ENDPOINT} > schema.graphql
```
でぶっこ抜き完了です．簡単ですね．

### gqlgenによるコード自動生成
こうしてschema.graphqlを得たので，gqlgenでコード自動生成してます．データモデルのコードが生成され，リソルバのスタブコードが生成されました．そして，あとはリゾルバの実装を書いていくだけ…

あれ？外部キーの解決，手動でしなくちゃいけないの？**またか！**

strawberryの時と同じ過ちを繰り返してしまいました．ORMを触って外部キーの解決するのは，DBスキーマでも記載しているので二重管理となり得ます．
振り出しに戻ってしまいました...

---

# 救世主 sqlc

この記事は実はGraphQLサーバの構築エントリに見せかけた **sqlc 布教記事**です．

sqlcとはgolangのライブラリで，**SQLファイルから型安全なコードを生成**するツールです．

> SQLファイルからデータベースにアクセスできる型安全なGoのコードを生成するライブラリ
> - 構造体のモデルの手書き実装不要
> - 複数テーブルをJOINしたときのマッパー実装不要
> - 生成されるコードは不要なリフレクションなし

「ORMでデータモデルの構造体を作成して，それをアプリケーションコードで整形する」のではなく「先にSQLクエリを書いて(必要ならSELECTやJOINを実行して)，そのクエリに対応するメソッドが自動生成されるので，それをアプリケーションコードに利用していく」という流れになります．

> MySQLとPostgreSQLの2つのデータベースをサポートしています。データベースのパーサを適用してクエリを解析している点が設計上の大きな特徴です。解析エンジンがPostgreSQLの場合、実際のPostgreSQLサーバーのソースを cgo を経由して、Goから呼び出せるようになっています。

[SQLファイルから型安全なコードを生成するsqlc](https://future-architect.github.io/articles/20210804a/)

具体的な利用方法を見ていきます．
sqlcでは```schema.sql```と```queries.sql```の2つのSQLファイルを必要とします．テーブル定義とクエリ定義でそれぞれ複数指定できるので，リソース毎に分割しておくのが良いでしょう．
SQLファイルが書けたら，そのファイルパスを```sqlc.yml```に記載して，sqlcコマンドを実行すると指定のディレクトリ以下にGolangのクエリファイルが自動生成されます．
また，懸念事項であった外部キーの解決は
 - テーブル定義でFOREIGN KEY... REFERENCES...
 - クエリ定義でJOIN...

と書いておけば**JOIN句のあるクエリに対応したメソッドが自動生成される**ので，手動でORMを操作する苦痛から開放されました．

GraphQLサーバを構築する旅路も最初は「GraphQLだから〜」と考え，ライブラリを取捨選択してきましたが，結局はSQL志向の強いライブラリsqlcに救われました．
sqlcのために用意したテーブル定義のSQLファイルによって，マイグレーションもできます．

sqlcの地味な便利さはここでは語りきれないので興味があればググってみてください．

---

ここまででテーブル定義とクエリ定義ファイルをベースにしてGolangでのクエリ関数を自動生成し，テーブル定義ファイルを利用してDBに対してマイグレーションを実施しました．
通常のCRUDサーバであればここまでで良いのですが，本エントリの目的はGraphQLサーバを構築することです．

# 第二の救世主Hasura
> hasura は PostgreSQL サーバーから自動的に GraphQL サーバーを建てられるツールです。
Docker イメージとして配布されていて、対象となる PostgreSQL サーバーのアドレスや PW を設定して起動すればすぐに GraphQL サーバーとして使えます。
[Hasuraがめちゃくちゃ便利だよという話](https://qiita.com/maaz118/items/9e198ea91ad8fc624491)

素晴らしいツールです！Dockerコンテナとして配布されているのもNiceです！
Postgresに限定されてしまうことにだけ注意して下さい（sqlc.yamlではpostgresを指定しておきます）
他にも，管理画面がありPostgresDBに対してクエリを発行できる他，GraphQLのPlaygroundも同梱されているため手軽に実験できます

具体的な利用方法を見ていきます．
 - Dockerコンテナをpull
 - テーブル・外部キーに対して"Track"を実行
「Trackを実行」とは，あるエンティティを別のエンティティへと追従させる(Track)かどうかの設定です．GraphQLサーバとしてのレスポンスデータに影響があります．

> コンソールのData -> Schemaセクションに移動します
Untracked foreign-key relationsの横にあるTrack Allボタンをクリックします
同様の手順を外部キーに対しても実行します。
[Hasuraを使ってみた](https://qiita.com/kyamamoto9120/items/e0f3f15dac9ff532e202)

Hasuraによって簡単にGraphQLサーバが構築できました

---

Hasuraの認証をNextJSにて認証プロバイダーAuth0で実装するにあたってチュートリアルで詰まったので，ここに備忘録として残しておきます．

 - クラウド版Hasuraのドキュメントを読まないようにする
   Hasuraの紹介でも触れたOSS提供しているHasuraと，Hasura Inc.自体がクラウド提供しているものがあります．それぞれで参照するドキュメントが異なることに気づきました．URLがhasura.ioの後，**docs**になっているか**learn**になっているかで見分けます．
    - クラウド版Hasura [https://hasura.io/docs/latest/index/](https://hasura.io/docs/latest/index/)
    - OSS版Hasura [https://hasura.io/learn/](https://hasura.io/learn/)
 - 自分のユースケースに沿ったチュートリアルを読む
   前項と似ていますが，OSS版Hasuraのチュートリアルも多岐に渡っており，特に**検索エンジンから飛んできた場合**などはそのドキュメントの対象読者が誰かを意識して読まなければ誤った設定をしてしまいます．

NextJSに対するチュートリアルは下記になりますが，

https://hasura.io/learn/graphql/nextjs-fullstack-serverless/introduction/

似たようなものに下記の日本語のチュートリアルもあるため紛らわしかったです

https://hasura.io/learn/ja/graphql/hasura/introduction/

ただ，[Hasura公式の「nextjs-fullstack-serverless」コースでのハマり所（2021.10.24 時点）](https://zenn.dev/fujiten/scraps/132c10cda52b36)でも述べられているように，両方に目を通しておくのが良いかもしれません

