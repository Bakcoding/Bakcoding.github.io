---
title: "[게임으로 배우는 파이썬] 리스트"
excerpt: "[게임으로 배우는 파이썬] 리스트"
categories:
  - Python
permalink: /programming/python/70-post/
tags:
  - "Python"
  - "function"
  - "list"
  - "게임으로 배우는 파이썬"
toc: true
toc_sticky: true
date: 2023-08-25
last_modified_at: 2023-08-25
source_url: https://b-note.tistory.com/70
---

<h3>리스트</h3>
<p>순서를 가지는 객체의 모음이다.</p>
<pre class="ini" style="background-color: var(--bc-code-bg); color: var(--bc-code-text); text-align: start"><code>list_1 = []	# 빈 리스트 	
list_2 = [0, 1] # 정수타입
list_3 = ['a', 'b', 'c'] # 문자타입
list_4 = [0, 1, 'a', 'b'] # 정수와 문자타입
list_5 = [0, ['a', 'b']] # 리스트는 리스트를 요소로 가질 수 있다.</code></pre>

<p>0개 이상의 요소를 콤마로 구분하며 전체 요소는 대괄호로 감싼다.</p>

<p>값을 참조할 때는 대부분의 프로그래밍 언어에서 사용되는 배열과 마찬가지로 인덱스로 접근할 수 있다.</p>

<p>역시 첫 번째 인덱스는 0으로 시작한다.</p>

<pre class="python"><code>&gt;&gt;&gt; list_1 = []
&gt;&gt;&gt; list[0]
Traceback (most recent call last):
  File "&lt;pyshell#1&gt;", line 1, in &lt;module&gt;
    list[0]
TypeError: 'type' object is not subscriptable
# 비어있기 때문에 값을 참조할 수 없다.

&gt;&gt;&gt; list_2[1]
1

&gt;&gt;&gt; list_3 = ['a','b']
&gt;&gt;&gt; list_3[0]
'a'

&gt;&gt;&gt; list_5[1][1]
'b'</code></pre>

<p>리스트 내부에 리스트 요소는 다차원 배열의 접근과 유사하다.</p>

<h3>함수</h3>
<p>리스트는 다양한 함수를 사용해서 다룰 수 있다.</p>


<p><b>append</b></p>
<p>리스트 맨 끝에 요소를 추가한다.</p>
<pre class="python"><code>&gt;&gt;&gt; list_functions = []
&gt;&gt;&gt; list_functions.append('a')
&gt;&gt;&gt; list_functions.append('b')
&gt;&gt;&gt; list_functions
['a', 'b']</code></pre>

<p><b>insert</b></p>
<p>지정한 위치에 요소를 추가할 수 있다.</p>
<pre class="python"><code>&gt;&gt;&gt; list_functions.insert(0, 'aa')
&gt;&gt;&gt; list_functions
['aa', 'a', 'b']
# 지정한 인덱스에 요소가 추가되고 그 뒤로 기존 요소들이 한칸씩 밀린.</code></pre>

<p><b>pop</b></p>
<p>리스트의 마지막 요소를 반환 후 삭제한다.</p>
<pre class="python"><code>&gt;&gt;&gt; list_functions.pop()
'b'
&gt;&gt;&gt; list_functions
['aa', 'a']

# 요소를 반환 후 해당 리스트에는 제거됨</code></pre>

<p>remove</p>
<p>지정한 값과 동일한 요소를 삭제한다.</p>
<pre class="python"><code>&gt;&gt;&gt; list_functions = ['a', 'a', 'b']
&gt;&gt;&gt; list_functions.remove('a')
&gt;&gt;&gt; list_functions
['a', 'b']
# 동일한 요소가 있을 경우 먼저 나오는 요소가 제거된다.</code></pre>

<p><b>index</b></p>
<p>요소의 인덱스를 반환한다.</p>
<pre class="python"><code>&gt;&gt;&gt; list_functions.index('a')
0
&gt;&gt;&gt; list_functions.append('a')
&gt;&gt;&gt; list_functions.index('a')
0
# 동일한 요소가 있을 경우 먼저 나오는 요소의 인덱스를 반환</code></pre>

<p><b>count</b></p>
<p>리스트 내에서 지정한 값과 동일한 요소의 개수를 반환한다.</p>
<pre class="python"><code>&gt;&gt;&gt; list_functions.count('a')
2</code></pre>

<p><b>sort</b></p>
<p>요소들을 정렬한다.&nbsp;</p>
<pre class="python"><code>&gt;&gt;&gt; list_char = ['d', 'a', 'e', 'c', 'b']
&gt;&gt;&gt; list_int = [3, 2, 5, 4, 1]
&gt;&gt;&gt; list_char.sort()
&gt;&gt;&gt; list_int.sort()
&gt;&gt;&gt; list_char
['a', 'b', 'c', 'd', 'e']
&gt;&gt;&gt; list_int
[1, 2, 3, 4, 5]</code></pre>
<p>오름차순으로 정렬되는 것으로 보이지만 정확하게는 기본값이 오름차순이고 이는 함수의 매개변수를 통해 설정가능하다.</p>
<pre class="python"><code>&gt;&gt;&gt; list_char_inc = ['d', 'a', 'e', 'c', 'b']
&gt;&gt;&gt; list_char_dec = ['d', 'a', 'e', 'c', 'b']
&gt;&gt;&gt; list_char_inc.sort(reverse=False) # defualt가 False이기 때문에 매개변수가 없으면 오름차순
&gt;&gt;&gt; list_char_dec.sort(reverse=True)
&gt;&gt;&gt; list_char_inc
['a', 'b', 'c', 'd', 'e']
&gt;&gt;&gt; list_char_dec
['e', 'd', 'c', 'b', 'a']</code></pre>

<p><b>reverse</b></p>
<p>요소들을 역순으로 정렬한다.</p>
<pre class="python"><code>&gt;&gt;&gt; list_char = ['d', 'a', 'e', 'c', 'b']
&gt;&gt;&gt; list_char.reverse()
&gt;&gt;&gt; list_char
['b', 'c', 'e', 'a', 'd']</code></pre>

<p><b>clear</b></p>
<p>리스트의 요소를 모두 제거한다.</p>
<pre class="python"><code>&gt;&gt;&gt; list_clear = [1, 2, 3, 4, 5, 6]
&gt;&gt;&gt; list_clear
[1, 2, 3, 4, 5, 6]
&gt;&gt;&gt; list_clear.clear()
&gt;&gt;&gt; list_clear
[]</code></pre>
