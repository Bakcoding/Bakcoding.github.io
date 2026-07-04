---
title: "C# 멤버 명시 키워드 : this"
excerpt: "C# 멤버 명시 키워드 : this"
categories:
  - CSharp
permalink: /programming/csharp/52-csharp-this/
tags:
  - "CSharp"
  - "C#"
  - "keyword"
  - "this"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/52
---

<h3>this</h3>
<h4>인스턴스 특정</h4>
<p>현재 인스턴스를 가리키는 기능을 한다.</p>
<p>주로 멤버 메서드나 생성자에서 인스턴스 변수를 참조할 때 사용한다.</p>

<pre class="csharp"><code>class Person {
    private string name;
    private int age;

    public Person(string name, int age) {
        this.name = name;
        this.age = age;
    }

    public void PrintInfo() {
        Console.WriteLine("Name: " + this.name);
        Console.WriteLine("Age: " + this.age);
    }
}</code></pre>
<p>이와 같은 경우 this 키워드는 동일한 이름의 name과 age를 멤버와 매개변수를 구분하는 데 사용된다.</p>
<p>PrintInfo 내에서는 this를 사용하지 않고 호출해도 되지만 일관성을 유지하기 위해 사용하는 등 개발자의 선호도에 따라 사용여부가 다르다.</p>


<h4>생성자 호출</h4>
<p>다른 생성자를 호출할 때 사용할 수 있다.</p>
<pre class="csharp"><code>class Person {
    private string name;
    private int age;

    public Person(string name, int age) {
        this.name = name;
        this.age = age;
    }

    public Person(string name) : this(name, 0) {
    }

    public void PrintInfo() {
        Console.WriteLine("Name: " + this.name);
        Console.WriteLine("Age: " + this.age);
    }
}</code></pre>
<p>위와 같이 두 개의 오버로딩된 생성자가 선언되었을 때 string name 매개변수만 받는 생성자의 경우 호출될 때 Person(string name, int age) 생성자를 호출하며 이때 age 값을 0으로 호출하는 동작이 수행된다.</p>

<h3>인덱서</h3>
<p>인덱서는 클래스나 구조체 등의 객체를 배열처럼 인덱싱할 수 있게 해주는 것으로 대괄호 안에 인덱스를 전달하여 객체의 멤버 변수나 속성 값을 가져오거나 설정할 수 있다.</p>

<pre class="csharp"><code>public class MyList
{
    private string[] _data = new string[10];

    public string this[int index]
    {
        get =&gt; _data[index];
        set =&gt; _data[index] = value;
    }
}

class Program
{
    static void Main(string[] args)
    {
        MyList list = new MyList();
        list[0] = "Hello";
        list[1] = "World";
        Console.WriteLine(list[0]); // "Hello" 출력
        Console.WriteLine(list[1]); // "World" 출력
    }
}</code></pre>
<p>this 키워드로 정의된 인덱서는 string 형식의 배열 _data 멤버 변수를 instance [indexer]와 같이 바로 접근하여 사용할 수 있다.&nbsp;</p>

<p>인덱서를 사용하지 않을 경우에는 해당 멤버에 접근하기 위해서 별도의 public 프로퍼티나 메서드 또는 _data를 public으로 선언해야 한다.</p>
