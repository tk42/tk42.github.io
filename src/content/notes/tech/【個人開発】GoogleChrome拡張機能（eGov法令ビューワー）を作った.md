---
title: 【個人開発】GoogleChrome拡張機能（eGov法令ビューワー）を作った
date: 2022-04-19
tags: 004,681/6,681/67,681/678,681/678/9
publish: true
feed: show
---
GoogleChrome拡張機能というものを初めて作ったのでその記録になります．

# 何を作ったか
[eGov法令検索](https://elaws.e-gov.go.jp/)という政府のサービスを利用したことはあるでしょうか？eGov法令検索とはその名の通り法令条文をインターネット経由で読むことができるサービスです．
>「法制執務業務支援システム」、通称「e-LAWS（イーローズ）」において整備された約8,000以上の法令データ（憲法、法律、政令、府省令、規則）を、「e-Gov法令検索」として公開しています．
[法令データベース「e-Gov法令検索」のリニューアル公開](https://www.soumu.go.jp/menu_news/s-news/01gyokan01_02000059.html)

そこでいざ法令にアクセスしてみるのですが，これが実際読んでみると結構大変です．
特に，条文内で別の条文を参照する「第X条Y項」といったところにページ内リンクが用意されていないため，その参照先の条文は頭に入れておくか別窓を開いて読むしかありません．

最初は地道に読んでいたのですが，**ついイラッとして**GoogleChromeの拡張機能を作成し，公開しました．

https://chrome.google.com/webstore/detail/egov-viewer/aohfhdeechcdenbhoomepenhjdlhedgc?hl=ja&authuser=0

正規表現でマッチした文字列に対応して，ページ内リンクを割り当てます．

![](https://storage.googleapis.com/zenn-user-upload/1edc31759a83-20220415.png)

また，リンクのマウスオーバーでツールチップ表示を行います．

![](https://storage.googleapis.com/zenn-user-upload/7337973b86c4-20220415.png)

# どのように作ったか
## 開発言語
開発言語はReact+TypeScriptで，主に下記ページなどを参考にしました
https://zenn.dev/tokku5552/articles/how-to-make-chrome-extension
https://qiita.com/RyBB/items/32b2a7b879f21b3edefc

## スターターレポジトリ
スターターレポジトリとしては yoshisansan/chrome-extension-react-ts-boiler があります．しかしテンプレート指定されていなかったため，forkしテンプレートとして使うよう指定をすると今後GoogleChrome拡張機能を量産する際に便利かと思います．これは私のテンプレートレポジトリです．以降の説明で，下記のディレクトリ構成に言及します．

https://github.com/tk42/chrome-extension-react-ts-boiler

## ManifestV3
現時点(2022/04)で開発するならば，ManifestV3の情報を探しましょう．もし古いManifestV2の情報をどうしても紐解かなければならない場合，差分は下記が分かりやすいです．
公式
https://developer.chrome.com/docs/extensions/mv3/intro/mv3-migration
解説記事
https://zenn.dev/katoaki/articles/4e7548b533d7b3

## 疑問
### Content Script？ Background Page？
GoogleChrome拡張機能開発では，2つのレイヤーに分けて開発する必要があります．それがBackground Page と Content Script です．
 - Background Page は，GoogleChromeと通信するレイヤーで，chrome.*APIを利用することができますが，一方で各ページの中身DOMの取得や操作はできません．テンプレートレポジトリではsrc/background に記述します．
 - Content Script は，Background Pageから隔離され(isolated world)ている，ビューのレイヤーです．chrome.*APIを利用することができない代わりに，DOMの取得や操作ができます．テンプレートレポジトリではsrc/App.tsx がエントリーポイントです．
今回の機能（法令ページにページ内リンクを貼り付ける）ではContent Scriptの記述が殆どです．

https://qiita.com/k7a/items/26d7a22233ecdf48fed8

### URL制約
今回は eGov法令検索 のサイトでしか有効にならない拡張機能を想定しているので，URLの制限が必要になります
→ manifest.json に下記を追記します．
```
  "content_scripts": [
    {
      "matches": ["https://elaws.e-gov.go.jp/*"],
    }
  ],
  "host_permissions": [
    "https://elaws.e-gov.go.jp/*"
  ],
```
```host_permissions```は，GoogleChrome拡張機能に許可するデータ取得元のサイトURLのマッチングパターンです．
```content_scripts```は，レンダリングを有効にするサイトURLのマッチングパターンです．
今回はデータ取得元と，レンダリングを有効にするサイトが同一なので，同じマッチングパターンを挿入します．

### 単体テスト
私がJavascript界隈に入門して日が浅いからかもしれませんが，正規表現のマッチングパターンを列挙するに際して，単体テストがどうしても欲しくなりました．
→ jestを導入することにしました．package.jsonに
```
  "scripts": {
    "test": "jest --verbose"
  },
```
と追記して，```__tests__``` ディレクトリを下記のように作成すると，実行されました．
```
/
├── src
├── assets
├── __tests__
│   └── parse_test.ts
...
```

### アプリ審査
デベロッパー登録には$5が一度だけかかります（**月額課金ではありません**🎉）．Google曰く本人確認の意味合いが強いらしいです．
審査に通すためにはプライバシーの取り組み等を埋めていく必要があります．
審査はアプリのバージョンを更新するたびに必要なようです．
公開には数週間かかるようです．自動公開にチェックして公開した場合，何の通知もなく公開されます．メール通知などもありませんでした．

# まとめ
いかがでしたでしょうか？
Chrome拡張機能の公開記事自体は珍しくありませんが，**週末だけで作れた**のでChrome拡張機能を作るのは意外と簡単です．
これから拡張機能を作成しようという方のお役に立てたなら幸いです．
また，間違いがありましたら指摘くださると助かります．