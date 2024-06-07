---
title: BigQueryで重複レコードを調べる
feed: show
date: 2024-06-07
tags: 
publish: true
---
BigQueryはクールだ．安いし，大規模なデータに対応している

だけど，唯一にして最大の欠点が

**ユニークキー制約がない**

ことだろう．

```
SELECT
 id,
 COUNT(*) AS duplicate_count
FROM
 `{table_id}`
GROUP BY
 id
HAVING
 COUNT(*) > 1;
```
