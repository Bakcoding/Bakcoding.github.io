---
title:  "가상 클래스 선택자"
excerpt: "css, selector, pseudo, class"

categories:
  - CSS
tags:
  - [css, selector, pseudo, class]

toc: true
toc_sticky: true
 
date: 2021-11-01 
last_modified_at: 2021-11-01
---  

***

### 가상 클래스 선택자

가상 클래스 선택자(pseudo class selector)는 클래스 선택자는 아니지만 요소의 상태에 따라서 클래스 선택자처럼 여러 요소를 선택할 수 있게 된다.  

<br>

### 동작

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    a:active{
      color:green;
    }
    a:hover{
      color:yellow;
    }
  </style>
</head>
<body>
  <a href="https://bakcoding.github.io/">blog</a>
</body>
</html>
```

style 내부의 코드를 살펴본다.  

* active  

  마우스를 클릭했을 때  

* hover  
  
  마우스를 롤오버 했을 때 

이렇게 요소의 상태에 따라 동작되는 것을 가상 클래스 선택자라고 한다. 

active와 hover가 동시에 발생할 경우 마지막에 작성된 코드가 적용되기 때문에 의도한대로 동작시킬 때는 작성 순서도 유의해야한다.  

<br>

### 방문

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    a:link{
      color:black;
    }
    a:visited{
      color:red;
    }
    a:focus{
      color:white;
    }
  </style>
</head>
<body>
  <a href="https://bakcoding.github.io/">방문</a>
  <a href="https://github.com/">방문안함</a>
</body>
</html>
```

* link

  방문한 적이 없는 링크

* visited

  방문한 적이 있는 링크

* focus

  tap 입력으로 선택

visited의 경우 보안장의 이유로 접근할 수 있는 속성이 제한적이다.  

<br>

**visited 속성**

* color

* background-color

* border-color

* outline-color

* The color parts of the fill and stroke properties
 
<br/>

작성 순서에 따라서 동작이 정해지기 때문에 일반적으로 

link > visited > hover > active > focus의 순서대로 작성하는게 좋다.  