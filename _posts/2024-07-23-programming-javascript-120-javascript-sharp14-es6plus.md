---
title: "JavaScript #14 ES6+ 문법"
excerpt: "JavaScript #14 ES6+ 문법"
categories:
  - Javascript
permalink: /programming/javascript/120-javascript-sharp14-es6plus/
tags:
  - "JavaScript"
  - "Web"
  - "arguments"
  - "Destructuring assignment"
  - "ES6+"
  - "export"
  - "Import"
  - "rest parameters"
  - "spread operator"
  - "template literal"
  - "자바스크립트"
toc: true
toc_sticky: true
date: 2024-07-23
last_modified_at: 2024-07-23
source_url: https://b-note.tistory.com/120
---

<h2>ES6+</h2>
<p>ECMAScript 6부터의 버전에서는 자바스크립트 언어에 여러 유용한 기능들이 추가되었다.&nbsp;</p>

<p>이 중에서도 특히 중요한 템플릿 리터럴, 디스트럭처링 할당, 스프레드 연산자와 나머지 매개변수, 모듈화에 대해서 정리한다.</p>

<h2>템플릿 리터럴 (Template Literals)</h2>
<p>템플릿 리터럴은 백틱을 사용하여 문자열을 작성하며, 문자열 내에 표현식을 포함할 수 있는 기능을 제공한다.</p>

<p><b>기본 사용법</b></p>
<pre class="javascript"><code>const name = 'Bak';
const greeting = `Hello, ${name}!`; // 표현식 ${}을 사용
console.log(greeting); // "Hello, Bak!"</code></pre>

<p>${} 표현식을 사용해서 문자열 내에서 직접 변수의 값에 바로 접근할 수 있다.</p>

<p><b>여러 줄 문자열</b></p>
<p>템플릿 리터럴을 사용하면 여러 줄에 걸쳐 문자열을 작성할 수 있다.</p>
<pre class="javascript"><code>const multiline = `This is
a string
that spans multiple lines.`;
console.log(multiline);</code></pre>

<p>ES6 이전에는 문자열을 쓸 때 큰따옴표를 사용해야 했으며 백틱을 사용하게 되면 구문 오류(Syntax Error)가 발생한다.</p>

<p>그리고 이전의 자바스크립트는 한 줄로 작성된 문자열을 인식하기 때문에 여러 줄에 걸쳐 문자열을 작성하기 위해서는 줄 끝에 백슬래시를 사용하여 줄 바꿈을 나타내야 했다.</p>

<pre class="javascript"><code>var multiLineString = "This is the first line \
This is the second line \
This is the third line";
console.log(multiLineString);
// "This is the first line This is the second line This is the third line"

// 또는 

var multiLineString = "This is the first line\n" +
                      "This is the second line\n" +
                      "This is the third line";
console.log(multiLineString);
// This is the first line
// This is the second line
// This is the third line</code></pre>

<p>이런 방법들은 코드의 가독성을 떨어뜨릴 여지가 충분했다.</p>

<h2>디스트럭처링 할당 (Destructuring Assignment)</h2>
<p>디스트럭처링 할당은 배열이나 객체의 값을 개별 변수로 쉽게 추출할 수 있게 해주는 문법이다. 이는 코드를 더 간결하고 가독성 좋게 만들며, 특히 복잡한 데이터 구조를 다룰 때 유용하다.&nbsp;</p>

<pre class="javascript"><code>const numbers = [1, 2, 3, 4];
const [first, second, ...rest] = numbers; // 배열의 첫 두 요소를 추출하고 나머지는 rest에 할당
console.log(first); // 1
console.log(second); // 2
console.log(rest); // [3, 4]</code></pre>

<p><b>객체 디스트럭처링</b></p>
<pre class="javascript"><code>const person = {
    name: 'Bob',
    age: 30,
    job: 'developer'
};
const { name, age, job } = person; // 객체의 프로퍼티를 개별 변수로 추출
console.log(name); // 'Bob'
console.log(age); // 30
console.log(job); // 'developer'</code></pre>

