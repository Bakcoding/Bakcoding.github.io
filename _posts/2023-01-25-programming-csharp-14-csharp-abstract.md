---
title: "C#  클래스 추상화 키워드 : abstract"
excerpt: "C#  클래스 추상화 키워드 : abstract"
categories:
  - CSharp
permalink: /programming/csharp/14-csharp-abstract/
tags:
  - "CSharp"
  - "abstract"
  - "C#"
  - "derived"
  - "inherit"
  - "keyword"
  - "modifier"
  - "virtual"
toc: true
toc_sticky: true
date: 2023-01-25
last_modified_at: 2023-01-25
source_url: https://b-note.tistory.com/14
---

<h2>abstract</h2>
<p>추상적인</p>
<p>구현이 완전하지 않은 상태임을 타나내는 키워드이다.</p>
<p>클래스, 메서드, 프로퍼티, 인덱서, 이벤트와 함게 사용될 수 있다.&nbsp;</p>
<p>일반적으로 추상 클래스를 구현하는데 사용되며 자체적으로는 인스턴스화 되지 않고 파생된 비추상 클래스에 의해 구현되어 사용된다.&nbsp;</p>

<pre class="csharp"><code>    abstract class Person
    {
        public abstract int GetInfo();
    }

    class Joon : Person
    {
        private int m_age;
        public Joon(int age) =&gt; m_age = age;
        public override int GetInfo() =&gt; m_age;
    }

    public class Program
    {
        static void Main(string[] args)
        {
            // Error, cannot create an instance of the abstract type.
            Person person = new Person(); 

            Joon joon = new Joon(30);
            Console.WriteLine(joon.GetInfo());
        }
    }</code></pre>
<h2>Feature</h2>
<p>- 추상 클래스는 인스턴스화할수없다.</p>
<p>- 추상 클래스는 추상 메서드와 접근자를 포함할 수 있다.</p>
<p>- abstract 제한자는 sealed 제한자와 반대의미이므로 같이 사용할 수 없다.</p>
<p>&nbsp; (abstract : 상속을 필요로하는 제한자, sealed : 상속을 방지하기위한 제한자)</p>
<p>- 추상 클래스로부터 파생된 클래스는 반드시 추상 메서드와 접근자의 구현이 필요하다.</p>

<p>메서드와 프로퍼티의 선언에서 abstract 제한자의 사용은 구현을 포함하지 않는것을 나타낸다.</p>
<p>- 추상 메서드는 암묵적으로 가상 메서드이다.</p>
<p>- 추상 메서드는 오직 추상 클래스 내에서만 선언이 허용된다.</p>
<p>- 추상 메서드는 구현이 없어야하므로 선언시 중괄호가 필요하지 않다.</p>

<h2>Derived abstract class</h2>
<p>추상 클래스를 파생 클래스로 만들어 특정 가상 메서드의 상속하여 추상 메서드로 가상 메서드를 재정의할 수 있다.</p>
<pre class="csharp"><code>    public class BaseClass
    {
        public virtual void VirtualMethod(int i) { }
    }

    public abstract class AbstractClass : BaseClass
    {
        public abstract override void VirtualMethod(int i);
    }

	//DerivedClass.ViertualMethod는 BaseClass.VirtualMethod에 접근할 수 없다.
    public class DerivedClass : AbstractClass
    {
        public override void VirtualMethod(int i)
        {
            throw new NotImplementedException();
        }
    }</code></pre>
<p>추상 클래스로부터 파생된 클래스는 메서드의 원래 구현에 접근할 수 없다.&nbsp;</p>
<p>이러한 방식으로 추상 클래스는 파생 클래스로부터 가상 메서드의 구현을 강제할 수 있다.</p>
