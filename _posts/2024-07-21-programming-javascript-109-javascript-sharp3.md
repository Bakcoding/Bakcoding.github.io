---
title: "JavaScript #3 연산자"
excerpt: "JavaScript #3 연산자"
categories:
  - Javascript
permalink: /programming/javascript/109-javascript-sharp3/
tags:
  - "JavaScript"
  - "Web"
  - "Expression"
  - "자바스크립트"
  - "표현식"
toc: true
toc_sticky: true
date: 2024-07-21
last_modified_at: 2024-07-21
source_url: https://b-note.tistory.com/109
---

<p>연산자 기호는 공통적으로 사용되는 사칙연산을 적용하고 있다.</p>
<p>그 밖에 추가로 사용되는 연산자 중 차이점을 정리한다.</p>

<h2>비교 연산자</h2>
<h3>동등 연산자와 일치 연산자</h3>
<pre class="javascript"><code>true == 1;
// true , 두 피연산자를 비교하기 전에 true를 1로 변환
true === 1;
// false , 두 피연산자의 타입부터 비교된다.</code></pre>

<p>비슷해 보이는 두 연산자의 동일한 값 비교에서 명확한 차이가 난다.</p>


<p><b>'==' 동등 연산자</b></p>
<p>비교하는 두 값의 타입이 다르면 비교하기 전에 타입을 동일하게 변환 후 비교를 한다.</p>
<pre class="javascript"><code>console.log(5 == '5');      // true, 숫자 5와 문자열 '5'가 타입 강제 변환 후 비교
console.log(null == undefined); // true, 둘 다 비어있는 값을 나타냄
console.log(0 == false);    // true, 숫자 0과 불리언 false가 타입 강제 변환 후 비교
console.log('' == false);   // true, 빈 문자열과 불리언 false가 타입 강제 변환 후 비교</code></pre>

<p><b>'===' 일치 연산자</b></p>
<p>타입과 값이 모두 동일해야만 참을 반환한다.</p>
<pre class="javascript"><code>console.log(5 === '5');     // false, 타입이 다르므로 일치하지 않음
console.log(null === undefined); // false, 타입이 다르므로 일치하지 않음
console.log(0 === false);   // false, 타입이 다르므로 일치하지 않음
console.log('' === false);  // false, 타입이 다르므로 일치하지 않음
console.log(5 === 5);       // true, 타입과 값이 모두 동일</code></pre>

<p>타입 강제 변환의 수행 때문에 예기치 않은 결과를 발생시킬 수 있다. 따라서 자바스크립트에서는 일관성과 예측 가능한 동작을 위해 일반적으로 '==='를 사용하는 것이 권장된다.</p>

<p><b>&lt;, &gt; 등호&nbsp;</b></p>
<p>숫자뿐만 아니라 문자열과 객체도 비교가 가능하다.&nbsp;</p>
<pre class="javascript"><code>console.log(5 &lt; 10);   // true
console.log(5 &gt; 10);   // false
console.log(10 &gt; 10);  // false
console.log(10 &lt; 10);  // false
console.log(10 &lt;= 10); // true
console.log(10 &gt;= 10); // true</code></pre>


<p>문자열 비교는 유니코드 값을 기준으로 문자열을 비교한다.</p>
<pre class="javascript"><code>console.log('apple' &lt; 'banana');   // true
console.log('grape' &gt; 'banana');   // true
console.log('apple' &gt; 'Apple');    // true ('a'의 유니코드 값이 'A'보다 큼)
console.log('2' &lt; '10');           // false (문자열 비교에서 '2'는 '10'보다 큼)</code></pre>

<p>객체의 경우 직접 등호를 사용해서 비교할 수 없지만 비교 시 객체를 원시 값으로 변환하려고 시도한다. 이 경우 두 객체의 참조를 비교한다. 일반적으로 객체의 비교는 특정 속성을 비교하는 방법으로 사용한다.</p>
<pre class="javascript"><code>// 객체 직접 비교시
let obj1 = { value: 10 };
let obj2 = { value: 20 };

console.log(obj1 &lt; obj2); // false
console.log(obj1 &gt; obj2); // false
console.log(obj1 == obj2); // false

// 객체의 속성 비교
let obj1 = { value: 10 };
let obj2 = { value: 20 };

console.log(obj1.value &lt; obj2.value); // true</code></pre>

<p>숫자와 문자열간의 비교도 가능하며 이 경우 자동으로 타입을 변환하여 비교한다.</p>
<pre class="javascript"><code>console.log('5' &lt; 10);  // true (문자열 '5'는 숫자 5로 변환됨)
console.log('5' &gt; 10);  // false
console.log('5' &gt; '10'); // true ('5'와 '10'은 문자열로 비교됨, '5'는 '10'보다 큼)</code></pre>

