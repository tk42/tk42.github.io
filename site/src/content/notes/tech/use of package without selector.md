---
title: use of package without selector
date: 2020-05-26
tags: 004/11,004/42,004/78
publish: true
---
# TL;DR

In case found “use of package {package name} without selector” while building Golang, you should check if the name of package is declared in spite of the name was the reserved word.

---
The namespace in Golang should be simple and it’s a one of differences than other languages such as Java.

[Package names - The Go Programming Language](https://blog.golang.org/package-names?source=post_page-----87ececa25357--------------------------------)

Then I followed the rules and declared ‘new’ package, then I stacked due to the above error.

> use of package new without selector

Please be careful if you use reserved words too much to simplify the package name.

[go - Getting a use of package without selector error - Stack Overflow](https://stackoverflow.com/questions/36994445/getting-a-use-of-package-without-selector-error?source=post_page-----87ececa25357--------------------------------)

