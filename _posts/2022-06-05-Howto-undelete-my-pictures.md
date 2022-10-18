---
title: How to undelete my pictures?
date: 2022-06-05
categories: [Howto]
tags: []
---

I accidentally lost a few folders under `D:\tech--BLOG\`.

0. I need "Windows File Recovery" tool. Go to [https://store.rg-adguard.net/](https://store.rg-adguard.net/) to retrieve direct download links for this tool.
1. Download VCLibs runtime and the tool itself
2. In elevated powershell, use `Add-AppPackage` command to install them.
3. Run command `winfr D: C: /regular /n tech--BLOG/`
4. It started scanning disk and appeared to freeze at 99% after around ten minutes. After retrying a couple of times, I quit.
5. So I turned to [recuva](https://www.ccleaner.com/recuva)
6. Following clear instructions in GUI prompts, all pictures except two were recovered in seconds.
