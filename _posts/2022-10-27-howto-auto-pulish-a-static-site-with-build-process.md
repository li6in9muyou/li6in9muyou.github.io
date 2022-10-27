---
title: 如何用GitHub Actions自动构建并发布一个静态页面。Howto build and publish a static web page with GitHub Actions
categories: [Howto]
tags: [github-actions]
---

1. create a file `/.github/workflows/deploy_gh_pages.yml`, with following content
2. add vite config entry `base: /${githubRepoName}/`, note leading and trailing slashes
3. setup secrets on GitHub

```yaml
name: deploy_gh_pages

on:
  push:
    branches: ["master"]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 16
          cache: "yarn"
      - run: |
          yarn
          yarn build
        env:
          SOME_ENV: ${{ secrets.SECRET_NAME }}
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./dist
```
