---
title: "C# 열거형 키워드 : enum"
excerpt: "C# 열거형 키워드 : enum"
categories:
  - CSharp
permalink: /programming/csharp/47-csharp-enum/
tags:
  - "CSharp"
  - "C#"
  - "enum"
  - "type keyword"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/47
---

<h3>enum</h3>
<p>enumeration</p>
<p>열거형은 몇 개의 상수 값들을 가지며 이를 사용하여 변수를 선언하거나 함수에서 사용할 수 있다.</p>

<pre class="csharp"><code>enum Color { Red, Green, Blue };</code></pre>

<p>열거형 Color는 Red, Green, Blue라는 세 개의 상수값이 있다. 각 상수 값은 0부터 시작하는 숫자로 자동으로 지정된다.</p>
<p>Red=0, Green=1, Blue=2&nbsp;</p>
<p>선언된 순서로 값이 지정되기 때문에 순서에 영향을 받는다.</p>

<p>만약 Red=10 으로 선언된 경우 뒤에는 별도의 선언이 없는 경우 자동으로 Green=11, Blue=12로 지정된다.</p>

<p>열거형으로 정의된 상수 값은 변수나 함수에서 사용될 수 있다.</p>
<pre class="csharp"><code>Color myColor = new Color();	// 기본값 0 ( Red )
myColor = Color.Red;</code></pre>

<h3>enum to int</h3>
<p>enum은 캐스트를 통해서 정수로 사용하는것도 가능하다.</p>
<pre class="csharp"><code>int a = (int)Color.Red;</code></pre>

<h3>enum to string</h3>
<p>enum 값을 toString()하면 선언된 상수명으로 반환된다.</p>
<pre class="csharp"><code>string strColor = Color.Red.ToString();
// strColor는 Red 이다.</code></pre>

<h3>string to enum</h3>
<p>문자열에서 enum 상수명으로 사용하는것도 가능하다.</p>
<pre class="csharp"><code>string colorName = "Red";
Color color = new Color();
Enum.TryParse&lt;eCurrency&gt;(str, out curr);
// curr = Color.Red;</code></pre>

<p>숫자를 문자열 형태로 볼 수 있기 때문에 코드의 가독성을 올리기 위한 매크로상수처럼 사용하거나 특정 상태를 관리하기 위해서 사용하기 한다.</p>
