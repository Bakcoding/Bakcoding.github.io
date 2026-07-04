---
title: "JavaScript #6 호이스팅(Hoisting)"
excerpt: "JavaScript #6 호이스팅(Hoisting)"
categories:
  - Javascript
permalink: /programming/javascript/112-javascript-sharp6-hoisting/
tags:
  - "JavaScript"
  - "Web"
  - "hoisting"
  - "자바스크립트"
  - "호이스팅"
toc: true
toc_sticky: true
date: 2024-07-21
last_modified_at: 2024-07-21
source_url: https://b-note.tistory.com/112
---

<h2>호이스팅</h2>
<p>변수나 함수 선언들이 포함된 범위 상단으로 끌어올려지는 동작을 말한다.</p>
<p>이는 코드의 실제 실행 순서와는 다르게 해석되어 변수와 함수의 선언만 끌어올려지고 초기화는 끌어올려지지 않는다는 점에서 의미를 가진다.</p>

<h2>변수 호이스팅</h2>
<p>변수의 선언은 호이스팅 되지만, 변수 초기화는 호이스팅 되지 않는다. 이는 변수 선언이 코드의 최상단으로 이동된 것처럼 동작하지만 초기화는 원래 위치에 남아 있음을 의미한다.</p>

<p>실제 코드</p>
<pre class="javascript"><code>console.log(a); // undefined
var a = 10;
console.log(a); // 10</code></pre>

<p>자바스크립트 엔진에 의해 해석된 코드</p>
<pre class="javascript"><code>var a;
console.log(a); // undefined
a = 10;
console.log(a); // 10</code></pre>

<p>a 변수의 선언만 끌어올려지고 초기화는 원래 위치에 남아있게 된다.</p>

<p>let, const 키워드의 경우 선언된 변수는 호이스팅 되지만 var와 달리 초기화 전에 해당 변수에 접근하면 '일시적 사각지대(TDZ, Temporal Dead Zone)'으로 인해서 ReferenceError가 발생한다.&nbsp;</p>

<h2>함수 호이스팅</h2>
<p>함수 선언은 변수 선언과 다르게, 함수의 정의 전체가 호이스팅 된다. 이는 함수가 코드에서 선언된 위치와 상관없이 호출될 수 있음을 의미한다.</p>

<p>작성된 함수 코드</p>
<pre class="javascript"><code>greet(); // "Hello, World!"

function greet() {
  console.log("Hello, World!");
}</code></pre>

<p>실행되는 엔진의 해석</p>
<pre class="javascript"><code>function greet() {
  console.log("Hello, World!");
}

greet(); // "Hello, World!"</code></pre>

<h2>함수 표현식 호이스팅</h2>
<p>함수 표현식은 변수 선언과 유사하게 동작하여 함수 선언과는 다르게 함수의 정의가 호이스팅 되지 않는다.</p>

<p>함수 표현식 코드</p>
<pre class="javascript"><code>sayHello(); // TypeError: sayHello is not a function

var sayHello = function() {
  console.log("Hello!");
};</code></pre>

<p>실행되는 엔진의 해석</p>
<pre class="javascript"><code>var sayHello;

sayHello(); // TypeError: sayHello is not a function

sayHello = function() {
  console.log("Hello!");
};</code></pre>

<p>sayHello 변수의 선언만 호이스팅 되어 상단으로 간다. 초기화는 원래 위치에 남아있어 sayHello가 함수로 초기화되기 전에 호출하기 때문에 TypeError가 발생한다.</p>

<h2>호이스팅 동작 원리</h2>
<p>자바스크립트의 실행 콘텍스트가 생성되는 과정에서 발생한다.&nbsp;</p>
<p>1. 생성 단계 : 변수와 함수 선언이 메모리에 저장되고 변수는 undefined로 초기화된다.</p>
<p>2. 실행 단계 : 코드를 순차적으로 실행하면서 변수에 값이 할당되고, 함수호출이 이루어진다.</p>

<p>작성된 코드</p>
<pre class="javascript"><code>console.log(a); // undefined
foo();          // "foo called"
console.log(bar); // undefined
// bar(); // TypeError: bar is not a function

var a = 10;

function foo() {
  console.log("foo called");
}

var bar = function() {
  console.log("bar called");
};

console.log(a);  // 10
foo();           // "foo called"
bar();           // "bar called"</code></pre>

<p>실행되는 엔진의 해석</p>

<pre class="javascript"><code>var a;
var bar;

function foo() {
  console.log("foo called");
}

console.log(a);  // undefined
foo();           // "foo called"
console.log(bar); // undefined
// bar(); // TypeError: bar is not a function

a = 10;
bar = function() {
  console.log("bar called");
};

console.log(a);  // 10
foo();           // "foo called"
bar();           // "bar called"</code></pre>

<p>따라서 의도하지 않은 문제가 발생하는 것을 막기 위해서는 호이스팅이 동작하는 방식에 대한 이해가 반드시 필요하다.&nbsp;</p>

<p>호이스팅으로 인한 문제를 예방하기 위해서 let, const 변수를 사용하는 것이 권장되는 방식이며 var 사용 시 코드의 순서에 유의할 필요가 있다.</p>
