---
title: "C# 정적 키워드 : static"
excerpt: "C# 정적 키워드 : static"
categories:
  - CSharp
permalink: /programming/csharp/38-csharp-static/
tags:
  - "CSharp"
  - "C#"
  - "keyword"
  - "static"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/38
---

<p>클래스 멤버를 정의할 때 사용된다.</p>
<p>static으로 정의된 멤버는 객체 인스턴스에 속하는 것이 아닌 클래스 자체에 속하게 된다.</p>
<p>즉, 객체가 인스턴스화되기 전에도 해당 멤버에 접근이 가능한데 클래스 자체에 속하기 때문에 클래스 이름을 통해서 직접 호출이 가능하다.</p>

<pre class="csharp"><code>class MyClass
{
	public static int myStaticVariable;
    public static void myStaticMethod(){}
}

class OtherClass
{
	public void SomeFunc()
    {
    	MyClass.myStaticVariable = 10;
    	MyClass.mySaticMethod();
    }
}</code></pre>

<p>static 멤버는 모든 인스턴스에 공유되기 때문에 한 객체에서 static 멤버에 대한 수정이 있는 경우 다른 객체에서도 동일한 값을 가지게 된다. 따라서 static 멤버는 클래스의 인스턴스와 관련이 없는 작업을 수행할 때 사용되며 일반적으로 유틸리티 클래스의 메서드나 상수 특정 클래스에서 공통으로 사용하는 변수 등을 정의할 때 static 키워드가 사용된다.</p>

<p>주의할 점은 모든 객체에서 공유되므로 서로 다른 스레드에서 동시에 static 멤버를 수정하는 상황이 발생할 수 있는 즉, thread-safe 하지 않기 때문에 멀티스레드 환경에서는 문제가 발생할 수 있다.</p>

<p>이러한 특징 때문에 static을 사용할 때는 몇가지 당연한 규칙이 있다.</p>

<p>우선 static 클래스의 모든 멤버는 static으로 선언되어야 한다.</p>
<p>클래스가 static이라는 것은 별도의 인스턴스를 생성하지 않아도 해당 클래스를 어디서든 사용이 가능하고 항시 메모리에 올라가 있는 상태라는 뜻이므로 인스턴스가 생성될 때 변수 할당이 이루어지는 일반 변수의 선언은 허용되지 않게 된다.</p>

<pre class="csharp"><code>public static class MyStaticClass
{
	// 불가능
    public int number_1;
    // 가능
    public static int number_2;
    static int number_3;
}</code></pre>

<p>하지만 반대로 static 클래스가 아니어도 내부의 멤버가 static으로 선언되는 것은 가능하다.&nbsp;</p>

<pre class="csharp"><code>public class MyClass
{
	public static int MyStaticVar = 0;
    public int MyVar = 0;
}</code></pre>

<h3>정리</h3>
<p>static은 처음 선언된 이후 메모리에 상주하기 때문에 언제든 접근 가능하다.</p>
<p>따라서 빈번하게 사용되는 공통적인 변수의 경우 정적으로 선언해서 사용하는 것이 좋을 수 있지만 너무 많은 static을 사용하게 되면 그만큼 상주하는 메모리가 많아지는 것이기 때문에 적절한 사용이 필요하다.</p>
