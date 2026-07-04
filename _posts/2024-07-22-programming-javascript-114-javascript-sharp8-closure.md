---
title: "JavaScript #8 클로저(Closure)"
excerpt: "JavaScript #8 클로저(Closure)"
categories:
  - Javascript
permalink: /programming/javascript/114-javascript-sharp8-closure/
tags:
  - "JavaScript"
  - "Web"
  - "Closure"
  - "lexical env"
  - "렉시컬 환경"
  - "자바스크립트"
  - "클로저"
toc: true
toc_sticky: true
date: 2024-07-22
last_modified_at: 2024-07-22
source_url: https://b-note.tistory.com/114
---

<h2>클로저</h2>
<p>클로저는 자바스크립트의 중요한 개념 중 하나로 함수와 그 함수가 선언된 렉시컬 환경(Lexical Environment)의 조합을 의미한다. 클로저는 함수가 선언될 때 그 함수의 스코프에 있는 변수들을 기억하고, 함수가 호출될 때에도 그 변수를 참조할 수 있게 한다.</p>

<h3>렉시컬 환경(Lexical Environment)</h3>
<p>자바스크립트의 실행 컨텍스트에서 변수와 함수 선언의 스코프를 관리하는 내부 구조를 의미한다. 렉시컬 환경은 코드가 작성된 위치에 따라 스코프를 결정하는데, 이는 코드가 실행될 때가 아니라 작성될 때의 구조에 따라 스코프가 결정된다는 점이 중요하다.</p>

<h3>렉시컬 환경의 구성 요소</h3>
<p>렉시컬 환경은 두 가지 구성 요소로 이루어져 있다.</p>

<p><b>1. 환경 레코드(Environment Record)</b></p>
<p>현재 스코프에서 정의된 모든 변수와 함수 선언을 저장한다.</p>

<p><b>2. 외부 렉시컬 환경 참조(Outer Lexical Environment Reference)</b></p>
<p>외부 스코프에 대한 참조를 가진다. 이는 중첩된 함수에 내부 함수가 외부 함수의 변수에 접근할 수 있게 한다.</p>

<h3>렉시컬 환경의 동작</h3>
<pre class="javascript"><code>function outerFunction() {
  let outerVariable = "I am an outer variable";

  function innerFunction() {
    let innerVariable = "I am an inner variable";
    console.log(outerVariable); // "I am an outer variable"
    console.log(innerVariable); // "I am an inner variable"
  }

  return innerFunction;
}

const closureFunction = outerFunction();
closureFunction();</code></pre>

<p><b>outerFunction 실행 시</b></p>
<p>환경 레코드 : { outerVariable: "I am an outer variable" }</p>
<p>외부 렉시컬 환경 참조 : 전역 환경</p>

<p><b>innerFunction 실행 시</b></p>
<p>환경 레코드 : { innerVariable : "I am an inner variable" }</p>
<p>외부 렉시컬 환경 참조 : <b>outerFunction</b>의 렉시컬 환경</p>

<h3>렉시컬 환경의 예제</h3>
<pre class="javascript"><code>let globalVariable = "I am a global variable";

function exampleFunction() {
  let localVariable = "I am a local variable";

  function innerFunction() {
    console.log(globalVariable); // "I am a global variable"
    console.log(localVariable); // "I am a local variable"
  }

  innerFunction();
}

exampleFunction();</code></pre>

<p><b>전역 렉시컬 환경</b></p>
<p>환경 레코드 : { globalVariable : "I am a global variable" }</p>
<p>외부 렉시컬 환경 참조 : 없음</p>

<p><b>exampleFunction 실행 시&nbsp;</b></p>
<p>환경 레코드 : { localVariable : "I am a local variable" }</p>
<p>외부 렉시컬 환경 참조 : 전역 환경</p>

<p><b>innerFunction 실행 시&nbsp;</b></p>
<p>환경 레코드 : 비어 있음 (현재 함수에서 변수를 선언하지 않음)</p>
<p>외부 렉시컬 환경 참조 : exampleFunction의 렉시컬 환경</p>

<p>렉시컬 환경은 자바스크립트의 변수와 함수 스코프를 관리하는 내부 구조로 코드가 작성된 위치에 따라 스코프가 결정된다. 렉시컬 환경은 환경 레코드와 외부 렉시컬 환경 참조로 구성되어 있으며 이를 통해 함수가 선언된 위치의 변수에 접근할 수 있다. 클로저는 이러한 렉시컬 환경을 활용하여 함수가 실행된 이후에도 외부 변수에 접근할 수 있게 하는 개념이다.</p>


<h2>클로저의 동작 원리</h2>
<p>클로저는 함수가 정의된 시점의 외부 스코프의 변수에 접근할 수 있는 기능을 제공하는 함수이다.&nbsp;</p>
<p>즉, 클로저는 함수가 생성될 때 외부 환경의 변수를 캡처하여 함수가 실행될 때에도 그 변수에 접근할 수 있게 한다.</p>

<p>자바스크립트에서 함수는 선언될 때마다 자신이 선언된 환경을 기억한다. 이 환경은 함수가 생성된 시점의 스코프와 변수를 포함하며 클로저는 함수가 실행된 이후에도 해당 환경을 유지하므로, 함수가 반환된 이후에도 그 환경에 접근할 수 있다.</p>

<pre class="javascript"><code>function outerFunction() {
  let outerVariable = "I am an outer variable";

  function innerFunction() {
    console.log(outerVariable); // "I am an outer variable"
  }

  return innerFunction;
}

