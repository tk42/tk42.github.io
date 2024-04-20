---
title: Super tedious behavior of Web Audio API on iPad
date: 2023-12-01
publish: true
tags: 004/62,621/381/3,004/678,681/324
---
A report that my webpage output no sound only on iPad was a starting point for my nightmare this week.

**TL;DR**

If you start your sounds with Web Audio API on an iPad, you must follow these steps.

1. **Arrange an HTML Audio element to output silence inside an event listener.**
2. Implement your Web Audio API codes after the above HTML Audio lines.

---
There are two ways to start your sounds on your webpage. “HTML Audio” and “Web Audio API”.

HTML Audio is literally like the Audio of HTML such as a`<audio>` tag element. HTML Audio has only simple functions like play, pause etc. You can also implement it easily as `const audio = new Audio("<your mp3 file path>")`

The Web Audio API enables advanced real-time audio processing that is impossible with HTML Audio elements, such as sound mixing, dynamic generation, reverb and delay effects, etc. In fact, the Web Audio API has a unique property in the output of sound.

On iPad, there are some rules for these HTML Audio and Web Audio API.

**I. Apple forbids playing sounds automatically without a user-driven action on the iPad.**

**II. HTML Audio element on iPad outputs sound, even if it is muted (mute button).** On the other hand, macOS, Windows 11 and Android do not output sound when muted (This behavior seems natural to me.)

**III. Web Audio API on iPad doesn’t output sound when muted (This is the opposite behavior to HTML’s Audio.)**

Furthermore, there’s another nuisance.

**IV. Beyond the above rule III, Web Audio API does output sound only after the HTML Audio element in the same webpage outputs sound at least once even when muted.**

The last rule is pretty tedious and seems nonsense. But it can’t be helped. So developers like me must implement fake HTML Audio before outputting the sound that you want by Web Audio API.

In short, at first, the webpage won’t output sound on the iPad caused of rules I & III. In the developer’s strategy, the fake HTML Audio (silence mp3) inside an event listener enables us to output sound at any time (caused by rule II), and then place sounds that we want by Web Audio API (caused by rule IV).

What a hassle!

---

At the beginning of this week, I tried checking basic points such as turning on the mute button or the sound volume being low. But those are no problem.  
Chrome didn’t sound too, which means it didn’t depend on the browser.

After spending a few days searching online, I felt Web Audio API might have some troubles. Not a few people reported that there’s a limitation to starting sounds on webpages by Apple or iPad OS. They also said that the limitation would be unlocked only after a user-driven action.

This is correct but not enough for my bug. Because the event listener on my webpage was already declared inside. So I needed to find another clue.

[iOS • iPadOSにおける音の出力条件がカオスすぎる｜Takehiko Ono](https://note.com/onopko/n/n6b30698417b5?sub_rt=share_h&source=post_page-----ef60db344722--------------------------------)

After reading this awesome tech post, my bug was resolved instantly by the above developer’s strategy. I hope this post saves your day!
