---
title: "C# 상속 방지 키워드 : sealed"
excerpt: "C# 상속 방지 키워드 : sealed"
categories:
  - CSharp
permalink: /programming/csharp/37-csharp-sealed/
tags:
  - "CSharp"
  - "C#"
  - "keyword"
  - "sealed"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/37
---

<h3>sealed</h3>
<p>클래스나 메서드를 상속하지 못하도록 하여 오버라이딩을 방지한다.</p>
<p>sealed로 선언된 클래스는 다른 클래스에서 상속받을 수 없으며 메서드의 경우 해당 클래스에서만 사용이 가능하다.</p>

<h4>sealed 클래스 선언</h4>
<pre class="csharp"><code>sealed class MyClass
{
	//
}</code></pre>
<p>이 클래스는 다른 클래스에서 상속받을 수 없으며 이 클래스를 파생 클래스로도 사용할 수 없다.</p>

<h4>&nbsp;sealed 메서드 선언</h4>
<pre class="csharp"><code>class MyBaseClass
{
	public virtual void MyMethod() {}
}

class MyDerivedClass : MyBaseClass
{
	public sealed override void MyMethod() {}
}</code></pre>
<p>MyMethod 함수는 MyDerivedClass에서 오버라이딩되고 이후 sealed로 선언된다. 따라서 MyDerivedClass를 상속하는 다른 파생 클래스에서 MyMethod를 오버라이딩할 수 없게 된다.</p>

<p>일반적으로 클래스를 마지막으로 봉할 때 사용하는 키워드로 최종적인 구현을 제공하는 클래스에서 사용된다.</p>
<p>파생되어 추가되는 내용이 필요하지 않게 하거나 해당 기능을 변경하거나 확장하려는 경우를 방지해 클래스의 안정성을 보장한다.</p>

<p>예를 들어 C#의 String 클래스의 경우 sealed로 선언되어 있어 개발자가 해당 클래스를 상속하거나 수정할 수 없도록 만들어 클래스의 안정성을 보장하도록 한다.</p>
