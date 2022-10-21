---
title: 书单分享项目：设计分析
date: 2022-04-15
categories: [ProjectDesign]
tags: [frontend]
---

> Author's Note: basically nonsense.

小小的视觉组件承担了太多的业务逻辑，这不合理，搞得我的组件不能复用，改逻辑也要到很多个地方去改。

最著名的例子就是一个`checkbox`承担了新建书单的任务。这么一个不起眼的东西不应该包括这么多业务逻辑。

在组件之间传递的：

用户用数字 id，书和书单用类的实例

## `BookListComponent`

### `::Create`

- import `createBookList`, `CurrentUserId`
- `dispatch(created)`

### `::Append`

- `export let thisBookList:BookList, thisBooks:Book[], userId:number`
- import `updateBooksBookList`
- `dispatch(appended)`

### `::Rename`

- `getContext(book_list_name)`
- `dispatch(rename, {new_name, old_name})`

## `BookListComponent::AddToBookList`

- main:
  - `export let thisBook:Book, userId:number`
  - import `fetchBookListsByUserId`

## `BookListComponent::Catalog`

- `main`:

  - import `$CurrentUserId`, `createBookList`, `deleteBookList`, `fetchBookListsByUserId`, `updateBooksBookList`
  - use `<Header/>`, `<Table/>`
  - capture: Header::remove, Table::remove, Header::rename

- `header`
  - use `<Rename/>`
  - `dispatch(remove, {book_list_title:title})`
- `table`
  - `dispatch(remove, {book_id:id})`

## `Libaray`

- `BookBagListing`
  - `getContext(Selected)`: read
  - `dispatch(unselect, { book:Book })`
- `BatchOp`

  - none
  - `dispatch(all)`, `dispatch(reverse)`, `dispatch(clear)`

- `Entry`
  - `getContext("toggle")`: execute , `getContext("Selected")`: read
  - `dispatch(addToList, {book_id:number, book_list_title:string})`
- `Filter`
  - `getContext("Filter")`: write
- `Listing`

  - `export let entries`: read

- `main`
  - capture: unselect, all, reverse, clear
  - import `CurrentUserId`, `fetchAllBooks`

# current design

## `AddToBookListModal`

- use `<PleaseProvideAuth/>`, `<ListUserBookLists/>`, `<CreateBookList/>`

# proposed design

## backend services and models

### Book

`Book`

- id: number
- path: string
- get title()
- get format()

`fetachAllBooks(): Book[]`

`fetachBooksById(number[]) :Book[]`

### Booklist

`BookList`

- `userId: number`
- `title: string`
- `books: number[]`
- `get id()`
- `getBooksInfo Book[]`
- `BookList(userId:number, title:string, books:number[]=[])`
- `static fromPouchDocument({_id:string, createdBy:number, books:number[]})`

`updateBooksBookList(userId:number, title:string, books: number[], shouldInList: boolean)`

`createBookList(userId:number, title:string, books: number[]=[])`

`BookList_create(title:string,books:number[]=[])`

- uses `$CurrentUserId`

`fetchBookListsByUserId(userId:number):BookList[]`

`BookList_removeBooks(bookListId:string, deadBooks:number[])`

`BookList_addBooks(bookListId:string, newBooks:number[])`

`fetchBOokListsContainOneBook(user:number,book:number)`

`fetchUserBookLists(userId:number)`

### User

`checkDisplayNameDoNotExists(displayName:string):boolean`
