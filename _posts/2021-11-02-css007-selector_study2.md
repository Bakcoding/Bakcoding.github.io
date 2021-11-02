---
title:  "선택자 종류_2"
excerpt: "css, selector"

categories:
  - CSS
tags:
  - [css, selector]

toc: true
toc_sticky: true
 
date: 2021-11-02 
last_modified_at: 2021-11-02
---  

***

### 자식 중 선택하기

**first child pseudo-selector**    

A:first-child{ }

자식 중 첫번째 자식을 선택한다.    

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li:first-child {
        color:blue;
      }
    </style>
  </head>
  <body>
    <ol>
      <li>HTML</li>
      <li>CSS</li>
      <li>JavaScript</li>
    </ol>
  </body>
</html>
```

<br>

**last child pseudo-selector**  

자식 중 마지막 태그를 선택한다.  

A:last-child{ }

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li:last-child {
        color:blue;
      }
    </style>
  </head>
  <body>
    <ol>
      <li>HTML</li>
      <li>CSS</li>
      <li>JavaScript</li>
    </ol>
  </body>
</html>
```

**empty selector**  

자식이 없는 태그를 선택한다.  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li:empty{
        background: lime;
      }
    </style>
  </head>
  <body>
    <li>HTML</li>
    <li>CSS</li>
    <li></li>
  </body>
</html>
```

<br>

### 나열된 순서로 선택하기  

**nth child pseudo-selector**

태그가 나열된 순서로 선택한다.  

A:nth-child(B) { }

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li:nth-child(2) {
        color:blue;
      }
    </style>
  </head>
  <body>
    <li>HTML</li>
    <li>CSS</li>
    <li>JavaScript</li>
  </body>
</html>
```

**nth last child selector**  

태그가 나열된 역순으로 선택한다.  

A:nth-last-child(B){ }

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li:nth-last-child(3) {
        color:blue;
      }
    </style>
  </head>
  <body>
    <li>HTML</li>
    <li>CSS</li>
    <li>JavaScript</li>
  </body>
</html>
```

<br>

### 타입으로 선택하기  

**first of type selector**  

A:first-of-type{ }

태그의 타입 중 첫번째를 선택한다.  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li:first-of-type {
        color:blue;
      }
    </style>
  </head>
  <body>
    <p>SELECTOR</p>
    <li>HTML</li>
    <li>CSS</li>
    <li>JavaScript</li>
  </body>
</html>
```

**nth of type selector**  

타입을 지정하는 방식에 규칙을 넣을 수 있다.  

A:nth-of-type(B){ }

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li:nth-of-type(odd) {
        color:blue;
      }
    </style>
  </head>
  <body>
    <p>SELECTOR</p>
    <li>HTML</li>
    <li>CSS</li>
    <li>JavaScript</li>
  </body>
</html>
```

숫자 뿐만 아니라 홀수(odd) 짝수(even) 또는 방정식으로 표현할 수 있다.  

A:nth-of-type(Bn+C){ }  

규칙을 다양하게 적용할 수 있다.  

<br>

**only of type selector**  

태그가 유일하다면 이 방법을 사용하여 선택할 수 있다.  

A:only-of-type{ }

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li:only-of-type{
        color:blue;
      }
    </style>
  </head>
  <body>
    <ol>
      <li>HTML</li>
      <li>CSS</li>
    </ol>
    <ol>
      <li>JavaScript</li>
    </ol>
  </body>
</html>
```

<br>

**last of type selector**  

동일한 태그 중 마지막에 배열된 태그를 선택한다.  

A:last-of-type{ }

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      .sel:last-of-type{
        color:blue;
      }
    </style>
  </head>
  <body>
    <ol>
      <li class="sel">HTML</li>
      <li class="sel">CSS</li>
      <li class="sel">JavaScript</li>
    </ol>
    <ol>
      <li class="sel">C</li>
      <li class="sel">C++</li>
    </ol>
  </body>
</html>
```

<br>

### A:not(B) { }  

B내용을 제외한 태그를 선택한다.  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li:not(.sel){
        color:blue;
      }
    </style>
  </head>
  <body>
    <li class="sel">HTML</li>
    <li class="sel">CSS</li>
    <li>JavaScript</li>
  </body>
</html>

```