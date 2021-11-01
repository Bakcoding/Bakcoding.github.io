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

### selector

  선택자, 사람의 언어로는 주어에 해당하는 것으로 어떠한 것에 대해서 디자인을 할것인지 선택한다.  

  리스트에 해당하는 요소들만 디자인 할것이기 때문에 선택자는 li가 된다.  

### declaration block  

  선언 블록, 서술어에 해당하는 부분으로 중괄호로 구분되며 선택자의 어떤 속성을 어떻게 바꿀지를 선언하는 구역이다.  

  li뒤의 { ~ } 중괄호 전체가 선언 블록에 해당한다.  

### declaration  

  선언, 속성과 속성값으로 디자인을 정한다. 선언 블록 안에는 여러개의 선언이 들어올 수 있으며 선언의 끝에는 세미콜론을 통해서 끝을 명시해야한다.  

  color는 속성(property), red는 속성값(property-value)에 해당하며 다른 선언과 구분하기 위해 세미콜론(;)을 붙여주어야한다.  

<img src="/assets/images/20211101_Posting/struct.png" alt="declaration_struct">



