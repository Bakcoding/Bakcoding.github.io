---
title: "C# 고정소수점 키워드 : decimal"
excerpt: "C# 고정소수점 키워드 : decimal"
categories:
  - CSharp
permalink: /programming/csharp/42-csharp-decimal/
tags:
  - "CSharp"
  - "C#"
  - "decimal"
  - "type keyword"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/42
---

<h3>decimal</h3>
<p>부동 소수점과 다르게 고정 소수점 숫자를 나타내는 자료형이다. 정확한 소수점 계산이 필요한 금융, 세금, 계산 등과 같은 분야에서는 decimal을 자주 사용한다.</p>

<p>최대 28자리의 숫자를 나타낼 수 있으며 부호, 정수, 소수점, 소수점 이하 자릿수를 나타내는 4바이트 정수형 정수부와 소수부를 나타내는 4바이트 정수형 소수부 그리고 소수점 위치를 나타내는 4바이트 정수형 지수부 등으로 구성된다.</p>

<pre class="csharp"><code>decimal balance = 100.50m;
decimal withdrawalAmount = 20.25m;
decimal newBalance = balance - withdrawalAmount;
Console.WriteLine($"New balance : {newBalance:C}");
// balance : 기존 잔액
// withdrawalanceAmount : 출금액
// newBalance : 출금 후 잔액

// New balance: $80.25 출력</code></pre>
<p>decimal을 사용할 때는 m으로 끝나는 접미사를 사용해서 변수를 선언해야 한다.</p>

<p>소수점 자릿수가 다른 경우의 계산에서는 더 적은 숫자와 같은 자릿수로 맞춘 후 계산이 된다.</p>

<pre class="csharp"><code>decimal d1 = 100.123m;
decimal d2 = 10.1m;

// d1 + d2 = 110.223m</code></pre>
<p>만약 자릿수를 맞추어도 계산이 불가능한 경우에는 OverflowException이 발생한다. 따라서 숫자를 계산할 때는 소수점 자릿수를 유의하여 맞추는 것이 좋다.</p>
