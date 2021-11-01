---
title:  "선택자"
excerpt: "css, selector"

categories:
  - CSS
tags:
  - [css, selector]

toc: true
toc_sticky: true
 
date: 2021-11-01 
last_modified_at: 2021-11-01
---  

***

### 선택자

선택을 해주는 요소이다. 선택자를 통해 특정 요소들을 선택하여 스타일을 적용할 수 있게 된다.

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    li{
      color:red;
      text-decoration:underline;
    }
  </style>
</head>
<body>
  <li>Hello World!</li>
</body>
</html>
```

리스트의 디자인을 만드는 css 코드를 살펴본다.  

* selector

  선택자, 사람의 언어로는 주어에 해당하는 것으로 어떠한 것에 대해서 디자인을 할것인지 선택한다.  

  리스트에 해당하는 요소들만 디자인 할것이기 때문에 선택자는 li가 된다.  

* declaration block  

  선언 블록, 서술어에 해당하는 부분으로 중괄호로 구분되며 선택자의 어떤 속성을 어떻게 바꿀지를 선언하는 구역이다.  

  li뒤의 { ~ } 중괄호 전체가 선언 블록에 해당한다.  

* declaration  

  선언, 속성과 속성값으로 디자인을 정한다. 선언 블록 안에는 여러개의 선언이 들어올 수 있으며 선언의 끝에는 세미콜론을 통해서 끝을 명시해야한다.  

  color는 속성(property), red는 속성값(property-value)에 해당하며 다른 선언과 구분하기 위해 세미콜론(;)을 붙여주어야한다.  

<img src="/assets/images/20211101_Posting/struct.png" alt="declaration_struct"><br>

<br>

### 선택자의 종류  

* 태그 선택자  
  
  태그를 선택한다. 선택한 태그는 문서의 모든 태그에 영향을 준다.  

* 아이디 선택자  

  아이디 속성의 값에 해당하는 태그를 선택한다.   

  ```html
  <!DOCTYPE html>
  <html>
    <head>
      <style>
        #select{
          font-size:50px;
        }
      </style>
    </head>
    <body>
      <ul>
        <li>HTML</li>
        <li id="select">CSS</li>
        <li>JavaScript</li>
      </ul>
    </body>
  </html>
  ```

  id가 select인 태그를 선택자로 사용하였다. 아이디 태그를 사용할 때는 #을 사용해 선택자를 지정할 수 있다.  
  
  아이디 선택자를 사용하면 전체가 아닌 일부에 대해서만 디자인을 적용시킬 수 있게 된다.   

* 클래스 선택자  

  하나의 태그에 대해서만 디자인을 바꿀때는 id를 사용하였다. 그럼 여러개를 골라서 동일한 디자인을 적용시킨다면 id를 동일하게 지정해주면 될 것이다. 

  하지만 이런식으로 사용하는것은 약속을 어기는 것이다. id는 하나의 고유한 값을 지정하는 것이기 때문에 여러개의 중복된 id를 지정한다는 것부터가 해서는 안되는 것으로 이렇게 여러 태그를 묶어서 관리하기 위해 사용하는 것이 class 선택자이다.  

  ```html
  <!DOCTYPE html>
  <html>
    <head>
      <style>
        #select{
          font-size:50px;
        }
        .deactive{
          text-decoration: line-through;
        }
      </style>
    </head>
    <body>
      <h1 class="deactive">웹 페이지 만들기</h1>
      <ul>
        <li clss="deactive">HTML</li>
        <li id="select">CSS</li>
        <li class="deactive">JavaScript</li>
      </ul>
    </body>
  </html>
  ```

  클래스는 묶음 단위로 디자인을 할 때 사용할 수 있으며 같은 태그가 아니어도 사용할 수 있다.

<br>

### 부모 자식 선택자  

태그, 아이디, 클래스 선택자를 기본으로하는 좀 더 복합적인 선택자를 만들어 더 섬세하게 다룰 수 있는 방법이다.  


ul과 ol 서로 다른 하위 목록안에 li가 있을 때 스타일에서 li를 선택자로 한다면 전체 li가 적용이 되어버린다.  

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
      ul li{
        color:red;
      }
    </style>
  </head>
  <body>
    <ul>
      <li>HTML</li>
      <li>CSS</li>
      <li>JavaScript</li>
    </ul>
    <ol id="lecture">
      <li>HTML</li>
      <li>CSS</li>
      <li>JavaScript</li>
    </ol>
  </body>
</html>
```
선택자를 ul li로 정할 수 있다.  
ul의 li 태그에만 색상이 붉은색으로 적용이된다.  

태그의 하위에 동일한 태그가 존재하는 경우에는

```html
<style>
      #lecture>li{
        border:1px solid red;
      }
</style>

<ol id="lecture">
  <li>HTML</li>
  <li>CSS
    <ol>
      <li>selector</li>
      <li>declaration</li>
    </ol>
  </li>
  <li>JavaScript</li>
</ol>
```

id를 통해서 중복되는 ol을 구분하고 직계자손만 선택할 경우에는 '>' 를 사용하면 된다.  

동일한 디자인을 서로 다른 두 태그에 적용하는 방법  

```html
    <style>
      ul{
        background-color:powderblue;
      }
      ol{
        background-color:powderblue;
      }
      /* 동일한 동작 */
      ul, ol{
        background-color:powderblue;
      }
    </style>

    <ul>
      <li>HTML</li>
      <li>CSS</li>
      <li>JavaScript</li>
    </ul>
    <ol>
      <li>HTML</li>
      <li>CSS</li>
      <li>JavaScript</li>
    </ol>
```

콤마를 사용해서 여러개 선택자를 지정해 동일한 디자인을 적용시킬 수 있다.  