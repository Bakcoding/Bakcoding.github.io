---
title: "Arrow Function"
excerpt: "Arrow Function"
categories:
  - Javascript
permalink: /programming/javascript/147-arrow-function/
tags:
  - "JavaScript"
  - "Web"
  - "anonymous function"
  - "arrow function"
  - "no bind"
toc: true
toc_sticky: true
date: 2024-08-26
last_modified_at: 2024-08-26
source_url: https://b-note.tistory.com/147
---

<h2>Arrow Function</h2>
<p><b>화살표 함수</b></p>
<p>화살표 함수는 return 밖에 없는 함수를 줄여서 표현할 수 있는 함수로, 람다식이라고도 부른다.</p>

<pre class="javascript"><code>function add(a, b){
	return a + b;
}
console.log(add(1, 4)); // 5

// Arrow Function
const add = (a, b) =&gt; {
	return a + b;
}

// 또는 
// const add = (a, b) =&gt; a + b;
console.log(add(1, 4)); // 5</code></pre>


<p>람다식의 표현은 함수의 앞에 매개변수를 괄호로 묶고 화살표 연산자를 사용한 뒤에 함수의 본문을 작성한다.</p>

<p>화살표 함수의 특징은 함수명, arguments, this 세 가지가 없다.</p>

<p>함수명이 없으므로 익명 함수로 동작하게 된다.</p>

<h2>Anonymous Function</h2>
<p><b>익명 함수</b></p>
<p>익명 함수는 이름이 없는 함수로 함수 코드가 변수명에 저장된 형태이다.</p>

<p>따라서 변숫값으로 구성된 함수 코드를 다른 변수명에 변수를 대입하듯이 사용되거나 다른 함수의 인수로 전달하는 방식으로 주로 사용된다.</p>

<pre class="javascript"><code>const func = function() {
	console.log("Anonymous Function");
};</code></pre>

<p>add라는 이름의 변수에 화살표 함수로 만든 이름 없는 익명 함수가 할당된다.</p>

<p>이렇게 익명함수는 간단한 표현으로 가독성과 간결함이 좋기 때문에 주로 일회성 작업이나 콜백 함수로 사용된다.</p>

<h4>One-time Use</h4>
<p><b>일회성 사용</b></p>
<p>익명 함수는 함수가 특정 작업을 수행한 후 다시 호출될 필요가 없는 경우와 같이 일회성으로 사용되는 경우가 많다.</p>

<pre class="javascript"><code>setTimeOut(function() {
	console.log("Time Out");
}, 2000);</code></pre>

<p>setTimeOut에 전달된 익명 함수는 2초의 시간 지연 후 한 번만 실행되게 된다.</p>

<h4>변수나 프로퍼티에 할당 가능</h4>
<p>일반적으로 변수나 객체의 프로퍼티에 할당될 수 있다. 이를 사용해서 여러 곳에서 재사용이 가능하다.</p>

<pre class="javascript"><code>conse obj = {
	greet : function() {
    	console.log("Hello");
    }
};
obj.greet(); // Hello</code></pre>

<p>greet 프로퍼티에 할당된 익명 함수는 객체를 통해서 여러 번 다시 사용이 가능하다.</p>

<h4>자신을 참조할 수 없음</h4>
<p>익명 함수는 이름이 없기 때문에 일반적으로 함수 내부에서 자신을 직접 참조할 수 없다.</p>

<p>따라서 재귀 호출과 같이 자신을 호출이 필요한 경우에는 이름이 있는 함수를 사용하는 것이 좋지만 이를 우회하여 표현식에 이름을 명시적으로 붙일 수 있다.</p>

<pre class="javascript"><code>const factorial = function f(n) { // 이름 f 명시
	if (n &lt;= 1) return 1;
    return n * f(n - 1);
};
console.log(factorial(5)); // 120</code></pre>

<p>f는 함수 표현식의 이름이지만 factorial 변수에 익명 함수처럼 할당되어 내부에서 f를 사용하여 재귀 호출이 가능하다.</p>

<h2>this 바인딩 없음</h2>
<p>익명 함수 중에서도 화살표 함수는 자체적인 this를 가지지 않고 선언된 환경의 this를 상속받는다.</p>

<p>하지만 일반적인 익명 함수는 호출 문맥에 따라 this를 설정하는데 this 바인딩이 없기 때문에 화살표 함수의 경우 다르게 동작한다.</p>

<pre class="javascript"><code>// anonymous func
const obj = {
  name: "bak",
  regularFunction: function() {
    console.log(this.name);
  }
};
obj.regularFunction(); // bak 

// arrow func
window.name = "global scope";
const obj = {
  name: "bak",
  arrowFunction: () =&gt; {
    console.log(this.name);
  }
};
obj.arrowFunction(); // global scope</code></pre>

<p>일반적인 익명 함수에서 this는 문맥, 즉 함수가 호출되는 시점과 방식에 따라서 그 객체가 this가 된다.</p>

<p>하지만 화살표 함수는 고유한 this 바인딩이 없고 대신에 함수를 정의한 상위 스코프의 this를 상속받게 된다.</p>

<p>obj의 메서드로 정의된 것처럼 보이는 화살표 함수는 이러한 바인딩이 없는 특성으로 인해서 상위 스코프의 this를 상속받게 되어 위의 예제의 경우처럼 화살표 함수는 자신이 정의된 시점의 this를 상속받게 된다</p>

<p>따라서 this의 객체는 obj가 아닌&nbsp; 전역 객체 this를 가리키게 되고 this.name 은 window.name을 출력하게 된다.</p>
