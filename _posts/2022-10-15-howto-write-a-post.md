---
title: 如何给本站添加文章
categories: [HowTo]
tags: [chore]
---

# steps

0. Clone this repo from GitHub
1. Create a post under `/_posts/`. See "A Post" section below for details
2. Commit then push.

## expected behavior:

- The push to GitHub kicks off a sequence GitHub Actions
- The new post is live at the site
- A small commit like [this](https://github.com/li6in9muyou/li6in9muyou.github.io/commit/682e485caccb328c7a4595632f69bdd63891ce79) takes about one minute from push to live.

# A Post

## file name

File names of posts should be `<YEAR>-<MONTH>-<DAY>-<title>.md` where title should a sequence of hyphen separated ASCII words.
File names will be used in links, non-ASCII character would be unreadable after URL encoding.
Blank spaces are replaced with hyphen automatically by Jekyll

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
categories: [HowTo]
tags: [chore]
---
```

For anything else, refer to [Jekyll doc](https://jekyllrb.com/docs/front-matter/).

fields

- title: blog title. Use any character you want
- date: **ADD THIS FIELD IF YOUR MUST**. this field override dates in file name
- categories: CamelCase category name, `[CategoryOne]`. Using multiple category names means sub-category e.g. `[Animal, Mammal]`
- tags: list of kebab-case tag names, `[tag-one, tag-two]`

## image assets

**When possible, use [mermaid-js](https://mermaid-js.github.io/mermaid/#/) to generate graphs.**

Images should be in `/assets/blog-images`. Links in markdown should have prefix `/assets/blog-images`.

**FIXME**

The set up above would cause markdown editor to be unable to locate and render images. This behavior is not desirable. I am working on a better solution.

## other guidelines

0. Markdown titles and subtitles are used to generate permalink, use concise ACSII titles if you don't want your link ends up to be gibberish like `example.com/posts/%E5%A6%82%E4%BD%95%E7%BB%99%E6%9C%AC%E7%AB%99%E6%B7%BB%E5%8A%A0%E6%96%87%E7%AB%A0`
1. YAML syntax requires a space after colon, see [this commit](https://github.com/li6in9muyou/li6in9muyou.github.io/commit/1bfe2750)
2. Do not use unidecode characters in image url, see [this commit](https://github.com/li6in9muyou/li6in9muyou.github.io/commit/9ac9a804)
3. coming soon...
