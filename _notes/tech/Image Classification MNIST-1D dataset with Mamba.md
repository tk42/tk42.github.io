---
title: Prediction MNIST-1D dataset with Mamba
feed: show
date: 2024-04-28
tags: 
publish: true
---
MNIST classification by CNN is not a difficult task, but MNIST-1D converted to 1D from 2D is a different situation. One of the difficulties of MNIST-1D classification comes from long-term memory. The classification by CNN can be used to 28 * 28 pixels but this task should be classified by 1-dimension 784 pixels clearly longer.
Blog post [The annotated S4](https://srush.github.io/annotated-s4/#experiments-mnist) is a good benchmark for this task. S4 is one of the structured state space models for time series signal modeling. This architecture was a new approach to very long-range sequence modeling tasks for vision, language and audio. Also the benefit of this model is more efficient than Transformer but less powerful due to compressed too much. That is the problem of this architecture.
For solving this issue, on December, 2023, Albert Gu et al published a new approach Mamba which compresses data selectively and is more powerful than S4.  This post [A Visual Guide to Mamba and State Space Models](https://newsletter.maartengrootendorst.com/p/a-visual-guide-to-mamba-and-state) would help your understanding of this architecture.
So here we gonna see the classification MNIST-1D with Mamba. Before going beyond this, let's take a look at some implementations of Mamba. 

First of all, the official implementation `state-spaces/mamba` is based on PyTorch and also you can install by pip with `mamba-ssm`. 

[GitHub - state-spaces/mamba](https://github.com/state-spaces/mamba)

srush who is an author of The annotated S4 earlier also explains Mamba here [GitHub - srush/annotated-mamba: Annotated version of the Mamba paper](https://github.com/srush/annotated-mamba) 
