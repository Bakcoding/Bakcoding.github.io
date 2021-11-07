---
title:  "링크와 임포트"
excerpt: "css, link, import"

categories:
  - CSS
tags:
  - [css, link, import]

toc: true
toc_sticky: true
 
date: 2021-11-07 
last_modified_at: 2021-11-07
---  

***

### 유지관리  

```html
<!-- page1 -->
<!doctype>
<html>
    <head>
        <style>
            h1{
                color:red;
            }
        </style>
    </head>
    <body>
        <h1>page1</h1>
    </body>
</html>

<!-- --------------------------- -->

<!-- page2 -->
<!doctype>
<html>
    <head>
        <style>
            h1{
                color:red;
            }
        </style>
    </head>
    <body>
        <h1>page2</h1>
    </body>
</html>
```

똑같은 css를 적용시킬 수 많은 페이지가 존재할 때 css의 내용이 바뀐다면 모든 페이지를 수정해야하는 일이 생긴다.  

또한 동일한 데이터를 페이지마다 다시 다운받게 되는 비효율적인 문제도 생긴다.

이 문제를 근본적으로 해결할 수 있는 방법이 link와 import이다.  

**link**  

중복해서 사용하는 css를 하나의 파일로 연결시켜 사용한다.  

중복되는 부분의 css를 따로 파일로 만들고 사용할 페이지에서 link태그를 사용하여 불러온다.  

```html
<!-- style.css -->
h1{
    color:red;
}

<!-- ------------------ -->

<!-- page1 -->
<!doctype>
<html>
    <head>
        <link rel="stylesheet" href="style.css">
        <style>
        </style>
    </head>
    <body>
        <h1>page1</h1>
    </body>
</html>
```

이제 page1은 웹 브라우저에서 파일이 열릴 때 href 경로의 css 파일을 다운받은 다음 그 내용을 읽어서 페이지에 적용시키게 된다.  

이 방법은 중복되는 작업을 피하면서 동시에 유지보수 및 관리, 사용자와 제공자의 비용절감 등 장점을 가진 강력한 기능이다.  

이렇게 외부 파일을 다운받게되면 브라우저는 캐시로 저장하기 때문에 다음에 다시 방문하는 페이지의 경우 외부파일을 다시 다운받지않고 캐시에 저장된 파일을 불러와 사용하기 때문에 html파일 자체의 경량화와 파일을 받는 비용을 줄일 수 있게 된다.  

**import**  

link는 html 태그로 외부의 css파일을 로드하는 방법이다. 다른 방법으로 css내부에서 다른 css 파일을 로드하는 방법이 있으며 두 방식은 동일하게 동작한다.  

```html
<!-- page1 -->
<!doctype>
<html>
    <head>
<!--        <link rel="stylesheet" href="style.css">-->
        <style>
            @import url("style.css");
        </style>
    </head>
    <body>
        <h1>page1</h1>
    </body>
</html>

<!-- style.css -->

@import url("other.css");
h1{
    color:red;
}
```

html에서 css를 작성하는 style 태그 영역에서 import를 사용하여 불러 올 수 있으며 이 방법으로 css 파일에서 또 다른 css 파일을 불러오는것도 가능하다.  