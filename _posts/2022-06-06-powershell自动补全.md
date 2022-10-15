---
title: PowerShell自动补全
date: 2022-06-06
categories: [HowTo]
tags: [tooling,PowerShell]
---

execute following lines in PowerShell, then restart it.

```powershell
Install-Module PSReadLine -AllowPrerelease -Force
echo "Set-PSReadLineOption -PredictionSource History" >> $profile
echo "Set-PSReadLineOption -PredictionViewStyle ListView" >> $profile
```

## showcase

![image-20220606103921745](/assets/blog-images/2022-06-06-powershell自动补全.assets/image-20220606103921745.png)