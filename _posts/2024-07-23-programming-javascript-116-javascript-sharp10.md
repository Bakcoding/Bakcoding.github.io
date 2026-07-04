---
title: "JavaScript #10 조건문과 반복문"
excerpt: "JavaScript #10 조건문과 반복문"
categories:
  - Javascript
permalink: /programming/javascript/116-javascript-sharp10/
tags:
  - "JavaScript"
  - "Web"
  - "do-while"
  - "Else"
  - "else if"
  - "FOR"
  - "If"
  - "switch"
  - "While"
  - "자바스크립트"
toc: true
toc_sticky: true
date: 2024-07-23
last_modified_at: 2024-07-23
source_url: https://b-note.tistory.com/116
---

<h2>조건문 (Conditional Statements)</h2>
<p>조건문은 특정 조건에 따라 코드 블록을 실행하거나 건너뛰는 방식으로 동작한다.</p>

<h3>if, else if, else&nbsp;</h3>
<pre class="javascript"><code>let x = 10;

if (x &gt; 5) {
    console.log("x는 5보다 크다.");
} else if (x === 5) {
    console.log("x는 5이다.");
} else {
    console.log("x는 5보다 작다.");
}</code></pre>

<h3>switch</h3>
<p>하나의 변수를 다양한 값과 비교하여 코드 블록을 실행한다.</p>
<pre class="javascript"><code>let day = 3;
let dayName;

switch (day) {
    case 0:
        dayName = 'Sunday';
        break;
    case 1:
        dayName = 'Monday';
        break;
    case 2:
        dayName = 'Tuesday';
        break;
    case 3:
        dayName = 'Wednesday';
        break;
    case 4:
        dayName = 'Thursday';
        break;
    case 5:
        dayName = 'Friday';
        break;
    case 6:
        dayName = 'Saturday';
        break;
    default:
        dayName = 'Invalid day';
}

console.log(dayName); // "Wednesday"</code></pre>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">break는 해당 조건에 해당하면 더 이상 다음 조건을 확인하지 않고 조건문을 종료시키는 기능을 한다.</p>
<p style="color: #333333; text-align: start;">case는 순서대로 모든 케이스를 확인하기 때문에 break가 없다면 swich의 모든 조건을 확인한다.</p>
<h2>반복문 (Loops)</h2>
<p>반복문은 특정 코드 블록을 여러 번 실행하는 데 사용된다.&nbsp;</p>

<h3>for</h3>
<p>일반적인 반복문이다.</p>
<pre class="javascript"><code>for (let i = 0; i &lt; 5; i++) {
    console.log(i); // 0, 1, 2, 3, 4
}</code></pre>


<h3>while</h3>
<p>조건이 참인 동안 코드 블록을 반복한다.</p>
<pre class="javascript"><code>let i = 0;
while (i &lt; 5) {
    console.log(i); // 0, 1, 2, 3, 4
    i++;
}</code></pre>

<h3>do-while</h3>
<p>코드 블록을 최소 한 번 실행하고, 그 후 조건이 참인 동안 반복한다.</p>
<pre class="javascript"><code>let i = 0;
do {
    console.log(i); // 0, 1, 2, 3, 4
    i++;
} while (i &lt; 5);</code></pre>

<h3>break</h3>
<p>break는 반복문을 종료시키는 기능을 한다.</p>
<pre class="javascript"><code>for (let i = 0; i &lt; 10; i++) {
    if (i === 5) {
        break;
    }
    console.log(i); // 0, 1, 2, 3, 4
}</code></pre>

<h2>continue</h2>
<p>continue 문은 현재 반복을 종료하고 다음 반복으로 넘어간다.</p>
<pre class="javascript"><code>for (let i = 0; i &lt; 10; i++) {
    if (i === 5) {
        continue;
    }
    console.log(i); // 0, 1, 2, 3, 4, 6, 7, 8, 9
}</code></pre>
