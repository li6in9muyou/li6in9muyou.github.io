---
title: 如何用GitHub Actions自动构建并发布一个静态页面。How to build and publish a static web page with GitHub Actions
categories: [HowTo]
tags: [github-actions]
---

1. create a file `/.github/workflows/deploy_gh_pages.yml`, with following content
2. add vite config entry `base: /${githubRepoName}/`, note leading and trailing slashes

```yaml
name: deploy_gh_pages

on:
  push:
    branches: ["main", "master"]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 20
          cache: "npm"
      - run: |
          npm install
          npm run build
      - uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./dist
```
