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

The other implementations are basically intended to apply LLM.

`srush` who is an author of The annotated S4 earlier also explains Mamba here [GitHub - srush/annotated-mamba: Annotated version of the Mamba paper](https://github.com/srush/annotated-mamba) 
Note that this post and repository use Triton which is a programming language from OpenAI for writing GPU code instead of PyTorch or Jax. When I try to run the code on Google Colab, **it didn’t work for me.**

There are several implementations for Mamba with JAX.
 - [GitHub - vvvm23/mamba-jax: Unofficial but Efficient Implementation of "Mamba: Linear-Time Sequence Modeling with Selective State Spaces" in JAX](https://github.com/vvvm23/mamba-jax)
 - [GitHub - radarFudan/mamba-minimal-jax](https://github.com/radarFudan/mamba-minimal-jax)
 - [GitHub - hu-po/jamba: Mamba in JAX](https://github.com/hu-po/jamba)

`vvvm23/mamba-jax` would help you to run Mamba algorithm with `equinox` which brings more power to your model building in JAX.

`radarFudan/mamba-minimal-jax` is basically intended to build LLM system.

`hu-po/jamba` needs more hyper parameters than the official implementation so you should dive deeper inside it.

