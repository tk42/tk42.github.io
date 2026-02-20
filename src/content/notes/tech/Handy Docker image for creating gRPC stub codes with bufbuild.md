---
title: Handy Docker image for creating gRPC stub codes with bufbuild
date: 2022-05-10
tags: 004/7,004/78,004/76,681/3,681/32
publish: true
---
Hi, everyone. Today I’m thinking of talking to you guys about the new handly docker image that creates gRPC stub codes with **bufbuild**.

First of all, Bufbuild is a new way of working with Protocol Buffers as they said. Basically the `buf` CLI is a replacement tool with `protoc`. and furthermore `buf`has those features such as a linter that enforces good API design choices and structure and a breaking change detector that enforces compatibility at the source code or wire level.

But now we are a beginner of `buf` so let me see how the `buf`generates gRPC codes from ProtocolBuffers IDL.

Basically, the `buf`requires three yaml files `buf.gen.yaml`, `buf.work.yaml`, and `buf.yaml`.  
`buf.gen.yaml`should be placed in the root directory and tells the compiler to use plugins that handle for go, python and typescript etc…  
`buf.work.yaml` should be placed in the root as same as `buf.gen.yaml` and tells directories contained proto files.  
`buf.yaml` should be placed in the directory containing the proto files and has the configure about linter or breaking change detector.  
Anyway, won’t you rushly to use it? Okay. Let’s pull the docker image of buf and `docker run`…

Wait! Before using the docker image, I have to tell you a bad news.

> Buf’s image does not contain protoc, and this is on purpose — specific generation plugins you need (including protoc, which contains the plugins for java, cpp, etc) need to be handled by you. We’ll be dealing with this ourselves in the future Buf Schema Registry, but for local generation, you are responsible for your own plugin versioning and installation. I’d recommend creating your own Docker image for this.

[Compiling to Java using the provided docker image · Issue #184 · bufbuild/buf · GitHub](https://github.com/bufbuild/buf/issues/184?source=post_page-----c6e8d70c00e7--------------------------------)

OMG. The buf image doesn’t contain `protoc` so you can’t generate stub codes derived from protoc. As following that proposal, we have to create a new `buf` docker image with protoc.

… No way. So I did it and made it public ;)

[GitHub - tk42/bufbuild: handly docker image with bufbuild](https://github.com/tk42/bufbuild?source=post_page-----c6e8d70c00e7--------------------------------)

As you can see from the repository, you should specify docker image `ghcr.io/tk42/bufbuild` with following parameters. `petapis` is a directory name contained the sample ProtocolBuffers files.

```yaml
version: '3'  
services:  
buf:  
context: .  
image: ghcr.io/tk42/bufbuild  
volumes:  
- ".:/workspace"  
working_dir: "/workspace"  
command: ["generate", "petapis"]
```

This image supports plugins for golang, python and typescript that I like. Someday I might support more languages but can’t tell you when.

See you next time!