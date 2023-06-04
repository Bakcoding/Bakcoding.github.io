---
title:  "ui 라이브러리"
excerpt: "css, library, semantic, ui"

categories:
  - CSS
tags:
  - [css, library, semantic, ui]

toc: true
toc_sticky: true
 
date: 2021-11-08 
last_modified_at: 2023-06-05
---  

***

### ui 라이브러리

웹페이지를 구축할 때 사용하는 라이브러리이다. 다양한 기능과 세련된 기본 디자인을 가지고 있기 때문에 유용하다.  

<a href="https://semantic-ui.com/">semantic ui</a>

<a href="https://getbootstrap.com/">bootstrap</a>

기타 다양한 라이브러리가 존재하기 때문에 직접 찾아보고 자신이 구축할 웹페이지에 적합한 라이브러리를 선택한다. (검색어 web front end framework library)  

<br>

### semantic ui  

시작하기  

NodeJS를 사용해서 설치하여 사용하는 방법과 압축 파일을 다운 받아서 사용하는 방법이 있다.    

**NodeJS**  

<img src="/assets/images/posting/20211108/semantic_install.png" alt="semantic_install" width="400">

* gulp 설치  

  node js로 설치하기 위해서는 npm으로 gulp의 설치가 선행되어야한다.  

  ```cmd
  npm install -g gulp
  ```

* semantic 설치  

  ```cmd
  npm install semantic-ui --save
  cd semantic/
  gulp build
  ```

  프로젝트 폴더로 이동해서 npm을 사용해 semantic-ui를 설치한다.  

  <img src="/assets/images/posting/20211108/gulp_choice.png" alt="gulp_choice" width="400"><br>

  gulp를 사용하여 설치가 진행되며 도중에 몇가지 옵션을 설정해주면 된다.  
  
<br>

**압축 파일 다운로드**  

<img src="/assets/images/posting/20211108/compress_install.png" alt="compress_install" width="400"><br>  

다운 받은 압축파일을 해제하여 프로젝트 폴더에 위치시킨다.  

Semantic-UI-CSS-master 폴더의 이름은 간단하게 semantic으로 변경하여 사용한다.  

* 참조할 파일 지정  

  ```html
  <link rel="stylesheet" type="text/css" href="semantic/dist/semantic.min.css">
  <script
    src="https://code.jquery.com/jquery-3.1.1.min.js"
    integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8="
    crossorigin="anonymous"></script>
  <script src="semantic/dist/semantic.min.js"></script>
  ```

  semanctic을 사용하기위해 참조할 파일을 선언한다. 

```html
<!-- index.html -->  
<!doctype html>
<html>
    <head>
        <!--  href 경로확인, 그리고 개발할 때는 min이 아닌 파일을 사용하는것이 편하다. 실제 사용할 때는 min.css -->
        <link rel="stylesheet" type="text/css" href="semantic/semantic.css">
        <script
            src="https://code.jquery.com/jquery-3.1.1.min.js"
            integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8="
            crossorigin="anonymous"></script>
        <script src="semantic/semantic.js"></script>
    </head>
</html>
```
**제대로 파일 경로가 잡혔는지 확인**

html 파일을 브라우저를 열고 개발자 툴을 사용하여 확인해 본다.  

크롬의 경우  

<img src="/assets/images/posting/20211108/check_files.png" alt="check_files" width="400"><br>

이제 카테고리에서 원하는 ui를 선택하면 디자인과 그것을 만들 수 있는 소스 코드를 얻을 수 있다. 

<img src="/assets/images/posting/20211108/button_example.png" alt="button_example" width="300"><br>

```html
<!doctype html>
<html>
    <head>
        <!--  href 경로확인, 그리고 개발할 때는 min이 아닌 파일을 사용하는것이 편하다. 실사용은 min     -->
        <link rel="stylesheet" type="text/css" href="semantic/semantic.css">
        <script
            src="https://code.jquery.com/jquery-3.1.1.min.js"
            integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8="
            crossorigin="anonymous"></script>
        <script src="semantic/semantic.js"></script>
    </head>
    <body>
        <button class="ui button">
              Follow
        </button>
    </body>
</html>
```