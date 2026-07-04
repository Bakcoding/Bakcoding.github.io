---
title: "JavaScript #17 고차 함수(High-order Function)"
excerpt: "JavaScript #17 고차 함수(High-order Function)"
categories:
  - Javascript
permalink: /programming/javascript/123-javascript-sharp17-high-order-function/
tags:
  - "JavaScript"
  - "Web"
  - "high-order func"
  - "고차 함수"
  - "자바스크립트"
toc: true
toc_sticky: true
date: 2024-07-24
last_modified_at: 2024-07-24
source_url: https://b-note.tistory.com/123
---

<h2>고차 함수</h2>
<p>고차 함수는 함수형 프로그래밍 개념 중 하나로 함수를 인수로 받거나, 함수를 반환하는 함수를 말한다.</p>
<p>코드를 더 모듈화 하고 재사용 가능하게 만들며, 함수 조합과 같은 고급 프로그래밍 기술을 사용할 수 있게 해 준다.</p>

<h3>함수를 인수로 받는 고차 함수</h3>
<p>고차 함수는 다른 함수를 인수로 받아서 호출하거나, 인수로 받은 함수를 내부에서 사용하는 함수이다. 자바스크립트의 내장 메서드 중 'map', 'filter', 'reduce' 등이 이에 해당한다.</p>

<p><b>map</b></p>
<p>배열의 각 요소에 대해 제공된 함수를 호출하고, 그 결과를 새로운 배열로 반환한다.</p>
<pre class="javascript"><code>const numbers = [1, 2, 3, 4, 5];

const doubled = numbers.map(num =&gt; num * 2);
console.log(doubled); // [2, 4, 6, 8, 10]</code></pre>

<p>여기서 'map' 함수는 'num =&gt; num * 2' 함수를 인수로 받아, 배열 'numbers'의 각 요소에 대해 이 함수를 호출한다.</p>

<p><b>filter</b></p>
<p>배열의 각 요소에 대해 제공된 함수를 호출하고, 그 결과가 'true'인 요소만을 포함하는 새로운 배열을 반환한다.</p>
<pre class="javascript"><code>const numbers = [1, 2, 3, 4, 5];

const evenNumbers = numbers.filter(num =&gt; num % 2 === 0);
console.log(evenNumbers); // [2, 4]</code></pre>

<p>여기서 'filter' 함수는 'num =&gt; num % 2 === 0' 함수를 인수로 받아, 배열 'numbers'의 각 요소에 대해 이 함수를 호출하고, 짝수인 요소만을 포함하는 새로운 배열을 반환한다.</p>

<h3>함수를 반환하는 고차 함수</h3>
<p>고차 함수는 새로운 함수를 반환할 수도 있다. 이를 통해 함수 조합이나 부분 적용(Partial Application)을 쉽게 구현할 수 있다.</p>

<p><b>함수 생성기</b><b></b></p>
<pre class="javascript"><code>function createMultiplier(multiplier) {
    return function(value) {
        return value * multiplier;
    };
}

const double = createMultiplier(2);
const triple = createMultiplier(3);

console.log(double(5)); // 10
console.log(triple(5)); // 15</code></pre>

<p>여기서 'createMultiplier' 함수는 'multiplier'를 인수로 받아, 'value'를 인수로 받아 'value'와 'multiplier'의 곱을 반환하는 함수를 반환한다.</p>

<p><b>함수 조합기</b></p>
<pre class="javascript"><code>function compose(f, g) {
    return function(x) {
        return f(g(x));
    };
}

const addOne = x =&gt; x + 1;
const square = x =&gt; x * x;

const addOneAndSquare = compose(square, addOne);

console.log(addOneAndSquare(2)); // 9</code></pre>

<p>'compose' 함수는 두 함수를 받아, 먼저 'g' 함수를 호출하고 그 결과를 'f' 함수에 전달하는 새로운 함수를 반환한다.</p>

<p>함수를 실행하면 addOne(2)가 먼저 실행되어 3을 반환하게 된다.</p>
<p>square 함수에 위의 반환값 3으로 실행되어 최종 출력값은 9가 된다.</p>

<h2>고차 함수의 장점</h2>
<p><b>1. 재사용성</b></p>
<p>고차 함수는 인수로 전달된 함수에 따라 다른 동작을 수행할 수 있어, 더 유연하고 재사용 가능한 코드를 작성할 수 있다.</p>

<p><b>2. 모듈화</b></p>
<p>고차 함수는 코드의 기능을 작은 단위로 나누고, 이를 조합하여 더 복잡한 동작을 만들 수 있게 한다.</p>

<p><b>3. 가독성</b></p>
<p>고차 함수를 사용하면 반복적인 패턴을 추상화하여 코드의 가독성을 높일 수 있다.</p>

<h3>이벤트 처리</h3>
<pre class="javascript"><code>function addEventListener(element, event, handler) {
    element.addEventListener(event, handler);
}

const button = document.querySelector('button');
addEventListener(button, 'click', () =&gt; alert('Button clicked!'));</code></pre>

<p>여기서 'addEventListener' 함수는 'handler' 함수를 인수로 받아, 특정 이벤트가 발생했을 때 이를 처리한다.</p>

<h3>데이터 변환</h3>
<pre class="javascript"><code>const data = [
    { name: 'Bak', age: 25 },
    { name: 'Kim', age: 30 },
    { name: 'Lee', age: 35 }
];

const names = data.map(person =&gt; person.name);
console.log(names); // ['Bak', 'Kim', 'Lee']</code></pre>

<p>'map' 함수는 'person =&gt; person.name' 함수를 인수로 받아, 'data' 배열의 각 객체에서 이름을 추출하여 새로운 배열을 만든다.</p>
