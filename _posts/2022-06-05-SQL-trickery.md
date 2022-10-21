---
title: 数据查询习题：用 pandas 解决
date: 2021-08-17
categories: []
tags: [pandas, python, database]
---

## 题目描述

假定你是李明，你拿到一份记录有 123 家企业在 2016~2020 四年期间的销售记录。记录的形式如下：

对每一笔交易，记录企业 id，买家 id，交易发生年份，这样的记录共有 16 万余条，以 csv 格式存储在文件系统中。如下图：

![image-20210817154025740](/assets/blog-images/用python生态的pandas解决一个aggregation需求.assets\image-20210817154025740.png)

李明的任务是对每一家企业`E1, E2, ..., E123`统计与它们合作了 1,2,3,4 年的合作伙伴的数量。结果应类似下图：

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>4</th>
      <th>3</th>
      <th>2</th>
      <th>1</th>
    </tr>
    <tr>
      <th>id</th>
      <th></th>
      <th></th>
      <th></th>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>E47</th>
      <td>80</td>
      <td>107</td>
      <td>160</td>
      <td>420</td>
    </tr>
    <tr>
      <th>E1</th>
      <td>71</td>
      <td>52</td>
      <td>52</td>
      <td>185</td>
    </tr>
    <tr>
      <th>E9</th>
      <td>45</td>
      <td>24</td>
      <td>29</td>
      <td>26</td>
    </tr>
    <tr>
      <th>E2</th>
      <td>43</td>
      <td>123</td>
      <td>275</td>
      <td>1170</td>
    </tr>
    <tr>
      <th>E8</th>
      <td>31</td>
      <td>170</td>
      <td>432</td>
      <td>2098</td>
    </tr>
    <tr>
      <th>...</th>
      <td>...</td>
      <td>...</td>
      <td>...</td>
      <td>...</td>
    </tr>
    <tr>
      <th>E120</th>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>26</td>
    </tr>
    <tr>
      <th>E104</th>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>10</td>
    </tr>
    <tr>
      <th>E115</th>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>4</td>
    </tr>
    <tr>
      <th>E96</th>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>3</td>
    </tr>
    <tr>
      <th>E101</th>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>2</td>
    </tr>
  </tbody>
</table>
<p>123 rows × 4 columns</p>

表格含义解读：`E47`号企业合作了 4 年的合作伙伴有 80 家，而`E101`号企业只有两个刚刚合作一年的伙伴，`E8`则有多达 2000 余家合作了一年的合作伙伴。

## 不太好的思路

一开始我是想先把每个企业每年的合作伙伴都列举出来：

```python
ff.groupby(by=['id', 'yr'])['sold'].unique()
```

