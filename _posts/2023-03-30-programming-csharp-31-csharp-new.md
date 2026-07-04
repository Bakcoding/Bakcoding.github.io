---
title: "C# 인스턴스 생성 키워드 : new"
excerpt: "C# 인스턴스 생성 키워드 : new"
categories:
  - CSharp
permalink: /programming/csharp/31-csharp-new/
tags:
  - "CSharp"
  - "C#"
  - "inherit"
  - "instance"
  - "keyword"
  - "modifier"
  - "New"
toc: true
toc_sticky: true
date: 2023-03-30
last_modified_at: 2023-03-30
source_url: https://b-note.tistory.com/31
---

<h3>new</h3>
<h4>Instance</h4>
<p>객체를 생성할때 사용한다.</p>
<p>C#에서는 내장 클래스인 string, int, double 등을 포함한 모든 클래스 object를 상속받기 때문에&nbsp; new 키워드를 사용해서 객체를 생성할 수 있다.&nbsp;</p>
<pre class="bash"><code>int n = new int();
string s = new string();
MyStruct structInstance = new MyStruct();
MyClass classInstance = new MyClass();</code></pre>
<p>하지만 내장 클래스들은 구조체로 정의되어 있기 때문에 구조체 변수를 생성할 때 new를 사용하지 않고 객체를 바로 생성할 수 있다.</p>
<pre class="bash"><code>int n = 0;
float f = 1.0f;</code></pre>
<p>string의 경우 .Net에서 특별히 내부적으로 string literal로 정의되어 있는데 때문에 일반적인 참조 타입과는 다르게 직접 변수를 할당하여 객체가 생성이 가능하다.&nbsp;&nbsp;</p>

<p><b>* string literal : </b>문자열 상수는 소스 코드 상에 고정된 문자열 값이다.</p>

<h4>Inherit</h4>
<p>new 키워드는 상속과 관련해서도 사용이된다.</p>
<p>상속 관계에 있는 클래스에서 메서드, 프로퍼티, 이벤트 등의 멤버를 재정의할 때 사용되는데 일반적으로 멤버의 재정의에는 override 키워드를 사용하지만 new키워드를 통해서도 멤버의 재정의가 가능하다.</p>

<pre class="bash"><code>class BaseClass
{
	public void Print()
    {
    	Console.WriteLine("Base class");
    }
}

class DerivedClass : BaseClass
{
	public new void Print()
    {
    	Console.WriteLine("Derived class");
    }
}</code></pre>
<p>여기서 new 키워드를 사용하여 재정의된 메서드는 부모 클래스에서 정의된 멤버와 자식 클래스에서 정의된 멤버가 모두 유지되는데 이는 덮어쓰는 override와 다르게 두 개의 멤버가 서로 다른 것으로 재정의된 메서드는 부모 클래스의 멤버와는 관계가 없는 새로운 멤버로 취급된다.</p>
<pre class="bash"><code>DerivedClass obj = new DerivedClass();
obj.Print();
// "Derived class" 출력

BaseClass obj = new DerivedClass();
obj.Print();
// "Base class" 출력</code></pre>
