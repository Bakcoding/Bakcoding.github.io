---
title: "C# 문자열 키워드 : string"
excerpt: "C# 문자열 키워드 : string"
categories:
  - CSharp
permalink: /programming/csharp/49-csharp-string/
tags:
  - "CSharp"
  - "C#"
  - "String"
  - "type keyword"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/49
---

<h3>string</h3>
<p>문자열을 나타내는 데이터 타입이다. 문자열은 큰 따옴표로 묶인 문자들의 집합으로 표현된다.</p>

<pre class="csharp"><code>string greeting = "Hello World!";</code></pre>

<p>string은 다른 기본 데이터 타입과 다르게 참조형으로 System.String 클래스의 인스턴스이다. 따라서 string 변수에는 문자열의 주소가 저장되는데 이로 인해 문자열에 변경이 생기면 새로운 문자열 인스턴스가 생성이 된다.</p>

<p>string 타입은 null 값을 가질 수 있으며 이때는 아직 초기화되지 않은 것으로 간주된다.</p>
<pre class="csharp"><code>string str = null;
// str 접근시 초기화 먼저 하라는 컴파일 에러 발생</code></pre>
