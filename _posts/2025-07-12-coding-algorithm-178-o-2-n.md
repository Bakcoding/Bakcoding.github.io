---
title: "O(2^n) - 지수 시간"
excerpt: "O(2^n) - 지수 시간"
categories:
  - Algorithm
permalink: /coding/algorithm/178-o-2-n/
tags:
  - "Algorithm"
toc: true
toc_sticky: true
date: 2025-07-12
last_modified_at: 2025-07-12
source_url: https://b-note.tistory.com/178
---

<h2>O(2^n)&nbsp;-&nbsp;지수&nbsp;시간</h2>
<p>O(n!) 시간 복잡도처럼, 지수 시간 복잡도 또한 입력 크기가 조금만 커져도 실행 시간이 급격히 증가하는 대표적인 비효율적인 복잡도이다. 특히, 모든 가능한 경우의 수를 탐색해야 하는 문제에서 자주 나타난다.</p>

<h3>부분 집합 생성</h3>
<p>집합 [1, 2, 3]이 있을 때, 모든 부분 집합의 개수는 2^3 = 8개이다.</p>

<pre class="python"><code>def subsets(arr):
    if not arr:
        return [[]]

    first = arr[0]
    rest_subsets = subsets(arr[1:])

    # 기존 부분집합들 + first를 포함한 새로운 부분집합들
    return rest_subsets + [[first] + subset for subset in rest_subsets]

print(subsets([1,2,3]))

"""
[[], [3], [2], [2, 3], [1], [1, 3], [1, 2], [1, 2, 3]]
"""</code></pre>

<p>1. 재귀를 사용해서 주어진 리스트의 모든 가능한 부분 집합을 생성한다.</p>
<p>재귀 호출의 종료 조건은 입력 리스트가 비어있어 더 이상 처리할 요소가 없으면 빈 리스트를 반환하여 공집합이 모든 집합의 부분집합이 되는 규칙을 반영한다.</p>

<p>2. 현재 리스트에서 첫 번째 요소를 분리하고, 나머지 요소를 처리하는 하위 문제로 분할한다.</p>
<p>첫 번째 요소를 제외한 나머지 리스트의 모든 부분집합을 재귀적으로 구한다.</p>

<p>3. 재귀적으로 얻은 나머지 요소들의 부분집합을 기반으로 최종 부분집합들을 조합한다.</p>
<p>first를 포함하지 않는 부분집합과 포함하는 부분집합 두 그룹을 반환한다.</p>


<p><span><span>subsets([1, 2, 3]) </span></span></p>
<p><span>├── first = 1 </span></p>
<p><span>├── rest_subsets = subsets([2, 3]) </span></p>
<p><span> │&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ├── first = 2 </span></p>
<p><span> │&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ├── rest_subsets = subsets([3]) </span></p>
<p><span> │&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;│&nbsp; &nbsp; &nbsp; &nbsp;├── first = 3</span></p>
<p><span> │&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;│&nbsp; &nbsp; &nbsp; &nbsp;├── rest_subsets = subsets([]) &rarr; [[]] </span></p>
<p><span> │&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;│ &nbsp; &nbsp; &nbsp; └── return [[], [3]]</span></p>
<p><span> │&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;└── return [[], [3], [2], [2, 3]] </span></p>
<p><span>└── return [[], [3], [2], [2, 3], [1], [1, 3], [1, 2], [1, 2, 3]]</span></p>

<p>- n개 원소의 부분집합 개수 2^n개</p>
<p>- 각 원소마다 포함 또는 비포함 2가지 선택</p>
<p>- 재귀 호출 2^n번 발생</p>

<p>부분집합을 구하는 방식은 비트마스킹을 사용하여 재귀 없이 반복문과 비트 연산으로 더 효율적으로 생성할 수 있다.</p>

<pre class="python"><code>def subsets_bitmask(arr):
    n = len(arr)
    result = []
    
    for i in range(2**n):  # 0부터 2^n-1까지
        subset = []
        for j in range(n):
            if i &amp; (1 &lt;&lt; j):  # j번째 비트가 1이면
                subset.append(arr[j])
        result.append(subset)
    
    return result
# 시간복잡도: O(2^n * n) &mdash; 모든 부분집합을 순회하며 최대 n개의 요소를 확인
print(subsets_bitmask([1, 2, 3]))

"""
[[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3]]
"""</code></pre>

<h3>피보나치수열(비효율적 재귀)</h3>
<p>&nbsp;피보나치수열은 첫째 및 둘째 항은 1로 고정되고 그 뒤의 모든 항은 바로 앞 두 항의 합으로 이루어진 수열이다.</p>
<p>입력을 받아서 해당 순서에 들어오는 수를 출력하는 코드를 만들어 본다.</p>

<pre class="python"><code>def fibonacci(n):
    if n &lt;= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# 호출 예시
print(fibonacci(5)) 

"""
5
"""</code></pre>

<p>시간 복잡도는 O(2^n)이며 재귀호출로 인한 중복 호출이 많이 발생하게 된다.</p>
<p><span style="color: #333333; text-align: start;">n = 5일 때,<span>&nbsp;</span></span></p>
<p>finbonacci(3) : 2번</p>
<p>finbonacci(2) : 3번</p>
<p>finbonacci(1) : 5번</p>
<p>finbonacci(0) : 3번</p>

<p>이러한 중복을 대처하기 위해 효율적인 대안으로 동적 계획법이나 메모이제이션으로 O(n)으로 개선이 가능하다.</p>

