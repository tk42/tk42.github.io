---
title: protobuf-ts を使ってTypescriptでgRPCクライアントを作成する
date: 2022-05-12
tags: Technology/Programming/TypeScript, Technology/Programming/gRPC, Technology/Programming/Protobuf
publish: true
feed: show
---
grpc/grpc-js や improbable-eng/grpc-web ではなく @protobuf-ts を使って
TypescriptでgRPCクライアントを作成したい. なお，Authorizationが必要なエンドポイント．

```typescript
import { HogeServiceClient } from "../backend/gen/proto/typescript/hoge.client";
import { GrpcWebFetchTransport } from "@protobuf-ts/grpcweb-transport";
import type { RpcOptions, UnaryCall } from "@protobuf-ts/runtime-rpc";

export const grpcOptions: RpcOptions = {
  interceptors: [
    {
      // adds auth header to unary requests
      interceptUnary(next, method, input, options: RpcOptions): UnaryCall {
        if (!options.meta) {
          options.meta = {};
        }
        options.meta["Authorization"] = process.env.GRPC_AUTH_TOKEN!;
        return next(method, input, options); // TypeError: Cannot read properties of undefined (reading 'endsWith')
      },
    },
  ],
};

export const hogeServiceClient = new HogeServiceClient(
  new GrpcWebFetchTransport({
    baseUrl: process.env.GRPC_SERVER_HOST!,
  })
);
```
![](https://storage.googleapis.com/zenn-user-upload/a273034e6d1f-20220513.png)

のように```TypeError: Cannot read properties of undefined (reading 'endsWith')```のエラーが発生する．

トランスパイルされた```grpc-web-transport.js``` で確認すると
```javascript
import { Deferred, RpcError, RpcOutputStreamController, ServerStreamingCall, UnaryCall, mergeRpcOptions } from "@protobuf-ts/runtime-rpc";
import { GrpcWebFrame, createGrpcWebRequestBody, createGrpcWebRequestHeader, readGrpcWebResponseBody, readGrpcWebResponseHeader, readGrpcWebResponseTrailer } from "./grpc-web-format";
import { GrpcStatusCode } from "./goog-grpc-status-code";
/**
 * Implements the grpc-web protocol, supporting text format or binary
 * format on the wire. Uses the fetch API to do the HTTP requests.
 *
 * Does not support client streaming or duplex calls because grpc-web
 * does not support them.
 */
export class GrpcWebFetchTransport {
    constructor(defaultOptions) {
        this.defaultOptions = defaultOptions;
    }
    mergeOptions(options) {
        return mergeRpcOptions(this.defaultOptions, options);
    }
    /**
     * Create an URI for a gRPC web call.
     *
     * Takes the `baseUrl` option and appends:
     * - slash "/"
     * - package name
     * - dot "."
     * - service name
     * - slash "/"
     * - method name
     *
     * If the service was declared without a package, the package name and dot
     * are omitted.
     *
     * All names are used exactly like declared in .proto.
     */
    makeUrl(method, options) {
        let base = options.baseUrl;
        if (base.endsWith('/')) // Uncaught TypeError: Cannot read properties of undefined (reading 'endsWith')
            base = base.substring(0, base.length - 1);
        return `${base}/${method.service.typeName}/${method.name}`;
    }
   (以下略)
```
と，options.baseUrl が undefined であることが原因と言っているが，
GrpcWebOptions の baseUrl は string なので，undefinedになることはないのだが…