<p><b>중첩된 구조 디스트럭처링</b></p>
<pre class="javascript"><code>const person = {
    name: 'Charlie',
    address: {
        city: 'New York',
        zip: '10001'
    }
};
const { name, address: { city, zip } } = person; // 중첩된 구조에서 프로퍼티 추출
console.log(name); // 'Charlie'
console.log(city); // 'New York'
console.log(zip); // '10001'</code></pre>

<p><b>함수 파라미터에서 디스트럭처링</b></p>
<p>함수 파라미터에서 디스트럭처링을 사용하면 코드가 더 직관적이고 명확해진다.</p>
<pre class="javascript"><code>function displayPerson({ name, age }) {
  console.log(`Name: ${name}, Age: ${age}`);
}

const person = { name: 'Bak', age: 25 };
displayPerson(person); // Name: Bak, Age: 25</code></pre>

<p>디스트럭처링을 잘 활용하면 코드의 유지보수성을 높이고, 가독성을 개선하며, 실수를 줄이는 데 도움이 된다.&nbsp;</p>

<h2>스프레드 연산자 (Spread Operator)</h2>
<p>스프레드 연산자('...')는 세 개의 점으로 표현된다.</p>

<p>배열이나 객체를 펼치거나, 함수의 나머지 매개변수로 사용할 수 있어 배열이나 객체를 보다 간결하고 직관적으로 다룰 수 있게 해 준다.</p>

<p><b>배열에서 스프레드 연산자</b></p>
<pre class="javascript"><code>// 배열 복사
const arr1 = [1, 2, 3];
const arr2 = [...arr1];
console.log(arr2); // [1, 2, 3]

// 배열 결합
const arr1 = [1, 2, 3];
const arr2 = [4, 5, 6];
const combined = [...arr1, ...arr2]; // 배열을 펼쳐서 결합
console.log(combined); // [1, 2, 3, 4, 5, 6]</code></pre>

<p><b>객체에서의 스프레드 연산자</b></p>
<pre class="javascript"><code>// 객체 복사
const obj1 = { a: 1, b: 2 };
const obj2 = { ...obj1 };
console.log(obj2); // { a: 1, b: 2 }

// 객체 결합
const obj1 = { a: 1, b: 2 };
const obj2 = { c: 3, d: 4 };
const combinedObj = { ...obj1, ...obj2 }; // 객체를 펼쳐서 결합
console.log(combinedObj); // { a: 1, b: 2, c: 3, d: 4 }</code></pre>

<p>배열이나 객체를 단순히 변수에 대입하는 것과 스프레드 연산자를 사용하여 복사하는 것은 중요한 차이가 있다.</p>
<h3>변수 대입과 참조</h3>
<p>자바스크립트에서 배열이나 객체를 변수에 대입할 때 실제로는 해당 배열이나 객체의 참조가 복사된다. 이는 두 변수가 같은 배열이나 객체를 참조하게 된다는 의미로 한 변수를 통해 배열이나 객체를 변경하면, 다른 변수에도 그 변경 사항이 반영된다.</p>


<h2>나머지 매개변수 (rest parameters)</h2>
<p>함수에서 가변 인자를 처리할 수 있도록 도와주는 기능이다. 이 기능은 보다 인자들을 유연하게 다룰 수 있게 된다.</p>
<pre class="javascript"><code>function sum(...args) { // 나머지 매개변수로 모든 인수를 배열로 받음
    return args.reduce((total, current) =&gt; total + current, 0);
}
console.log(sum(1, 2, 3)); // 6
console.log(sum(4, 5, 6, 7)); // 22</code></pre>

<p>나머지 매개변수를 사용하면 함수가 전달받는 인자의 수에 제한이 없어 특히 가변 인자를 처리해야 하는 상황에서 유용하다.</p>
<pre class="javascript"><code>function concatenate(separator, ...strings) {
  return strings.join(separator);
}

