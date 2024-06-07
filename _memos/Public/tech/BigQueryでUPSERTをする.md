---
title: BigQueryで重複レコードを調べる
feed: show
date: 2024-06-07
tags: 
publish: true
---
BigQueryはクールだ．安いし，大規模なデータ検索も超はやい．Pythonはじめ複数の言語のSDKがあり，スケーラビリティにも強い．

しかし，唯一にしておそらく最大の欠点が

**ユニークキー制約がない**

ことだろう．

だから `UPSERT`などという便利なものはない．普通に重複してしまう．BigQuery的には別の一時的なテーブルを作って，それを`MERGE`しろ，ということのようだ（気軽にテーブルを作っては壊すということが奨励されているように思える）


2023年登場した BigQuery の主キー・外部キー制約は正直肩透かしだった

> - 主キー・外部キー制約を強制することはできない😇
>- 重複データもinsertできてしまう😭

[プレビューになったBigQueryの主キー・外部キー制約を使ってみた](https://zenn.dev/seiya0429/articles/b777cc2c5d8817)

そう．主キー・外部キー制約を登録しても**何もしてくれない**のだ．はっきり言ってカスである．

この記事には，他のDWH(Amazon RedshiftやSnowflake)でも制約は機能しないと書いている．まあ，NoSQLの仕組みを考えればあまり期待できることではない．

しかし，それでは困る！

そういう場合，まず重複レコードがあるかどうかを調べることになるだろう．

```
SELECT unique_key,
COUNT(1)
FROM `{table_id}`
GROUP BY 1
HAVING COUNT(1) > 1
```

こんな感じで調べられる．350万レコードでも4秒ぐらいで調べられた．

さて，`UPSERT`のための`MERGE`を調べる

```
MERGE INTO {destination_table} AS target
USING {source_table} AS source
ON target.Epoch = source.Epoch
WHEN MATCHED THEN
  UPDATE SET target.column1 = source.Open, target.High = source.High, target.Low = source.Low, target.Close = source.Close, target.Volume = source.Volume, target.Number = source.Number

WHEN NOT MATCHED THEN

INSERT (Epoch, Open, High, Low, Close, Volume, Number) VALUES (source.Epoch, source.Open, source.High, source.Low, source.Close, source.Volume, source.Number)
```