---
title: ED(Error Diffusion)法
feed: show
date: 2024-04-27
tags:
  - 004/45
  - 681/3
publish: true
---
ED(ErrorDiffution)法 誤差拡散法

> - 日本語で言うと誤差拡散法
>- バックプロパゲーションはエラーを後ろに渡すが、ED法はエラーを全体で共有している

[『Winny』の金子勇さんの失われたED法を求めて...いたら見つかりました #機械学習 - Qiita](https://qiita.com/kanekanekaneko/items/901ee2837401750dfdad)

中間層を増やしても勾配消失せず学習が進むというものらしい．学習が安定しているとも．

> 結局ＥＤ法は、階層型神経網学習における単純山登り法です。ＢＰも同様に山登り法ですが、ＢＰがエラー関数の勾配による最急降下法であるのに対して、ＥＤ法は方向だけ考慮した特殊な山登り法です。概念的にはパーセプトロンに近いです。ＢＰが勾配情報で誤差を局所最小化するのに対して、ＥＤ法では回路構成を工夫することにより、階層型神経網でも確実に誤差が降下する方向に重みを変えます。ただし、神経素子はＥＤでも、ＢＰ同様、シグモイド関数を用いるアナログ非線型素子です。

> 予想通り、ＥＤ法では、ＢＰに比べて認識率が落ちます。ＢＰと比べて、よりローカルミニマに落ちやすく、ノイズを拾いやすいということでしょう。ただ、中間層素子数を変えたときの振る舞いが違います。良く知られているように、神経回路網では中間層はむやみに多くとればよいというわけではなく、問題に合わせた適当な数というのが決まっています。今回の例では、ＢＰの結果から６４個近辺が良いようです。ですが、それはあくまで学習アルゴリズムにＢＰを用いた時の話です。

> ＥＤでは、中間数は多ければ多いほど良いのです。多いほど収束速度が上がると共に、認識率も上がります。これは、出力層の誤差信号を中間層でも用いるために、中間層が増えれば増えるほど試行数が増えるのと同じことになるためだと思われます。確率での大数の法則と同じです。予想ですが、中間層素子数が無限個になるか、学習回数が無限大になると、汎化能力が、最適化したＢＰと同じになるのではないかと思います＜いまのところ、あくまで予想。

[EDLA](https://web.archive.org/web/19991124023203/http://village.infoweb.ne.jp:80/~fwhz9346/ed.htm)


[[SpikingNeuralNetworks]]の特殊な形式じゃないのか？という批判もある．
[ED法とSNNの違いを考えてみる #ED法 - Qiita](https://qiita.com/obgynengine/items/44e8cfe2bdd25ac49cb3)
