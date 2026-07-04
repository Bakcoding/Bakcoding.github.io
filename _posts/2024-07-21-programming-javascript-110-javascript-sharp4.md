---
title: "JavaScript #4 변수"
excerpt: "JavaScript #4 변수"
categories:
  - Javascript
permalink: /programming/javascript/110-javascript-sharp4/
tags:
  - "JavaScript"
  - "Web"
  - "Variable"
  - "변수"
  - "자바스크립트"
toc: true
toc_sticky: true
date: 2024-07-21
last_modified_at: 2024-07-21
source_url: https://b-note.tistory.com/110
---

<h2>변수</h2>
<p>자바스크립트에서 변수를 선언할 때 사용하는 키워드에는 var, let, const가 있다.</p>
<p>각 키워드는 변수의 스코프와 재할당 가능성, 호이스팅 방식에서 차이가 있다.</p>

<h2>var</h2>
<p><b>함수 스코프</b></p>
<p>var로 선언된 변수는 함수 스코프를 가지며 함수 내에서 선언된 변수는 함수 전체에서 접근할 수 있다.</p>

<p><b>호이스팅</b></p>
<p>var로 선언된 변수는 호이스팅 되며<span style="color: #333333; text-align: start;"><span>&nbsp;</span></span>선언이 코드의 최상단으로 끌어올려지고 <span style="color: #333333; text-align: start;">초기화는 선언한 위치에서 이루어진다.</span></p>

<p><b><span style="color: #333333; text-align: start;">변수 재선언 가능</span></b></p>
<p><span style="color: #333333; text-align: start;">같은 스코프 내에서 여러 번 선언할 수 있다. 이때 이전 값은 덮어씌워지게 된다.</span></p>

<p><b><span style="color: #333333; text-align: start;">전역 객체에 속성으로 추가</span></b></p>
<p><span style="color: #333333; text-align: start;">전역 스코프에서 선언된 var변수는 전역 객체의 속성이 된다. (global 또는 window)</span></p>

<pre class="javascript"><code>console.log(x); // undefined (호이스팅)
var x = 5;
console.log(x); // 5

if (true) {
  var y = 10;
}
console.log(y); // 10 (블록 스코프가 아님)

function foo() {
  var z = 20;
  console.log(z); // 20
}
foo();
// console.log(z); // ReferenceError: z is not defined (함수 스코프)</code></pre>

<h2>let&nbsp;</h2>
<p><b>블록스코프</b></p>
<p>let으로 선언된 변수는 블록 스코프를 가지고 블록 내에서만 접근할 수 있다.</p>

<p><b>호이스팅</b></p>
<p>let으로 선언된 변수는 호이스팅 되지만 선언하기 전에는 사용할 수 없으며 이를 '일시적 사각지대(TDZ, Temporal Dead Zone)'이라고 한다.</p>

<p><b>변수 재선언 불가</b></p>
<p>같은 스코프 내에서 두 번 선언할 수 없다.</p>
<pre class="javascript"><code>// console.log(a); // ReferenceError: Cannot access 'a' before initialization (TDZ)
let a = 5;
console.log(a); // 5

if (true) {
  let b = 10;
  console.log(b); // 10
}
// console.log(b); // ReferenceError: b is not defined (블록 스코프)

let c = 15;
// let c = 20; // SyntaxError: Identifier 'c' has already been declared (재선언 불가)</code></pre>

<h2>const</h2>
<p><b>블록스코프</b></p>
<p>const로 선언된 변수는 블록 스코프를 가진다.</p>

<p><b>호이스팅</b></p>
<p>const로 선언된 변수는 호이스팅 되지만, 선언하기 전에는 사용할 수 없다. TDZ에 영향을 받는다.</p>

<p><b>변수 재선언 불가</b></p>
<p>같은 스코프 내에서 두 번 선언할 수 없다.</p>

<p><b>상수</b></p>
<p>const로 선언된 변수는 초기화 후에 값을 변경할 수 없지만 객체나 배열의 속성은 변경할 수 있다.</p>

<pre class="javascript"><code>// console.log(d); // ReferenceError: Cannot access 'd' before initialization (TDZ)
const d = 5;
console.log(d); // 5

if (true) {
  const e = 10;
  console.log(e); // 10
}
// console.log(e); // ReferenceError: e is not defined (블록 스코프)

const f = 15;
// const f = 20; // SyntaxError: Identifier 'f' has already been declared (재선언 불가)

// f = 25; // TypeError: Assignment to constant variable. (값 변경 불가)

const obj = { key: "value" };
obj.key = "new value"; // 객체의 속성은 변경 가능
console.log(obj.key); // "new value"

const arr = [1, 2, 3];
arr.push(4); // 배열의 요소는 추가 가능
console.log(arr); // [1, 2, 3, 4]</code></pre>
