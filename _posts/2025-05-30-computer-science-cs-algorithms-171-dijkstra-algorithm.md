---
title: "Dijkstra algorithm"
excerpt: "Dijkstra algorithm"
categories:
  - ComputerAlgorithm
permalink: /computer-science/cs-algorithms/171-dijkstra-algorithm/
tags:
  - "Algorithm"
  - "Computer Science"
toc: true
toc_sticky: true
date: 2025-05-30
last_modified_at: 2025-05-30
source_url: https://b-note.tistory.com/171
---

<h2>데이크스트라(Dijkstra) 알고리즘</h2>
<p>데이크스트라&nbsp;알고리즘은&nbsp;그래프에서&nbsp;꼭짓점(노드)&nbsp;간의&nbsp;최단&nbsp;경로를&nbsp;찾는&nbsp;알고리즘이다.</p>
<p>기본적으로 단일 출발점(Single-Source)에서 그래프의 다른 모든 꼭짓점까지의 최단 경로를 찾는 데 활용되며, 음의 가중치(negative weights)가 없는 그래프에서만 정확하게 동작한다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="283" data-origin-height="222"><span data-alt="https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm"><img src="/assets/images/posts/2025/05/30/171-1.gif" loading="lazy" width="283" height="222" data-origin-width="283" data-origin-height="222"/></span><figcaption>https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm</figcaption>
</figure>
</p>


<h3>데이크스트라 기본 형태 (선형 탐색 방식)</h3>
<p>데이크스트라 알고리즘의 초기 형태는 우선순위 큐를 사용하지 않고, 일반적인 배열 또는 리스트를 사용하여 구현되었다. 이 방식은 매 단계마다 방문하지 않은 노드 중에서 시작점으로부터의 거리가 가장 짧은 노드를 선형 탐색하여 찾아낸다.</p>

<h4>시간 복잡도</h4>
<p>- 그래프에 V개의 노드가 있을 때, 매번 가장 짧은 노드를 찾기 위해 O(V) 시간이 소요된다.</p>
<p>- 가장 짧은 노드 선택과정을 총 V번 반복하기 때문에, 전체 시간 복잡도는 O(V * V) = O(V^2)이 된다.</p>

<h4>플로우(일반 배열/리스트 사용)</h4>
<p>기본 형태에서는 일반 배열/리스트를 사용하여 구현했는데 이 경우 그래프의 모든 노드를 방문하면서 각 노드를 방문할 때마다 짧은 거리를 찾는 과정이 필요한데 이때 V개의 노드가 있다면 모든 노드를 순회하는 작업이 O(V)의 시간이 걸리고 여기서 매&nbsp;반복마다&nbsp;O(V)의&nbsp;시간이&nbsp;소요되는&nbsp;'가장&nbsp;짧은&nbsp;거리&nbsp;노드&nbsp;선택'&nbsp;과정이&nbsp;총&nbsp;V번&nbsp;반복되기&nbsp;때문에 전체 시간 복잡도는 O(V^2)이 된다.</p>


<h3>플로우</h3>
<pre class="csharp"><code>dist[] : 각 노드까지의 최단 거리를 저장, infinity 초기화
visited[] : 각 노드를 방문했는지 여부, false 초기화
start_node ( dist = 0 )</code></pre>

<p>그래프의 노드 V개를 모두 방문할 때까지 다음 동작을 반복한다.</p>
<pre class="csharp"><code>min_dist = infinity
closest_node = -1;
visited == false 인 노드(index i) 
- dist[i] &lt; min_dist : min_dist = dist[i], closest_node = i</code></pre>

<p>선택된 노드는 방문 처리를 하고 visited [closest_node] = true, 이 노드의 최단 거리는 확정됨</p>
<p>만약 closest_node == -1이라면 모든 노드가 방문되었거나 연결되지 않은 경우로 반복을 종료한다.</p>

<p>이후 인접 노드 거리를 갱신한다.</p>
<p>closest_node와 연결된 모든 인접 노드에 대해서</p>
<pre class="csharp"><code>visited == false &amp;&amp; 
dist[closest_node] + edge_weight(closest_node, neighbor) &lt; dist[neighbor]
(인접 노드를 거치는 것이 현재 저장된 최단 거리보다 더 짧다면 최단 거리를 갱신)</code></pre>

<p>모든 반복이 끝나면 최종적으로 dist [] 배열에는 시작 노드로부터 각 노드까지의 최단 거리가 저장된다.</p>

<h3>우선순위 큐를 활용한 개선된 데이크스트라</h3>
<p>데이크스트라 알고리즘의 효율성을 높이기 위해 가장 짧은 거리 노드 선택 과정을 개선한 방식으로 우선순위 큐(Priority Queue)를 사용한다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">우선순위<span>&nbsp;</span>큐는 선입선출 방식인 일반적인 큐와 달리 데이터들이 우선순위를 가지고 있어, 가장 높은(또는 낮은) 우선순위를 가진 데이터가 먼저 나가는 자료구조이다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<h4 style="color: #333333; text-align: start;">시간복잡도</h4>
<p style="color: #333333; text-align: start;">- 우선순위 큐는 가장 작은 값 추출(extract_min) 및 값 삽입(insert) 연산을 각각 O(log N) (N은 큐에 있는 원소의 개수)의 시간 복잡도로 수행한다.</p>
<p style="color: #333333; text-align: start;">- 간선의 개수를 E라고 할 때, 각 간선이 한 번씩 큐에 삽입될 수 있으므로, 전체 시간 복잡도는 O((V+E)logV) 또는 O(ElogV)로 개선된다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<h4 style="color: #333333; text-align: start;">플로우</h4>
<pre class="csharp"><code>dist[] : 최단 거리 저장 배열, 무한대 초기화
pq(priority_queue) : 우선순위 큐, (거리, 노드) 튜플로 저장, 가장 거리가 짧은 튜플이 항상 최상단에 정렬
시작 노드 : pq &lt;- (0, start_node) 삽입</code></pre>

<p>pq에서 거리 값이 가장 작은 튜플을 추출, 짧은 경로가 발견되어 처리되었다면 확정된 노드를 불필요하게 재처리하는 것을 방지하기 위해서 무시하고 다음 반복으로 넘긴다.</p>
<pre class="csharp"><code>current_dist &gt; dist[current_node] continue</code></pre>

<p>인접 노드 거리 갱신, 현재 방문 중인 노드와 인접한 노드들에 대해서 해당 간선의 가중치에 대해 반복</p>
<pre class="csharp"><code>dist[current_node] + edge_weight &lt; dist[neighbor]
dist[neighbor] = dist[current_node] + edge_weight
pq &lt;- (dist[neighbor], neighbor) insert</code></pre>

<p>current_node를 경유할 때 인접한 노드까지의 거리가 현재 저장된 값보다 더 짧다면 해당 값으로 갱신하고 거리와 노드를 우선순위 큐에 저장한다.</p>

<p>pq가 완전히 비워지게 되면 dist [] 배열에는 시작 노드에서 다른 모든 노드까지의 최단거리가 저장된다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-filename="2025-05-30141140-ezgif.com-video-to-gif-converter.gif" data-origin-width="800" data-origin-height="758"><span data-alt="Dijkstra"><img src="/assets/images/posts/2025/05/30/171-2.gif" loading="lazy" width="415" height="393" data-filename="2025-05-30141140-ezgif.com-video-to-gif-converter.gif" data-origin-width="800" data-origin-height="758"/></span><figcaption>Dijkstra</figcaption>
</figure>
</p>
