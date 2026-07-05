---
title: "NP - TSP"
excerpt: "NP - TSP"
categories:
  - Algorithm
permalink: /coding/algorithm/177-np-tsp/
tags:
  - "Algorithm"
  - "NP"
  - "TSP"
toc: true
toc_sticky: true
date: 2025-07-11
last_modified_at: 2025-07-11
source_url: https://b-note.tistory.com/177
---

<h2>외판원 문제(TSP)</h2>
<p>NP는&nbsp;정답을&nbsp;빠르게&nbsp;검증할&nbsp;수&nbsp;있는&nbsp;문제&nbsp;집합이다.&nbsp;즉,&nbsp;어떤&nbsp;해답이&nbsp;주어졌을&nbsp;때,&nbsp;그것이&nbsp;맞는지&nbsp;다항&nbsp;시간&nbsp;내에&nbsp;확인&nbsp;가능한&nbsp;문제들을&nbsp;말한다.&nbsp;</p>

<p>NP-complete는&nbsp;NP&nbsp;문제&nbsp;중&nbsp;가장&nbsp;어려운&nbsp;문제들로,&nbsp;NP에&nbsp;속하면서&nbsp;모든&nbsp;NP&nbsp;문제로부터&nbsp;다항&nbsp;시간&nbsp;내에&nbsp;환원이&nbsp;가능한&nbsp;문제이다.&nbsp;</p>

<p>NP-hard는&nbsp;모든&nbsp;NP-complete&nbsp;이상의&nbsp;난이도를&nbsp;포함하는&nbsp;상위&nbsp;개념이다.&nbsp;이&nbsp;집합은&nbsp;NP를&nbsp;포함하지&nbsp;않을&nbsp;수도&nbsp;있으며,&nbsp;검증조차&nbsp;다항&nbsp;시간&nbsp;내에&nbsp;불가능할&nbsp;수&nbsp;있는&nbsp;문제까지&nbsp;포함한다.</p>

<p><b>P&nbsp;&sube;&nbsp;NP&nbsp;&nbsp; </b><br /><b>NP-complete&nbsp;&sube;&nbsp;NP&nbsp;&nbsp; </b><br /><b>NP-complete&nbsp;&sube;&nbsp;NP-hard&nbsp;&nbsp;</b> </p>

<p>TSP는 하나의 경로가 주어졌을 때, 그 경로가 총얼마의 비용을 갖는지 계산하는 데는 O(n)으로 정답을 빠르게 검증하는 게 가능하기 때문에 NP 문제에 속한다.</p>

<p>최적 경로를 찾기 위한 모든 경우를 탐색하면 (n-1)!개의 경로가 생기고, 이는 O(n!) 시간 복잡도로, 도시 수가 조금만 늘어나도 계산이 불가능한 수준으로 커지게 된다. 현재까지는 다항 시간 내에 최적해를 찾는 알고리즘은 발견되지 않았기 때문에 TSP의 최적화 문제(정답을 찾는 문제)는 NP-hard이다.</p>

<p>TSP의 최단 경로를 묻는 최적화가 문제가 아닌 "총 경로 비용이 K 이하인 경로가 존재하는가?"처럼 결정 문제로 형태를 바꾸면 예/아니오로 답할 수 있고, 다항 시간 검증/환원이 가능한 NP-complete 문제가 된다.</p>

<p>즉, 본질적으로는 NP-hard 한 최적화 문제지만, 이를 결정 문제로 변환하면 NP-complete 문제로 볼 수 있다. 실제 적용에서는 정확한 해 대신, 근사 알고리즘이나 동적 계획법을 활용해 현실적인 해를 구하는 방향으로 발전하였다.</p>

<h3>Held-Karp 알고리즘</h3>
<p><span style="text-align: start">작은 규모의 문제에 대해 최적해를 찾는 효율적인 방법을 제공하는</span> TSP를 해결하기 위한 동적 계획법 기반의 알고리즘이다. 알고리즘의 핵심은 문제를 더 작은 하위 문제로 분할하고, 이 하위 문제들의 해를 저장하여 중복 계산을 피하는 것으로 이때 비트 마스킹을 사용하여 효율적으로 표현한다.</p>

<h4>문제 풀이의 구조</h4>
<p><b>하위 문제 정의</b></p>
<p>C(S, j) : 시작 도시(0)에서 출발해 집합 S(0 포함, j 포함)에 속한 도시를 한 번씩 방문, 마지막 도시가 j일 때의 최소 비용&nbsp;</p>

<p>- S:&nbsp;방문한&nbsp;도시&nbsp;집합&nbsp;(도시&nbsp;0은&nbsp;항상&nbsp;포함)</p>
<p>- j&nbsp;&isin;&nbsp;S,&nbsp;j&nbsp;&ne;&nbsp;0</p>

