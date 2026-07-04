---
title: "this"
excerpt: "this"
categories:
  - Javascript
permalink: /programming/javascript/146-this/
tags:
  - "JavaScript"
  - "Web"
  - "this"
toc: true
toc_sticky: true
date: 2024-08-26
last_modified_at: 2024-08-26
source_url: https://b-note.tistory.com/146
---

<h2>this</h2>
<p>자바스크립트에서 this는 함수가 호출될 때, 즉 함수의 실행 문맥에 따라 결정되는 특수한 객체이다.</p>


<h3>Global Context</h3>
<p><b>전역 문맥</b></p>
<p>전역에서 this를 사용할 때 window 또는 global 객체를 가리킨다.</p>

<pre class="javascript"><code>console.log(this) // this 는 window or global 객체이다</code></pre>


<h3>Function Context</h3>
<p><b>함수 문맥</b></p>
<p>일반 함수 내부에서 this는 호출된 문맥에 따라 다르다.&nbsp;</p>

<p>기본적으로 전역 문맥에서 호출된 함수의 this는 전역 객체를 가리키지만 엄격 모드에서는 this가 undefined로 설정된다.</p>

<pre class="javascript"><code>"use strict";
function Func(){
	console.log(this);
}

Func(); // undefined</code></pre>


<h3>Method Context</h3>
<p><b>메서드 문맥</b></p>
<p>객체의 메서드로 호출된 함수에서 this는 그 메서드가 속한 객체를 가리키게 된다.</p>
<pre class="javascript"><code>const myObject = {
	name : "bak",
    say : function() {
    	console.log(this.name);
    }
};

myObject.say(); // bak 출력</code></pre>

<p>여기서 this는 myObject 객체가 된다.</p>
