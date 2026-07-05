---
title: "JavaScript #11 함수"
excerpt: "JavaScript #11 함수"
categories:
  - Javascript
permalink: /programming/javascript/117-javascript-sharp11/
tags:
  - "JavaScript"
  - "Web"
  - "function"
  - "자바스크립트"
  - "함수"
toc: true
toc_sticky: true
date: 2024-07-23
last_modified_at: 2024-07-23
source_url: https://b-note.tistory.com/117
---

<h2>함수</h2>
<p>함수는 자바스크립트에서 재사용 가능한 코드 블록이자 일종의 객체이다. 따라서 속성도 가질 수 있으며 그 속성의 값이 변수라면 property, 함수라면&nbsp; method가 된다.</p>

<p>함수는 선언, 호출, 매개변수, 반환값으로 구성된다.</p>

<h3>함수 선언</h3>
<pre class="javascript"><code>// 선언
function greet(name) { // name : 매개변수
    return `Hello, ${name}!`; // 반환값
}
console.log(greet('Alice')); // "Hello, Alice!" // 호출</code></pre>

<h3>함수 표현식</h3>
<p>함수 선언과 달리 변수에 할당되는 방식으로 정의되는 함수이다.</p>
<pre class="javascript"><code>let greet = function(name) {
    return `Hello, ${name}!`;
};
console.log(greet('Bob')); // "Hello, Bob!"</code></pre>

<p><b>let greet</b> : let 변수로 greet라는 이름의 변수를 선언한다.</p>
<p><b>function(name) </b>&nbsp;: 매개변수 name을 받는 함수를 정의한다.</p>
<p><b>{ return ~ } </b>: 함수의 본문으로 'Hello, ${name}!'을 반환한다. 템플릿 리터럴을 사용하여 매개변수 name의 값을 포함한 문자열로 반환한다.</p>

<h3>화살표 함수</h3>
<p style="text-align: start">ES6부터 도입된 것으로 함수를 간결하게 표현하는 문법이다.</p>
<pre style="background-color: var(--bc-code-bg); color: var(--bc-code-text)"><code>let greet = (name) =&gt; `Hello, ${name}!`;
console.log(greet('Charlie')); // "Hello, Charlie!"</code></pre>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start">함수 키워드와 이름이 생략되고 전달받을 매개변수만 괄호 안에 표기한다.</p>
<p style="text-align: start">함수의 본문을 작성하는 중괄호와 반환 키워드가 생략되고 본문을 바로 표기할 수 있다.</p>