<p><b>비트마스킹으로 상태 표현</b></p>
<p>방문한 도시의 집합 S를 정수로 표현한다</p>
<p>예) s =&nbsp; 0b1011 (0, 1, 3번 도시를 방문한 상태)</p>

<h4>알고리즘 구성</h4>
<p><b>기저 사례 (Base&nbsp;Case)</b></p>
<p>더 이상 쪼갤 수 없는 최소 단위 하위 문제이다.</p>

<p>두 도시만 방문한 경우(<span style="text-align: start">0에서 j로 바로 가는 비용) : </span>C({0, j}, j) = cost(0, j)&nbsp;</p>

<p><b>점화식&nbsp;(Recurrence)</b></p>
<p>작은 하위 문제를 통해 큰 문제를 푸는 공식이다.</p>

<p>C(S,&nbsp;j)&nbsp;=&nbsp;min&nbsp;{&nbsp;C(S&nbsp;-&nbsp;{j},&nbsp;i)&nbsp;+&nbsp;cost(i,&nbsp;j)&nbsp;}&nbsp;(단,&nbsp;i&nbsp;&isin;&nbsp;S&nbsp;-&nbsp;{j})</p>

<p>도시 j에 도착하기 직전 도시 i를 고려해, i까지 최소 비용 + i -&gt; j 비용을 더한 값을 구한다.</p>

<p><b>계산 순서</b></p>
<p>S의 크기를 2 &rarr; n까지 증가시키며 모든 C(S, j) 계산한다.</p>
<p>각 상태는 비트마스킹으로 구현한다.</p>

<p><b>최종 결과</b></p>
<p>모든 도시(V) 방문 후 0으로 돌아오는 최소 경로를 구한다.</p>

<p>min&nbsp;{&nbsp;C(V,&nbsp;j)&nbsp;+&nbsp;cost(j,&nbsp;0)&nbsp;}&nbsp;(단,&nbsp;j&nbsp;&ne;&nbsp;0)</p>

<pre class="python"><code>def tsp_dp(dist):
    n = len(dist)
    
    # dp[visited][curr]:
    # 시작 도시 0에서 출발, visited(비트마스킹) 상태의 도시 방문 &amp;&amp; 현재 위치 curr일 때 최소 비용
    # 2^n * n -&gt; O(n * 2^n)
    dp = [[float('inf')] * n for _ in range(1 &lt;&lt; n)]
    dp[1][0] = 0 # Base Case : 시작 도시(0) 방문 상태

    for visited in range(1 &lt;&lt; n): # 총 2^n개의 visited 상태
        for curr in range(n):     # 현재 위치한 도시 (j)
            if not (visited &amp; (1 &lt;&lt; curr)):
                continue
            for next in range(n):
                if visited &amp; (1 &lt;&lt; next):
                    continue
                next_visited = visited | (1 &lt;&lt; next)
                
               	# C(S &cup; {next}, next) = min(C(S, curr) + cost(curr, next))
                dp[next_visited][next] = min(
                    dp[next_visited][next],
                    dp[visited][curr] + dist[curr][next]
                ) # O(n^2 * 2^n)
    
    # 모든 도시 방문 후, 다시 0으로 돌아오는 비용 중 최솟값
    # min(C(V, j) + cost(j, 0))  (j != 0)
    return min(dp[(1 &lt;&lt; n) - 1][i] + dist[i][0] for i in range(1, n))

dist = [
    [0, 10, 15, 20],
    [10, 0, 35, 25],
    [15, 35, 0, 30],
    [20, 25, 30, 0]
]

result = tsp_dp(dist)
print(f"최소 이동 비용: {result}")

"""
최소 이동 비용: 80
"""</code></pre>

<p>시간 복잡도는 개선되어 O(m^2 * 2^n)이 되지만 여전히 도시 수가 증가했을 때 지수적으로 증가하므로 큰 입력엔 부적합하다.</p>

<h3>근사 알고리즘</h3>
<p>도시 수가 증가하면 계산량이 급격히 증가하는 문제를 해결하기 위한 방법으로, 정확한 최적해는 아니지만 계산 가능한 시간 내에 효율적인 경로를 찾는 방법이다.</p>

<h4>최소 신장 트리 (Minimum Spanning Tree, MST) 알고리즘</h4>
<p>MST는 가중치가 있는 무방향 그래프에서 모든 정점을 연결하면서, 간선 가중치의 총합이 최소가 되는 트리를 말한다.</p>
<p>TSP는 출발점에서 모든 정점을 한 번씩 방문하고, 다시 출발점으로 돌아오는 사이클(순환 경로)을 찾는 문제이지만, MST는 사이클이 없는 트리이다. 하지만 이 MST를 활용하여 다음과 같은 방식으로 TSP 근사 경로를 만들 수 있다.</p>

