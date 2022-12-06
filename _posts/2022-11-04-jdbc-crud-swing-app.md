---
title: 用swing开发数据库CRUD应用。Build a CRUD app with JDBC and swing
categories: [ProjectExperience]
tags: [java, database, jdbc, gui, swing]
mermaid: true
---

仓库地址：[github.com/li6in9muyou/SwingDbCrudApp](https://github.com/li6in9muyou/SwingDbCrudApp)

# 将程序调试过程中遇到的典型错误列出

## `ArrayStoreException` is thrown when putting `java.sql.Date` into an `Object[]`

Cause: `Object[] objects = new String[colCount];`

Solution:
[commit](https://github.com/li6in9muyou/SwingDbCrudApp/commit/9240a4af)
`Object[] objects = new Object[colCount];`

## custom table cell renderer is not used

Cause: class parameter in `setDefaultRenderer` is not generic enough

Solution:
[commit](https://github.com/li6in9muyou/SwingDbCrudApp/commit/885adbe)
change `setDefaultRenderer(String.class, ...)` to `setDefaultRenderer(Object.class, ...)`

## after reset local tracking branch to HEAD~N, force pushing to remote is rejected

Cause: IDE forbids me from doing this not git.

Solution: `git push --force`.

## Selected rows background are all white

Expected: blue background, appropriate foreground color for reading.

## Many cells are unexpectedly painted with highlight color for NULLs and empty strings

Expected: Normal cells background alternates between two colors according to row index and
turns blue on focus

Cause: The same renderer is used to paint many cells. If its internal state is changed
when rendering one cell, all cells after that is affected.

Solution:
[commit](https://github.com/li6in9muyou/SwingDbCrudApp/commit/9e848fa7)
Create a class that implements `TableCellRenderer` and holds reference to a
`DefaultTableCellRenderer`. It should return itself if some cell needs special treatment, otherwise
return that referenced default renderer.

Remarks: `TableModel` in `JTable` can be strongly typed however `DefaultTableModel` see all
data as `Object`s. To use type specific renderer, one must override `getColumnClass()` in
a `TableModel`.

# 怎么连接到 vmware 虚拟机中的 DB2 数据库？

客户机应该使用 NAT 网络模式，在笔者的这个环境中，不能使用 Bridge 模式，因为没有 IP 会被分配给虚拟机。
此 NAT 模式下，宿主机的一个网卡接口和客户机的一个网卡接口是在同一个子网。

1. 在虚拟机中用`ipconfig`命令查看虚拟机的 ip 地址。
2. 使用此地址和 50000 端口号来连接此数据库。

# 怎么让宿主机中的 java 程序连接到虚拟机中的数据库？

原资料中的连接方法使用的是 DB2 数据库的 type 2 JDBC 驱动，在宿主机上使用 type 4 JDBC 驱动比较方便。
这两中驱动的主要区别是 type 2 驱动依赖于操作系统的原生二进制，type 4 则不需要，因其纯 Java 实现。
这几种驱动的说明见[此链接](https://www.ibm.com/docs/en/db2/9.7?topic=apis-supported-drivers-jdbc-sqlj)。

1. 用你最喜欢的依赖管理器，从 maven 仓库中安装 `com.ibm.db2.jcc:db2jcc:db2jcc4` 库。
2. 在 java 程序中载入 `com.ibm.db2.jcc.DB2Driver` 驱动类。
3. 用`DriverManager.getConnection("jdbc:db2://<ip addr>:50000/sample", "<user name>", "<user password>")`
   得到一个`Connection`类实例。

注意，在源码中写入用户名，用户密码，和数据库主机地址是非常非常恶劣的行为。
比较好的在各编程语言生态中通行的做法是从环境变量中引入这些秘密的值。Java 生态中还有其他的引入秘密的方法。

# 怎么显示详细的出错信息

先尝试在 JDBC 连接字符串中设置 `retrieveMessagesFromServerOnGetMessage` 属性为真，
此后，捕获到 JDBC 驱动抛出的异常时，使用 `getMessage()` 就可以得到详细的错误说明。

示例如下：

```java
public static class Program {
  private final static Connection con = DriverManager.getConnection(
    "jdbc:db2://192.168.245.128:50000/sample:" +
      "retrieveMessagesFromServerOnGetMessage=true;",
    "student",
    "student"
  );
}
```

如果显示的不是中文，则需使用如下方法，手动查询中文简体字的错误说明。也许可以在数据库后台设置本地化策略集为中文简体以免去
下面描述的步骤。

1. 捕获 JDBC 驱动抛出的异常。
2. 强制将此异常类型转换为 `com.ibm.db2.jcc.DB2Diagnosable`，再调用 `getSqlca()` ，得到一个 `DB2Sqlca` 对象。
3. 作如下查询，查询字符串为 `values (sysproc.SQLERRM(?, ?, ';', 'zh_CN', 1))`，第一参数设置为字符串
   `"SQL%s".formatted(Math.abs(sqlca.getSqlCode()))`，第二参数设置为`sqlca.getSqlErrmc()`

示例如下：

```java
public static class Program {
  private final static Connection con;

  public String fetchErrorMessage(Throwable error) {
    // CAUTION! sqlca may be null due to run-time cast.
    DB2Sqlca sqlca = ((DB2Diagnosable) error).getSqlca();
    PreparedStatement query = con.prepareStatement(
      "values (sysproc.SQLERRM(?, ?, ';', 'zh_CN', 1))"
    );
    query.setString(1, "SQL" + Math.abs(sqlca.getSqlCode()));
    query.setString(2, sqlca.getSqlErrmc());
    ResultSet rs = query.executeQuery();
    rs.first();
    return rs.getString(1);
  }
}
```

关于这种做法的详细说明见
[Handling an SQLException under the IBM Data Server Driver for JDBC and SQLJ](https://www.ibm.com/docs/en/db2/9.7?topic=ewudsdjs-handling-sqlexception-under-data-server-driver-jdbc-sqlj)
。

---

# TODO

本节内容正在迁移到[GitHub Issues 页面](https://github.com/li6in9muyou/SwingDbCrudApp/issues)。

- [x] 即使在程序启动时连接数据库失败，也要能够提示连接失败并让用户可以重试。

- [x] `Fetch` 中的修改数据库状态的各方法用模版方法模式重构，主要是为了保证将缓存设置为失效。

- [x] `Fetch` 中发送请求的的各方法用模版方法模式重构，主要是为了处理异常和警告。

- [ ] 显示跟查询命令关联的警告，比如删除时指定的谓词查询不到任何行。

- [ ] 改各功能暂存区的文本框为 `JTable`。

- [ ] `Fetch::createRows()` 里面硬编码了 employee 表的元数据，要查看其他数据表时该怎么办？

- [ ] `TableModel`、`Fetch`中的缓存究竟该用什么类型？怎么处理这两处地方和数据表这三处地方类型转换？

- [ ] 新功能：重置已经暂存了的单元格的修改。

- [ ] 编译为 WASM 使之能够运行在浏览器中，能否在 Azure 上部署类似的数据库实例？。

- [x] 修正：批处理的查询出错时，不能显示详细的错误信息。

- [ ] 增强：强力区分处理 `Fetch` 中的 SQL 异常和 Java 异常，Java 异常的 errorMessage
      并不十分有描述性，必须带上`error.toString()`。

- [ ] 修正：创建多行时若日期类型的列以空字符串为参数，在`Fetch::fetchErrorMessage`中，`Db2Diagnosable::getSqlca`
      会返回 `null`。

# Multimedia queries

- [ ] 功能：切换数据表，处理原硬编码的仅适用于 employee 表的代码。

- [ ] 重构：如何修改能使代码适应面向多媒体数据的表查询？
