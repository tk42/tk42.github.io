---
title: Resolve ml_collections DuplicateFlagError
date: 2024-05-05
tags: 004/7,004/42,004/43,004/45,681/4
publish: true
feed: show
---
One of my *hate* library is `google/ml_collections` which is a library of Python Collections designed for ML use cases. For this purpose, I often see many frameworks of reinforcement learning or machine learning based on this library. 

The reason why I don't like this library is that many developers of those frameworks don't seem to understand it, because this library has too rich functions and features to use it well. For most cases, we don't need to use most of them. 

Today, I got an error on [RL-X](https://github.com/nico-bohlinger/RL-X) as following;

```python
DuplicateFlagError: The flag 'runner' is defined twice. First from rl_x.runner.runner, Second from ml_collections.config_flags.config_flags.  Description from first occurrence: ConfigDict instance.
```

This error sounds like coming from ml_collections to be locked for an flag defined twice. This behavior is quite reasonable but the problem is that this flag stays longer unexpectedly even if you unimport `ml_collections`  .
To resolve this, I read long time to try resolving it reading [stackoverflow1](https://stackoverflow.com/questions/54910914/duplicate-flag-error-the-flag-is-defined-twice-first-in-package-and-second-in), [stackoverflow2](https://stackoverflow.com/questions/49089740/duplicateflagerror-when-trying-to-train-tensorflow-object-detection-api-on-googl) and [stackoverflow3](https://stackoverflow.com/questions/50262618/tensorboard-duplicateflagerror), but finally it was in vain at all.

The only thing to do is to clear `flags` from `absl`. So, only you need to do is to like as following 

```python
from absl import flags

for name in list(flags.FLAGS):
	delattr(flags.FLAGS, name)
```

It sucks.

I'm fond of using `omegaconf` instead of `ml_collections` btw.