<p><b>1. 완전 그래프 구성</b></p>
<p>풀고자 하는 TSP 문제의 원래 그래프가 주어지면, 모든 도시 간의 최단 거리를 간선 가중치로 하는 완전 그래프를 구성한다.</p>
<p>이는 특히 <b>삼각 부등식을 만족하는 Metric TSP</b>에서 유용하다.</p>

<p><b> * <span>&nbsp;</span>Metric TSP?</b></p>
<p>- 모든 정점 쌍이 연결되어 있으며, 거리 함수가 삼각 부등식을 만족하는 TSP를 의미한다.</p>
<p>- distance(A, C) &le; distance(A, B) + distance(B, C)</p>
<p>- 이러한 조건을 만족할 경우, 근사 알고리즘의 성능 보장이 가능하다.</p>

<p><b>2. MST 구성</b></p>
<p>완전 그래프에 대해 MST를 구성한다. 보통 프림(Prim) 알고리즘이 사용되며, 전체&nbsp;간선&nbsp;가중치의&nbsp;합이&nbsp;최소가&nbsp;되도록&nbsp;트리를&nbsp;구성한다.</p>

<p><b>3. MST&nbsp;전위&nbsp;순회&nbsp;(Preorder&nbsp;Traversal)</b></p>
<p>MST를&nbsp;DFS&nbsp;방식으로&nbsp;전위&nbsp;순회하여&nbsp;방문&nbsp;순서를&nbsp;얻는다.&nbsp;이&nbsp;순서는&nbsp;중복&nbsp;방문이&nbsp;가능하며,&nbsp;이후&nbsp;중복된&nbsp;정점을&nbsp;생략하고&nbsp;한&nbsp;번씩만&nbsp;방문하는&nbsp;경로로&nbsp;정제한다.&nbsp;이를&nbsp;통해&nbsp;<b>해밀턴&nbsp;순환&nbsp;경로</b>에&nbsp;근사한&nbsp;경로를&nbsp;얻는다. </p>
<p><b><br />* 해밀턴 순환 경로</b></p>
<p>- 해밀턴 경로 : 그래프 내의 모든 정점을 정확히 한 번씩만 방문하는 경로, 시작점과 도착점이 다를 수 있다.(비순환)</p>
<p>- 해밀턴 순환 경로는 해밀턴 경로의 조건에서 시작점으로 다시 돌아오는 순환 경로를 추가한다.</p>

<p><b>4. 쇼트컷 적용 및 최종 경로 구성</b></p>
<p>방문 순서 중 이미 방문한 정점은 <b>건너뛰고</b> 다음 미방문 정점으로 이동하는 <b>쇼트컷(shortcut)</b>을 적용한다. 이를 통해 중복 없이 정점을 한 번씩만 방문하는 해밀턴 순환 경로가 완성되며, 마지막에 시작 도시로 돌아와 TSP의 근사해를 얻는다.</p>

<p><b>프림 (Prim) 알고리즘</b></p>
<p>최소 신장 트리를 찾을 때는 대표적으로 프림 알고리즘을 사용한다. 이 알고리즘은 그래프의 한 정점에서 시작해서, MST 바깥에 있는 정점 중 현재 MST에 있는 정점과 가장 가중치가 낮은 간선으로 연결된 정점을 하나씩 추가하면서 MST를 만들어 나가는 방식이다. 모든 정점을 연결하는 트리를 사이클 없이 만들고, 총 간선 가중치의 합이 최소가 되도록 구성한다.</p>

<p>1. 정점 중 하나를 시작 정점으로 선택하고 MST에 포함시킨다.</p>
<p>2. 현재 MST에 포함된 정점들과 연결된 간선들 중에서, MST 바깥에 있는 정점으로 연결되며 가중치가 가장 낮은 간선을 선택한다.</p>
<p>3. 선택한 간선의 반대쪽 정점을 MST에 새롭게 추가하고, 해당 간선도 MST에 포함시킨다.</p>
<p>4. 모든 정점이 MST에 포함될 때까지 반복한다.</p>

<pre class="python"><code>import heapq

# 1. Prim 알고리즘으로 MST 구성
def prim_mst(graph):
    n = len(graph)
    visited = [False] * n
    mst = [[] for _ in range(n)]  # MST를 인접 리스트로 표현
    min_heap = [(0, 0)]  # (가중치, 정점)
    
    while min_heap:
        weight, u = heapq.heappop(min_heap)
        if visited[u]:
            continue
        visited[u] = True
        for v in range(n):
            if not visited[v] and u != v:
                heapq.heappush(min_heap, (graph[u][v], v))
                mst[u].append(v)
                mst[v].append(u)  # 무방향 MST
    return mst