const closureFunction = outerFunction();
closureFunction(); // "I am an outer variable"</code></pre>

<p>innerFunction은 outerFunction 내부에서 선언되었으며 outerFunction의 스코프에 접근할 수 있다. outerFunction이 반환된 이후에도 innerFunction은 outerVariable에 접근할 수 있으며 이 경우 innerFunction은 클로저를 형성한다.</p>

<h3>클로저의 주요 특징</h3>
<p><b>함수가 생성될 때의 스코프를 기억</b></p>
<p>함수가 정의된 위치의 외부 변수를 기억하고, 함수가 호출될 때 해당 변수에 접근할 수 있다.</p>

<p><b>은닉화(Encapsulation)</b></p>
<p>클로저를 사용하여 함수 외부에서 접근할 수 없는 프라이빗 변수를 만들 수 있다.</p>

<p><b>고차 함수</b></p>
<p>클로저는 함수를 반환하거나 함수의 인수로 함수를 받을 수 있는 '고차 함수'와 함께 자주 사용된다.</p>

<h3>프라이빗 변수(Private Variable)</h3>
<p>변수를 캡슐화하여 외부에서 변수에 직접 접근할 수 없도록 만드는 패턴이다.</p>
<p><b>예제 1)</b></p>
<pre class="javascript"><code>function createCounter() {
  let count = 0;

  return {
    increment: function() {
      count++;
      console.log(count);
    },
    decrement: function() {
      count--;
      console.log(count);
    },
    getCount: function() {
      return count;
    }
  };
}

const counter = createCounter();
counter.increment(); // 1
counter.increment(); // 2
counter.decrement(); // 1
console.log(counter.getCount()); // 1</code></pre>

<p>count 변수는 createCounter 함수 내에 선언되어 있으며, createCounter 함수 외부에서도 직접 접근할 수 없으며, increment, decrement, getCount 메서드만이 count 변수에 접근할 수 있다.</p>

<p><b>예제 2)</b></p>
<pre class="javascript"><code>function factory_game(title) {
  return
   {
   
    get_title : function () {
      return title;
    },
    
    set_title : function(_title) {
      title = _title 
    }
  }
}</code></pre>
<p><br />factorty_game 함수는 내부에 get_title, set_title 두 개의 내부 함수를 가지고 있다.</p>
<p><br />외부함수의 인수 title은 함수 안에서 지역변수로 사용되며 첫 번째 속성인 get_title 메서드가 반환하는 title은 인수의 값이 된다.</p>

<p>set_title은 매개변수로 _title을 가지며 이 매개변수를 가지고 title = _title로 저장하여 외부함수의 인수가 title이 된다.</p>

<pre class="javascript"><code>elder_scroll = factory_movie('The Elder Scrolls V: Skyrim');
fallout = factory_movie('Fallout: New Vegas');

console.log(elder_scroll.get_title());
// 'The Elder Scrolls V: Skyrim' 출력
console.log(fallout.get_title());
// 'Fallout: New Vegas' 출력</code></pre>


<h3>부분 적용 함수(Partial Application)</h3>
<p>클로저를 사용하여 함수의 일부 인수를 고정한 새로운 함수를 생성할 수 있으며, 이는 함수의 재사용성을 높이고, 코드의 간결성을 유지하는 데 유용하다.</p>

<pre class="javascript"><code>function multiply(a) {
  return function(b) {
    return a * b;
  };
}

const double = multiply(2);
console.log(double(5)); // 10

const triple = multiply(3);
console.log(triple(5)); // 15</code></pre>

<h3>주의사항</h3>
<p><b>메모리 관리</b></p>
<p>클로저는 함수가 참조하는 변수들을 계속 유지하므로, 과도하게 사용하면 메모리 누수가 발생할 수 있다. 불필요한 클로저 사용을 피하고 필요하지 않은 참조는 명시적으로 제거하는 것이 좋다.</p>

<p><b>성능</b></p>
<p>클로저를 사용할 때는 성능에 주의가 필요하다. 특히 큰 데이터 구조를 포함하는 클로저는 메모리 사용량을 증가시킬 수 있다.</p>

<h2>중첩 함수와 클로저</h2>
<pre class="javascript"><code>function makeCounter() {
  let count = 0;

  return function() {
    count++;
    return count;
  };
}

const counter = makeCounter();
console.log(counter()); // 1
console.log(counter()); // 2
console.log(counter()); // 3</code></pre>

<p>위 렉시컬 환경은 다음과 같이 동작한다.</p>

<p><b>makeCounter 실행 시</b></p>
<p>환경 레코드 : { count : 0 }</p>
<p>외부 렉시컬 환경 참조 : 전역 환경</p>

<p><b>반환된 함수(클로저) 실행 시</b></p>
<p>환경 레코드 : 비어 있음</p>
<p>외부 렉시컬 환경 참조 : makeCounter의 렉시컬 환경&nbsp;</p>

<hr contenteditable="false" />

<p>클로저는 자바스크립트의 강력한 기능 중 하나로 함수가 선언된 렉시컬 환경을 기억하고, 함수가 호출될 때에도 그 환경에 접근할 수 있게 한다. 이를 통해 변수 은닉화, 부분 적용 함수, 콜백 함수 등 다양한 활용이 가능하다.</p>

<p>클로저의 주의사항을 유념하여 적절히 사용하면 코드의 재사용성과 유지보성을 높일 수 있다.</p>
