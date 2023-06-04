---
title:  "캐스케이딩"
excerpt: "css, cascading"

categories:
  - CSS
tags:
  - [css, cascading]

toc: true
toc_sticky: true
 
date: 2021-11-03 
last_modified_at: 2023-06-04
---  

***

### 캐스케이딩  

cascading  

CSS의 첫번째 문자의 의미를 가지고 있는만큼 가장 중요하며 철학을 담고있다.  

CSS는 browser-user-author 간의 조화의 철학을 가지고있다.  

브라우저가 기본적으로 가지는 css 속성에 저자가 작성한 css를 읽어서 표시되며 이렇게 만들어진 페이지는 사용자가 디자인을 수정하여 반영할 수 도 있다.

이렇게 다수의 디자인에 영향을 받기 때문에 충돌을 피하면서 조화를 이루기 위해서 우선순위를 정하는것을 캐스케이딩이라 한다.

<br>

### 캐스케이딩 규칙  
질서를 지키기 위한 규칙이 존재한다.  

* 중요도 

  css의 선언된 위치에 따라서 우선순위가 달라진다.  

* 명시도  

  대상을 명확하게 특정할수록 명시도와 우선순위가 높아진다. 

* 소스순서

  css 선언을 나중에 할수록 우선순위가 높아진다.  

<br>

### 중요도  

브라우저 css < 사용자 css < 저자 css

기본적인 브라우저의 css속성이 있다. 이 속성은 브라우저마다 다르지만 사용자의 css 수정으로 디자인을 바꿀 수 있다. 예를들어 크롬의 stylish가 사용자의 css 일반선언에 해당한다. 

하지만 사용자 역시 저자가 디자인한 웹 페이지를 수정하는데 한계가있다.   

```html
<!DOCTYPE html>
<html>
    <head>
        <style type="text/css">
          h1 {
            color: red
          }
          h1 {
            color: purple !important
          }
      </style>
    </head>
    <body>
        <h1>title</h1>
    </body>
</html>
```

이 소스파일을 브라우저로 열어서 개발자 도구로 편집해보면 편집이 적용되지 않는다.  

<br>

### 명시도  

css선언이 엘리먼트를 상세하게 특정할수록 우선순위가 높아진다. 
**예시**  

하나의 태그에 여러 css가 적용되었을 때 규칙보기  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li{color:red;}
      #idsel{color:blue;}
      .classsel{color:green;}
    </style>
  </head>
  <body>
    <li>html</li>
    <li id="idsel" class="classsel" style="color:powderblue">css</li>
    <li>javascript</li>
  </body>
</html>
```
위 css 코드를 하나씩 우선순위를 확인해보면 다음과 같다.  

1. style attribute

2. id selector

3. class selector

4. tag selector

우선 순위를 이해할 때는 무엇이 더 포괄적인가 세부적인가를 비교하면 된다.  

즉 세부적이면서 구체적으로 대상이 특정될수록 우선순위가 높아지고 대상이 포괄적이게 되면 우선도가 떨어지게 된다.  

이러한 구조이기 때문에 더 효율적인 작업이 가능해진다.  

**강제로 우선도 높이기**  

!important 를 사용하면 우선 순위를 강제로 높여주게 된다.  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      li{color:red !important;}
      #idsel{color:blue;}
      .classsel{color:green;}
    </style>
  </head>
  <body>
    <li>html</li>
    <li id="idsel" class="classsel" style="color:powderblue">css</li>
    <li>javascript</li>
  </body>
</html>
```

순위가 제일 낮은 태그 선택자가 !important를 통해서 제일 우선적으로 적용된다.  

<img src="/assets/images/posting/20211103/evince.png" alt="evince" title="https://stuffandnonsense.co.uk/archives/css_specificity_wars.html" width="400"><br>

<br>

### 소스순서  

css가 작성된 순서에 따라서 우선도가 정해진다.  

```html
<!DOCTYPE html>
<html>
    <head>
        <style type="text/css">
            #example.examples {
                color: red;
            }
            #example.examples {
                color: green;
            }
        </style>
    </head>
    <body>
        <div id="example" class="examples">
            example
        </div>
    </body>
</html>
```

동일한 명시도와 중요도라면 작성 순서로 우선순위가 결정된다. 