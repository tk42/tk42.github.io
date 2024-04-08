---
title: Converting swagger.json to API on stand-alone
date: 2021-01-05
tags: Technology/Programming, Software Development, API Documentation
publish: true
---
In this post, we’re gonna take a look at converting swagger.json to HTML on stand-alone.

swagger.json is a JSON file describing the structure of your APIs so that system can read them. Swagger.json can be converted to API document in HTML. You can generate the document into Swagger Editor.
[Swagger Editor](https://editor.swagger.io/?source=post_page-----4a9ea82638f4--------------------------------)

But if you create the API document in an offline environment such as an intranet in your office, Swagger Editor would be useless. So I make a tiny convert tool with Python.
[GitHub - tk42/swagger-to-html-standalone: Convert Swagger YAML into HTML with Docker](https://github.com/tk42/swagger-to-html-standalone?source=post_page-----4a9ea82638f4--------------------------------)

Somehow this repository is copied to the stand-alone environment, then type the following command to generate the API document.

```bash
python ==swagger-to-html-standalone.py== < swagger.json > doc.html
```

The HTML document refers to CSS and JS files, so don’t forget to copy them as well.

This script supports not only json but also yaml that is technically **YAML** is a superset of **JSON**. (This means that, in theory at least, a **YAML** parser can understand **JSON**.)

Enjoy!