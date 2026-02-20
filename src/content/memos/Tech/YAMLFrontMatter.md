---
title: "YAMLFrontMatter"
aliases: 
tags:
  - PKM/Obsidian
cssclasses: 
publish: false
Source:
---
上記のようなプロパティのこと。ノートに紐付けられたメタ情報。


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




フロントマターは**プログラムに**「それが何で、どんなものか」を伝える場所。つまりプログラムを使わないのであれば、無理に記入する必要もありません。  
ただしより多くの情報を扱い、よりスムーズな情報管理を目指すならプログラムの力は必須とも言えます。ということで、最後にフロントマターとつながりが深いプラグインをいくつかご紹介して終わりとしましょう。

- Templates (コアプラグイン。フロントマターの自動入力に)
- QuickAdd (templatesと組み合わせて)
- Dataview
- Templater (QuickAddに慣れたら)
- Markdown prettifier (ページ内のタグなどをフロントマターに自動入力)
- MetaEdit (フロントマターに対する様々な操作)
- Various Components (フロントマターにタグを追加する際、サジェストを有効に)
- Breadcrumbs (メタデータによって、ノートに親子/きょうだいの概念を追加する)