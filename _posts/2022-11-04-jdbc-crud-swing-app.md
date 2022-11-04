---
title: 用swing开发数据库CRUD应用。Build a CRUD app with JDBC and swing
categories: [ProjectExperience]
tags: [java, database, jdbc, gui, swing]
---

# 怎么连接到 vmware 虚拟机中的 DB2 数据库？

客户机应该使用 NAT 网络模式，在笔者的这个环境中，不能使用 Bridge 模式，因为没有 IP 会被分配给虚拟机。
此 NAT 模式下，宿主机的一个网卡接口和客户机的一个网卡接口是在同一个子网。

1. 在虚拟机中用`ipconfig`命令查看虚拟机的 ip 地址。
2. 使用此地址和 50000 端口号来连接此数据库。

# 怎么让宿主机中的 java 程序连接到虚拟机中的数据库？

原资料中的连接方法使用的是 DB2 数据库的 type 2 JDBC 驱动，在宿主机上使用 type 4 JDBC 驱动比较方便。
这两中驱动的主要区别是 type 2 驱动依赖于操作系统的原生二进制，type 4 则不需要，因其纯 Java 实现。
这几种驱动的说明见[此链接](https://www.ibm.com/docs/en/db2/9.7?topic=apis-supported-drivers-jdbc-sqlj)。

1. 从 maven 仓库中，安装 `com.ibm.db2.jcc:db2jcc:db2jcc4` 库。
2. 在 java 程序中载入 `com.ibm.db2.jcc.DB2Driver` 驱动类。
3. 用`DriverManager.getConnection("jdbc:db2://<ip addr>:50000/sample", "<user name>", "<user password>")`得到一个`Connection`类实例。

注意，在源码中写入用户名，用户密码，和数据库主机地址是非恶劣的行为。
比较好的在各编程语言生态中通行的做法是从环境变量中引入这些秘密的值。Java 生态中还有其他的引入秘密的方法。
