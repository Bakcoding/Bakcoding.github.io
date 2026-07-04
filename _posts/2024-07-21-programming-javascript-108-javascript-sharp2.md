---
title: "JavaScript #2 표현식"
excerpt: "JavaScript #2 표현식"
categories:
  - Javascript
permalink: /programming/javascript/108-javascript-sharp2/
tags:
  - "JavaScript"
  - "Web"
  - "자바스크립트"
toc: true
toc_sticky: true
date: 2024-07-21
last_modified_at: 2024-07-21
source_url: https://b-note.tistory.com/108
---

<p>표현식은 코드에서 값으로 평가될 수 있는 코드의 조각이라고 말할 수 있다.</p>
<p>표현식의 결과는 값이 될 수 있으며, 이를 통해 값을 할당하거나 다른 표현식의 일부로 사용할 수 있다.</p>

<p>표현식을 파악하면 자바스크립트의 문법이 어떤 코드의 조각들로 작성되어서 변수의 값이 할당되고 조건문 및 반복문 등이 구성되고 함수의 인수로 전달되는지 알 수 있다.</p>

<h2>표현식 종류</h2>
<p><b>리터럴 표현식</b></p>
<p>고정된 값을 나타낸다.</p>
<p>가장 간단한 형태로 다른 표현식을 포함하지 않는 독립적인 표현식이다.</p>
<pre class="javascript"><code>1; // 숫자 리터럴
"hello" // 문자열 리터럴
true; //boolean 리터럴
[1,2,3]; // 배열 리터럴
{key:"value"}; // 객체 리터럴</code></pre>

<p><b>식별자 표현식</b></p>
<p>변수나 상수의 이름을 나타낸다.</p>
<pre class="javascript"><code>let x = 10;
x; // 식별자 표현식 값 : 10</code></pre>


<p><b>연산자 표현식</b></p>
<p>연산자를 사용하여 값을 생성한다.</p>
<pre class="javascript"><code>5 + 5;
x * 2;
y &gt; 5;</code></pre>

<p><b>함수 호출 표현식</b></p>
<p>함수를 호출하여 값을 생성한다.</p>
<pre class="javascript"><code>function add(a, b){
	return a + b;
}
add(3, 4); // 함수 호출 표현식, 값 : 7</code></pre>

<p><b>객체 프로퍼티 접근 표현식</b></p>
<p>프로퍼티에 접근하는 표현식이다.</p>
<pre class="javascript"><code>let person = { name : "Bak", age: 25};
person.name; // 객체 프로퍼티 접근 표현식, 값 : "Bak"</code></pre>

<p><b>산술 표현식</b></p>
<pre class="javascript"><code>let a = 5;
let b = 10;
let sum = a + b; // 값 15</code></pre>
<p>수로 변환 불가능한 피연산자인 경우 NaN(Not-a-Number) 값으로 변환되며 피연산자 중 하나라도 NaN일 경우 연산 결과는 NaN이 된다.</p>

<p><b>비교 표현식</b></p>
<pre class="javascript"><code>let isEqual = (a === b);</code></pre>

<p><b>논리 표현식</b></p>
<pre class="javascript"><code>let isAdult = (age &gt;= 25 &amp;&amp; age &lt; 100);</code></pre>

<p><b>삼항 표현식</b></p>
<pre class="javascript"><code>let access = (age &gt;= 18) ? "Adult" : "None";</code></pre>

<h2>표현식 사용</h2>
<p><b>변수 할당</b></p>
<pre class="javascript"><code>let result = 5 + 10; // 연산자 표현식을 사용하여 result에 값 할당</code></pre>

<p><b>조건문</b></p>
<pre class="javascript"><code>let age = 25;
if (age &gt;= 25) { // 비교 연산자 표현식을 사용한 조건문
	console.log("Bakcdoing's Blog");
}</code></pre>

<p><b>함수 인수</b></p>
<pre class="javascript"><code>fuction greet(name){
	console.log("Hello, " + name);
}
greet("Bak"); // 문자열 리터럴을 함수 인수로 사용</code></pre>
