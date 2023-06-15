---
title: 你说一下响应式。what do you know about responsive web design
categories: [Learning]
tags: [responsive]
---

响应式设计就是一批行业内的最佳实践，用来处理不同屏幕大小和屏幕方向对网页的影响，用来给用户最好的体验。
主要着力点是三个方面：页面布局、图片、文字。详见[https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design](https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design)

页面布局应该根据屏幕尺寸调整视觉元素的布局，例如，在窄屏幕上使用单列布局，在宽屏幕上采用多列布局；在窄屏幕上将列表合并为下拉菜单，
在宽屏幕上则将其展开。

图片响应式的做法主要是给同一个图片提供多种不同分辨率、不同尺寸、不同容量的图片源供用户代理选用，其目标是在不同的屏幕大小和不同的带宽
环境下使用合适用户的图片。有时，仅仅在在小屏幕上使用小容量的图片在大屏幕上使用大容量图片以期节省用户的网络流量可能还不够，
[这篇文章](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images)讲述了有时应该在在小屏幕上提供局部特写照片，而在宽屏幕上可是适当提供远景照片，也就是说图片响应式也应该适配画面
的内容。

文字响应式的做法是根据屏幕大小尺寸调整文字的大小，例如在大屏幕上可以适当增大标题文字的尺寸。
可以用 media query 和 viewport units 来实现。
