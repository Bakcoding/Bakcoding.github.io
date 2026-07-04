---
title: "C# 문자 저장 키워드 : char"
excerpt: "C# 문자 저장 키워드 : char"
categories:
  - CSharp
permalink: /programming/csharp/46-csharp-char/
tags:
  - "CSharp"
  - "C#"
  - "char"
  - "type keyword"
toc: true
toc_sticky: true
date: 2023-04-25
last_modified_at: 2023-04-25
source_url: https://b-note.tistory.com/46
---

<h3>char</h3>
<p>유니코드 문자를 표현하기 위한 데이터 타입이다.</p>
<p>2바이트의 크기를 가지며 0부터 65535까지의 값을 저장할 수 있다. 이 범위 내의 값은 유니코드 표준에서 정의된 문자와 대응되는데 A라는 문자를 char 타입으로 표현하면 65 값을 가진다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="683" data-origin-height="439"><span><img src="/assets/images/posts/2023/04/25/46-1.png" loading="lazy" width="683" height="439" data-origin-width="683" data-origin-height="439"/></span></figure>
</p>
<p>또한 이스케이프를 사용하여 특수 문자들을 표현할 수 있다. \n, \t ...</p>

<p>C#의 문자열은 char 타입의 배열 형태로 구현되어 있으며 문자열에서 인덱스를 사용하여 개별 문자에 접근하는 것이 가능하다.</p>
