---
title: Obsidian
date: 2024-04-07
tags: Technology/Software/Personal Knowledge Management
publish: true
feed: show
---
# Obsidian とは

[[Personal Knowledge Management]] を実現するためのツールの一つ．

## Obsidianの特徴
### Markdown
Obsidianでは全ての文章（これはノートと呼ばれる）はMarkdownファイルで管理される．ファイル名はタイトルであり，文章内からリンクを貼ることができる

### バックリンク
キーワードに対してバックリンクと呼ばれるリンクは貼ることができる．バックリンクによりノートにネットワーク構造をもたせることができる

### オフライン動作
高速起動・編集: 正直大半のメモアプリは動作が遅い．余計な機能を付与する前にまずメモとしての機能を発揮して欲しい．

### プラグイン 
プラグインでObsidianに様々な拡張機能（後述）をもたせられる．

### テンプレート
定型文を挿入することができる．YAML Front Matter（後述）を入れておくと楽．

### スマホアプリ同期
iCloud上のフォルダにVault（保存場所）を設定すればスマホからも編集ができる．iCloud同期は高速なので同期によるストレスはほぼない．

## 他のツールとの比較

### EverNote 

Evernoteは全体的に動作が遅い．起動が遅くて，書き込む時には何をしようとしていたか忘れるし，情報を取り出す時も遅くなってしまう．何が変わったのか良くわからない拡張機能よりもまずメモアプリとして基本に忠実にあってほしい．
### Apple Notes

iOSに標準で付属しているNotesは悪くない．起動も編集も比較的に早く，誰かとメモを共有，同時編集もできる．Obsidian は誰かと同時に編集することは意図されておらず，あくまでPKMとしてのツールとして君臨している．

