---
title: "빅-오(Big-O) 표기법"
excerpt: "빅-오(Big-O) 표기법"
categories:
  - Algorithm
permalink: /coding/algorithm/174-big-o/
tags:
  - "Algorithm"
  - "빅-오"
toc: true
toc_sticky: true
date: 2025-07-08
last_modified_at: 2025-07-08
source_url: https://b-note.tistory.com/174
---

<h3>빅-오(Big-O) 표기법</h3>
<p>빅-오(Big-O) 표기법은 알고리즘이 입력 크기(n)에 따라 수행 시간이나 연산 횟수가 어떻게 증가하는지를 나타내는 수학적 표기법이다. 보통&nbsp;최악의&nbsp;경우(Worst&nbsp;Case)&nbsp;기준으로&nbsp;시간&nbsp;복잡도를&nbsp;분석하며,&nbsp;다양한&nbsp;알고리즘의&nbsp;효율성을&nbsp;비교하는&nbsp;데&nbsp;활용된다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="250" data-origin-height="250"><span data-alt="https://en.wikipedia.org/wiki/File:Comparison_computational_complexity.svg"><img src="/assets/images/posts/2025/07/08/174-1.png" loading="lazy" width="250" height="250" data-origin-width="250" data-origin-height="250"/></span><figcaption>https://en.wikipedia.org/wiki/File:Comparison_computational_complexity.svg</figcaption>
</figure>
</p>

<p>시간 복잡도는 입력 크기에 따른 실행 시간의 증가율에 따라 여러 등급으로 나뉘며 다음은 효율이 낮은 순서부터 정리한 목록이다.</p>
<p><b>O(n!) - 팩토리얼 시간</b></p>
<p>가능한 모든 순열을 탐색하는 경우</p>
<p>외판원 문제(TSP), 순열 생성 등</p>

<p><b>O(2^n) - 지수 시간</b></p>
<p>모든 부분 조합이나 경우의 수를 탐색할 때</p>
<p>부분집합 생성, 피보나치(재귀), DFS/백트래킹 등</p>

<p><b>O(n^2) - 이차 시간</b></p>
<p>이중 루프를 사용하는 비교 기반 알고리즘</p>
<p>버블 정렬, 선택 정렬 등</p>

<p><b>O(n log n) - 선형 로그 시간</b></p>
<p>효율적인 비교 기반 정렬 알고리즘의 평균/최선 시간</p>
<p>병합 정렬, 힙 정렬, 퀵 정렬(평균적 경우)</p>

<p><b>O(n) - 선형 시간</b></p>
<p>입력 전체를 한 번 순회하는 경우</p>
<p>배열을 전체 탐색</p>

<p><b>O(log n) - 로그 시간</b></p>
<p>입력이 절반씩 줄어드는 알고리즘</p>
<p>이진 탐색, 힘 삽입/삭제 등</p>

<p><b>O(1) - 상수 시간</b></p>
<p>입력 크기와 무관하게 항상 일정한 시간</p>
<p>배열 인덱스 접근, 해시맵 키 조회</p>
