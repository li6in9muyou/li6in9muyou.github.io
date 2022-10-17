---
title: 把历史上的post migrate到本站
date: 2022-06-05
categories: [Howto]
tags: [chore]
---

# **THIS POST IS OUTDATED, REFER TO [THE LASTEST VERSION](https://blog.li6q.fun/posts/howto-write-a-post/)**

1. 添加front matter。
2. 把源post复制到`/_posts/`，重命名为`YYYY-MM-DD-${title}.md`的格式。
   I may leave title as is knowing that chineses characters are preserved in browser's address bar and white spaces will be automatically replaced with dashes.
3. 如果有，把`*.assets`文件夹移到`/assets/blog-images`。
4. 在源post中给所有图片链接prefix `/assets/blog-images`。