<div><pre>
id   yr
E1   2017    [B03711, B00844, B03700, B10763, B00713, B0351...
     2018    [B09944, B03455, B07545, B07664, B07993, B0129...
     2019    [B00385, B00983, B04335, B04337, B03455, B0754...
     2020    [B00812, B00813, B01025, B03199, B03455, B0754...
E10  2016    [B10116, B07899, B00892, B00002, B07900, B0302...
                                   ...
E98  2018     [B03020, B03022, B03805, B03154, B03869, B03518]
     2019    [B04162, B03020, B09633, B10459, B02361, B0277...
     2020                                             [B03022]
E99  2018                                     [B00892, B00637]
     2019                                     [B00892, B03170]
Name: sold, Length: 435, dtype: object
</pre></div>

然后用分治法，先考虑一个企业的记录：

```python
ff.groupby(by=['id', 'yr'])['sold'].unique()\
.loc['E10'].to_frame()['sold']
```

<div><pre>
yr
2016    [B10116, B07899, B00892, B00002, B07900, B0302...
2017    [B00002, B10337, B01616, B00641, B07899, B0089...
2018    [B07693, B01930, B10337, B00697, B00212, B0067...
2019    [B00678, B01930, B03643, B10337, B00685, B0069...
Name: sold, dtype: object
</pre></div>

然后想着把每一行里面的列表拆开，准备等会在用`value_counts`计数每一个的出现次数。

```python
ff.groupby(by=['id', 'yr'])['sold'].unique()\
.loc['E10'].to_frame()['sold']\
.apply(pd.Series).unstack().dropna()
```

```
    yr
0   2016    B10116
    2017    B00002
    2018    B07693
    2019    B00678
1   2016    B07899
    2017    B10337
    2018    B01930
    2019    B01930
...
15  2017    B03643
dtype: object
```

这样合作伙伴代号都拆开了，每一行有一个合作伙伴代号。然后用两次`value_counts`计算出现了 1,2,3,4 次的代号分别有多少个。

```python
ff.groupby(by=['id', 'yr'])['sold'].unique()\
.loc['E10'].to_frame()['sold']\
.apply(pd.Series).unstack().dropna()\
.value_counts().value_counts()
```

<div><pre>1    14
3     6
4     4
2     3
dtype: int64</pre></div>

这样就完成了一个企业的统计，下面把同样的过程应用到每一个 id

```python
ff.groupby(by=['id', 'yr'])['sold'].unique().to_frame()\
.groupby('id').apply(
    lambda tt:tt['sold']\
              .apply(pd.Series).unstack().T\
              .value_counts().value_counts()
).to_frame().unstack()\
.fillna(0).astype(int).droplevel(0, axis='columns')
```

基本上跟单个的时候一致，只有两个区别，apply 的算子接收到的参数类型就是`pd.DataFrame`，而上面`loc`得到的是`pd.Series`，这里就不需要`to_drame`操作了。再有一个是需要用转置换成`pd.Series`后面才能使用`value_counts`。

这种方法是比较慢的，而且也比较不合理，不是正确的 pandas 使用方法。因为使用了比较多的`apply`跟反复两次`to_frame`，应该多使用 pandas 提供的功能。

计时结果如，需要 2 秒余：

```python
%%timeit -n 7 -r 10
ff.groupby(by=['id', 'yr'])['sold'].unique().to_frame()\
.groupby('id').apply(
    lambda tt:tt['sold']\
              .apply(pd.Series).unstack().T\
              .value_counts().value_counts()
).to_frame().unstack().fillna(0).astype(int)\
.droplevel(0, axis='columns')\
.sort_values(by=[4,3,2,1], ascending=False).reindex(columns=[4,3,2,1])

7 loops, best of 10: 2.19 s per loop
```

## 比较好的思路

后来我以年份来考虑

```python
%%timeit -n 7 -r 10
ff.groupby(by=['id', 'sold', 'yr']).size().unstack().fillna(0).astype(bool)\
.apply(lambda row:int(sum(row)), axis=1).astype(int)\
.unstack().fillna(0).T.astype(int)\
.apply(lambda row: row.value_counts()).fillna(0).drop(0, axis='index')\
.astype(int).T.sort_values(by=[4,3,2,1], ascending=False)\
.reindex(columns=[4,3,2,1])

7 loops, best of 10: 474 ms per loop
```

用 SQL 来写

```sql
SELECT
	id,
	ycnt,
	count( 1 ) as pcnt
FROM
	(
	SELECT
		id,
		sold_to,
		sum( yc ) AS ycnt
	FROM
		(
		SELECT
			id,
			sold_to,
			count( 1 ) AS yc
		FROM
			( SELECT DISTINCT id, sold_to, year FROM quiz )
		GROUP BY
			id,
			sold_to,
			year
		)
	GROUP BY
		id,
		sold_to
	)
GROUP BY
	id,
	ycnt
```

效果示例：

| id  | ycnt | pcnt |
| --- | ---- | ---- |
| E1  | 1    | 185  |
| E1  | 2    | 52   |
| E1  | 3    | 52   |
| E1  | 4    | 71   |
