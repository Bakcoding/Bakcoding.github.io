---
title: "O(n!) - 팩토리얼 시간"
excerpt: "O(n!) - 팩토리얼 시간"
categories:
  - Algorithm
permalink: /coding/algorithm/175-o-n/
tags:
  - "Algorithm"
  - "o(n!)"
  - "TSP"
  - "브루트포스"
  - "순열"
  - "외판원 문제"
toc: true
toc_sticky: true
date: 2025-07-08
last_modified_at: 2025-07-08
source_url: https://b-note.tistory.com/175
---

<h2>O(n!) - 팩토리얼 시간</h2>
<p>주어진 배열의 원소들을 가능한 모든 순서로 배열하는 것을 순열 생성의 모든 경우의 수이다. <span style="color: #333333; text-align: start;">여기서 순열은 일반적인 순열인 직순열로 일직선상의 배열이다.</span></p>

<p>이러한 연산에서 n개 원소는 n! 개의 순열이 존재하고, 각 순열을 생성하는 데 걸리는 시간을 포함한 전체 시간 복잡도는 n! * n = O(n!)이다.</p>

<h3>순열 생성</h3>
<p>배열 [1, 2, 3]가 있을 때, 가능한 모든 순열은 다음과 같다.</p>

<p>[1, 2, 3], [1, 3, 2],</p>
<p>[2, 1, 3], [2, 3, 1],</p>
<p>[3, 1, 2], [3, 2, 1]</p>

<p>총 3! = 6가지 경우가 존재한다.</p>

<p>코드로 표현하면 다음과 같다.</p>
<pre class="python" style="background-color: #f8f8f8; color: #383a42; text-align: start;"><code>def permutations(arr):
    if len(arr) &lt;= 1:
        return [arr]
    result = []
    for i in range(len(arr)):
        # ':' 슬라이싱, :끝 : 처음부터 끝 인덱스 바로 전까지(끝 비포함), 시작: : 시작 인덱스부터 끝까지
        # =&gt; :i i인덱스를 제외한 그 앞의 집합, i+1: 다음 인덱스까지의 집합, 길이 초과하는 경우 빈 배열
        rest = arr[:i] + arr[i+1:] 
        for p in permutations(rest): # 
            result.append([arr[i]] + p) # append : 리스트 객체 맨 끝에 새로운 요소 추가
    return result

print(permutations([1, 2, 3]))

"""
[[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]]
"""</code></pre>
<p><br />1. 하나의 인덱스를 고정한다.</p>
<p>2. 나머지 요소들의 순열을 재귀적으로 구한다.</p>
<p>3. 그 앞에 고정 요소를 붙여서 순열을 구성한다.</p>

<p>이 방식은 재귀 호출마다 n-1개의 원소로 순열을 생성하며, 전체 시간 복잡도는 O(n!)이다.</p>

<h3>외판원 문제(TSP, Travelling Salesman Problem)</h3>
<p>외판원이 n개의 도시를 모두 방문하고 출발점으로 돌아오는 최단 경로를 찾는 문제이다.</p>
<p>NP-hard 문제의 대표적인 예시로 자주 사용된다.</p>

<p><b>조건</b></p>
<p>- 각 도시는 정확히 한 번씩만 방문한다.</p>
<p>- 모든 도시 간의 거리가 주어진다.</p>

<p>이 문제는 다양한 해결법이 존재하지만 그중에서 브루트포스 접근법이 O(n!)의 시간 복잡도를 가진다.</p>

<p><b>브루트포스</b></p>
<p>4개 도시 A, B, C, D가 있을 때, 가능한 모든 경로를 확인한다.</p>
<p>A -&gt; B -&gt; C -&gt; D -&gt; A</p>
<p>A -&gt; B -&gt; D -&gt; C -&gt; A</p>
<p>...</p>

<p>다시 출발점으로 돌아오기 때문에 원순열로 취급할 수 있어 <span style="color: #333333; text-align: start;">시작점을 A로 고정하고 모든 경로를 구한다.</span></p>
<p>나머지 n-1개 도시의 순열을 구한다. (n-1)!</p>
<p>4개 도시 -&gt; (4 - 1)! = 6가지</p>

