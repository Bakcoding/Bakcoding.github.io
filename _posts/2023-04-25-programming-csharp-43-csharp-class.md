---
title: "C# 클래스 타입 키워드 : class"
excerpt: "C# 클래스 타입 키워드 : class"
categories:
  - CSharp
permalink: /programming/csharp/43-csharp-class/
tags:
  - "CSharp"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/43
---

<h3>class</h3>
<p>클래스는 객체 지향 프로그래밍에서 가장 중요한 개념 중 하나로 데이터와 해당 데이터를 다루는 메서드를 하나의 단위로 묶어서 정의한 사용자 정의 데이터 형식이다. C#에서는 기능들의 단위가 클래스로 만들이 지고 사용된다.</p>

<p>class는 일반적으로 클래스 멤버로 프로퍼티, 메서드, 이벤트, 인덱서, 생성자, 중첩 클래스 등을 포함할 수 있으며 클래스를 정의함으로써 해당 클래스를 사용해요 객체를 생성할 수 있다.&nbsp;</p>

<pre class="csharp"><code>class MyClass {
    // 클래스 멤버 정의
    private int myField;
    public void MyMethod() {
        // 메서드 구현
    }
}
.
.
.

MyClass myObject = new MyClass();</code></pre>
<p>MyClass는 class의 이름이며 myField와 MyMethod는 클래스의 멤버이다.</p>
<p>myField는 private 접근 제한자를 가지고 있어 클래스 내부에서만 접근이 가능하다. myMethod는 public 접근 제한자로 클래스 외부에서도 해당 클래스의 객체를 통해서 메서드를 호출할 수 있다.</p>

<p>myObject는 인스턴스화된 MyClass 객체이다.</p>
<p>클래스명을 타입으로 사용하여 변수를 선언하고 new를 통해서 해당 클래스의 객체를 생성해 할당한다.</p>
<p>myObject 변수를 사용하여 클래스의 멤버에 접근하여 사용할 수 있게된다.</p>
