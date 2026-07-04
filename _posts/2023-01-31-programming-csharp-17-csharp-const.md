---
title: "C# 상수 키워드 : const"
excerpt: "C# 상수 키워드 : const"
categories:
  - CSharp
permalink: /programming/csharp/17-csharp-const/
tags:
  - "CSharp"
  - "C#"
  - "const"
  - "keyword"
  - "literal const"
toc: true
toc_sticky: true
date: 2023-01-31
last_modified_at: 2023-01-31
source_url: https://b-note.tistory.com/17
---

<h3>const</h3>
<p>상수라는 뜻을가지는 Constant에서 따온 키워드이다.</p>
<p>상수란 프로그래밍에서 변하지 않는 값을 의미하는데 한번 값이 정해지면 프로그램이 실행되는 동안 그 값은&nbsp; 항상 일정하다. 컴파일 타임에 값이 결정되므로 런타임 시 메모리를 사용하지 않게 되어 상수를 사용하면 메모리 사용을 줄일 수 있다.</p>

<pre class="csharp"><code>public class Program
{
	public static void Main(string[] args)
    {
    	const int A = 10;
        A = 10; // Compiler Error CS0131
    }
}</code></pre>

<p>const 키워드로 선언된 변수는 상수로 취급되기 때문에 값을 재할당하면 컴파일 에러가 뜬다. 따라서 상수는 코드 흐름에서도 바뀔 필요가 없고 일정하게 사용될 값이 필요할 때 사용한다.</p>

<h3>literal const</h3>
<p>리터럴 상수 또한 상수와 마찬가지로 변하지 않는 값을 표현할 때 사 용는데 두 개념에는 약간의 차이가 있다.</p>
<p>상수는 const 예약어를 사용해서 변수형태로 선언되고 컴파일 시간에 값이 결정되어 프로그램 중에 값이 변경되지 않는 것이라면 리터럴 상수는 컴파일러가 코드에서 직접 사용할 수 있는 값을 의미한다. 예를 들어서 0, 1, 2, 3 등이 모두 정수형 리터럴 상수로 변수나 상수가 아니면서 프로그램 실행 중에도 변경할 수 없는 값이다.</p>

<pre class="csharp"><code>// 상수 PI
const double PI = 3.14159265358979;
// 숫자 리터럴 상수
double radius = 3.0;
// 문자 리터럴 상수
char c = 'C';
// 문자열 리터럴 상수
string str = "Str";</code></pre>
<p>리터럴 상수에는 숫자뿐만 아니라 문자 또한 포함된다.</p>
<p>즉 코드 상에서 선언되지 않았으면서 변수에 할당이 가능한 모든 값을 리터럴 상수라고 할 수 있다.</p>