<h2>in 연산자</h2>
<p>객체의 속성이나 배열의 인덱스가 존재하는지 확인하는 데 사용된다.</p>

<p>객체의 특정 속성이 존재하는지 확인할 때</p>
<pre class="javascript"><code>let person = {
  name: "Alice",
  age: 30
};

console.log("name" in person); // true
console.log("age" in person);  // true
console.log("gender" in person); // false</code></pre>

<p>배열의 특정 인덱스가 존재하는지 확인할 때</p>
<pre class="javascript"><code>let numbers = [10, 20, 30];

console.log(0 in numbers); // true
console.log(1 in numbers); // true
console.log(3 in numbers); // false (인덱스 3은 존재하지 않음)</code></pre>

<p>in 연산자는 주어진 속성 또는 인덱스가 객체의 자체 속성인지, 프로토타입 체인에 속한 속성인지 여부를 검사한다.</p>
<pre class="javascript"><code>let person = {
  name: "Alice"
};

console.log("toString" in person); // true, toString은 Object.prototype의 속성</code></pre>

<p>toString은 person 객체에 직접 정의된 속성이 아니지만 Object.protorype에 정의된 속성이기 때문에 in 연산자는 true를 반환한다.</p>

<p>객체의 자체 속성만을 검사하려면 Object.hasOwnProperty 메서드를 사용한다.</p>
<pre class="javascript"><code>let person = {
  name: "Alice"
};

console.log(person.hasOwnProperty("name")); // true
console.log(person.hasOwnProperty("toString")); // false</code></pre>

<h2>instanceof 연산자</h2>
<p>특정 객체가 특정 생상저 함수 또는 클래스의 인스턴스인지 확인하는 데 사용된다. 이를 통해 객체의 프로토타입 체인을 검사하여 객체가 특정 생성자 함수의 프로토타입을 상속받았는지 여부를 확인할 수 있다.</p>
<pre class="javascript"><code>object instanceof Constructor</code></pre>

<p>여기서 object는 검사할 객체, Constructor는 생성자 함수이다.</p>

<p>원시 타입인 숫자, 문자열, 불리언 등에는 사용할 수 없다.</p>
<pre class="javascript"><code>console.log(5 instanceof Number); // false
console.log("hello" instanceof String); // false</code></pre>

<p>instanceof 연산자는 객체의 프로토타입 체인을 따라가면서 주어진 생성자 함수의 prototype 속성과 일치하는 프로토타입이 있는지 검사한다. 이 과정은 객체의 프로토타입 체인 끝에 도달할 때까지 계속된다.</p>

<pre class="javascript"><code>function Foo() {}
function Bar() {}

let foo = new Foo();

console.log(foo instanceof Foo); // true
console.log(foo instanceof Bar); // false
console.log(foo instanceof Object); // true (Foo의 인스턴스는 Object의 인스턴스이기도 함)</code></pre>

<p>따라서 객체의 프로토타입이 동적으로 변경된다면 instanceof의 결과도 달라질 수 있게 된다.</p>
<pre class="javascript"><code>function Foo() {}
function Bar() {}

let obj = new Foo();
console.log(obj instanceof Foo); // true

Object.setPrototypeOf(obj, Bar.prototype);
console.log(obj instanceof Foo); // false
console.log(obj instanceof Bar); // true</code></pre>

<h2>typeof 연산자</h2>
<p>typeof 연산자는 데이터 타입을 검사하는 데 사용되며 주로 원시 타입을 검사할 때 사용한다.</p>
<pre class="javascript"><code>console.log(typeof 5);          // "number"
console.log(typeof "hello");    // "string"
console.log(typeof true);       // "boolean"
console.log(typeof {});         // "object"
console.log(typeof []);         // "object"
console.log(typeof function(){}); // "function"</code></pre>

<h2>논리 연산자</h2>
<p>논리적인 조건을 평가하거나 결합하는 데 사용된다. 주로 조건문에서 사용되며 참 또는 거짓 값을 반환한다.</p>

<p><b>&amp;&amp; AND</b></p>
<p>두 피연산자가 모두 참일 때 참, 하나라도 거짓이면 거짓을 반환한다.</p>
<pre class="javascript"><code>console.log(true &amp;&amp; true);   // true
console.log(true &amp;&amp; false);  // false
console.log(false &amp;&amp; true);  // false
console.log(false &amp;&amp; false); // false

let a = 5;
let b = 10;
console.log(a &gt; 0 &amp;&amp; b &gt; 0); // true (a와 b가 모두 0보다 큼)</code></pre>

