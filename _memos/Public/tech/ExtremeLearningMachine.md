---
title: Extreme Learning Machine
feed: show
date: 
tags: 
publish: true
---
[Extreme learning machine - Wikipedia](https://en.wikipedia.org/wiki/Extreme_learning_machine)

[Extreme learning machineを実装してみた #Python - Qiita](https://qiita.com/koreyou/items/c7d92948fe86cf7d1b50)

> ## Extreme Learning Machine (ELM) とは?
ELMは特殊な形式のフィードフォワードパーセプトロンです。隠れ層を1層持ちますが、隠れ層の重みはランダムに決定し、出力層の重みを擬似逆行列を使って決定します。イメージ的には、隠れ層はランダムな特徴抽出器を多数作って、出力層で特徴選択をしてやるといった感じです。
> 
> ELMは次のような特性を持っています。
> - 解いているのは単なる擬似逆行列なので、高速に解を求めることができる
> - 凸な問題（局所解がない）
>- 任意の関数を近似可能（普通のパーセプトロンと同じ)
> - 任意のactivationが使用可能（微分できる必要なし）

[GitHub - tk42/q-elm: Q-learning based on Extreme Learning Machine implementation in Python](https://github.com/tk42/q-elm)


