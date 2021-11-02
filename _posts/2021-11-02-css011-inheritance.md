---
title:  "상속"
excerpt: "css, inheritance"

categories:
  - CSS
tags:
  - [css, inheritance]

toc: true
toc_sticky: true
 
date: 2021-11-02 
last_modified_at: 2021-11-02
---  

***

### 상속

html에서 부모 자식 관계는 태그의 열고 닫는 사이로 표현된다. 

```html
<!DOCTYPE html>
<html>
  <head>
    <style>
    /*
      li{color:red;}
      h1{color:red;}
      */
      html{color:red;}
      #select{color:black;}
      body{border:1px solid red;}
    </style>
  </head>
  <body>
    <h1>수업내용</h1>
    <ul>
      <li>html</li>
      <li>css</li>
      <li id="select">javascript</li>
    </ul>
  </body>
</html>
```

여기서 가장 최상위 부모는 html태그이다.  

따라서 부모에 적용시키면 문서 전체에 효과가 있기 때문에 페이지 전범위에 관한거라면 상속의 개념을 활용하는게 더 편리하게된다.  

부모로 공통적인 특징을 적용 -> 자식마다 세부적인 사항 적용  

중요한점은 상속이 되는 속성과 그렇지 않은 속성이 구분되기 때문에 이를 잘 파악하고 있어야한다.  

<a href="https://www.w3.org/TR/CSS21/propidx.html">CSS 상속 속성</a><br>

* html{color:red;}

  페이지 전체에 적용  

* \#select{color:black;}

  id="select"에만 적용  

* body{border:1px solid red;}

  테두리를 만들어준다. body에 적용되었지만 하위의 태그에 상속되지 않는다.