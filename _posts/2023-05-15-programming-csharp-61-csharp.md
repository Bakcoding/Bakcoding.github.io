---
title: "C# 객체지향 프로그래밍"
excerpt: "C# 객체지향 프로그래밍"
categories:
  - CSharp
permalink: /programming/csharp/61-csharp/
tags:
  - "CSharp"
  - "C#"
  - "CLASS"
  - "Object Oriented Programming"
  - "OOP"
toc: true
toc_sticky: true
date: 2023-05-15
last_modified_at: 2023-05-15
source_url: https://b-note.tistory.com/61
---

<p>C#은 객체지향 언어로 객체지향 프로그래밍을 위한 개념들이 있다.</p>

<h3>Class</h3>
<p>객체를 정의하는 템플릿이며 객체의 상태를 나타내는 필드와 동작을 나타내는 메서드를 포함한다.</p>
<p>즉 클래스는 객체를 표현하기 위한 설계도로 볼 수 있다.</p>
<pre class="csharp"><code>public class MyClass
{
    // field, 멤버 변수
    public int id;
    public string name;
    public int age;
    
    // method, 멤버 함수
    public void Introduc()
    {
        string introduce = "My age : " + agem + "\nMy name : " + name;
    	Cosole.WriteLine(introduce);
    }
}</code></pre>
<p>MyClass라는 객체에는 id, name, age 멤버변수와 Introduce 메서드를 포함하고 있다.</p>

<h3>Instance</h3>
<p>클래스의 인스턴스로 실제로 메모리에 할당된 데이터이다. 객체는 클래스에서 정의된 필드와 메서드를 사용할 수 있으며 개별적인 상태를 유지한다.</p>
<pre class="csharp"><code>public void Main(string[] args)
{
    // Instance, MyClass 클래스의 객체
    MyClass myClass = new MyClass();
    myClass.id = 1;
    myClass.name = "bak";
    myClass.age = 30;
    myClass.Introduce();
    
    // Instance, myClass와는 개별적인 객체
    MyClass myClass2 = new MyClass();
    myClass2.id = 2;
    myClass2.name = "kim";
    myClass2.age = 25;
    myClass2.Introduce();
}</code></pre>
<p>동일한 MyClass를 인스턴스화한 myClass와 myClass2는 개별적인 객체이다.</p>

<h3>Inherit</h3>
<p>클래스 간의 계층 구조를 형성하여 코드의 재사용성과 구조화를 실현한다. 기존 클래스를 기반으로 새로운 클래스를 정의하고 확장할 수 있는데 ㅅ상속을 통해 부모 클래스의 멤버를 자식 클래스에서 사용하는 것이 가능하다.</p>

<pre class="csharp"><code>public class Parent
{ 
    public int id;
    public string name;
    
    public void MethodParent()
    {
    	Console.Log(id, name);
    }
}

public class Child
{
    public void MethodChild()
    {
    	id = 10;
        name = "bak";
        MethodParent();
    }
}</code></pre>
<p>재사용할 코드는 부모 클래스로 만들어서 자식 클래스에서 상속하여 그대로 사용할 수 있다.</p>

<h3>Polymophism</h3>
<p>다형성은 같은 이름의 메서드나 속성을 다른 방식으로 구현하는 개념이다. 다형성은 상속과 관련이 깊으며 부모 클래스의 타입으로 자식 클래스의 객체를 참조하면 다형성을 활용할 수 있다.</p>

<pre class="csharp"><code>public class Parent
{
    public virtual void MethodParent()
    {
    	Console.WriteLine("Call Parent Method");
    }
}

public class Child
{
 	public override void MethodParent()
    {
    	Console.WriteLine("Call Parent Method From Child");
    }
}</code></pre>
<p>다형성의 대표적인 예는 부모 클래스의 메서드를 자식에서 오버라이딩하는 경우가 있다.</p>

<h3>Encapsulation</h3>
<p>객체의 상태와 동작을 외부로부터 감추는것을 뜻한다.&nbsp; 클래스는 필드와 메서드를 적절한 접근 제한자로 제어하여 캡슐화를 구현할 수 있다. 이는 객체의 내부 구현을 보호하며 외부에서는 필요한 기능만 사용할 수 있도록 한다.</p>

<pre class="csharp"><code>public class MyClass
{
    private string name;
    private int age;
    
    public void SetName(string name)
    {
    	this.name = name;
    }
    
    public string GetName()
    {
    	return name;
    }
    
    public void SetAge(int age)
    {
    	this.age = age;
    }
    
    public int GetAge()
    {
    	return age;
    }
}

public class Program
{
    public static void Main(string[] args)
    {
    	MyClass myClass = new MyClass();
        myClass.SetName("Bak");
        myClass.SetAge(30);
        Console.WriteLine("Name : " + myClass.GetName());
        Console.WriteLine("Age : " + myClass.GetAge());
    }
}</code></pre>
<p>클래스에서 접근을 허용할 부분을 public 불필요한 부분은 private로 접근 제한자를 두어 필요한 부분만 제어할 수 있도록 한다.</p>

<h3>Abstract</h3>
<p>복잡한 시스템을 단순화하고 핵심적인 요소만을 추출하여 모델링하는 과정을 말한다. 추상화는 클래스의 공통적인 특징을 추출하여 부모 클래스나 인터페이스로 정의할 수 있다.</p>

<pre class="csharp"><code>public class Person
{
    public int age;
    public string name;
    public int countryCode;
    
    public virtual void Eat() {}
    public virtual void Sleep() {}
    public virtual void Work() {}
}

public class Student : Person
{
    public override void Work()
    {
    	Console.WirteLine("Studying");
    }
}

public class Teacher : Person
{
    public override void Work()
    {
    	Console.WriteLine("Teaching");
    }
}</code></pre>
<p>추상화는 클래스를 만들 때 필요한 기본 개념으로 재사용, 다형성 등을 고려하여 최대한 구체적이지 않으면서 공통적인 부분을 부모 클래스로 만들 때 필요하다.</p>
