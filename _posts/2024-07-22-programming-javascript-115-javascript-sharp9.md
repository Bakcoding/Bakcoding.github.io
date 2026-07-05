---
title: "JavaScript #9 데이터 타입"
excerpt: "JavaScript #9 데이터 타입"
categories:
  - Javascript
permalink: /programming/javascript/115-javascript-sharp9/
tags:
  - "JavaScript"
  - "Web"
  - "data cast"
  - "Data Type"
  - "데이터 타입"
  - "데이터 형변환"
  - "자바스크립트"
toc: true
toc_sticky: true
date: 2024-07-22
last_modified_at: 2024-07-22
source_url: https://b-note.tistory.com/115
---

<h2>기본 데이터 타입</h2>
<h3>숫자(Number)&nbsp;</h3>
<p>정수 및 부동 소수점 숫자를 포함한다.</p>
<pre class="javascript"><code>let integer = 42;
let float = 3.14;</code></pre>

<p><b>숫자 조작</b></p>
<p>산술 연산자를 사용해 숫자를 조작할 수 있다.</p>
<pre class="javascript"><code>let sum = 10 + 5; // 15
let difference = 10 - 5; // 5
let product = 10 * 5; // 50
let quotient = 10 / 5; // 2
let remainder = 10 % 5; // 0</code></pre>

<h3>문자열(String)</h3>
<p>텍스트 데이터를 나타낸다.</p>
<pre class="javascript"><code>let singleQuoteString = 'Hello, world!';
let doubleQuoteString = "Hello, world!";
let templateString = `Hello, ${name}!`;</code></pre>

<p><b>문자열 조작</b></p>
<p>연결 연산자를 사용해 문자열을 조작할 수 있다.</p>
<pre class="javascript"><code>let greeting = 'Hello' + ' ' + 'world'; // "Hello world"</code></pre>

<p>템플릿 리터럴</p>
<pre class="javascript"><code>let name = 'Alice';
let message = `Hello, ${name}!`; // "Hello, Alice!"</code></pre>

<h3>불리언(Boolean)</h3>
<p>참 또는 거짓 값을 가진다.</p>
<pre class="javascript"><code>let isTrue = true;
let isFalse = false;</code></pre>

<p><b>값과 조건 판단</b></p>
<pre class="javascript"><code>let isAdult = true;
if (isAdult) {
    console.log('You are an adult.');
} else {
    console.log('You are not an adult.');
}</code></pre>

<h3>null</h3>
<p>값이 비어 있음을 나타낸다.</p>
<pre class="javascript"><code>let emptyValue = null;</code></pre>

<h3>undefiend</h3>
<p>값이 정의되지 않았음을 나타낸다.</p>
<pre class="javascript"><code>let undefinedValue;</code></pre>

<p style="text-align: start"><b>null과 undefined의 차이</b></p>
<p style="text-align: start">null : 명시적으로 값이 없음을 나타내기 위해 사용된다.</p>
<p style="text-align: start">undefined : 변수가 선언되었지만 값이 할당되지 않았을 때의 초기 상태를 나타낸다.</p>

<pre class="javascript" style="background-color: var(--bc-code-bg); color: var(--bc-code-text); text-align: start"><code>let a = null;
let b;

console.log(a); // null
console.log(b); // undefined</code></pre>

<h3>객체(Object)</h3>
<p>키-밸류 쌍의 집합, 배열도 객체의 일종이다.</p>
<pre class="smali" style="background-color: var(--bc-code-bg); color: var(--bc-code-text)"><code>let person = {
    name: 'John',
    age: 30
};
let array = [1, 2, 3];</code></pre>

<p><b>객체와 배열의 초기화 및 조작</b></p>
<p>객체 초기화</p>
<pre class="javascript"><code>let car = {
    make: 'Toyota',
    model: 'Camry',
    year: 2020
};</code></pre>

<p>배열 초기화</p>
<pre class="javascript"><code>let numbers = [1, 2, 3, 4, 5];</code></pre>

<p>객체 속성 접근 및 조작</p>
<pre class="javascript"><code>console.log(car.make); // "Toyota"
car.year = 2021;
console.log(car.year); // 2021</code></pre>

<h2>데이터 타입 확인</h2>
<p>typeof 연산자를 사용하여 데이터 타입을 확인할 수 있다.</p>
<pre class="javascript"><code>console.log(typeof 42); // "number"
console.log(typeof 'Hello'); // "string"
console.log(typeof true); // "boolean"
console.log(typeof null); // "object" (자바스크립트의 역사적 이유로)
console.log(typeof undefined); // "undefined"
console.log(typeof {name: 'John'}); // "object"</code></pre>

<h2>데이터 타입 간의 변환</h2>
<p>자바스크립트에서는 데이터 타입 간의 변환이 자주 발생한다. 이를 명시적 변환과 암시적 변환으로 나눌 수 있다.</p>

<h2>명시적 변환(Explicit Conversion)</h2>
<h3>숫자로 변환&nbsp;</h3>
<p>Number(), parseInt(), parseFloat()</p>
<pre style="background-color: var(--bc-code-bg); color: var(--bc-code-text)"><code>let str = "123";
let num = Number(str); // 123
let int = parseInt("123.45"); // 123
let float = parseFloat("123.45"); // 123.45</code></pre>

<h3>문자열로 변환</h3>
<p>String()</p>
<pre style="background-color: var(--bc-code-bg); color: var(--bc-code-text)"><code>let num = 123;
let str = String(num); // "123"</code></pre>

<h3>불리언으로 변환</h3>
<p>Boolean()</p>
<pre style="background-color: var(--bc-code-bg); color: var(--bc-code-text)"><code>let str = "";
let bool = Boolean(str); // false</code></pre>

<h2>암시적 변환(Implicit Conversion)</h2>
<p>숫자와 문자열의 연산에서 발생</p>
<pre style="background-color: var(--bc-code-bg); color: var(--bc-code-text)"><code>let result = 123 + "456"; // "123456" (숫자가 문자열로 변환됨)</code></pre>
