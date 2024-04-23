---
title: UnixTimestamp auto-padding with 0
date: 2024-04-23
tags: 
publish: true
feed: show
---
巷によくある UnixTimestamp 変換器(例えば [Unix Time Stamp - Epoch Converter](https://www.unixtimestamp.com/) )を使うとき，10桁全て入力しないと変換してくれないことが多い（プログラムで変換する時も動揺）

ざっくりと「いつぐらいか」を早く知りたい時に，後方を0で勝手にpaddingしてくれたら便利だなと思って作ったら，思いの外便利だったので

[Unix Timestamp Converter](https://tk42.jp/unixts/)

