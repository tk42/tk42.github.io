---
title: UnixTimestamp auto-padding with 0
date: 2024-04-23
tags: 004/7,004/42,004/6,681/3
publish: true
feed: show
---
Hi.

When using a common UnixTimestamp converter (e.g. [Unix Time Stamp - Epoch Converter](https://www.unixtimestamp.com/)), you often have to input all 10 digits to get a conversion. (The same goes for programmatic conversions.)

When you want to know “roughly when" before inputting all of 10 digits, it would be convenient if you padded the back part with 0.

I made it with the idea that it would be useful, but it turned out to be unexpectedly convenient, so I'm releasing it to the public. It is also useful that it works only on the client side.

### [Unix Timestamp Converter](https://tk42.jp/unixts/)


[Source](https://github.com/tk42/unixts)
