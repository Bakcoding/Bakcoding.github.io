---
title: "C# 읽기 전용 키워드 : readonly"
excerpt: "C# 읽기 전용 키워드 : readonly"
categories:
  - CSharp
permalink: /programming/csharp/35-csharp-readonly/
tags:
  - "CSharp"
  - "C#"
  - "const"
  - "Difference"
  - "literal"
  - "readonly"
  - "static"
toc: true
toc_sticky: true
date: 2023-03-30
last_modified_at: 2023-03-30
source_url: https://b-note.tistory.com/35
---

<h3 style="color: #000000; text-align: start;">readonly</h3>
<p>변수 앞에 위치하면 해당 변수는 읽기 전용이 되어 해당 변수가 정의된 클래스나 구조체, 메서드 등에서만 수정이 가능하며 readonly로 선언된 변수는 선언할 때 또는 생성자에서 값을 할당해야한다.</p>

<pre class="csharp"><code>public class MyClass
{	
	readonly int myReadOnlyInt;
    public MyClass(int value)
    {
    	myReadonlyInt = value;
    }
}</code></pre>
<p>위 코드에서 myReadOnlyInt는 읽기 전용으로 선언되었기 때문에 생성자에서 값을 할당한 이후에는 변경이 불가능하다.</p>

<p>상수를 선언한다는 점에서 const와 비슷한데 둘의 차이를 비교할 필요가 있다.</p>

<h3>const vs readonly</h3>
<h4>초기화 방법</h4>
<p>const와 readonly는 초기화 방법에서부터 차이가 있다.</p>
<pre class="csharp"><code>// 반드시 선언과 동시에 초기화 필요
const int constNum = 10;

// 선언에서 뿐만 아니라 생성자에서 값을 할당해서 초기화 할 수 있다.
readonly int readonlyNum_1 = 10;
readonly int readonlyNum_2;
public MyClass(int value)
{
	readonlyNum_2 = value;
}</code></pre>

<h4>사용 범위</h4>
<p>const는 클래스 멤버 또는 데이터 형식 멤버로 선언할 수 있지만 클래스 멤버 중에서도 인스턴스 멤버는 const 키워드를 사용할 수 없다. 즉 인스턴스 변수, 인스턴스 메서드 등에서는 const 키워드 사용이 불가능하다.</p>
<pre class="csharp"><code>public class MyClass
{
    public const int number = 10;
    public void Test()
    {
        int test = number;
    }
}

public static class MyStaticClass
{
    public const int number = 20;
    public static void Test()
    {
        int test = number;
    }
}

public class OtherClass()
{
    public void TestMethod()
    {
        MyClass instance = new MyClass();
        // 접근 불가능함
        int test1 = instance.number;
        
		// static 클래스 인스턴스화 안됨
        //MyStaticClass staticInstance = new MyStaticClass();
        // 직접 호출가능
        int test2 = MyStaticClass.number;
    }
}</code></pre>

<h4>실행시간</h4>
<p>const는 컴파일 시간에 값이 결정되기 때문에 런타임 성능이 상대적으로 좋다.</p>
<p>readonly는 런타임에 값을 할당할 수 있기 때문에 const보다는 조금 더 느릴 수 있다.&nbsp;</p>
<p>그렇기 때문에 런타임에 값을 결정해야할 경우에만 readonly를 사용하고 그 이외에는 const를 사용하는게 낫다.</p>

<pre class="csharp"><code>public class MyClass
{
    public const int number = DateTime.Now.Year; // 컴파일 에러 발생
    public readonly int year = DateTime.Now.Year; // 실행 시간에 값이 결정됩니다.
}</code></pre>

<p>const와 readonly의 가장 큰 차이점은 값이 결정되는 시점이다.</p>
<p>const는 컴파일 타임 readonly는 런타임</p>

<p>따라서 애초에 고정된 값이라면 const를 사용하지만 인스턴스가 생성될 때 값을 할당하고 그 이후에 변경되지 않도록하려면 readonly를 사용하면된다.</p>
