---
title:  "선택자 종류_3"
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

### 속성으로 선택  

attribute selector  

속성을 지정해서 사용중인 태그를 선택한다.

\[attribute\] { }

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      [class]{
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

태그를 특정해서 사용할 수 있다.  

A\[attribute\]  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li[class]{
        color:blue;
      }
    </style>
  </head>
  <body>
    <li class="sel">HTML</li>
    <li class="sel">CSS</li>
    <li>JavaScript</li>
    <section class="sel">
      SELECTOR
    </section>
  </body>
</html>
```

<br>

### 속성값으로 선택  

속성에 할당된 값으로 선택한다.  

\[attribute="value"\]  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li[class="val"]{
        color:blue;
      }
    </style>
  </head>
  <body>
    <li class="sel">HTML</li>
    <li class="sel">CSS</li>
    <li class="val">JavaScript</li>
  </body>
</html>
```
<br>

**attribute starts with selector**  

속성값의 시작에서부터 같은 문자를 포함하는 태그를 선택한다.   

\[attribute^="value"\]  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li[class^="sel"]{
        color:blue;
      }
    </style>
  </head>
  <body>
    <li class="sel">HTML</li>
    <li class="selec">CSS</li>
    <li class="select">JavaScript</li>
  </body>
</html>
```

<br>

**attribute ends with selector**  

속성값의 뒤에서부터 같은 문자를 포함하는 태그를 선택한다.  

\[attribute$="value"\]  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li[class$="tor"]{
        color:blue;
      }
    </style>
  </head>
  <body>
    <li class="selector">HTML</li>
    <li class="collector">CSS</li>
    <li class="select">JavaScript</li>
  </body>
</html>
```

<br>

**attribute wildcard selector**  

속성값에 같은 문자를 포함하는 태그를 선택한다.  

\[attribute*="value"\]

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li[class*="le"]{
        color:blue;
      }
    </style>
  </head>
  <body>
    <li class="selector">HTML</li>
    <li class="collector">CSS</li>
    <li class="select">JavaScript</li>
  </body>
</html>
```