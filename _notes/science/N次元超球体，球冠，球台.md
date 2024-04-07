---
title: N次元超球体，球冠，球帯
feed: show
date: 2024-04-07
tags: 
publish: true
---
$$N$$次元超球体の体積や表面積は広く知られている

$$V_{超球体} = \frac{2\pi^{N/2}}{\Gamma(N/2)} \frac{r^N}{N}$$

$$S_{超球体}=\frac{2\pi ^{N/2}}{\Gamma(N/2)}r^{N-1}$$

導出は$$N$$次元ガウス積分を二通りの方法で計算する
[n 次元球の体積 - EMANの統計力学](https://eman-physics.net/statistic/sphere_vol.html)
[Ex-0002.pdf](https://www.oit.ac.jp/ge/~nakano/Ex-0002.pdf)

---
$$N$$次元超球冠を考える．球冠とは図の青い領域．

![](https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Spherical_cap_diagram.tiff/lossless-page1-1194px-Spherical_cap_diagram.tiff.png)

[球冠 - Wikipedia](https://ja.wikipedia.org/wiki/%E7%90%83%E5%86%A0#%E8%B6%85%E7%90%83%E5%86%A0) によれば，この体積は

$$V_{球冠} = \frac{\pi^{\frac{n-1}{2}} r^n}{\Gamma\left(\frac{n+1}{2}\right)} \int_0^{\arccos\left(\frac{r-h}{r}\right)} \sin^n(t) \, dt$$

となることが知られている．([ Li, S (2011). “Concise Formulas for the Area and Volume of a Hyperspherical Cap”. _Asian Journal of Mathematics & Statistics_ **4** (1): 66–70.](https://scialert.net/fulltext/fulltextpdf.php?pdf=ansinet/ajms/2011/66-70.pdf))

この表面積を計算する．$$r$$で微分して，

$$S_{球冠} = \frac{dV}{dr} = \frac{\pi^{\frac{n}{2} - \frac{1}{2}} n r^{n-1}}{\Gamma\left(\frac{n}{2} + \frac{1}{2}\right)} \int_0^{\arccos\left(\frac{-h + r}{r}\right)} \sin^n(t) \, dt + \frac{\pi^{\frac{n}{2} - \frac{1}{2}} h r^{n - 2} \left(\frac{h}{r} \left(2 - \frac{h}{r}\right) \right)^{\frac{n}{2} - \frac{1}{2}}}{\Gamma\left(\frac{n}{2} + \frac{1}{2}\right)}$$

を得る．第二項は$$h\to 0, h\to 2r$$ で消滅するので，球冠の底の部分の超面積になっている．

球面部分の面積（側面積）は$$S_{球冠}$$の第一項がそれにあたるから，

$$S_{側面積}=\frac{\pi^{\frac{n-1}{2}} n r^{n-1}}{\Gamma\left(\frac{n+1}{2}\right)} \int_{0}^{\arccos\left(\frac{r-h}{r}\right)} \sin^n(t) \, dt $$

これを$$h$$で微分すると，

$$\frac{dS_{側面積}}{dh} = \frac{\pi^{\frac{n-1}{2}} n r^{n - 2} \left(\frac{h}{r} \left(2-\frac{h}{r} \right) \right)^{\frac{n}{2} - \frac{1}{2}}}{\Gamma\left(\frac{n}{2} + \frac{1}{2}\right)} = \frac{\pi^{\frac{n-1}{2}} n r^{\frac{n-3}{2}} \left(h r \left(2-\frac{h}{r} \right) \right)^{\frac{n}{2} - \frac{1}{2}}}{\Gamma\left(\frac{n}{2} + \frac{1}{2}\right)}$$

が得られる．

----
$$N$$次元超球台を考える．球台とは球を1対の平面で切断することで得られる図のような図形である．

![](https://upload.wikimedia.org/wikipedia/commons/8/83/LaoHaiKugelschicht1.png)

この体積，表面積共に球冠の$$h$$差分を取れば求められる．
