---
title:  "의미론적인 태그"
excerpt: "html, tag, semantic"

categories:
  - HTML
tags:
  - [html, tag, semantic]

toc: true
toc_sticky: true
 
date: 2021-10-30 
last_modified_at: 2021-10-30
---  

***

### 의미론적

웹이 발전되면서 보여지는 정보 뿐만 아니라 포함하고있는 정보 또한 중요해진다.  

사람에게 뿐만아니라 해석하는 기계에게도 활용될 수 있는 데이터가 중요해지면서 의미론적(semantic)의 개념이 대두되었다.  

<br/>

### semantic tag
html5에 들어서면서 특별한 기능보다 페이지의 구조를 명확하게 표현할 수 있는 태그들이 추가되었다. 이런 태그들을 semantic 태그라고 한다.

```html
<!DOCTYPE html>
<html>
<head>
  <title>HTML 기본 문법 연습</title>
  <meta charset="UTF-8">
</head>

<body>
  <h1><a href="index.html">HTML 연습용 페이지</a></h1>
  <ol>
    <li><a href="1.html">HTML이란?</a></li>
    <li><a href="2.html">태그와 속성</a></li>
    <li><a href="3.html">기본 문법</a></li>
    <li><a href="4.html">문서의 구조</a></li>
  </ol>
  <h2>페이지 만들기</h2>
  HTML기본 문법을 가지고 웹 페이지를 직접 만들어 본다.   
</body>
</html>
```

* header  

  소개 및 탐색에 도움을 주는 콘텐츠를 나타낸다. 제목, 로고, 검색 폼 등이 해당된다.  

* footer  

  문서의 내용 중 가장 하단에 해당하는 구획이다. 일반적으로 작성자, 저작권 정보, 관련 문서 등이 해당된다.  

* nav  

  문서의 부분 중 현재 페이지 또는 다른 페이지로의 링크를 보여주는 구획을 나타낸다. 메뉴, 목차, 색인 등이 해당한다.  

* article  

  독립적으로 구분해 배포하거나 재사용할 수 있는 구획을 나타낸다. 일반적으로 본문에 해당한다.  

* section

  독립적인 구획을 나타낸다. 명확하게 구분할 수 있는 적합한 의미를 가진 요소가 없다면 사용한다.  


```html
<!DOCTYPE html>
<html>
<head>
  <title>HTML 기본 문법 연습</title>
  <meta charset="UTF-8">
</head>

<body>
<header>
  <h1><a href="index.html">HTML 연습용 페이지</a></h1>
</header>
<nav>
  <ol>
    <li><a href="1.html">HTML이란?</a></li>
    <li><a href="2.html">태그와 속성</a></li>
    <li><a href="3.html">기본 문법</a></li>
    <li><a href="4.html">문서의 구조</a></li>
  </ol>
</nav>
  <article>
    <h2>페이지 만들기</h2>
    TML기본 문법을 가지고 웹 페이지를 직접 만들어 본다.
  <article>   
</body>
</html>
```
  

semantic tag를 추가해도 웹 페이지의 보여지는 모습에는 차이가 없지만 의미론적인면에서 페이지의 가치가 올라갔다고 할 수 있다.  

<br>

### 종류와 정의  

<a href="https://developer.mozilla.org/ko/docs/Glossary/Semantics#%EC%9D%98%EB%AF%B8%EB%A1%A0%EC%A0%81_%EC%9A%94%EC%86%8Celement%EB%93%A4">Semantic tags</a>

위 사이트에서 의미론적 태그들의 정의와 그 예제들을 살펴볼 수 있다.  

