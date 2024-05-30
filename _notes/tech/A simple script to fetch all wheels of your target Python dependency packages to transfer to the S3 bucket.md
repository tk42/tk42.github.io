---
title: A simple script to fetch all wheels of your target Python dependency packages to transfer to the S3 bucket
date: 2024-05-30
tags: 004/7,004/678,681/3,681/3/06,004/738
publish: true
feed: show
---
This post is slightly relative to the previous post [[How to install docker-cli and docker images to standalone EC2 instance of AmazonLinux2023]].

Since the internet connection restriction in my office, I needed to download all Python wheels of dependency packages from a target library. Usually, you don't need to even think about that if your computer connects to the Internet because the package manager such as `pip` or `poetry` resolves that chore. 

Dependencies are usually nested. To get a package, you need to get other packages, to get them to get other packages, to get them to get other packages...

So it's tough to resolve it manually obviously. So my idea was a web service to get all wheels of dependencies of a package name when you input.
That server should connect to the Internet (thus, it can be a web server) and also the server fetches all packages after your request.
This server should work on Python and it should be the same platform/version of your target library and your environment.

Also since my office admits to connecting to AWS S3, the service would be better if the dependencies packages are uploaded to AWS S3 after fetched.

I gave permission to my S3 and IAM, then the service seems to be good so far.

You can use this script here.

[GitHub - tk42/pypi-dependencies-downloader](https://github.com/tk42/pypi-dependencies-downloader/tree/main)

