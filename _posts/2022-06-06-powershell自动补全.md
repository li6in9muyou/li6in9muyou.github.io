---
title: PowerShell自动补全
date: 2022-06-06
categories: [HowTo]
tags: [tooling, PowerShell]
---

_THIS POST IS DEPRECATED, SEE [POWERSHELL DOTFILE](https://github.com/li6in9muyou/powershell-dotfiles/blob/master/Microsoft.PowerShell_profile.ps1)_

Execute following lines in PowerShell, then restart it.

```powershell
Install-Module PSReadLine -AllowPrerelease -Force
echo "Set-PSReadLineOption -PredictionSource History" >> $profile
echo "Set-PSReadLineOption -PredictionViewStyle ListView" >> $profile
```

## showcase

Picture was removed when this post got deprecated.
