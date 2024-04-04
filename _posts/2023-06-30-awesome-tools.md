---
title: 好的工具。a curated list of tools
categories: []
tags: [memo]
---

# source code screenshots

[https://carbon.now.sh/](https://carbon.now.sh/?bg=rgba%28171%2C+184%2C+195%2C+1%29&t=vscode&wt=none&l=text%2Fx-c%2B%2Bsrc&width=680&ds=true&dsyoff=20px&dsblur=68px&wc=true&wa=true&pv=56px&ph=56px&ln=false&fl=1&fm=Hack&fs=14px&lh=133%25&si=false&es=1x&wm=false&code=float%2520InvSqrt%28float%2520x%29%257B%250A%2520%2520float%2520xhalf%2520%253D%25200.5f%2520*%2520x%253B%250A%2520%2520int%2520i%2520%253D%2520*%28int*%29%2520%2526x%253B%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%250A%2520%2520i%2520%253D%25200x5f3759df%2520-%2520%28i%2520%253E%253E%25201%29%253B%2520%2520%2520%2520%250A%2520%2520x%2520%253D%2520*%28float*%29%2520%2526i%253B%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%250A%2520%2520x%2520%253D%2520x%2520*%2520%281.5f%2520-%2520xhalf%2520*%2520x*x%29%253B%2520%2520%2520%2520%2520%250A%2520%2520return%2520x%253B%250A%257D)

<iframe
src="https://carbon.now.sh/embed?bg=rgba%28171%2C+184%2C+195%2C+1%29&t=vscode&wt=none&l=text%2Fx-c%2B%2Bsrc&width=680&ds=true&dsyoff=20px&dsblur=68px&wc=true&wa=true&pv=56px&ph=56px&ln=false&fl=1&fm=Hack&fs=14px&lh=133%25&si=false&es=1x&wm=false&code=float%2520InvSqrt%28float%2520x%29%257B%250A%2520%2520float%2520xhalf%2520%253D%25200.5f%2520*%2520x%253B%250A%2520%2520int%2520i%2520%253D%2520*%28int*%29%2520%2526x%253B%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%250A%2520%2520i%2520%253D%25200x5f3759df%2520-%2520%28i%2520%253E%253E%25201%29%253B%2520%2520%2520%2520%250A%2520%2520x%2520%253D%2520*%28float*%29%2520%2526i%253B%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%2520%250A%2520%2520x%2520%253D%2520x%2520*%2520%281.5f%2520-%2520xhalf%2520*%2520x*x%29%253B%2520%2520%2520%2520%2520%250A%2520%2520return%2520x%253B%250A%257D"
style="width: 453px; height: 335px; border:0; transform: scale(1); overflow:hidden;"
sandbox="allow-scripts allow-same-origin">
</iframe>

# lorem ipsum but it's picture

`https://placehold.co/600x400/orange/blue`

![https://placehold.co/600x400/orange/blue](https://placehold.co/600x300/orange/blue)

# copy a directory and its git history

[This article](https://www.baeldung.com/linux/git-copy-commits-between-repos) outlines the cherry-picking approach.

1. Create a new git repo, `git init`
2. Set original repo as a remote, `git remote add hmwk file://path/to/original/repo`
3. Download history from original repo, `git remote update`
4. List commits that change this directory, `git log -- day2009-bouncing-discs`. Or use helper in IDE.
5. Cherry-pick commits from remote, `git cherry-pick f1a6884d^..5dfa0336` if commits are consecutive. Or cherry-pick them one by one.

However, cherry-pick will throw fatal error if specified hash range contains merge commit.
And commits from another branch will be "merged" to HEAD which is a very undesirable behaviour.

Subtree merging approach preserves merge commits and full commit history,
see [this link](https://mirrors.edge.kernel.org/pub/software/scm/git/docs/howto/using-merge-subtree.html).
Excerpt:

> Here is the command sequence you need:
>
> ```bash
> $ git remote add -f Bproject /path/to/B <1>
> $ git merge -s ours --no-commit --allow-unrelated-histories Bproject/master <2>
> $ git read-tree --prefix=dir-B/ -u Bproject/master <3>
> $ git commit -m "Merge B project as our subdirectory" <4>
> $ git pull -s subtree Bproject master <5>
> ```
>
> 1. name the other project "Bproject", and fetch.
> 2. prepare for the later step to record the result as a merge.
> 3. read "master" branch of Bproject to the subdirectory "dir-B".
> 4. record the merge result.
> 5. maintain the result with subsequent merges using "subtree"
>
> The first four commands are used for the initial merge, while the last one is to merge updates from B project.

# git stash

`git stash` common commands includes: `list`, `push`, `pop`/`apply`, `show`. Their meaning are pretty strateforward and don't forget to use `git stash show -p` to show stash detail. For options other than "-p" see _"DIFF FORMATTING"_ section in `git show --help`.