console.log(concatenate(', ', 'Hello', 'World', 'JavaScript')); // "Hello, World, JavaScript"
console.log(concatenate(' - ', 'Learn', 'Code', 'Enjoy')); // "Learn - Code - Enjoy"</code></pre>

<p>배열 메서드를 직접 사용할 수 있어 가변 인자를 처리하는 로직이 명확해져 가독성이 높아지고 가변 인자를 처리하기 위한 별도의 코드를 작성할 필요가 없어 중복 코드를 줄일 수 있다.</p>

<h3>arguments&nbsp;</h3>
<p>전통적으로 자바스크립트에서는 arguments 객체를 사용하여 함수의 모든 인자를 접근할 수 있다. 하지만 arguments 객체는 배열이 아니기 때문에 배열 메서드를 직접 사용할 수 없어 추가적인 변환 작업을 필요로 한다.</p>
<pre class="javascript"><code>function oldSum() {
  const args = Array.prototype.slice.call(arguments);
  return args.reduce((total, num) =&gt; total + num, 0);
}

console.log(oldSum(1, 2, 3)); // 6</code></pre>

<p>반면 나머지 매개변수는 배열로 제공되기 때문에 배열 메서드를 바로 사용할 수 있어 더 직관적이고 간편하다.</p>

<h2>모듈화 (Modules)</h2>
<p>모듈화를 통해 코드를 여러 파일로 나눠서 관리할 수 있어 코드의 재사용성과 유지보수성을 높여준다.</p>

<h3>모듈 내보내기/가져오기 (Export/Import)</h3>
<p>모듈에서 함수를 내보내는 두 가지 방법이 있다.&nbsp;</p>

<p><b>name exports</b></p>
<p>모듈에서 여러 개의 변수를 내보낼 수 있으며, 각 변수를 특정 이름으로 내보낸다. 가져올 때는 내보낸 이름을 사용하여 모듈을 가져와야 한다.</p>
<pre class="javascript"><code>// math.js
export const pi = 3.14;
export function add(x, y) {
  return x + y;
}
export class Calculator {
  subtract(x, y) {
    return x - y;
  }
}</code></pre>

<p><b>import</b></p>
<pre class="javascript"><code>// main.js
import { pi, add, Calculator } from './math.js';

console.log(pi); // 3.14
console.log(add(2, 3)); // 5
const calc = new Calculator();
console.log(calc.subtract(5, 3)); // 2</code></pre>

<p>name export의 경우 같은 이름을 가진 변수가 이미 사용 중이라면 이름 충돌이 발생하기도 한다. 이를 해결하기 위해서 as 키워드를 사용하여 별칭을 붙일 수 있다.</p>
<pre class="javascript"><code>import { add as addNumbers } from './math.js';</code></pre>

<p><b>default exports</b></p>
<p>모듈에서 하나의 기본 값을 내보낸다. 모듈당 하나의 default export만 가질 수 있으며 이름 없이 내보낼 수 있다.</p>
<pre class="javascript"><code>// utils.js
export default function greet(name) {
  return `Hello, ${name}!`;
}</code></pre>

<p><b>import</b></p>
<pre class="javascript"><code>// main.js
import greet from './utils.js';

console.log(greet('Bak')); // Hello, Bak!</code></pre>

<p><b>혼합 사용</b></p>
<p>하나의 모듈에서 named exports와 default export를 동시에 사용할 수 있다.</p>
<pre class="javascript"><code>// module.js
export const pi = 3.14;
export function add(x, y) {
  return x + y;
}
export default function subtract(x, y) {
  return x - y;
}

// main.js
import subtract, { pi, add } from './module.js';

console.log(pi); // 3.14
console.log(add(2, 3)); // 5
console.log(subtract(5, 3)); // 2</code></pre>
