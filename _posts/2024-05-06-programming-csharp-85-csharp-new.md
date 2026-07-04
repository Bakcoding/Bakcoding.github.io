---
title: "C# 인스턴스 생성 키워드 : new - 생성자와 소멸자"
excerpt: "C# 인스턴스 생성 키워드 : new - 생성자와 소멸자"
categories:
  - CSharp
permalink: /programming/csharp/85-csharp-new/
tags:
  - "CSharp"
  - "C#"
  - "Constructor"
  - "Destructor"
  - "New"
  - "객체"
  - "메모리 할당"
  - "생성자"
  - "소멸자"
  - "인스턴스"
toc: true
toc_sticky: true
date: 2024-05-06
last_modified_at: 2024-05-06
source_url: https://b-note.tistory.com/85
---

<h3 style="color: #000000;">new</h3>
<h4 style="color: #000000;">메모리 할당</h4>
<p>new 키워드를 사용하면 CLR은 관리되는 힙에 객체를 위한 메모리를 할당한다.&nbsp;</p>
<p>할당된 메모리는 해당 객체에 대한 모든 참조가 없어질 때까지 메모리에 존재하고 더 이상 참조되지 않을 때 GC에 의해 관리된다.</p>
<pre class="arduino" style="background-color: #f8f8f8; color: #383a42; text-align: start;"><code>public class MyClass
{
    public int Number { get; set; }
}

public class Program
{
    public static void Main()
    {
        MyClass myObject = new MyClass();
        myObject.Number = 1;
        Console.WriteLine(myObject.Number);
    }
}</code></pre>


<h4>생성자</h4>
<p>생성자는 객체가 할당될 때 호출되는 생명주기 메서드(Lifecycle Methods)이다.</p>
<p>클래스의 객체를 생성하는 방식을 생각해 보면 new 키워드 뒤에 클래스명의 함수를 쓰는데 이 함수는 클래스에서 따로 작성하지 않았는데도 문제없이 컴파일된다.</p>

<pre class="csharp" style="background-color: #f8f8f8; color: #383a42; text-align: start;"><code>MyClass myObject = new MyClass();</code></pre>

<p>그 이유는 클래스에 별도로 생성자에 대한 작성을 하지 않아도 컴파일 단계에서 자동으로 기본 생성자를 만들어서 사용하기 때문에 컴파일 에러가 발생하지 않게 된다.</p>

<p>기본 생성자의 형태는 클래스 명의 메서드로 함수 내부에는 비어있는 형태로 볼 수 있다.</p>

<pre class="csharp" style="background-color: #f8f8f8; color: #383a42; text-align: start;"><code>public class MyClass
{
    public int Number { get; set; }
    // 기본 생성자 형태
    public Number(){}
}

public class Program
{
    public static void Main()
    {
        MyClass myObject = new MyClass();
        myObject.Number = 1;
        Console.WriteLine(myObject.Number);
    }
}</code></pre>
<p><br />생성자의 접근제한자를 private 등을 사용해서 클래스의 인스턴스 생성을 제한할 수 있다.</p>

<p>생성자는 파라미터를 추가한 형태로 선언이 가능하며 클래스의 인스턴스가 생성될 때 필드나 프로퍼티를 초기화하는 방법으로 사용할 수 있다.</p>

<pre class="csharp" style="background-color: #f8f8f8; color: #383a42; text-align: start;"><code>public class MyClass
{
    public int Number { get; set; }
    private string _id;
    private string _pw;
    private int _age;
    private bool _isAgree;
    
    // 기본 생성자 형태
    public Number(string id, string pw, int age, bool isAgree)
    {
    	_id = id;
        _pw = pw;
        _age = age;
        _isAgree = isAgree;
    }
}

public class Program
{
    public static void Main()
    {
        MyClass myObject = new MyClass("bak", "****", 19, true);
        // 에러 발생
        MyClass myObject = new MyClass();
    }
}</code></pre>

<p>이렇게 하면 인스턴스를 생성과 동시에 필드값을 초기화할 수 있다.</p>
<p>주의할 점은 이렇게 파라미터를 받는 생성자를 작성하게 되면 컴파일러에서는 더 이상 기본 생성자는 만들어 주지 않기 때문에 기본 생성자를 사용하려고 하면 컴파일 에러가 발생하게 되므로 기본 생성자도 사용하기를 원하면 추가로 작성해야 한다. 즉 생성자도 오버로딩이 가능하기 때문에 다양한 매개변수를 받는 생성자의 선언이 가능하다.</p>

<h4>소멸자</h4>
<p>생성자와는 호출 시점에만 차이가 있는 생명주기 메서드이다. (파괴자라고도 한다.)</p>
<p>소멸자는 객체가 소멸되는 시점에 호출되며 C#에서는 더 이상 객체가 참조되는 곳이 없을 때 GC에 의해서 관리되어 소멸될 때 소멸자가 호출된다.</p>

<p>따라서 소멸자의 호출 시점이 명확하지 않으므로 소멸자 내부에서 어떠한 기능을 수행시키게 한다면 동작에 대한 기대가 힘들기 때문에 C#에서는 이를 활용하는 경우는 드물다.&nbsp;</p>

<pre class="csharp"><code>public class MyClass
{
    public Number(){}
    // 소멸자 선언
    ~Number(){}
}</code></pre>

<p>소멸자는 직접 호출도 불가능하기 때문에 별도의 접근 제한자를 지정할 필요도 없다.</p>
