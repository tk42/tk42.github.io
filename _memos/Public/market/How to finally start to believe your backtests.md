---
title: How to finally start to believe your backtests
feed: show
date: 2024-06-05
tags: 
publish: true
---
![](https://miro.medium.com/v2/resize:fit:1400/format:webp/1*tTmvKIhwtYOaV-tilw5fYg.png)

> - **“Accuracy proxy”:** Matthew's correlation coefficient (MCC) is a relatively general measure of “accuracy” of a predictive model that can give insights about how much we can rely on the model. Also, it can be helpful for detecting regimes, where our model is unreliable.

![](https://miro.medium.com/v2/resize:fit:1400/format:webp/0*QGaddmol9LZzjl8H.png)

> - **Sharpe ratios** (annualized, probabilistic, deflated): basic performance metrics that, however, have to be fixed for fat-tail and skewed distributions and multiple testing.
> - **“Smart” Sharpe ratios:** we want our strategy to lack autocorrelation, be memoryless, and hence, not have any long burn periods. If we penalize our Sharpe with autocorrelation, it can help us to choose such strategies via optimization.
> - **Information ratio:** this metric helps us to compare our strategy to the underlying or the benchmark beyond the “alpha”. It is the annualized ratio between the average excess return and the tracking error.

![](https://miro.medium.com/v2/resize:fit:1216/format:webp/1*jlTe-xzVWQD03tCfg3xZKQ.png)

[AI in Finance: how to finally start to believe your backtests \[1/3\] | by Alex Honchar | Towards Data Science](https://towardsdatascience.com/ai-in-finance-how-to-finally-start-to-believe-your-backtests-1-3-1613ad81ea44)

> # Backtesting through cross-validation
Long story short, we want to have more than one historical path to check our strategy performance. We could **sample it somehow from the historical data**, but in what way? We could take different parts from different times from the whole dataset as training and testing sets. For generating these parts we already know the mechanism — it’s called **cross-validation**. For our purposes, we need as rich as possible a set of simulations — all possible **combinations** of subsets for training and testing the algorithm, which brings us the **Combinatorial Purged Cross-Validation** algorithm:

![](https://miro.medium.com/v2/resize:fit:1308/format:webp/1*qNZ5JDuTUj3ikHmgX79kpg.png)


[AI in Finance: how to finally start to believe your backtests \[2/3\] | by Alex Honchar | Towards Data Science](https://towardsdatascience.com/ai-in-finance-how-to-finally-start-to-believe-your-backtests-2-3-adfd13da20ec)