<p><b>|| OR</b></p>
<p>두 피연산자 중 하나라도 참이면 참, 둘 다 거짓일 때만 거짓을 반환한다.</p>
<pre class="javascript"><code>console.log(true || true);   // true
console.log(true || false);  // true
console.log(false || true);  // true
console.log(false || false); // false

let a = 5;
let b = -10;
console.log(a &gt; 0 || b &gt; 0); // true (a가 0보다 큼)</code></pre>

<p><b>! NOT</b></p>
<p>피연산자의 부정을 반환한다. 참이면 거짓, 거짓이면 참을 반환한다.</p>
<pre class="javascript"><code>console.log(!true);  // false
console.log(!false); // true

let a = 5;
console.log(!(a &gt; 0)); // false (a &gt; 0은 true이므로, !true는 false)</code></pre>
<h2>&nbsp;</h2>

<h3>논리 연산자의 단축 평가 (Short-Circuit Evaluation)</h3>
<p>논리 연산자는 단축 평가를 사용하여 불필요한 연산을 피한다. 이는 첫 번째 피연산자가 전체 표현식의 결과를 결정할 수 있는 경우 두 번째 피연산자를 평가하지 않는다는 것을 의미한다.</p>

<p>&amp;&amp;, 첫 번째 연산자가 거짓이면 두 번째 피연산자를 평가하지 않는다.</p>
<pre class="javascript"><code>console.log(false &amp;&amp; true);  // false (두 번째 피연산자를 평가하지 않음)
console.log(true &amp;&amp; false);  // false
console.log(false &amp;&amp; false); // false (두 번째 피연산자를 평가하지 않음)
console.log(true &amp;&amp; true);   // true

let a = 5;
let b = 10;
console.log(a &gt; 0 &amp;&amp; b &gt; 0 &amp;&amp; b &gt; a); // true (모든 조건이 참)</code></pre>

<p>||, 첫 번째 피연산자가 참이면 두 번째 피연산자를 평가하지 않는다.</p>
<pre class="javascript"><code>console.log(true || false);  // true (두 번째 피연산자를 평가하지 않음)
console.log(false || true);  // true
console.log(true || true);   // true (두 번째 피연산자를 평가하지 않음)
console.log(false || false); // false

let a = 5;
let b = -10;
console.log(a &gt; 0 || b &gt; 0 || b &lt; a); // true (첫 번째 조건이 참이므로 나머지 조건을 평가하지 않음)</code></pre>

<h2>delete 연산자</h2>
<p>객체의 속성을 삭제하는 데 사용된다. 주로 객체의 속성만을 삭제할 때 사용한다.&nbsp;</p>

<pre class="javascript"><code>delete object.property;
//또는
delete object['property'];</code></pre>

<p>객체의 특정 속성을 삭제하고 삭제된 속성은 객체에서 완전히 제거되어 더 이상 해당 속성에 접근할 수 없다.</p>

<pre class="javascript"><code>let person = {
  name: "Alice",
  age: 30
};

console.log(person.age); // 30

delete person.age; // age 속성 삭제

console.log(person.age); // undefined (삭제된 속성에 접근 시)
console.log(person); // { name: "Alice" }</code></pre>

<p><b>배열의 요소 삭제</b></p>
<p>배열의 요소를 삭제할 수 있지만 배열의 길이는 변경되지 않고 해당 인덱스는 undefined로 남아 있게 되므로 완전히 제거하고 길이를 줄이기 위해서는 splice 메서드를 사용하는 것이 좋다.</p>

<pre class="javascript"><code>let numbers = [1, 2, 3, 4];

delete numbers[2]; // 배열의 세 번째 요소 삭제

console.log(numbers); // [1, 2, undefined, 4]
console.log(numbers.length); // 4 (배열 길이는 그대로)</code></pre>

<p><b>프로토타입 속성 삭제</b></p>
<p>객체의 프로토타입에 정의된 속성은 delete 연산자로 삭제할 수 없다.</p>

<pre class="javascript"><code>function Person(name) {
  this.name = name;
}

Person.prototype.age = 30;

let alice = new Person("Alice");

console.log(alice.age); // 30 (프로토타입 속성)

delete alice.age; // 인스턴스의 age 속성 삭제 시도 (실제로 프로토타입의 속성은 삭제되지 않음)

console.log(alice.age); // 30 (프로토타입의 속성은 여전히 존재)</code></pre>

<p><b>변수 삭제</b></p>
<p>전역 변수와 함수의 경우 delete 연산자를 사용해도 삭제되지 않는다. 지역 변수는 delete로 삭제할 수 없다.</p>
