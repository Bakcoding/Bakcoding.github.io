---
title: "JavaScript #5 유효 범위, 스코프(Scope)"
excerpt: "JavaScript #5 유효 범위, 스코프(Scope)"
categories:
  - Javascript
permalink: /programming/javascript/111-javascript-sharp5-scope/
tags:
  - "JavaScript"
  - "Web"
  - "scope"
  - "유효범위"
  - "자바스크립트"
toc: true
toc_sticky: true
date: 2024-07-21
last_modified_at: 2024-07-21
source_url: https://b-note.tistory.com/111
---

<p>스코프는 변수나 함수가 유효한 범위를 정의한다.</p>
<h2>함수 스코프</h2>
<p>함수 내부에서 선언된 변수의 유효 범위를 의미한다.&nbsp;</p>
<p>var 키워드로 선언된 변수는 함수 스코프를 가진다는 의미는 변수가 함수 내 어디서든 접근 가능하지만 함수 외부에서 접근할 수 없음을 의미한다.</p>

<pre class="javascript"><code>function Func() {
  var funcScopeVar = "I am inside a function";
  console.log(funcScopeVar); // "I am inside a function"
}

Func();
// console.log(funcScopeVar); // ReferenceError: functionScopedVariable is not defined</code></pre>

<p>Func 함수 내에서 선언된 var 변수 funcScopeVar는 함수 내부에서만 접근이 유효하고 함수 외부에서 접근할 때는 ReferenceError가 발생한다.</p>

<h2>블록 스코프</h2>
<p>블록 스코프는 중괄호 {}로 묶인 코드 블록 내부에서 선언된 변수의 유효 범위를 의미한다.</p>
<p>let과 const 키워드로 선언된 변수는 블록 스코프를 가진다. 이는 변수가 블록 내부에서만 접근 가능하며 블록 외부에서는 접근할 수 없음을 의미한다.</p>

<pre class="javascript"><code>if (true) {
  let blockScopedVariable = "I am inside a block";
  const anotherBlockScopedVariable = "I am also inside a block";
  console.log(blockScopedVariable);   // "I am inside a block"
  console.log(anotherBlockScopedVariable); // "I am also inside a block"
}

// console.log(blockScopedVariable);   // ReferenceError: blockScopedVariable is not defined
// console.log(anotherBlockScopedVariable); // ReferenceError: anotherBlockScopedVariable is not defined</code></pre>

<p>조건문의 중괄호 내에서 선언된 let과 const 변수들은 내부에서만 유효하며 블록 외부인 중괄호 바깥에서 접근 시 ReferenceError가 발생한다.</p>

<p>var의 경우 조건문의 중괄호 내에서 선언되어도 외부에서 접근이 유요하다.</p>
<pre class="javascript"><code>if (true) {
  var variable = "I am a var variable";
}

console.log(variable); // "I am a var variable"</code></pre>

<h3>호이스팅</h3>
<p>var, let, const로 선언된 변수는 모두 호이스팅 되지만 let, const로 선언된 변수는 TDZ로 인해 초기화 전에 접근이 불가능하게 된다.</p>


<h2>전역 스코프</h2>
<p>변수를 전역 스코프에서 선언할 때 각 키워드의 동작에는 차이가 있다.&nbsp;</p>
<p>전역 스코프에서 변수의 선언은 코드 전체에서 접근 가능한 범위를 의미하며 변수 선언 방식에 따라 전역 객체에 미치는 영향이 다르게 된다.</p>

<h3>var</h3>
<p>전역 변수로 선언된 var 변수는 전역 객체의 속성이 되며 같은 이름의 변수를 여러 번 선언할 수 있다.</p>
<pre class="javascript"><code>var globalVar = "I am a global var";
console.log(window.globalVar); // "I am a global var"

var globalVar = "I am a redefined global var";
console.log(window.globalVar); // "I am a redefined global var"</code></pre>

<p>같은 이름의 변수를 여러 번 선언이 가능하다는 점은 코드가 복잡해질수록 중복된 이름을 사용하여 의도하지 않게 값을 변경하는 등의 문제를 발생시킬 수 있다.</p>

<p>또한 전역 객체의 속성이 되기 때문에 전역 네임스페이스 오염을 발생시켜 다른 스크립트나 라이브러리와 충돌할 위험이 있다.</p>

<pre class="javascript"><code>var globalVar = "I am global";
console.log(window.globalVar); // "I am global"</code></pre>

<h3>let, const</h3>
<p>let, const로 선언된 전역 변수는 전역 객체의 속성이 되지 않으며 같은 이름의 변수를 같은 스코프에서 두 번 선언할 수 없다.</p>

<p>여기서 같은 스코프란 전역 스코프로 다른 함수, 블록 스코프에서는 해당 이름을 사용할 수 있다. 이 경우 해당 스코프 내에서 선언된 변수로만 접근이 가능해지므로 전역에 존재하는 동일한 이름의 다른 변수는 접근할 수 없다.</p>

<pre class="javascript"><code>let globalLet = "I am a global let";

function func() {
  let globalLet = "I am a local let";
  console.log(globalLet); // "I am a local let"
}

func();
console.log(globalLet); // "I am a global let"</code></pre>
