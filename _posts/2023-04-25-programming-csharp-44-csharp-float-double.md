---
title: "C# 부동 소수점 키워드 : float, double"
excerpt: "C# 부동 소수점 키워드 : float, double"
categories:
  - CSharp
permalink: /programming/csharp/44-csharp-float-double/
tags:
  - "CSharp"
  - "C#"
  - "decimal"
  - "DOUBLE"
  - "float"
  - "keyword"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/44
---

<p>부동소수점 숫자를 나타내는 데이터 형식 중 하나이다.&nbsp;</p>

<h3>float</h3>
<p>32비트의 고정된 크기를 가지며 숫자의 소수점 이하 7자리까지 정밀도를 가지고 있다.</p>
<p>실수 리터럴을 표현할 때 컴파일러가 float으로 인식하게 하려면 숫자 뒤에 f 또는 F를 붙여야 한다.</p>
<pre class="csharp"><code>float a = 1.0f
float b = 1.0F</code></pre>
<h3>double</h3>
<p>float보다 더 큰 범위의 수를 저장할 수 있으며 64비트 부동소수점 형식을 사용하여 약 15~16자리의 정밀도를 가진다. 하지만 이론적으로는 무한한 자릿수까지 표현이 가능하며 더 정밀한 값을 표현하기 위해서는 decimal을 사용해야 한다.</p>

<p>* decimal의 경우 높은 정밀도를 제공하지만 128비트 크기로 계산 속도가 느리기 때문에 성능이 중요한 경우에는 사용에 주의가 필요하다.</p>

<pre style="background-color: var(--bc-code-bg); color: var(--bc-code-text); text-align: start"><code>double d = 1.0d;
double e = 1.0;</code></pre>
<p>double을 사용할 때는 접미사 d를 생략할 수 있다. 또한 double 형에 1.0f 처럼 float 값을 넣어도 암시적 형변환이 이루어져 허용이되지만 반대의 경우는 에러가 발생한다.</p>
<pre class="csharp"><code>double d = 1.0f;	// implicitly convert
float a = 1.0d; 	// error</code></pre>

<p>float보다 double이 더 많은 소수점 자릿수의 표현이 가능하지만 메모리의 크기가 차이가 나기 때문에 꼭 필요한 상황에서만 double을 사용하며 이외의 소수점을 사용할때는 float을 사용하는 것이 좋다.</p>
