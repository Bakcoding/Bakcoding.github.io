---
title: "C# 가상 함수/재정의 키워드 : virtual/override"
excerpt: "C# 가상 함수/재정의 키워드 : virtual/override"
categories:
  - CSharp
permalink: /programming/csharp/32-csharp-virtual-override/
tags:
  - "CSharp"
  - "inherit"
  - "Override"
  - "virtual"
toc: true
toc_sticky: true
date: 2023-03-30
last_modified_at: 2023-03-30
source_url: https://b-note.tistory.com/32
---

<h3>virtual</h3>
<p>가상 메서드를 정의할 때 사용되는데 이 키워드를 통해서 메서드를 재정의할 수 있도록 허용한다.</p>
<pre class="arduino"><code>class Base
{
	public virtual void Print()
    {
    	Console.WriteLine("Base class");
    }
}</code></pre>

<h3>override</h3>
<p>상속 관계에서 부모 클래스에 정의된 메서드를 자식 클래스에서 다시 정의할 때 사용된다.</p>
<pre class="bash"><code>class Derived
{
	public override void Print()
    {
    	Console.WriteLine("Derived class");
    }
}</code></pre>

<p>override 키워드를 사용하여 부모 클래스에서 정의한 메서드를 자식 클래스에서 재정의하면 자식 클래스의 인스턴스에서 호출할 때 부모 클래스와 자식 클래스의 구현 차이를 쉽게 반영할 수 있다.</p>

<pre class="bash"><code>Base base = new Base();
base.Print();
// "Base class"

Derived derived = new Derived();
derived.Print();
// "Derived class"

Base base2 = new Derived();
base2.Print();
// "Derived class"</code></pre>