Notesから移行する場合は下記が参考になる
 - [Import from Apple Notes to Obsidian - Share & showcase - Obsidian Forum](https://forum.obsidian.md/t/import-from-apple-notes-to-obsidian/732)
 - [iCloud noteからの移行]([](https://www.reddit.com/r/applehelp/comments/wdtw2f/how_to_bulk_export_all_of_your_icloud_notes_from/?utm_source=share&utm_medium=mweb3x&utm_name=mweb3xcss&utm_term=1&utm_content=share_button))

### Notion 

Notion と比較してみる．Notionはメモアプリでありながら，本質的にはデータベースアプリだ．
表データで管理できるものはNotionが得意だろう．あるいはカレンダーやスケジュール．Obsidianにもプラグインで実現可能．

使い分けの例：[NotionとObsidianの使い分け方を徹底解説 - こふぶろぐ](https://blog.cohu.dev/how-to-use-notion-and-obsidian-separately)
Notionから移行する場合は下記が参考になる
- [Import from Notion - Share & showcase - Obsidian Forum](https://forum.obsidian.md/t/import-from-notion/636)

## YAML Front Matter

```
---
aliases: 
tags:
  - PKM/Obsidian
cssclasses: 
publish: false
Source:
---
```

YAML Front Matter とはノートの最上段に書かれる，上記のようなプロパティのこと．ノートに紐付けられたメタ情報．

[[Obsidian] フロントマターなんて簡単だ](https://pouhon.net/obsidian-frontmatter/7261/?amp=1)

### フロントマターのルール

- フロントマターは**ファイルの冒頭部分**に記述しなければならない
- 本文と分けるため、フロントマターは`---`(半角ハイフン×3)で囲む
- 1つの「key」と0個以上の「value (値) 」を1組とする

### YAMLの書式

- `key: value`のようにkeyの後ろにコロンを付け、その後に半角スペース、valueと続ける
- keyは基本的に英数字、アンダースコア、スペースのどれかで構成する
- 1つのKeyに対し複数のValueがある場合、`key: [v1, v2, v3]`のようにValue全体をブラケットで囲み、カンマで分ける (他の書式も有り)
### フロントマターにメタデータを記入する

その問いに対する答えの1つがフロントマターです。早速柱たちのノートにメタデータを付与しましょう。

![](https://pouhon.net/wp-content/uploads/2022/02/ss20220221150543.png)

今回はaliasesもpublishも設定していません。一番上の「tags」以外のkeyは**僕が勝手に**設定したkeyです。

もう一度お伝えしておきますが、特殊なkeyがあるからと言ってそれを入力しなければならないわけではありません。**フロントマターは自由である**ことを忘れないでください。

### Dataviewでメタデータを解析し、表示する

全てのファイルにメタデータを入力したら、それを使って情報を取り出し、表示します。使うのはObsidianユーザーにはお馴染みの「Dataview」プラグイン

[https://github.com/blacksmithgu/obsidian-dataview](https://github.com/blacksmithgu/obsidian-dataview "GitHub - blacksmithgu/obsidian-dataview: A high-performance data index and query language over Markdown files, for https://obsidian.md/.")

有効化して任意のノートのコードブロック内にこう記述します。

```markdown
dataview
table breath as 呼吸, age as 年齢, height as 身長, words as セリフ
from #鬼殺隊/柱
```

![](https://pouhon.net/wp-content/uploads/2022/02/ss20220221234841.png)

コードブロックを抜けると、

![](https://pouhon.net/wp-content/uploads/2022/02/ss20220221145128.png)

フロントマターに書き込んだデータがインデックスページに一覧表示されました。


## はじめかた

[Obsidianを導入した際に設定したこと｜penchi](https://note.com/penchi/n/n01668ba7594e)

始めてみるとかなり自由度が高いことが分かる．VaultはNoteを保存場所のルートだ．複数作っても情報が分散するので，Vaultは一つで十分だろう．
既に述べたようにiPhoneはじめiOSのモバイルと同期する予定なら保存先はiCloud一択である．

テンプレートを作成することになる．読書メモかTODO Listかノートの目的に応じて様々なテンプレートが必要になるだろう．
そこでテンプレート用のフォルダを作成し，そこに各種テンプレートを保管しておくと良い．

## おすすめプラグイン
### Thino (X like なポスト機能)

 ObsidianをTwitterぽくしてインプットを捗らせるプラグインがある．正直このプラグインがなければインプットは今ほどまでに増やせなかっただろうと思う．スマホのObsidianではいつもこれが最前面にある．思いついたら書きなぐる．時間がある時にパソコンで読み返し，似たものはMemoに放り込む．Memoが溜まって自分の言葉で話す用意ができたらNoteにいれる．このような流れができたのもこのアプリのおかげだ．
 - [Twitter 形式でメモが残せる Obsidian Memos で「考えるな、書け」を体現できるくらい筆が進むようになった \| Shunya Ueta](https://shunyaueta.com/posts/2023-06-16-1452/)

### Auto Link Title 

これも超有用．URLだけを貼り付けておけば，リンク先のタイトルを取得してリンクを作ってくれる．ちょっとメモしておきたいときに便利

### Auto

### BookSearch (読書メモ)

Obsidianで本を読書メモをつけるならこれがオススメ．本のカバー画像や作者・ジャンル・出版日などを自動で取得してくれる．
 - [Obsidian読書メモのすゝめ #メモ - Qiita](https://qiita.com/Yporon/items/db4655b1782d48d860a5)

### Obsidian Git

Obsidian の Valut をGithubレポジトリにpush & mergeするプラグイン．

[ObsidianをGitでバージョン管理する - Kattsun.dev](https://kattsun.dev/posts/2021-05-25-obsidian-with-git/)

### Periodic Notes

日次ノート（Daily Note）はデフォルトの機能に存在するが，週次月次のサマリーノートも作ってくれる．


## tk42.jp

### jekyll-garden

ウェブサイトに公開するにあたって DegitalGarden と呼ばれるプラグインファミリーを利用することもできるが，これはjekyllを使っており，より細かくサイトを構築したい時に有用．
### 独自アカウントで情報発信する意義

独自アカウントで情報発信していたが，Zennプラットフォームに移行した話．

[荒廃したテックブログの再生](https://zenn.dev/levtech/articles/0224ec13e6663e#%E2%91%A4zenn%E3%81%AF%E3%81%84%E3%81%84%E3%81%9E%EF%BC%81)

おそらくこれは正しいし，事実だろう．しかしこのウェブサイトは思考の整理のために開設したのでPVは多くなくて良い．

### 継続性は道具の使いやすさに依存する

その道具に愛着を持っていれば，その道具を頻繁に触るだろう．それがインプットの糧であり，アウトプットに繋がっていく

第二の脳，作れるだろうか．