<pre class="python"><code>import itertools

def tsp_bruteforce(distance):
    # distance : 2D 배열, distance[i][j] : 도시 i에서 j로의 거리
    n = len(distance)
    cities = list(range(1, n)) # 시작 도시(0번)를 고정한 상태에서 나머지 도시의 순열을 생성

    min_cost = float('inf')
    best_path = None

	# itertools.permutations : 순열을 생성해준다.
    # 내부적으로 최적화가 잘되어있어 메모리 효율이 좋다. 시간복잡도는 그대로 O(n!)
    for path in itertools.permutations(cities):
        current_cost = 0
        current_city =0

        for next_city in path:
            current_cost += distance[current_city][next_city]
            current_city = next_city

        current_cost += distance[current_city][0]

        if current_cost &lt; min_cost:
            min_cost = current_cost
            best_path = [0] + list(path) + [0]

    return min_cost, best_path

distance = [
    [0, 10, 15, 20],
    [10, 0, 35, 25],
    [15, 35, 0, 30],
    [20, 25, 30, 0]
]

city_names = ["A", "B", "C", "D"]

cost, path = tsp_bruteforce(distance)
print(f"Min cost : {cost}")
print(f"Best path : {path}")

named_path = ' -&gt; '.join(city_names[i] for i in path)
print(f"Best path : {named_path}")

"""
Min cost : 80
Best path : [0, 1, 3, 2, 0]
Best path : A -&gt; B -&gt; D -&gt; C -&gt; A
"""</code></pre>

<p><b>순열생성</b></p>
<p>O((n-1)!), n-1개 도시의 모든 순열 생성&nbsp;</p>

<p><b>각 경로 비용 계산</b></p>
<p>O(n), 각 순열마다 n개 도시를 거쳐가는 비용 계산</p>

<p><b>전체 시간복잡도</b></p>
<p>O(n * (n-1)!) = O(n!)</p>

<p>브루트포스의 가장 큰 문제점은 도시의 수가 조금만 늘어나도 실행 시간이 급격하게 증가하여 계산이 불가능해진다.</p>

<p><b>계산 시간 테스트 코드</b></p>
<p>도시의 개수를 추가하고 경과시간을 체크해 본다.</p>
<pre class="python"><code>import time
import itertools
import random

def generate_distance_matrix(n):
    matrix = [[0]*n for _ in range(n)]
    for i in range(n):
        for j in range(i+1, n):
            dist = random.randint(1, 99)
            matrix[i][j] = dist
            matrix[j][i] = dist
    return matrix

def tsp_bruteforce(distance):
    n = len(distance)
    cities = list(range(1, n))

    min_cost = float('inf')
    best_path = None

    for path in itertools.permutations(cities):
        current_cost = 0
        current_city = 0

        for next_city in path:
            current_cost += distance[current_city][next_city]
            current_city = next_city

        current_cost += distance[current_city][0]

        if current_cost &lt; min_cost:
            min_cost = current_cost
            best_path = [0] + list(path) + [0]

    return min_cost, best_path

# 테스트 도시 수: 4 ~ 10
for n in range(4, 11):
    print(f"\n=== TSP for {n} cities ===")
    distance = generate_distance_matrix(n)

    start = time.perf_counter()
    cost, path = tsp_bruteforce(distance)
    end = time.perf_counter()
    elapsed = end - start

    print(f"Min cost: {cost}")
    print(f"Best path (index): {path}")
    print(f"Elapsed time: {elapsed:.6f} seconds")

"""
=== TSP for 4 cities ===
Min cost: 209
Best path (index): [0, 1, 2, 3, 0]
Elapsed time: 0.000019 seconds

=== TSP for 5 cities ===
Min cost: 167
Best path (index): [0, 2, 1, 3, 4, 0]
Elapsed time: 0.000019 seconds

=== TSP for 6 cities ===
Min cost: 159
Best path (index): [0, 3, 1, 2, 5, 4, 0]
Elapsed time: 0.000077 seconds

=== TSP for 7 cities ===
Min cost: 186
Best path (index): [0, 5, 2, 1, 4, 3, 6, 0]
Elapsed time: 0.000502 seconds

=== TSP for 8 cities ===
Min cost: 161
Best path (index): [0, 3, 1, 2, 4, 6, 7, 5, 0]
Elapsed time: 0.019747 seconds

=== TSP for 9 cities ===
Min cost: 172
Best path (index): [0, 4, 5, 8, 2, 7, 3, 1, 6, 0]
Elapsed time: 0.157354 seconds

=== TSP for 10 cities ===
Min cost: 236
Best path (index): [0, 2, 3, 6, 1, 9, 4, 5, 8, 7, 0]
Elapsed time: 1.502671 seconds
"""</code></pre>

