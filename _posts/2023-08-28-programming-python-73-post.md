---
title: "[게임으로 배우는 파이썬] 딕셔너리"
excerpt: "[게임으로 배우는 파이썬] 딕셔너리"
categories:
  - Python
permalink: /programming/python/73-post/
tags:
  - "Python"
  - "dictionary"
  - "게임으로 배우는 파이썬"
toc: true
toc_sticky: true
date: 2023-08-28
last_modified_at: 2023-08-28
source_url: https://b-note.tistory.com/73
---

<p>딕셔너리는 해시 테이블 또는 키, 밸류라고 부른다.&nbsp;</p>
<p>데이터는 중괄호 안에 선언되며 키와 밸류는 콜론으로 구분된다.</p>

<pre class="python"><code>&gt;&gt;&gt; dic_1 = {"key_1": 'value_1', 'key_2':"value_2"}
&gt;&gt;&gt; dic_1["key_1"]
'value_1'
&gt;&gt;&gt; dic_1['key_1']
'value_1'
&gt;&gt;&gt; dic_1["key_2"]
'value_2'</code></pre>
<p>키는 큰 따옴표 또는 작은따옴표를 사용해 선언할 수 있다.</p>
<p>키값의 경우 보통 문자열, 숫자, 튜플 등이 사용되고 밸류에는 어떠한 데이터 타입도 사용할 수 있다.&nbsp;</p>

<p>딕셔너리의 특징은 맵 형식이기 때문에 순서가 보장되지 않는다. 따라서 인덱스를 통한 요소의 접근이나 첫 번째, 마지막 등의 순서가 필요한 정보에 대해서는 접근이 불가능하며 키값을 사용해서 접근해 사용한다.</p>

<pre class="python"><code>&gt;&gt;&gt; dic_1[0]
Traceback (most recent call last):
  File "&lt;pyshell#9&gt;", line 1, in &lt;module&gt;
    dic_1[0]
KeyError: 0</code></pre>

<p>중복된 이름의 키를 사용하게 될 경우 에러는 발생하지 않지만 앞에 선언된 키, 밸류가 뒤에 값으로 덮어씌워진다.</p>

<pre class="python"><code>&gt;&gt;&gt; dic_2 = {'key_1':'val_1','key_1':'val_2'}
&gt;&gt;&gt; dic_2['key_1']
'val_2'
&gt;&gt;&gt; len(dic_2)
1</code></pre>
<p>딕셔너리의 요소 개수를 반환하는 함수인 len()을 사용하면 앞에 선언된 요소가 존재하지 않는걸 알 수 있다.</p>
