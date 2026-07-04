---
title: "C# Yes or No 키워드 : bool"
excerpt: "C# Yes or No 키워드 : bool"
categories:
  - CSharp
permalink: /programming/csharp/41-csharp-yes-or-no-bool/
tags:
  - "CSharp"
  - "bool"
  - "C#"
  - "type keyword"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/41
---

<h3>bool</h3>
<p>영국의 수학자 겸 논리학자인 조지 불의 이름에서 유래되었다.</p>
<p>bool은 참과 거짓의 값을 저장하는 변수타입으로 논리 자료형이라고도 한다.</p>

<p>프로그래밍 언어마다 다르지만 true, false는 정수형 1, 0과도 대응된다.</p>
<p>조건문과 논리 연산자 등에서 많이 사용된다.</p>

<h3>조건문</h3>
<pre class="csharp"><code>bool isDone = true;
if (isDone)
{
	Console.WriteLine("작업 완료");
}</code></pre>

<h3>논리 연산자</h3>
<p>&amp;&amp; (and) : 좌항과 우항이 모두 true일 때 true를 반환한다.</p>
<p>||(or) : 좌항과 우항 중 하나라도 true이면 true를 반환한다.</p>
<p>!(not) : 피연산자의 값을 반대로 반환한다.</p>

<pre class="csharp"><code>int x = 10;
bool b1 = ( x &gt; 5 ) &amp;&amp; ( x &lt; 20 );	// b1 == true
bool b2 = ( x &lt; 0 ) || ( x &gt; 100 );	// b2 == true
bool b3 = !(x == 10);	// b3 == false</code></pre>

<p>bool 타입의 가장 흔하게 사용하는 방식으로 토글이 있다.</p>

<pre class="csharp"><code>isDone = !isDone;</code></pre>

<p>해당 코드가 실행되면 isDone은 언제나 현재 값의 반대 값을 가지게 되며 이 코드를 통해서 true와 false를 번갈아 가지는 토글 기능을 갖게 된다.</p>
