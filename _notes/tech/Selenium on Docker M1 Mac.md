---
title: Selenium on Docker M1 Mac
date: 2023-05-26
publish: true
tags: 004/678,004/42,681/3,681/142,004/66
---
After spending the entire day searching online, I was finally able to locate the solution. In order to assist others who may encounter the same issue, I am documenting it here. Selenium is a widely used Python software for conducting end-to-end testing. Chrome is the preferred headless web browser for this purpose. Our objective is to replicate this process on an M1Mac in a Docker environment.

**TL;DR**

```Dockerfile
FROM python:3.9  
# actually python image is debian based  
  
ENV DEBIAN_FRONTEND noninteractive  
  
RUN pip install --upgrade pip  
  
# set environment variables  
ENV PYTHONDONTWRITEBYTECODE 1  
ENV PYTHONUNBUFFERED 1  
  
WORKDIR /backend  
  
COPY requirements.txt . /  
  
RUN pip install -r requirements.txt --no-cache-dir  
  
COPY . .  
  
RUN apt update -y && apt install libgl1-mesa-glx sudo chromium chromium-driver -y  
  
ENTRYPOINT [ ". /run-celery.sh"]
```

---  

Basically, you can use this docker image
[GitHub - SeleniumHQ/docker-selenium: Provides a simple way to run Selenium Grid with Chrome, Firefox, and Edge using Docker, making it easier to perform browser automation](https://github.com/SeleniumHQ/docker-selenium?source=post_page-----47985b7e1802--------------------------------)


However, on M1Mac you’ll be annoyed as follows;  
`unknown error: DevToolsActivePort file doesn’t exist launching ChromeDriver`

Many articles on StackOverflow weren’t helpful so need to fix some lines.
[selenium - headless chrome on docker M1 error - unable to discover open window in chrome - Stack Overflow](https://stackoverflow.com/questions/69784773/headless-chrome-on-docker-m1-error-unable-to-discover-open-window-in-chrome?source=post_page-----47985b7e1802--------------------------------)

