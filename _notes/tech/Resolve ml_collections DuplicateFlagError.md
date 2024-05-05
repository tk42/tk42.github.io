---
title: Resolve ml_collections DuplicateFlagError
date: 2024-05-05
tags: 
publish: true
feed: show
---
One of my *hate* library is `google/ml_collections` which is a library of Python Collections designed for ML use cases. For this purpose, I often see many frameworks of reinforcement learning or machine learning based on this library. 

The reason why I don't like this library is that many developers of those frameworks don't seem to understand and use it well, because this library has rich functions and features. For most cases, we don't need to use most of them.

Today, I got an error on RL-X as following;

```
DuplicateFlagError: The flag 'runner' is defined twice. First from rl_x.runner.runner, Second from ml_collections.config_flags.config_flags.  Description from first occurrence: ConfigDict instance.
```

This error sounds like coming from ml_collections so I took long time to resolve it reading [stackoverflow1](https://stackoverflow.com/questions/54910914/duplicate-flag-error-the-flag-is-defined-twice-first-in-package-and-second-in), [stackoverflow2](https://stackoverflow.com/questions/49089740/duplicateflagerror-when-trying-to-train-tensorflow-object-detection-api-on-googl) and []


