---
title: "Expression, Statement"
excerpt: "Expression, Statement"
categories:
  - ProgrammingBasic
permalink: /programming/programming-basics/12-expression-statement/
tags:
  - "Programming"
  - "Programming Basics"
  - "CODE"
  - "Evaluate"
  - "Expression"
  - "Statement"
toc: true
toc_sticky: true
date: 2023-01-20
last_modified_at: 2023-01-20
source_url: https://b-note.tistory.com/12
---

<h2>Expression</h2>
<p>표현, 식 등의 뜻을 가지고 있다.</p>
<p>하나 이상의 값으로 표현될 수 있는 코드를 의미한다.&nbsp;</p>
<p>여기에는 사칙연산의 수식과 같은 것들 뿐만 아니라 함수 콜, 변수 이름, 식별자, 연산자 등까지도 포함된다.</p>

<p>요점은 expression은 evaluate가 가능하여 하나의 값으로 나타나는것을 의미한다.</p>
<pre class="shell"><code>A = 1;
B = 2;
Arr = [1, 2, 3]; 
A + B // 3
Arr[2] = 3;
...</code></pre>
<p>형태는 다르지만 모두 단일 값으로 평가될 수 있는 expression이다.&nbsp;</p>
<h2>Statement</h2>
<p>진술, 성명 등의 뜻을 가지고 있다.</p>
<p>프로그래밍에서는 실행 가능한 최소의 독립적인 코드 단위를 말한다.</p>
<p>즉 컴파일러가 이해하고 실행할 수 있는 모든 구문을 Statement라 할 수 있고 문법적으로 적합한 모든 한 줄의 코드나 블록도 Statement라 할 수 있다. 일반적으로 Statement는 하나 이상의 Expression과 키워드를 포함한다.</p>

<pre class="cpp"><code>int a = 1;	//expression
int b = 2;	//expression
if (a == b)	// if keyword
{
	return true; //expression
}</code></pre>
<h2>정리</h2>
<p>Expression은 하나의 값을 표현하는 식이며 하나 이상의 Expression과 키워드로 작성된 구문은 모두 Statement로 볼 수 있다. 따라서 모든 Expression은 Statement라 볼 수 있지만 모든 Statement가 Expression은 아닌 두 관계는 부분집합이 된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="statement_expression.png" data-origin-width="374" data-origin-height="251"><span><img src="/assets/images/posts/2023/01/20/12-1.png" loading="lazy" width="374" height="251" data-filename="statement_expression.png" data-origin-width="374" data-origin-height="251"/></span></figure>
</p>
