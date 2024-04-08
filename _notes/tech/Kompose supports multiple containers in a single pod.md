---
title: Kompose supports multiple containers in a single pod
date: 2021-07-10
tags: Technology/Software Development, Technology/Containers, Technology/Kubernetes
publish: true
---
Coucou. Today I gonna write about my PR recently merged to Kompose.

docker-compose.yml is a simple and a handy description of multi containers to run them simotaneously. But it does not have enough information to deploy them to Kubernetes because it needs more detail such as the composition of pods, the strategy of restarting pods or exposing services etc.

Kompose is an owesome CLI tool to convert YAML of docker-compose to YAML of Kubernetes. It’s written by golang and is cross compiled. Kompose converts docker-compose.yml to deployment (the composition and restarting strategy of pods), service (the way of outbounding) or config (environment variables) to be needed to deploy them to Kubernetes Cluster.

But it was not designed very well, unfortunately, that Kompose was creating each containers as its own single pod. This behaivour is not good intended for Container Patterns so-called such as side-car pattern, ambassador pattern or adaptor pattern.

This problem has been reported years but I have to deside to add an optional argument — multiple-container-mode to change the behavior after looking out the source code of Kompose which would not cause another effects.  
Moreover the multiple containers to be intended shipping in a single pod should have same label “kompose.service.group”.

Here is that PR.

[support multiple containers in a pod by tk42 · Pull Request #1394 · kubernetes/kompose · GitHub](https://github.com/kubernetes/kompose/pull/1394?source=post_page-----20ce5313be1e--------------------------------)

The added codes are so scattered to hope to brush up them someday but I suppose Kompose should cut off the support older docker-compose version 2 or Openshift. There are many OSS that support only latest dependencies.

Have a nice weekend deploying multiple containers in a single pod on K8s.