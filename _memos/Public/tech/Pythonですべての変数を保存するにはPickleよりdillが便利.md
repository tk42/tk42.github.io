---
title: Pythonですべての変数を保存するにはPickleよりdillが便利
feed: show
date: 2024-05-31
tags: 004/42,004/438,004/44
publish: true
---
pickle との使い分けがまだわかってないがとりあえずメモ

> ここでこれまでに作った変数を全て保存したいときには、以下のようにします。

```
import dill
dill.dump_session('session.pkl')
```

> この続きからまた処理をしたいときには、次のように`session.pkl`をロードをすれば、先ほど作った変数がまたすべて使えます。

```
import dill
dill.load_session('session.pkl')
```

[Pythonですべての変数を保存するにはPickleよりdillが便利 #Python - Qiita](https://qiita.com/karadaharu/items/948e4d313fbaa32e408c)
