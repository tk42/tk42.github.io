---
title: Handy docker image for creating gRPC stub codes
date: 2021-05-30
tags: 004/42,004/678,004/678/3,004/678/31,004/678/312
publish: true
---
Hi everyone. Today’s story is to create gRPC stub codes when you need in developing gRPC application with golang.

# gRPC

gRPC is an HTTP/2-based RPC (Remote Produce Call) framework developed by Google. Protocol Buffers is used to serialize data (other protocols are also available, but it’s the standard).  
There are other RPCs such as the REST-API, but it is not necessary to specify paths and methods like the REST-API.

# Protocol Buffers

Protocol Buffers is Google’s format for data serialization, and is supposed to be a replacement for JSON. It is used for client-server communication, data persistence, etc. It is compatible with various languages that describe data structures in IDL (Interactive Data Language) in proto files (Golang/Java/Python/Rust etc…).  
The code for serialization and deserialization is automatically generated. `protoc` command is to compile it.

# Go Protocol Buffer Message API

Go Protocol Buffer Message API is a way for Golang applications to use Protocol Buffer. There are many repositories related to the API, so I will sort out them as of May 2021.  
20 Mar 2020, APIv2 was announced on the official Go blog. Reflection can be used now. APIv2 is not backward compatible, but no worries, APIv1 will continue to be supported.  
The Protocol Buffer repository has been moved from `golang/protobuf`to `protocolbuffers/protobuf-go`, using the protocol-gen-go command for messages and serialization of Protocol Buffers.  
It’s note that a new command, `protoc-gen-go-grpc`, has been added to `grpc/grpc-go`in the gPRC repository, and this command is used to generate interfaces (stub code) for gPRC server/client. It’s important that both of those commands are required to create an application with gRPC.

# Docker image for protoc, protoc-gen-go-grpc and grpc-go

It’s quite tough to prepare the infrastracture to make those stub codes.

Basic idea could be seen in `znly/docker-protobuf` or `namely/docker-protoc` , but those repository is huge to support many languages and API v1 is out of date for grpc of golang developers.

So I made a handy docker image for those people.
[GitHub - tk42/protoc: Docker image for protoc and protoc-gen-go](https://github.com/tk42/protoc?source=post_page-----ff76114548c8--------------------------------)

As you can see `docker-compose.yml`, all you have to do is to pull the image `ghcr.io/tk42/protoc` with some arguments with `protoc`

`helloworld.proto`is a sample proto code and `example.com/hello` are stub codes for the proto file.

Enjoy!

----

After wrote this post, I found `bufbuild` that is a newer and easier way than `protoc`

[Buf](https://buf.build/?source=post_page-----ff76114548c8--------------------------------)

Someday I might write a story about Buf.
