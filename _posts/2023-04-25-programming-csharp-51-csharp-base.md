---
title: "C# 상위 멤버 접근 키워드 : base"
excerpt: "C# 상위 멤버 접근 키워드 : base"
categories:
  - CSharp
permalink: /programming/csharp/51-csharp-base/
tags:
  - "CSharp"
  - "base"
  - "C#"
  - "keyword"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/51
---

<h3>base</h3>
<p>상위 클래스로부터 파생된 클래스에서 사용할 수 있는 키워드로 상위 클래스의 멤버에 액세스 할 때 사용된다.</p>
<p>예를 들어 상위 클래스에서 정의된 멤버를 파생 클래스에서 다시 구현할 때 base 키워드를 사용하면 상위 클래스의 멤버에 접근할 수 있다.</p>

<pre class="csharp"><code>public class Parent{
	virtual public void CallFunc(){
    	Console.WriteLine("Parent Call");
    }
}

public class Child : Parent{
	override public void CallFunc(){
    	base.CallFunc();
        Console.WriteLine("Child Call");
    }
}

Child child = new Child();
child.CallFunc();
// Parent Call, Child Call 모두 출력됨</code></pre>
