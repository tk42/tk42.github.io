---
title: Prediction MNIST-1D dataset with Mamba
feed: show
date: 2024-04-28
tags: 004/42, 004/7, 004/8, 681/4, 681/5
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

Thus, this post will show the image classification of MNIST-1D with the official implementation of Mamba.

First of all, we need to `pip install` the official  implementation  of Mamba.

```shell
!pip install mamba-ssm pytorch_lightning tqdm
```

`tqdm` is useful for the progress visualization, as well.

Then, we gonna load MNIST dataset.

```python
import torch
import torch.nn as nn
import torch.nn.functional as F

from torchvision import transforms
from torchvision.datasets import MNIST


def create_dataloader(batch_size):
	data_train = torch.utils.data.DataLoader(
		MNIST(
			'~/mnist_data', train=True, download=True,
			transform=transforms.ToTensor(),
		),
		batch_size=batch_size,
		shuffle=True
	)
	
	data_test = torch.utils.data.DataLoader(
		MNIST(
			'~/mnist_data', train=False, download=True,
			transform=transforms.ToTensor(),
		),
		batch_size=batch_size,
		shuffle=True
	)
	
	return data_train, data_test


batch_size = 32
trainloader, testloader = create_dataloader(batch_size=batch_size)
```

Now, we define `MambaMNISTClassifier`

```python
import torch
from mamba_ssm import Mamba

  
class MambaMNISTClassifier(nn.Module):
	def __init__(
		self,
		length,
		dim,
		device="cuda"
	):
		super().__init__()
		self.mamba_model = Mamba(
			# This module uses roughly 3 * expand * d_model^2 parameters
			d_model=dim, # Model dimension d_model
			d_state=16, # SSM state expansion factor
			d_conv=4, # Local convolution width
			expand=2, # Block expansion factor
		).to(device)
		
		self.classifier = nn.Sequential(
			nn.Linear(length*dim, 10, ),
			nn.LogSoftmax(dim=1)
		).to(device)
		
	def forward(self, x):
		batch_size = x.shape[0]
		x = self.mamba_model(x)
		x = x.view(batch_size, -1)
		x = self.classifier(x)
		return x


length, dim = 784, 1
model = MambaMNISTClassifier(length, dim)
```

Note that the dimension of our dataset MNIST-1D is `(784, 1)`. Finally we can train this `MambaMNISTClassifier` as below

```python
import torch
import torch.nn as nn
from tqdm.contrib import tenumerate

criterion = nn.CrossEntropyLoss()
optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)

for epoch in range(10):
	print(f"Epoch: {epoch}")
	train_loss, test_loss = 0.0, 0.0
	model.train()

	for idx, samples in tenumerate(trainloader):
		data, label = samples
		# print(f"{data.shape=}, {label.shape=}") # (32, 1, 28, 28), (32,)

		inputs = data.view(batch_size, -1, 1).cuda()
		# print(f"{inputs.shape=}") # (32, 784, 1)
		targets = F.one_hot(label.view(batch_size), num_classes=10).float().cuda()

		optimizer.zero_grad()
		outputs = model(inputs)
		assert outputs.shape[1] == 10, f"{outputs.shape=}, {targets.shape=}"
		# print(f"{outputs.shape=}, {targets.shape=}") # (32, 10), (32, 10)

		loss = criterion(outputs, targets)
		loss.backward()
		optimizer.step()
		train_loss += loss.item()

	print("train loss: ", train_loss / len(trainloader))

	model.eval()
	with torch.no_grad():
		for idx, samples in enumerate(testloader):
			data, label = samples
			if idx == len(testloader) - 1:
				continue

			inputs = data.view(batch_size, -1, dim).cuda()
			targets = F.one_hot(label, num_classes=10).float().cuda()
			outputs = model(inputs)
			loss = criterion(outputs, targets)
			test_loss += loss.item()

	print("test loss: ", test_loss / len(testloader))
```

We can see the result as below.

```
Epoch: 0
100% 1875/1875 [00:12<00:00, 153.39it/s]
train loss:  2.007297973759969
test loss:  1.2626248857083793

Epoch: 1
100% 1875/1875 [00:12<00:00, 150.18it/s]
train loss:  0.7616089713652928
test loss:  0.48858184769702034

Epoch: 2
100% 1875/1875 [00:12<00:00, 152.72it/s]
train loss:  0.4489669246673584
test loss:  0.38821695004693996

Epoch: 3
100% 1875/1875 [00:12<00:00, 150.30it/s]
train loss:  0.39068551207383473
test loss:  0.3567553902276979

Epoch: 4
100% 1875/1875 [00:12<00:00, 153.96it/s]
train loss:  0.36337787111997605
test loss:  0.33719901688182696

Epoch: 5
100% 1875/1875 [00:12<00:00, 154.69it/s]
train loss:  0.34521514528393743
test loss:  0.3230373412370682

Epoch: 6
100% 1875/1875 [00:12<00:00, 151.86it/s]
train loss:  0.3320234338223934
test loss:  0.31317343878241394

Epoch: 7
100% 1875/1875 [00:12<00:00, 155.58it/s]
train loss:  0.32165717258850735
test loss:  0.30604891240977633

Epoch: 8
100% 1875/1875 [00:12<00:00, 153.68it/s]
train loss:  0.31338001331885657
test loss:  0.29762586681082986

Epoch: 9
100% 1875/1875 [00:12<00:00, 151.90it/s]
train loss:  0.3063583553204934
test loss:  0.2924835445781866
```

[This colab notebook of this post is available here](https://colab.research.google.com/drive/1wOTKQbCD92sUxOS_EM-yfYgcokdXpwyi?usp=sharing)
