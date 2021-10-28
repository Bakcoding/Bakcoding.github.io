---
title:  "기본 문법_태그"
excerpt: "html, tutorial"

categories:
  - HTML
tags:
  - [html, tutorial]

toc: true
toc_sticky: true
 
date: 2021-10-27 
last_modified_at: 2021-10-27
---  

***

<h1> 기본 태그 </h1>  

웹 페이지를 만들 때 자주 사용되는 가장 기본적인 태그를 살펴본다.  

### \<strong> ~ \</strong>  
  
* 태그 사이의 텍스트를 굵게 표시한다.  

  ```html
  This page is <strong>Bakcoding</strong> blog.
  ```

  This page is <strong>Bakcoding</strong> blog.  

### \<u> ~ \</u>  

* 사이에 있는 텍스트에 밑줄을 긋는다.  

  ```html
  This page is <strong>Bakcoding</strong> <u>blog.</u>
  ```

  This page is <strong>Bakcoding</strong> <u>blog.</u>

### \<h1> ~ \</h1>  
  
* 태그 사이의 텍스트를 제목으로 정한다.  

  ```html
  <h1>Bakcoding</h1>
  ```
  <h1>Bakcoding</h1>

  h1, h2, ~, h6 으로 중첩해서 사용할 수 있다.  

  ```html
  <h1>Bakcoding</h1>
  <h2>My blog</h2>
  <h3>Studying</h3>
  <h4>Programming</h4>
  ```
  <h1>Bakcoding</h1>
  <h2>My blog</h2>
  <h3>Studying</h3>
  <h4>Programming</h4>

### \<li> ~ \</li>  

목록을 만드는 태그이다.  

  ```html
  <li>C</li>
  <li>C++</li>
  <li>Javascript</li>
  <li>HTML</li>
  ```
  <li>C</li>
  <li>C++</li>
  <li>Javascript</li>
  <li>HTML</li>

보통 단독으로 쓰지 않고 \<ul>, \<ol> 태그와 같이 쓰인다.  

**\<ul> ~ \</ul>**

  순서가 필요 없는 목록을 만든다.  

  ```html
  <ul>
  <li>C</li>
  <li>C++</li>
  </ul>

  <ul>
  <li>Unity</li>
  <li>Cocos</li>
  </ul>
  ```
<ul>
<li>C</li>
<li>C++</li>
</ul>
  
<ul>
<li>Unity</li>
<li>Cocos</li>
</ul>

동일한 성질 끼리 묶어서 목록을 구분할 수 있다.  

**\<ol> ~ \</ol>**  

숫자, 알파벳 등 순서가 있는 목록을 만든다.  

```html
<ol>
<li>프로그램 목적 정의</li>
<li>프로그램 설계</li>
<li>코드 작성</li>  
</ol>
```
<ol>
<li>프로그램 목적 정의</li>
<li>프로그램 설계</li>
<li>코드 작성</li>  
</ol>  


### \<dl> ~ \</dl>
용어의 정의를 나열하는 목록을 만든다.  

\<dt> ~ \</dt> : 용어의 제목을 나타내는 태그  

\<dt> ~ \</dt> : 용어에 대한 설명을 나타내는 태그

```html
<dl>
  <dt>내 블로그</dt>
  <dd>프로그래밍 언어</dd>
  <dd>게임엔진</dd>
</dl>

<dl>
  <dt>HTML이란?</dt>
  <dd>Hyper Text Markdown Language</dd>
  <dd>웹 브라우저를 표현하기 위한 언어</dd>
</dl>
```
<dl>
  <dt>내 블로그</dt>
  <dd>프로그래밍 언어</dd>
  <dd>게임엔진</dd>
</dl>

<dl>
  <dt>HTML이란?</dt>
  <dd>Hyper Text Markdown Language</dd>
  <dd>웹 브라우저를 표현하기 위한 언어</dd>
</dl>