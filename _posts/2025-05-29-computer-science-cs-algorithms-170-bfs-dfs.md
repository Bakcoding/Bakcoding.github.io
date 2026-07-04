---
title: "탐색 알고리즘 - BFS/DFS"
excerpt: "탐색 알고리즘 - BFS/DFS"
categories:
  - ComputerAlgorithm
permalink: /computer-science/cs-algorithms/170-bfs-dfs/
tags:
  - "Algorithm"
  - "Computer Science"
  - "BFS"
  - "dfs"
  - "pathfinding"
toc: true
toc_sticky: true
date: 2025-05-29
last_modified_at: 2025-05-29
source_url: https://b-note.tistory.com/170
---

<h2>BFS</h2>
<p>Breath-First Search, 너비 우선 탐색</p>
<p>트리 자료구조의 순회 방법으로 같은 계층의 모든 노드를 먼저 탐색하고 다음 계층을 탐색하는 방식으로 순차적으로 진행하는 방식이다.&nbsp;</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="187" data-origin-height="175"><span data-alt="https://en.wikipedia.org/wiki/Breadth-first_search"><img src="/assets/images/posts/2025/05/29/170-1.gif" loading="lazy" width="187" height="175" data-origin-width="187" data-origin-height="175"/></span><figcaption>https://en.wikipedia.org/wiki/Breadth-first_search</figcaption>
</figure>
</p>

<p>아직 탐색하지 않은 자식 노드를 추적하고 모든 노드를 탐색하기 위해서 일반적으로 FIFO 방식인 큐를 사용한다.</p>
<p>탐색을 시작할 때 먼저 루트 노드를 큐에 넣는다. 큐에서 가장 앞에 있는 노드를 먼저 탐색하고 그 자식 노드를 모두 큐에 넣는다. 그리고 큐에서 제거를 하면 가장 먼저 넣었던 노드가 빠지게 된다. 그리고 다시 큐의 가장 앞에 있는 노드를 탐색하고 자식을 큐에 넣고 가장 앞의 노드를 제거하는 과정을 큐가 빌 때까지 반복하면 최종적으로 모든 노드를 방문할 수 있게 된다.</p>


<p>이 방법을 확장하면 사이클 유무, 방향성, 가중치 유무 등에 상관없이 모든 형태를 포함할 수 있는 자유로운 구조로 노드와 간선으로 구성된 구조인 일반 그래프에도 적용할 수 있게 된다. 이때는 부모-자식 관계가 확실한 트리에서와는 달리 중복해서 탐색하는 것을 방지하는 작업이 추가로 필요하다.</p>

<p>시각적으로 확인하기 쉬운 이차원 그리드에서 이를 응용하면 특정 셀을 루트 노드로 간주하고 그 인접한 각 셀들을 자식 노드로 치환할 수 있다. 이때 셀들은 중복해서 인접하기 때문에 이를 체크하여 순차적으로 탐색을 이어가면 모든 셀을 중복 없이 탐색할 수 있다.</p>

<p>여기서 시작 셀 이외에 또 다른 셀을 도착 지점으로 지정하고 이 셀을 만날 때까지 탐색을 진행하고 각 셀들이 어떤 셀로부터 이어져 온 것인지에 대한 정보를 저장한다면 도착한 셀에서 이전 셀을 타고 올라가면 시작 셀에서부터 도착 셀까지 이어지는 경로를 알 수 있게 된다. 이 과정이 BFS를 응용한 길 찾기 알고리즘이다.</p>


<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-filename="2025-05-29212143-ezgif.com-video-to-gif-converter.gif" data-origin-width="800" data-origin-height="749"><span data-alt="BFS Pathfinding"><img src="/assets/images/posts/2025/05/29/170-2.gif" loading="lazy" width="318" height="749" data-filename="2025-05-29212143-ezgif.com-video-to-gif-converter.gif" data-origin-width="800" data-origin-height="749"/></span><figcaption>BFS Pathfinding</figcaption>
</figure>
</p>


<h2>DFS</h2>
<p>Depth-First Search, 깊이 우선 탐색</p>
<p>트리&nbsp;자료구조의&nbsp;순회&nbsp;방법으로&nbsp;한&nbsp;방향으로&nbsp;최대한&nbsp;깊이&nbsp;탐색한&nbsp;후,&nbsp;더&nbsp;이상&nbsp;갈&nbsp;곳이&nbsp;없으면&nbsp;이전&nbsp;노드로&nbsp;돌아가서&nbsp;다른&nbsp;방향을&nbsp;탐색하는&nbsp;방식으로&nbsp;진행한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="250" data-origin-height="161"><span data-alt="https://en.wikipedia.org/wiki/Depth-first_search"><img src="/assets/images/posts/2025/05/29/170-3.png" loading="lazy" width="250" height="161" data-origin-width="250" data-origin-height="161"/></span><figcaption>https://en.wikipedia.org/wiki/Depth-first_search</figcaption>
</figure>
</p>

<p>아직 탐색하지 않은 경로를 추적하고 모든 노드를 탐색하기 위해서 일반적으로 LIFO 방식인 스택을 사용하거나 재귀 함수를 활용한다. 탐색을 시작하면 루트 노드부터 시작해서 자식이 없는 리프 노드가 나올 때까지 스택에 노드를 저장하면서 탐색을 진행한다. 리프노드에 도착하면 스택에서 제거하면서 다시 역으로 거슬러 올라가는 백트래킹 과정을 진행한다. 해당 노드에 아직 탐색하지 않은 다른 자식이 있는지 확인 후 있으면 다시 깊이 탐색을 진행하고 리프에서 다시 역으로 올라가는 작업을 스택이 빌 때까지 반복한다.</p>

<p>BFS나 DFS는 트리 구조에 따라서 다르겠지만 BFS는 같은 계층의 모든 노드를 저장하기 때문에 깊이난 얕지만 계층이 넓은 경우 메모리상 불리하고 DFS는 계층이 얇지만 트리가 깊다면 또 불리하기 때문에 구조에 따라 방법을 선택해야 한다.</p>

<p>DFS 또한 길 찾기에 적용시킬 수 있는데 BFS는 가장 인접한 노드를 탐색하기 때문에 자연스럽게 최단 경로를 찾게 되는 것과 달리 DFS의 경우에는 최단 경로는 보장하지 않지만 경로 존재 여부나 모든 경로 탐색 등의 경우에 유리하다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-filename="2025-05-29215717-ezgif.com-video-to-gif-converter.gif" data-origin-width="800" data-origin-height="691"><span data-alt="DFS Pathfinding"><img src="/assets/images/posts/2025/05/29/170-4.gif" loading="lazy" width="308" height="266" data-filename="2025-05-29215717-ezgif.com-video-to-gif-converter.gif" data-origin-width="800" data-origin-height="691"/></span><figcaption>DFS Pathfinding</figcaption>
</figure>
</p>
