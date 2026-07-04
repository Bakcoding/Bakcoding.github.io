---
title: "C# 구조체 키워드 : struct"
excerpt: "C# 구조체 키워드 : struct"
categories:
  - CSharp
permalink: /programming/csharp/50-csharp-struct/
tags:
  - "CSharp"
  - "C#"
  - "padding"
  - "struct"
  - "type keyword"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/50
---

<h3>struct</h3>
<p>값 형식을 나타내는 키워드이다.</p>
<p>struct로 정의된 데이터 타입은 클래스와 비슷한 멤버를 가질 수 있지만 다른 특징이 있다.</p>

<h4>클래스와 차이</h4>
<p>struct는 클래스와 달리 상속이나 인터페이스 구현 등의 기능을 제공하지 않으며 struct는 메모리에 적재되며 개체의 인스턴스화를 할 수 있다. 또한 struct는 기본적으로 stack에 할당되어 heap 메모리를 사용하지 않기 때문에 일반적인 값 형식을 나타내기 위해서 사용된다.</p>

<p>struct는 변수에 값을 할당할 때 복사가 일어나게 된다. 예를 들어 struct로 정의된 Point 타입의 변수에 값을 할당하면 해당 값을 복사하여 새로운 메모리 공간에 저장한다.</p>

<pre class="csharp"><code>struct Point
{
	public int X;
    public int Y;
}

Point p1 = new Point{X = 10, Y = 20};
Point p2 = p1;	// 이때 p1의 값 전체가 복사되어 p2에 저장된다.</code></pre>
<p>구조체가 메모리에 할당될 때 데이터 멤버들 사이에는 일정한 간격을 두고 배치된다.&nbsp;</p>
<p>이 간격을 Padding이라고 하며 데이터 멤버의 크기와 정렬을 고려해 계산된다. 이는 구조체 전체 크기가 미리 예측 가능하기 위해서이며 이 크기는 구조체 전체 크기 합에 패딩을 합한 값이다.</p>

<p>패딩은 구조체의 크기를 불필요하게 늘리기도 하므로 크기를 최소화하기 위해서는<span style="color: #333333; text-align: start;"><span>&nbsp;</span>큰 데이터를 먼저 선언하고 뒤에 작은 데이터들이 선언되도록</span> 멤버들을 크기에 따라 정렬하는것이 좋다. 이렇게 구조체를 제대로 이해하고 사용하기 위해서는 각 타입들의 크기와 패딩의 존재에 대해 정확한 이해가 필요하다.</p>
