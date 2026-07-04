---
title: "[게임으로 배우는 파이썬] 튜플"
excerpt: "[게임으로 배우는 파이썬] 튜플"
categories:
  - Python
permalink: /programming/python/72-post/
tags:
  - "Python"
  - "packing"
  - "tuple"
  - "unpacking"
  - "게임으로 배우는 파이썬"
toc: true
toc_sticky: true
date: 2023-08-27
last_modified_at: 2023-08-27
source_url: https://b-note.tistory.com/72
---

<p>튜플은 리스트처럼 배열로 요소를 저장할 수 있다.</p>
<p>요소를 선언할 때는 값을 콤마로 구분해서 저장이 가능하며 이때 소괄호를 사용해서 값을 감싸서 튜플로 표시하는 게 일반적이다.</p>
<pre class="python"><code>&gt;&gt;&gt; tuple_1 = 1, 2, 3
&gt;&gt;&gt; tuple_2 = 4,
&gt;&gt;&gt; tuple_3 = (5, 6, 7)
&gt;&gt;&gt; tuple_1
(1, 2, 3)
&gt;&gt;&gt; tuple_2
(4,)
&gt;&gt;&gt; tuple_3
(5, 6, 7)</code></pre>

<p>이렇게 튜플에 값을 할당하는것을 패킹이라고 한다.</p>

<p>이 튜플은 한 번에 여러 개의 변수에 값을 할당하는 게 가능한데 이것을 언패킹이라고 한다.</p>

<pre class="python"><code>&gt;&gt;&gt; tuple_1 = 4, 5, 6
&gt;&gt;&gt; x, y, z = tuple_1
&gt;&gt;&gt; x, y, z
(4, 5, 6)</code></pre>

<h3>불변성</h3>
<p>튜플이 리스트와 다른 점은 선언된 이후에 값의 수정이 불가능하다.</p>
<pre class="python"><code>&gt;&gt;&gt; tuple_1 = 1, 2, 3
&gt;&gt;&gt; tuple_1[0] = 4
Traceback (most recent call last):
  File "&lt;pyshell#38&gt;", line 1, in &lt;module&gt;
    tuple_1[0] = 4
TypeError: 'tuple' object does not support item assignment
&gt;&gt;&gt; tuple_1 = 4, 5, 6
&gt;&gt;&gt; tuple_1[0]
4
&gt;&gt;&gt;</code></pre>
<p>튜플의 요소에 인덱스로 접근하여 값을 변경하면 에러가 발생하지만 새로 값을 할당하는 것은 문제가 되지 않는다.</p>


<p>이러한 튜플의 특징을 활용해서 런타임에 값이 변하면 안 되는 정보를 저장하거나 또는 하나 이상의 정보가 조합을 이룰 때 의미를 가지는 데이터를 저장할 때 사용된다.</p>

<pre class="python"><code>&gt;&gt;&gt; tuple_1 = 4, 5, 6
&gt;&gt;&gt; x, y, z = tuple_1
&gt;&gt;&gt; x, y, z
(4, 5, 6)
&gt;&gt;&gt; vector3 = (10, 2, -4)
&gt;&gt;&gt; x, y, z = vector3
&gt;&gt;&gt; x
10
&gt;&gt;&gt; y
2
&gt;&gt;&gt; z
-4
&gt;&gt;&gt; x, y, z
(10, 2, -4)</code></pre>


<p>여래 값을 전달할 수 있기 때문에 함수에서 여러 개의 값을 반환하거나 또는 매개변수로 전달이 필요할 때 등 다양하게 활용이 가능하다.</p>
