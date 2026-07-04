---
title: "C# 코드 분할 키워드 : partial"
excerpt: "C# 코드 분할 키워드 : partial"
categories:
  - CSharp
permalink: /programming/csharp/34-csharp-partial/
tags:
  - "CSharp"
  - "C#"
  - "keyword"
  - "modifier"
  - "partial"
toc: true
toc_sticky: true
date: 2023-03-30
last_modified_at: 2023-03-30
source_url: https://b-note.tistory.com/34
---

<h3>Partial</h3>
<p>클래스, 구조체, 인터페이스 등의 선언에 사용된다.</p>
<p>partial 제한자로 선언된 클래스, 구조체, 인터페이스 등은 여러 파일에 나누어 작성할 수 있다.</p>

<pre class="csharp"><code>public class Person
{
	public string FirstName { get; set; }
    public string LastName { get; set; }
    
    public void SayHello()
    {
    	Console.WriteLine($"Hello, my name is {FirstName} {LastName}.");
    }
}</code></pre>
<p>Person이라는 클래스가 하나의 파일에 선언되고 작성되어 있다. 이 클래스를 여러 파일로 나누어 선언하기 위해 partial 키워드를 사용하면 다음과 같이 사용할 수 있다.</p>

<pre class="csharp"><code>// Person.cs
public partial class Person
{
	public string FirstName { get; set; }
    public string LastName { get; set; }
}

// Person_SayHello.cs
public partial class Person
{
	public void SayHello()
    {
    	Console.WriteLine($"Hello, my name is {FirstName} {LastName}.");
    }
}</code></pre>

<p>Person.cs 파일과 Person_SayHello.cs 파일은 같은 네임스페이스 안에 있으며 partial 키워드를 사용해 클래스를 선언하였기 때문에 다른 파일에서 Person 클래스를 동일하게 partial 키워드를 사용해 선언하면 이 클래스는 하나의 클래스로 인식된다. partial로 선언된 클래스는 컴파일 시점에 자동으로 하나의 클래스로 합쳐지기 때문에 별도의 참조가 필요하지 않다.</p>

<p>이러한 기능은 특히 협업에서 용이하게 사용이 가능하다.</p>
<p>큰 규모의 코드를 개발하기 위해서 여러 개발자가 협업을 하게 된다면 동시에 하나의 클래스나 구조체를 작성하는 상황이 있다. 이런 상황에서 partial 키워드를 사용하여 하나의 클래스를 여러 파일에 나누어 각자 작성할 수 있고 이렇게 하면 동시에 작성을 각자가 코드를 작성하더라도 서로 영향을 주지 않고 작업을 진행할 수 있다.</p>

<p>양이 많은 코드의 경우 하나의 파일에 모두 작성하게 되면 보기나 수정이 힘들어진다. 이때 partial 키워드를 사용하면 코드를 작은 단위로 분할하여 작성할 수 있기 때문에 코드 가독성도 좋아지고 유지보수도 편리해진다.&nbsp;</p>