<h3>조합 탐색 (<span style="color: #333333; text-align: start;">DFS/백트래킹<span> 기반)</span></span><span style="color: #333333; text-align: start;"><span></span></span></h3>
<p>n개의 원소 중에서 순서에 상관없이 R개를 뽑는 모든 조합을 탐색한다.</p>
<p>- DFS : 깊이 우선 탐색</p>
<p>- 백트래킹 : 모든 경우의 수를 탐색하면서 가능성이 없는 분기는 중단하고 되돌아가는 기법</p>

<pre class="python"><code>def dfs(arr, path, start, r):
    if len(path) == r:
        print(path)
        return
    for i in range(start, len(arr)):
        dfs(arr, path + [arr[i]], i + 1, r)

dfs([1, 2, 3, 4], [], 0, 2)

"""
[1, 2]
[1, 3]
[1, 4]
[2, 3]
[2, 4]
[3, 4]
"""</code></pre>

<p>주어진 배열(arr)에서 r개의 원소를 선택하는 모든 조합을 찾는다.</p>
<p>선택한 원소보다 뒤에 있는 원소들만 탐색하여 중복 선택을 방지하고 순서를 고려하지 않는 조합의 특성을 구한다.</p>

<p>조합의 수는 C(n, r)로 최대 O(2^n)이 된다. 백트래킹의 경우 조건에 따라 일부 경로는 생략 가능해서 효율은 개선되지만 최악의 경우는 여전히 O(2^n)이다.</p>

<h3>동적 계획법</h3>
<h4 style="color: #000000; text-align: start;">Top-Down</h4>
<p>큰 문제를 작은 하위 문제로 쪼개면서 재귀적으로 호출한다.</p>
<p>이미 계산한 하위 문제의 결과는 메모이제이션을 통해 저장하여 중복 호출을 방지한다.</p>
<p>재귀 호출 중에 처음 계산되는 하위 문제만 실제 계산되고, 이후에는 저장된 값을 재사용한다.</p>

<pre class="python"><code>def fibonacci_memo_top_down(n, memo=None):
    # memo는 계산된 값을 저장하기 위한 딕셔너리 (기본값은 None으로 시작)
    if memo is None:
        memo = {}

    if n in memo:
        return memo[n]  # 이미 계산된 값이 있으면 바로 반환 (중복 계산 방지)

    if n &lt;= 1:
        return n  # 기저 사례: 피보나치(0) = 0, 피보나치(1) = 1

    # 아직 계산되지 않은 경우 재귀적으로 계산
    memo[n] = fibonacci_memo(n - 1, memo) + fibonacci_memo(n - 2, memo)
    return memo[n]  # 계산된 값을 반환
    
print(fibonacci_memo_top_down(10))
# 55</code></pre>

<p>시간 복잡도 O(n), 코드가 간결하지만 메모리 사용량이 많을 수 있으며 재귀 한도가 있어 너무 큰 입력에는 스택 오버플로우 위험이 있다.</p>

<h4>Bottom-Up</h4>
<p>가장 작은 하위 문제부터 차례대로 해결하면서 결과를 쌓아 올린다.</p>
<p>반복문을 이용해 누적적으로 해결하여 스택 사용 없이 처리한다.</p>

<pre class="python"><code>def fibonacci_dp_bottom_up(n):
    # 피보나치 수열의 n번째 수를 구하기 위한 동적 계획법 (Bottom-Up 방식) 구현

    if n &lt;= 1:
        return n  # n이 0 또는 1일 경우, 그대로 반환 (기저 사례)

    dp = [0] * (n + 1)  # 0부터 n까지의 값을 저장할 DP 테이블 생성 (n+1 크기)
    dp[1] = 1  # 초기 조건 설정: 피보나치(0) = 0, 피보나치(1) = 1

    # 점화식에 따라 2부터 n까지 순차적으로 계산
    for i in range(2, n + 1):
        dp[i] = dp[i - 1] + dp[i - 2]  # 이전 두 항을 더한 값을 현재 위치에 저장

    return dp[n]  # 최종적으로 n번째 피보나치 수를 반환
    
 print(fibonacci_dp_bottom_up(10))</code></pre>

<p>테이블을 통해 모든 값을 저장한다. 시간 복잡도 O(n)을 가지며 재귀 호출이 없어 스택 오버플로우 걱정이 없으며 공간복잡도를 O(n)에서 O(1)로 개선 가능하여 메모리 최적화가 가능하다. 하지만 DP 테이블을 모두 만들어야 하기 때문에 필요 없는 값도 계산하게 되기도 한다.</p>

<p><b>공간 복잡도 개선</b></p>
<pre class="python"><code>def fibonacci_optimized(n):
    # 피보나치(0) = 0, 피보나치(1) = 1 처리
    if n &lt;= 1:
        return n

    # 이전 두 항만 저장 (dp 테이블 전체 필요 없음)
    prev2 = 0  # 피보나치(n-2)
    prev1 = 1  # 피보나치(n-1)

    for i in range(2, n + 1):
        curr = prev1 + prev2  # 현재 피보나치 수
        prev2 = prev1         # 피보나치(n-2) &larr; 피보나치(n-1)
        prev1 = curr          # 피보나치(n-1) &larr; 현재 피보나치 수

    return prev1  # n번째 피보나치 수</code></pre>

<p>일반적인 bottom-up 방식은 dp = [0] * (n+1)로 전체 수열을 저장하므로 공간복잡도는 O(n)이다. 하지만 피보나치수열의 다른 특징은 항을 계산할 때 오직 이전 두 항만 사용하기 때문에 dp 배열 없이 prev1, prev2 두 변수만 사용해도 충분하다. 불필요한 dp 배열을 제거하게 되면 공간 복잡도는 O(1)로 줄어들게 된다.</p>
