---
title: gRPC backend server with SurrealDB
date: 2022-10-31
tags: 004/6,004/7,004/678,004/738,004/738/2
publish: true
---
Recently I found an ‘ultimate’ database made by Rust which is called “SurrealDB”.

SurrealDB is a self-hosted Database, not DBaaS like PlanetScale or xata.

> With an SQL-style query language, real-time queries with highly-efficient related data retrieval, advanced security permissions for multi-tenant access, and support for performant analytical workloads, SurrealDB is the next generation serverless database.

I think gRPC protocol is the best match with SurrealDB than anything.

SurrealDB behaves like GraphDB which supports ‘edge’ relation between entities. In the conventional SQL, we must create junction tables whenever the M vs M entities would be associated or some attributes of the association would be added. The methods of gRPC protocol have no restrictions compared with CRUD of REST.

And SurrealDB has websocket endpoints because the database will notify to the clients whenever the stored data is changed. gRPC supports also bi-directional communication as well as unary protocol.

So the backend database of gRPC server would suit SurrealDB.

[GitHub - tk42/grpc-surrealdb-template](https://github.com/tk42/grpc-surrealdb-template?source=post_page-----f30e23283299--------------------------------)

This sample repository is implemented as a backend server with gRPC and SurrealDB.

I hope this sample helps someone.