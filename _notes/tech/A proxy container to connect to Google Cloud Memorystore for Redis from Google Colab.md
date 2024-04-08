---
title: A proxy container to connect to Google Cloud Memorystore for Redis from Google Colab
date: 2020-09-09
tags:
  - Technology/Computers
  - Electronics/Programming
publish: true
---
Hi there. Have you enjoyed Google Cloud services? I really have. In this article, I discuss a way to connect to Google Cloud Memorystore for Redis from Google Colab.

Memorystore for redis launched in 2018 or so from Google is a managed service of Redis on Google Cloud Platform. You can find to create redis instances on Google’s awesome infrustracture easily.

Recently, I had to debug Memorystore for redis because my containers running in my GKE cluster input or output some significant variables to redis.  
It’s an obvious solution that you can launch a jupyter-notebook container on the cluster, and you’ll install “redis-py” with pip there, then import redis client which is called “import RedisModuleTimeSeries”. yes, i did.

But due to my few budget, my jupyter-notebook containers were “evicted” frequently. What the hell is going on. Working cells on the jupyter-notebook container was completely cleared out, once the container was evicted. I’m not sure to find out the solution precisely but one of it is to upgrade (purchase) my GCP instances not to run out resources.

Actually I’ve felt inconnvinient slightly not to save the working cells and the notebook file easily. Though I can save cells with “Download” button on Jupiter-lab, I felt troubles such that manually savings.

So I came up my mind to use Google Colab to debug Memorystore for redis. Google Colab is also a managed service of jupyter notebook and it’s apparently connected with Google Drive so you can find to save ipynb files there very easily.

To connect to Redis from Colab, a proxy server in my cluster should be created. I found that ‘haproxy’ is a famous and easy to use.

Here, this container is what I created. I deployed this container in my cluster, then the container is set as exposed. Finally, my Colab can access to my Redis cluster.

Reference: 

[google cloud platform - Accessing GCP Memorystore from local machines - Stack Overflow](https://stackoverflow.com/questions/50281492/accessing-gcp-memorystore-from-local-machines?source=post_page-----f660bb32012d--------------------------------)

Though I try to filter accesses by the domain name, I found that domain filtering by haproxy in TCP mode is not supported, as follows:

“If you’re using `mode tcp` in haproxy then you can't match HTTP headers with `hdr()` etc.”

[haproxy acl with "header(host)" check is not working for mqtt backend - Server Fault](https://serverfault.com/questions/962112/haproxy-acl-with-headerhost-check-is-not-working-for-mqtt-backend?source=post_page-----f660bb32012d--------------------------------)

----

USE [AI Platform Notebooks](https://cloud.google.com/ai-platform-notebooks)!! THIS IS THE BEST WAY

Establishing connections from Google Colab to MemoryStore for Redis in Google Cloud Platform, but those connections are not filtered well. so it could be vulnerable.

Since those connections are need to be filtered by domain, I was thinking of building a lightweight proxy server at the TCP layer. And here it is!

[GitHub - tk42/go-tcp-proxy: A small TCP proxy written in Go](https://github.com/tk42/go-tcp-proxy?source=post_page-----5076d6eb443d--------------------------------)

This repo is forked from [jpillora/go-tcp-proxy](https://github.com/jpillora/go-tcp-proxy) (Thanks!)

If you filtered by the domain, you can set some environment variables as follows;

- `PROXY_LOCAL_ADDR`: The source address of the connection (Google Colab address)
- `PROXY_REMOTE_ADDR`: The destination address of the connection (Redis MemoryStoree address)
- `PROXY_FILTER_DOMAIN`: The domain that will be blocked (e.g. `bc.googleusercontent.com` )

Then you deploy this container to somewhere GCP (GKE is a good choice), then access to the container from Google Colab with redis-py or aioredis.

And it would be a nice idea that these snippet codes are stored in My Drive. e.g.

```bash
#/usr/bin/python  
import redis  
COLAB_PROXY_IP = "256.256.256.256"  
COLAB_PROXY_PORT = 99999def getConn():  
  return redis.Redis(host=COLAB_PROXY_IP, port=COLAB_PROXY_PORT, db=0)
```

This completely works for me! Now I can manage Redis MemoryStore on Google Colab. Very handy!

Have a nice day!
