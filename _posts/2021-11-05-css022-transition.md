---
title:  "전환"
excerpt: "css, graphic, transition"

categories:
  - CSS
tags:
  - [css, graphic, transition]

toc: true
toc_sticky: true
 
date: 2021-11-05 
last_modified_at: 2021-11-05
---  

***

### 전환

transition 

효과가 변경될 때 부드럽게 처리해주는 기능이다.  

**종류**  

* transition-duration

* transition-property

* transition-delay

* transition-timing-function

* transition

```html
<!doctype>
<html>
    <head>
        <style>
            a{
                font-size:3rem;
                display:inline-block;
/*
                transition-property:all;
                transition-property:font-size transform;
                transition-duration:0.5s;
                transition:all 0.5s;
*/
                transition: font-size 0.5s, transform 0.5s;
                transition-delay:1s;
            }
            a:active{
                transform:translate(20px, 20px);
                font-size:2rem;
            }
        </style>
    </head>
    <body>
        <a href="#">Click</a>
    </body>
</html>
```

**transition-**  

* property

  효과를 적용할 속성을 지정한다. 모든 속성이나 개별적으로 지정할 수 있다.  

* duration

  지속시간, 지정한 시간만큼 동작을 진행한다.  

* delay

  동작 발동시간을 지연시킨다.  

* 축약형  

  transition: 속성 시간;


<head>
    <style>
        .transition{
            font-size:3rem;
            display:inline-block;
            transition: font-size 0.5s, transform 0.5s;
            transition-delay:1s;
        }
        .transition:active{
            transform:translate(20px, 20px);
            font-size:2rem;
        }
    </style>
</head>
<body>
    <a class="transition"href="#">Click</a>
</body><br>

<br>

### timing func

트랜지션의 효과를 몇 가지 함수를 통해서 간단하게 동작할 수 있다.  

```html
<!doctype>
<html>
    <head>
        <style>
            div{
                background-color: black;
                color:white;
                padding:10px;
                width:100px;
                height:50px;
                transition:height 1s;
                transition-timing-function:ease-out;
            }
            div:hover{
                height:400px;
            }
        </style>
    </head>
    <body>
        <div>
            TRANSITION
        </div>
    </body>
</html>
```

**transition func**  

몇가지 함수들이 기본적으로 제공되어 간단한 동작들을 쉽게 구현할 수 있다. 

이중에서 cubic-bezier 함수는 인자를 넣을 수 있어서 원하는 동작을 직접 구현이 가능하다. 

자유도가 올라가지만 그만큼 어려워진다. 이 때 쉽게 원하는 값을 구할 수 있는 사이트가 있다.  

<a href="https://matthewlein.com/tools/ceaser">timing function</a>
 
다양한 동작들을 api로 확인이 가능하며 직접 동작을 만들 수 있다. 그리고 그 동작에 대한 소스코드도 만들어주기 때문에 쉽게 커스텀 트랜지션을 만들 수 있다.  

```html
<!doctype>
<html>
    <head>
        <style>
            div{
                background-color: black;
                color:white;
                padding:10px;
                width:100px;
                height:50px;
                /* transition:height 1s; */
                transition: all 500ms cubic-bezier(0.680, -0.550, 0.265, 1.550); /* easeInOutBack */
                transition-timing-function: cubic-bezier(0.680, -0.550, 0.265, 1.550); /* easeInOutBack */
            }
            div:hover{
                height:400px;
            }
        </style>
    </head>
    <body>
        <div>
            TRANSITION
        </div>
    </body>
</html>
```

<p class="codepen" data-height="300" data-default-tab="html,result" data-slug-hash="PoKQyEP" data-user="bakcoding" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/bakcoding/pen/PoKQyEP">
  Untitled</a> by Bakcoding (<a href="https://codepen.io/bakcoding">@bakcoding</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script><br>


<br>

### 활용

페이지 로드를 자연스럽게 한다.  

```html
<!doctype>
<html>
    <head>
        <style>
            body{
                background-color:black;
                transition:all 1s;
            }
            div{
                background-color: black;
                color:white;
                padding:10px;
                width:100px;
                height:50px;
                transition:height 1s;
                transition-timing-function: cubic-bezier(0.680, -0.550, 0.265, 1.550); /* easeInOutBack */
            }
            div:hover{
                height:400px;
            }
        </style>
    </head>
    <body onload="document.querySelector('body').style.backgroundColor='white'">
        <div>
            TRANSITION
        </div>
    </body>
</html>
```

자바스크립트로 페이지가 열릴 때 백그라운드 색을 흰색으로 바꾼다.  

