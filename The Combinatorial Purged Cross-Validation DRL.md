---
title: The Combinatorial Purged Cross-Validation method
date: 2024-04-12
tags: Technology, Data-Science, Machine-Learning, Deep-Learning, Reinforcement-Learning, Validation-Methods
publish: true
feed: show
---
We gonna talk about the combinatorial purged cross validation method applied to DRL (Deep Reinforcement Learning) referred to [Combinatorial PurgedKFold Cross-Validation for Deep Reinforcement… – Towards AI](https://towardsai.net/p/l/combinatorial-purgedkfold-cross-validation-for-deep-reinforcement-learning)

# Why we need validation

Non-stationary dataset especially market time series usually has a lot of noises and their trends are difficult to be told. This behavior is so-called as a high SN(signal and noise) ratio. Also, models would be easily overfitted depends on validation methods such as walk-forward method or cross validation method as later. We need to test your models on as many backtest paths of the train/valid dataset as possible and also need to check the model on the test dataset.
To do this, Combinatorial Purged Cross-Validation (CPCV) method may be useful and also we gonna talk about its application for DRL.

# Methods

Before to explain CPCV method, we need quickly to look back to the walk forward method and the cross validation method.

## Walk Forward Method

The walk forward method is the one of the primitive validation methods.

## Cross Validation Method 


## Combinatorial  Purged Cross Validation Method



# Explanation for CPCV applied to DRL

