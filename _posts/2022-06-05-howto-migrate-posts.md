---
title: 如何把历史上的post迁移到本站
date: 2022-06-05
categories: [HowTo]
tags: [chore]
---

# **THIS POST IS OUTDATED, REFER TO [THE LATEST VERSION]({% post_url 2022-10-15-howto-write-a-post %})**

1. 添加 front matter。
2. 把源 post 复制到`/_posts/`，重命名为`YYYY-MM-DD-${title}.md`的格式。
   I may leave title as is knowing that chineses characters are preserved in browser's address bar and white spaces will be automatically replaced with dashes.
3. 如果有，把`*.assets`文件夹移到`/assets/blog-images`。
4. 在源 post 中给所有图片链接 prefix `/assets/blog-images`。
