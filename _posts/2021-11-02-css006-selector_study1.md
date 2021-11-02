---
title:  "선택자 종류_1"
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

### descendant selector  

중복되는 태그중 특정 태그의 자식을 선택한다.    

A B{ }

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      ol li{
        color:red;
      }
    </style>
  </head>
  <body>
    <ol>
      <li>HTML</li>
    </ol>
    <li>CSS</li>
    <li>JavaScript</li>
  </body>
</html>
```

<br>

### combine the class selector  

클래스 속성이 지정된 태그를 선택한다.

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li.sel{
        color:blue;
      }
    </style>
  </head>
  <body>
    <li class="sel">HTML</li>
    <li>CSS</li>
    <li class="sel">JavaScript</li>
  </body>
</html>
```

두 가지를 조합해서 특정 태그의 자식 중 클래스 속성이 지정된 태그를 선택할 수 있다.  

A B.class{ }

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      ol li.sel{
        color:blue;
      }
    </style>
  </head>
  <body>
    <ol>
      <li class="sel">HTML</li>
      <li>CSS</li>
    </ol>
    <li class="sel">JavaScript</li>
  </body>
</html>
```

<br>

#### universal selector

모든 태그를 선택한다.  

\* { } 

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      * {
        color:blue;
      }
    </style>
  </head>
  <body>
    <ol>
      <li class="sel">HTML</li>
      <li>CSS</li>
    </ol>
    <li class="sel">JavaScript</li>
  </body>
</html>
```

특정 태그의 자식에 한해서 모두 선택할 수 있다.  

A * { }

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      ol*{
        color:blue;
      }
    </style>
  </head>
  <body>
    <ol>
      <li id="selector" class="sel">HTML</li>
      <li>CSS</li>
    </ol>
    <li class="sel">JavaScript</li>
  </body>
</html>
```

<br>

### adjacent sibling selector

기준 태그와 인접한 태그를 선택한다.  

A + B { } 

기준이 되는 태그는 선택되지 않는다.  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li+p{
        color:blue;
      }
    </style>
  </head>
  <body>
    <li>HTML</li>
    <p>C</p>
    <p>JS</p>
    <li>CSS</li>
    <p>C++</P>
    <li>JavaScript</li>
  </body>
</html>
```

기준 태그부터 특정 태그 사이의 태그들을 선택한다.  

A ~ B { }

기준을 제외하고 선택된다.  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li~p{
        color:blue;
      }
    </style>
  </head>
  <body>
    <li>HTML</li>
    <p>C</p>
    <p>JS</p>
    <p>C++</P>
    <li>CSS</li>
    <li>JavaScript</li>
  </body>
</html>
```