<p>10개까지의 테스트는 실행이 되었지만 테스트를 위해 사용한 웹 컴파일러는 15초 이상의 작업은 실패로 처리하는데 11개의 도시 테스트에서 실패로 처리되었다.</p>

<p>수치를 추정해 보면,</p>
<p>10개의 도시인 경우 10! = 3,628,800개의 경우의 수를 처리하는데 1.5초의 소요 시간이 걸렸다.</p>
<p>11개의 도시는 11! = 39,916,800개로 약 11배가 증가했으므로 추정 소요 시간은 16.5초로 예상된다.</p>
<div>
<table style="border-collapse: collapse; width: 100%;" border="1" data-end="1220" data-start="993">
<tbody>
<tr>
<td><span style="color: #333333; text-align: start;">도시<span>&nbsp;수</span></span></td>
<td>순열 수</td>
<td>예상 시간 (초)</td>
</tr>
<tr data-end="1084" data-start="1060">
<td data-col-size="sm" data-end="1065" data-start="1060">10</td>
<td data-end="1077" data-start="1065" data-col-size="sm">3,628,800</td>
<td data-end="1084" data-start="1077" data-col-size="sm">1.5</td>
</tr>
<tr data-end="1111" data-start="1085">
<td data-col-size="sm" data-end="1090" data-start="1085">11</td>
<td data-end="1103" data-start="1090" data-col-size="sm">39,916,800</td>
<td data-end="1111" data-start="1103" data-col-size="sm">16.5</td>
</tr>
<tr data-end="1150" data-start="1112">
<td data-col-size="sm" data-end="1117" data-start="1112">12</td>
<td data-end="1131" data-start="1117" data-col-size="sm">479,001,600</td>
<td data-end="1150" data-start="1131" data-col-size="sm">198+ 초 (약 3.3분)</td>
</tr>
<tr data-end="1184" data-start="1151">
<td data-col-size="sm" data-end="1156" data-start="1151">13</td>
<td data-end="1172" data-start="1156" data-col-size="sm">6,227,020,800</td>
<td data-end="1184" data-start="1172" data-col-size="sm">약 27~30분</td>
</tr>
<tr data-end="1220" data-start="1185">
<td data-col-size="sm" data-end="1190" data-start="1185">14</td>
<td data-end="1207" data-start="1190" data-col-size="sm">87,178,291,200</td>
<td data-end="1220" data-start="1207" data-col-size="sm">5시간 이상</td>
</tr>
</tbody>
</table>
<div>
<div>&nbsp;</div>
<div>사용법은 간단하지만 한계가 명확하기 때문에 실용적이지 않아 다른 효율적인 방법으로 대체된다.</div>
<div>&nbsp;</div>
<div><b>동적 계획법 (O(n^2 * 2^n)</b>)</div>
<div>정확한 해를 구할 수 있는 방법으로, 방문 상태를 비트마스크로 표현하여 중복 계산을 줄인다.</div>
<div>&nbsp;</div>
<div><b>근사 알고리즘(다항시간)</b></div>
<div>최적 해는 아니지만, 일정한 오차 범위 내에서 빠르게 좋은 해를 보장한다.</div>
<div>대표적으로 MST 기반 알고리즘이 있다.</div>
<div>&nbsp;</div>
<div><b> 휴리스틱 기법</b></div>
<div>엄밀한 최적 보장은 없지만, 실제 환경에서 유용하게 사용된다.&nbsp;</div>
<div>유전 알고리즘(GA)이나 시뮬레이티드 어닐링(SA)들이 이에 해당한다.</div>
</div>
</div>
