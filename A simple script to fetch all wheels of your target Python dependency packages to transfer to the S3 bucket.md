---
title: A simple script to fetch all wheels of your target Python dependency packages to transfer to the S3 bucket
date: 2024-05-30
tags: 
publish: true
feed: show
---
This post is slightly relative to the previous post [[How to install docker-cli and docker images to standalone EC2 instance of AmazonLinux2023]].

Since the internet connection restriction in my office, I needed to download all Python wheels of dependency packages from a target library. Usually, you don't need to even think about that if your computer connects to the Internet because the package manager such as `pip` or `poetry` resolves that chore. 

Dependencies are usually nested. 