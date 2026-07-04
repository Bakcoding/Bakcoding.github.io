---
title: "C# Namespace 키워드"
excerpt: "C# Namespace 키워드"
categories:
  - CSharp
permalink: /programming/csharp/53-csharp-namespace/
tags:
  - "CSharp"
  - "C#"
  - "extern alias"
  - "keyword"
  - "namespace"
  - "operator"
  - "Using"
toc: true
toc_sticky: true
date: 2023-04-27
last_modified_at: 2023-04-27
source_url: https://b-note.tistory.com/53
---

<h3>Namespace</h3>
<p>네임스페이스는 다른 식별자와 구분하기 위한 식별자의 집합을 의미한다.</p>
<p>즉, 클래스, 구조체, 인터페이스, 델리게이트, enum 등의 데이터 형식, 메서드, 변수 등을 구별하기 위한 컨테이너 역할을 한다.&nbsp;</p>

<p>예를 들어 클래스명 같은 경우 일반적으로 흔히 사용하는 이름으로 작명한 경우 다른 패키지를 설치하여서 사용하다 보면 동일한 클래스명으로 인해서 충돌이 발생할 수 있다. 이럴 때 클래스를 자신만의 네임스페이스로 지정해서 구분해 두면 이름이 중복되더라도 namespace.class와 같이 구분해서 접근되기 때문에 에러를 방지할 수 있다.</p>

<pre class="csharp"><code>public class MyClass{}

namespace MyScript
{
	public class MyClass{}
}
// 네임스페이스로 인해 동일한 이름의 두 클래스는 구분 된다.</code></pre>

<p>MyScript 네임스페이스로 싸여진 MyClass를 사용하기 위해서는 MyScript에서 사용할 것임을 명시해야 한다.</p>

<h3>using</h3>
<p>코드에서 다른 네임스페이스를 가져오기 위해 사용된다.</p>
<p>네임스페이스로 싸인 클래스를 사용하기 위해서는 해당 네임스페이스를 명시한 뒤에 그 내부의 클래스에 접근이 가능하다.</p>

<pre class="csharp"><code>namespace MyScript
{
	public class MyClass{}
}

public void Main(string[] args)
{
	MyScript.MyClass() myClass = ...
}</code></pre>

<p>만약 네임스페이스로 싸여진 클래스의 사용이 빈번해지게 되면 매번 명시해 주는 것이 번거롭고 코드의 가독성을 떨어뜨리게 된다.</p>

<p>이때 using을 통해서 사용할 네임스페이스를 전역으로 선언할 수 있다.</p>

<pre class="csharp"><code>using MyScript;

~

public void Main(string[] args)
{
	MyClass myClass = ... // using으로 인해서 MyScript의 MyClass임을 알 수 있다.
}</code></pre>

<p>그럼에도 동시에 동일한 클래스명을 가지게 되는 경우에는 코드 앞에 네임스페이스를 명시해주어야 한다.</p>

<h3>operator</h3>
<p>연산자 오버로딩을 정의하는 데 사용되는 키워드이다.&nbsp;</p>
<p>산술, 비교, 논리 등의 연산자를 재정의하여 다른 연산을 수행하도록 한다.&nbsp;</p>
<p>예를 들어 내가 만든 타입의 경우 내장 연산자에는 정의되어있지 않기 때문에 계산이 불가능한데 이때 오버로딩을 해서 내가 만든 타입을 연산자로 처리하고 결과를 리턴할 수 있다.</p>

<pre class="csharp"><code>public static MyClass operator +(MyClass a, MyClass b)
{
	// add MyClass a and b
    return result;
}

public void Main(string[] args)
{
	MyClass myClass1 = new MyClass();
    MyClass myClass2 = new MyClass();
    
    // 오버로딩한 내용으로 결과를 반환받게 된다.
    MyClass result = myClass1 + myClass2;
}</code></pre>
<p>내가 만든 클래스 타입의 MyClass 두 개를 + 연산하기 위해서 + 연산자를 오버로딩했다.</p>
<p>원하는 결과를 얻기 위해서는 내부에서 필요한 동작을 구현하면 MyClass 결과를 return 받을 수 있다.</p>

<h3>extern alias</h3>
<p>다른 어셈블리를 참조할 때 사용되는 지시어이다.</p>
<p>일반적으로 프로젝트에서는 하나 이상의 어셈블리를 참조해야 하는데 두 개 이상의 어셈블리가 같은 이름을 가지고 있는 경우 이를 구분하기 위해서 extern alias를 사용할 수 있다.</p>

<pre class="csharp"><code>extern alias A1;
extern alias A2;

A1::SomeNamespace.SomeClass someObjcet = new A1::SomeNamespace.SomeClass();
A2::SomeNamespace.SomeClass anotherObjcet = new A2::SomeNamespace.SomeClass();</code></pre>
<p>A1과 A2는 각각 어셈블리의 별칭으로 이를 이용해서 어셈블리의 이름을 지정할 수 있다. 이렇게 구분지은 어셈블리는 동일한 이름을 가지고 있더라도 참조할 때 충돌하지 않는다.</p>

<h3>:: operator</h3>
<p>:: 연산자는 extern alias 지시어를 사용해 참조된 어셈블리 내의 형식을 참조하기 위해서 사용한다.</p>
<p>System 네임스페이스에 있는 COnsole 클래스를 사용하고자 할 때 System.Console로 사용할 수 있지만 다른 어셈블리에 있는 System 네임스페이스의 Console을 사용하고자 할 때는 extern alias 지시어를 사용한 구분이 필요하다.</p>

<pre class="csharp"><code>extern alias aliasName;
aliasName::System.Console.WriteLine("Hello World");</code></pre>
<p>여기서 aliasName은 다른 어셈블리에서 사용할 alias 이름을 지정하는 데 사용된다.</p>
<p>:: 연산자는 aliasName과 System.Console을 구분하는 데 사용한다.</p>
