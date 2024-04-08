---
title: Deploy Apache/Airflow to GCE
date: 2023-03-04
tags: Technology/Computers/Software/Workflow Management
publish: true
---
Hi everyone. Here I wrote just a memo how to deploy Apache/Airflow to GCE.

# Apache/Airflow

> [Apache Airflow](https://airflow.apache.org/docs/apache-airflow/stable/) (or simply Airflow) is a platform to programmatically author, schedule, and monitor workflows.
> 
> When workflows are defined as code, they become more maintainable, versionable, testable, and collaborative.
> 
> Use Airflow to author workflows as directed acyclic graphs (DAGs) of tasks. The Airflow scheduler executes your tasks on an array of workers while following the specified dependencies. Rich command line utilities make performing complex surgeries on DAGs a snap. The rich user interface makes it easy to visualize pipelines running in production, monitor progress, and troubleshoot issues when needed.

[GitHub - apache/airflow: Apache Airflow - A platform to programmatically author, schedule, and monitor workflows](https://github.com/apache/airflow?source=post_page-----58ab1e9ce4c2--------------------------------)

So let’s see how to deploy in GCE.

One of the easiest way to launch Airflow is to use docker-compose. So we can start from using **Container Optimized OS**.  
Next, it’s important for airflow to consume 4GB memory at least. Otherwise, [we can’t start webserver due to gunicorn’s error.](https://github.com/apache/airflow/issues/10964) But if we choose at just 4GB memory, airflow recognize 3.9GB or so. So we can set it up at least **4.25GB memory.  
**And we prepare firewall setting for 8080 port and external static IP.

Then, we can connect the instance by SSH and add an alias to use `docker-compose` command, like following

```bash
alias docker-compose='docker run --rm \  
-v /var/run/docker.sock:/var/run/docker.sock \  
-v "$(pwd):$(pwd)" \  
-w "$(pwd)" \  
docker compose'
```

Basically, now we are in a good start point to use `docker-compose` command.

Then we’ll follow the instruction of airflow as below.

[Running Airflow in Docker — Airflow Documentation](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html?source=post_page-----58ab1e9ce4c2--------------------------------)

First, we’ll download `docker-compose.yml` .

```bash
curl -LfO 'https://airflow.apache.org/docs/apache-airflow/2.5.1/docker-compose.yaml'
```

Next we’ll set up directories
```bash
mkdir -p ./dags ./logs ./plugins  
echo -e "AIRFLOW_UID=$(id -u)" > .env
```

after that, we can launch finally.
```bash
docker-compose up
```

We can start it from webserver by accessing port 8080.