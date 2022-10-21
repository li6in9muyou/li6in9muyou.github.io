---
title: 用Go编写一个解释器 Write an interpreter in go
categories: [Learning]
tags: [chore, compiler, go]
---

**THIS POST IS WORK-IN-PROGRESS**

I am using this book _"Writing An Interpreter In Go"_ by Thorsten Ball. You can but this book at [https://interpreterbook.com/](). In the mean time, I am taking [this free course](https://learning.edx.org/course/course-v1:StanfordOnline+SOE.YCSCS1+3T2020/home) at edx.org.

# Lexer

Lexer and parser have a very common behavior. Both of them will peek one character/token then decide which concrete lexer/tokenizer to use. Some tokens may start with the same character. For example, `let` and `latitude` both starts with character `l` but they are keyword and identifier respectively. So when character `l` is encountered a lexer would try to use a sequence of "sub-lexers" according to some predefined priority. When one "sub-lexer" fails, it tries the next one. An example is given below.

```go
word := lexer.eatWord()

t, err = lexer.tryKeyword(word)
if err == nil {
    return t, err
}

t, err = lexer.tryIdentifier(word)
if err == nil {
    return t, err
}
```

# Parser

A parser parses tokens into abstract syntax trees. Parsing is one of the most well-understood branches of computer science and really smart people have already invested a lot of time into the problems of parsing.

I will implement a "Pratt parser" or "top down operator precedence parser"

## let statement

### steps

1. ensure there is a LET token
2. try parse an identifier
3. ensure there is an equal sign
4. try parse an expression

Steps above closely resemble a let statement literal.