# 2. DFS로 MST 순회하여 TSP 경로 획득
def dfs_path(tree, node, visited, path):
    visited[node] = True
    path.append(node)
    for neighbor in tree[node]:
        if not visited[neighbor]:
            dfs_path(tree, neighbor, visited, path)

# 3. 근사 TSP 실행
def tsp_mst_approx(graph):
    mst = prim_mst(graph)  # MST 생성
    path = []
    visited = [False] * len(graph)
    dfs_path(mst, 0, visited, path)  # DFS로 순회 경로 생성
    path.append(0)  # 출발 도시로 복귀
    total_cost = sum(graph[path[i]][path[i+1]] for i in range(len(path)-1))
    return total_cost, path

# 테스트용 그래프 (대칭 행렬, 삼각 부등식 만족)
graph = [
    [0, 10, 15, 20],
    [10, 0, 35, 25],
    [15, 35, 0, 30],
    [20, 25, 30, 0]
]

cost, path = tsp_mst_approx(graph)
print(f"근사 비용: {cost}")
print(f"근사 경로: {path}")

"""
근사 비용: 95
근사 경로: [0, 1, 2, 3, 0]
"""</code></pre>


<p>이 알고리즘은 Metric TSP (삼각 부등식 만족) 조건에서만 유효하며, 항상 최적해의 2배 이내의 근사 결과를 보장하는 2-근사 알고리즘(2-approximation)이다.</p>


<h4>최근접 이웃 (Nearest Neighbor) 알고리즘</h4>
<p>출발점에서 시작해서 가장 가까운 도시부터 방문해 나가는 방식이다. 정점을 한 번씩만 방문하고, 모든 도시를 돌고 나면 다시 출발점으로 돌아간다.&nbsp;</p>

<p>1. 시작 정점을 임의로 선택</p>
<p>2. 현재 정점에서 가장 가까운 미방문 정점으로 이동</p>
<p>3. 모든 정점을 한 번씩 방문할 때까지 반복</p>
<p>4. 마지막 정점에서 시작 정점으로 돌아와 순환 경로 완성</p>

<pre class="python"><code>def tsp_nearest_neighbor(graph, start=0):
    n = len(graph)
    visited = [False] * n
    path = [start]
    total_cost = 0
    current = start
    visited[current] = True

    for _ in range(n - 1):
        nearest = None
        min_dist = float('inf')
        for i in range(n):
            if not visited[i] and graph[current][i] &lt; min_dist:
                nearest = i
                min_dist = graph[current][i]
        visited[nearest] = True
        path.append(nearest)
        total_cost += min_dist
        current = nearest

    # 돌아오는 거리 추가
    total_cost += graph[current][start]
    path.append(start)
    return total_cost, path

# 테스트용 대칭 거리 행렬
graph = [
    [0, 10, 15, 20],
    [10, 0, 35, 25],
    [15, 35, 0, 30],
    [20, 25, 30, 0]
]

cost, path = tsp_nearest_neighbor(graph)
print(f"근사 비용: {cost}")
print(f"근사 경로: {path}")

"""
근사 비용: 80
근사 경로: [0, 1, 3, 2, 0]
"""</code></pre>

<p>(한 번의 탐색마다 O(n) 거리 계산) * (n개 도시) = O(n^2)의 시간복잡도를 가진다.</p>

<p>구현이 간단하고 빠르고 직관적이지만, 초기 시작점에 따라 결과가 달라지며 지역 최적 해에 빠지기 쉽다. 최악의 경우 낮은 수준의 근사율을 가질 수 있어 최적해보다 빠른 근사해가 필요한 시스템에 활용되거나 대규모 TSP문제 등에 활용하거나 최적해를 개선하기 위한 방식들로 개선한다.</p>

<p>1. Multi-Start Nearest Neighbor</p>
<p>- n개의 정점을 모두 출발점으로 시도, 최적 경로 선택</p>
<p>- 시간복잡도 O(n^3)까지 증가하지만 품질이 향상된다.</p>

<p>2. 2-opt / 3-opt 알고리즘</p>
<p>- 최근접 이웃으로 얻은 경로에서 두 정점 간 경로를 교환하여 더 짧은 경로 탐색</p>
<p>- 지역 최적해 탈출 가능</p>

<p>3. 다른 휴리스틱과 결합</p>
<p>- MST 기반 알고리즘, Christofiedes 알고리즘 등과 비교 및 결합 가능</p>
