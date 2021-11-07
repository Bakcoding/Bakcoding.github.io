---
title:  "preprocessor"
excerpt: "css, preprocessor, stylus, brackets, nodejs"

categories:
  - CSS
tags:
  - [css, preprocessor, stylus, brackets, nodejs]

toc: true
toc_sticky: true
 
date: 2021-11-07 
last_modified_at: 2021-11-07
---  

***

### preprocessor  

preprocessor

css가 뛰어난 언어임에도 모든 면에서 장점만 가질 수 없다. 그렇기 때문에 css에 편리한 기능을 더해서 새로운 언어를 만들고 이 새로운 언어를 프로그램을 통해서 결과적으로 css로 만들어 주는 도구들이 만들어졌다.  

이런 도구들을 preprocessor라고 한다.  

**대표적인 preprocessor**  

<a href="http://ww12.less2css.org/">lesscss</a>  

<a href="https://sass-lang.com/">sass-lang</a>  

<a href="https://stylus-lang.com/">stylus-lang</a>  

각 preprocessor를 비교한 사이트  

<a href="https://csspre.com/compile/">csspre</a>  

<br>

### stylus

<a href="https://stylus-lang.com/try.html#?code=body%20%7B%0A%20%20font%3A%2014px%2F1.5%20Helvetica%2C%20arial%2C%20sans-serif%3B%0A%20%20%23logo%20%7B%0A%20%20%20%20border-radius%3A%205px%3B%0A%20%20%7D%0A%7D">Try Stylus Online</a><br>

<img src="/assets/images/20211107_Posting/try_stylus_onlline.png" alt="try_stylus_onlline" width="400"><br>  

기본 동작 방식은 stylus로 작성된 코드를 css로 변환하여 사용하면 웹 브라우저는 stylus의 문법을 몰라도 css로 동작을 수행하게 된다.  

**사용이유**  

```css
body {
  font: 14px/1.5 Helvetica, arial, sans-serif;
}
body #logo {
  border-radius: 5px;
}
```

코드 처럼 css에서는 body 태그의 css를 작성할 때와 body 중 id값이 logo인 태그에 대해서 작업할 때 선택자가 따로 작성되어야한다.  

이 동작을 stylus 문법을 사용하여 작성하면  

```stylus
body {
  font: 14px/1.5 Helvetica, arial, sans-serif;
  #logo {
    border-radius: 5px;
  }
}
```

body 하나의 선택자를 사용하고 그 내부에서 선언을 통해서 id에 접근하는 코드를 작성할 수 있게 된다. 

즉 코드를 stylus 문법에 맞춰서 편하게 작성한 뒤 사용할 때는 변환기를 통해 css로 바꾸어주는것이 preprocessor이다.   

<br>

### stylus 실습

brackets의 확장 기능에 있는 stylus를 사용해 본다.  

Stylus Auto Compile 플러그인  

<a href="https://github.com/phoenix3008/stylus-autocompile">추가 정보</a><br>  

컴파일 옵션을 설정하는 코드를 확인한다.  

```
// out: ../dist/app.css, compress: true, sourcemap: true
```

주석이지만 stylus는 이 코드를 통해 컴파일한다.  

out: 파일 생성 결로와 이름  
compress: 압축, minify 여부  
sourcemap: 소스맵 생성 여부  

<br>

pp.styl 파일을 만들고 코드를 작성한다.

```stylus
// pp.styl
// out: pp.css, compress: true
body{
    color:red;
    h1{
        font-size:10px;   
    }
}
```

저장을 하면 자동으로 stylus를 통해서 css 파일이 설정한대로 생성된다.  

```css
/* pp.css */
body{color:#f00;}body h1{font-size:10px}
```

pp.html 파일을 만들어 테스트 해보면  

```html
<!docytype html>
<html>
    <head>
        <link rel="stylesheet" href="pp.css">
    </head>
    <body>
        <h1>stylus compile</h1>
    </body>
</html>
```

pp.styl 파일을 수정하면 페이지에 반영된다.   

<br>

### 명령어로 실행  

nodejs의 설치가 선행되어야한다.  

npm으로 stylus를 설치하여 사용해본다.  

<img src="/assets/images/20211107_Posting/stylus_nodejs.png" alt="stylus_nodejs" width="300"><br>  

```
 npm install stylus -g
```

명령프롬프트로 코드를 입력하면 stylus가 설치된다.  

명령어 참고 <a href="https://github.com/stylus/stylus">stylus github</a>  

파일 pp.styl을 만들고 명령창에서 css 파일로 컴파일 해본다.  

명령어 입력전에 현재경로는 styl 파일이 저장된 위치로 이동한다.  

```cmd
styl -w pp.styl -o pp.css
```

명령어를 입력하면 css 파일이 생성되는걸 볼 수 있다.  -w 키워드는 styl 파일의 변화를 감지해서 css 파일로 컴파일 해주는 것이다.  
