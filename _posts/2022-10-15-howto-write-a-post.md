---
title: 如何给本站添加文章
categories: [Howto,Memo]
tags: [chore]
---

# steps:

0. Clone this repo from GitHub
1. Create a post under `/_posts/`. See "A Post" below for detail
2. Commit then push.

## expected behavior:

- The push to GitHub kicks off a sequence GitHub Actions
- The new post is live at the site
- A [small commit](https://github.com/li6in9muyou/li6in9muyou.github.io/commit/682e485caccb328c7a4595632f69bdd63891ce79) takes about one minute from push to live.

# A Post

## file name

File names of posts should be `<YEAR>-<MONTH>-<DAY>-<title>.md` where title should a sequence of hyphen separated ASCII words. File names will be used in links, blank spaces and non-ASCII character would be unreadable after URL encoding.

```
good:
2022-10-17-howto-write-a-post.md
bad: 
2022-10-17-howto write a post.md
2022-10-17-如何添加文章.md
```

## front matter

The front matter must be the first thing in the file.

example:

```
---
title: 如何给本站添加文章
categories: [Howto,Memo]
tags: [chore]
---
```

For anything else, refer to [jekyll doc](https://jekyllrb.com/docs/front-matter/).

fields

- title: blog title. Use any character you want
- date: **ADD THIS FIELD IF YOUR MUST**. this field override dates in file name
- categories: list of CamelCase category names, `[CategoryOne, CategoryTwo]`
- tags: list of kebab-case tag names, `[tag-one, tag-two]`

## image assets

**When possible, use [mermaid-js](https://mermaid-js.github.io/mermaid/#/) to generate graphs.**

Images should be in `/assets/blog-images`. Links in markdown should have prefix `/assets/blog-images`.

**FIXME**

The set up above would cause markdown editor to be unable to locate and render images. This behavior is not desirable. I am working on a better solution.
