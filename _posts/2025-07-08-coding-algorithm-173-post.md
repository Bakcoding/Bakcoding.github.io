---
title: "시간 복잡도"
excerpt: "시간 복잡도"
categories:
  - Algorithm
permalink: /coding/algorithm/173-post/
tags:
  - "Algorithm"
  - "time-complexity"
  - "빅-세타"
  - "빅-오"
  - "빅-오메가"
  - "시간 복잡도"
toc: true
toc_sticky: true
date: 2025-07-08
last_modified_at: 2025-07-08
source_url: https://b-note.tistory.com/173
---

<h3>시간 복잡도(Time Complexity)</h3>
<p>시간 복잡도는 알고리즘이 입력 코기(n)에 따라 얼마나 많은 연산을 수행하는지를 수학적으로 표현한 것이다.</p>
<p>보통 알고리즘의 효율성과 실행 속도를 평가하기 위해 사용된다.</p>

<p>시간 복잡도는 주로 세 가지 표기법으로 분류된다.</p>

<p><b>빅-오(Big-O)</b></p>
<p>최악의 경우(Worst Case)를 나타내며, 가장 많이 사용되는 표기법이다. 알고리즘이 가장 오래 걸리는 상황에서의 연산 횟수를 설명한다.</p>

<p><b>빅-오메가(Big-&Omega;)</b></p>
<p>최선의&nbsp;경우(Best&nbsp;Case)&nbsp;를&nbsp;나타내며,&nbsp;가장&nbsp;적게&nbsp;걸리는&nbsp;상황에서의&nbsp;연산&nbsp;횟수를&nbsp;설명한다.</p>

<p><b>빅-세타(Big-&Theta;)</b></p>
<p>상한과 하한이 같을 때 사용되며, 정확한 수행 시간을 나타낸다.</p>

<h4>예시</h4>
<p>다음은 1~100 사이에서 무작위 숫자를 뽑고, 해당 숫자를 찾을 때까지 순회하는 알고리즘이다.</p>

<pre class="python"><code>import random

randNumber = random.randrange(1, 101)

for i in range(1, 101):
    if i == randNumber:
        print(i)
        break</code></pre>

<p><b>Best Case</b></p>
<p>뽑은 숫자가 1일 경우, 단 1번만에 찾는다 &rarr; &Omega;(1)</p>

<p><b>Average Case</b></p>
<p style="color: #333333; text-align: start;">1 일 때 1번</p>
<p style="color: #333333; text-align: start;">2 일 때 2번</p>
<p style="color: #333333; text-align: start;">...</p>
<p style="color: #333333; text-align: start;">n 일 때 n번</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">전체 평균 횟수를 계산하면 1 + 2 + ... + n으로 등차수열을 계산하면 n(n + 1) / 2, 이는&nbsp;입력&nbsp;크기&nbsp;n이&nbsp;커질수록&nbsp;선형적으로&nbsp;증가하므로,&nbsp;Average&nbsp;Case는&nbsp;O(n)으로&nbsp;표현한다.</p>

<p><b>Worst Case</b></p>
<p>뽑은&nbsp;숫자가&nbsp;100일&nbsp;경우,&nbsp;100번&nbsp;순회&nbsp;&rarr;&nbsp;O(n)</p>
