---
title: "Reserved Word, Keyword"
excerpt: "Reserved Word, Keyword"
categories:
  - ProgrammingBasic
permalink: /programming/programming-basics/13-reserved-word-keyword/
tags:
  - "Programming"
  - "Programming Basics"
  - "identifier"
  - "keyword"
  - "reserved word"
  - "키워드 종류"
toc: true
toc_sticky: true
date: 2023-01-20
last_modified_at: 2023-01-20
source_url: https://b-note.tistory.com/13
---

<h2>예약어</h2>
<p>예약어는 <b>식별자</b>로 사용할 수 없는 문자를 뜻한다.</p>
<p>현재 또는 향후 사용될 문자까지 예약어로 등록되기도 한다.</p>
<p><b>*식별자(identifier)</b></p>
<p>변수, 함수, 클래스 등의 이름을 지정하는데 사용되는 문자열</p>

<h2>키워드</h2>
<p>컴파일러에게 특별한 의미를 가지고 있는 문자이다.&nbsp;</p>
<p>키워드가 가지는 특징은 언어마다 다른데 키워드를 식별자로 사용할 수 있는 경우도 있고 그렇지 않은 경우도 있다.</p>

<p>두 개념을 명확하게 구분짓는게 애매하다.&nbsp;</p>
<p>어떤 언어에서는 모든 키워드가 예약어로 되어있어 키워드를 식별자로 사용하는게 불가능하지만 또 일부 언어에서는 키워드를 식별자로 사용하기도 하기 때문에 키워드를 예약어로 단정할 수 없고 예약어 또한 현재 사용중이 아닌 문자도 사용을 못하게 하는 경우가 있기 때문에 모든 예약어가 키워드처럼 의미를 가지고 있지 않을 수 있다.</p>

<p>그래서 예약어는 식별자로 사용 못하는 문자 키워드는 특별한 의미를 가지고 있는 문자로 구분하고 각 언어마다 키워드와 예약어를 파악하는게 중요하는게 좋을것같다.</p>

<p><span style="background-color: #f6e199;">💡키워드를 식별자로 사용하는 예 : Fortan ( <span style="color: #232629;">if then then then = else else else = then)</span></span></p>
<p><span style="background-color: #f6e199;">💡예약어가 키워드로 사용되지 않는 예 : Java&nbsp; (goto)</span></p>

<h3>키워드 종류</h3>
<p>키워드는 사용되는 방식과 기능 그리고 문맥에 따라서 종류가 나누어지며 언어마다 각기 다른 특징을 가지고 있기도 하지만 공통되는 부분도 많다.</p>

<p>일반적으로 사용되는 키워드를 정리한다.</p>

<p><b>제한자(Modifier)</b></p>
<p>타입과 멤버를 누가 수정할 수 있는지 특정하여 나타내는 키워드이다. 프로그램의 특정한 부분이 다른 곳에서 수정되는것을 허용하거나 방지하도록한다.</p>

<p><b>접근 제한자(Access Modifier)</b></p>
<p>클래스, 메서드, 프로퍼티, 필드 등의 멤버를 선언할 때 적용되는 것으로 클래스간의 멤버 접근성을 정의한다.</p>

<p><b>구문(Statement)</b></p>
<p>구문은 프로그램의 흐름과 연관된 키워드이다.</p>
<p>대표적으로 if, for 등의 키워드가 있다.</p>

<p><b>메서드 매개변수(Method Parameter)</b></p>
<p>메서드의 매개변수에서만 적용되는 키워드이다.</p>

<p><b>네임스페이스 키워드(Namespace Keywords)</b></p>
<p>네임스페이스 및 관련 연산자에 적용되는 키워드이다.</p>
<p>using ...&nbsp;</p>

<p><b>연산자 키워드(Operator Keywords)</b></p>
<p>기타 작업을 수행하는 키워드이다.</p>
<p>sizeof ...</p>

<p><b>접근 키워드(Access keywords)</b></p>
<p>객체 또는 클래스에 접근하는데 사용된다.</p>
<p>this ...</p>

<p><b>리터럴 키워드(Literal Keywords)</b></p>
<p>특정 값으로 평가될 수 있는 키워드이다.</p>
<p>null, false, true 등</p>

<p><b>타입 키워드(Type Keywords)</b></p>
<p>자료형에 사용되는 키워드이다.</p>
<p>int, char, float ...</p>

<p><b>문맥상 키워드(Contextual Keywords)</b></p>
<p>특정 문맥상에서만 키워드로 취급된다.</p>
