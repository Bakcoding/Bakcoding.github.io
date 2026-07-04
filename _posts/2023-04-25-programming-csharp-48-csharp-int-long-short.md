---
title: "C# 정수형 키워드 : int, long, short ..."
excerpt: "C# 정수형 키워드 : int, long, short ..."
categories:
  - CSharp
permalink: /programming/csharp/48-csharp-int-long-short/
tags:
  - "CSharp"
  - "C#"
  - "inteager"
  - "type keyword"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/48
---

<h3>정수형</h3>
<p>정수형을 표현하는 데이터 타입에는 대표적으로 int가 있고 그 외에 long, short... 등이 있다.</p>
<p>일반적인 상황에서 모두 int로 표현이 가능하기 때문에 가장 많이 사용된다.</p>

<p>하지만 int로 표현할 수 있는 크기를 벗어난 특별한 경우도 있기 때문에 long이 존재한다.</p>
<p>long은 int 보다 더 큰 정수 범위를 저장할 수 있다.</p>

<p>반대로 저장할 정수값이 작은 경우에는 굳이 int를 사용하지 않아도 되기 때문에 더 적은 공간을 차지하는 short 정수형도 있다.</p>

<h3>양의 정수</h3>
<p>만약 저장할 데이터가 항상 양의 정수라면 굳이 음의 정수까지 저장하기 위한 변수의 크기를 할당할 필요가 없다.</p>
<p>따라서 unsigned를 붙여서 uing, ulong, ushort 정수형의 양의 범위만 저장할 수 있도록 크기를 사용할 수 있다.</p>


<p>그 외의 특징으로는 CPU가 정수 계산에 대해서 최적화되어 있기 때문에 소수점 계산보다 훨씬 빠르게 계산이 가능하다.</p>
<p>또한 부동 소수점 숫자와 비교하여 더 작은 메모리를 사용하기 때문에 대규모 데이터 세트를 처리할 때 중요한 요소가 된다.</p>
