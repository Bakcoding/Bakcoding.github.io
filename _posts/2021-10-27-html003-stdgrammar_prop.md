---
title:  "기본 문법_속성"
excerpt: "html, tutorial"

categories:
  - HTML
tags:
  - [html, tutorial]

toc: true
toc_sticky: true
 
date: 2021-10-27 
last_modified_at: 2021-10-27
---  

***

<h1> 기본 속성 </h1>  

속성은 태그만으로 표현할 수 없을 때 부가설명을 위해 사용한다.  

웹 페이지를 만들 때 자주 사용하는 속성을 살펴본다.  

### 링크  

웹 페이지에서 특정 텍스트를 누르면 해당 정보와 관련된 링크로 이동하는 방법이다.  

\<a> ~ \</a> 태그로 링크 영역이 정해진다. 하지만 이것만으로는 사용할 수 가 없다.  

링크는 어떤 페이지와 연결할건지에 대한 정보가 반드시 필요하기 때문에 이 정보에 대한 추가 입력이 필요하다.  

**href**  
부가적인 정보, 연결할 주소 입력

```html
<a href="https://bakcoding.github.io/">blog</a>
```
<a href="https://bakcoding.github.io/">blog</a>

속성 문법은 이처럼 추가적인 정보가 반드시 필요한 경우에 사용하기 위해서 추가되었고 부가적인 정보를 작성하는 기능을 하게 된다.  

* 새 탭에서 링크를 띄우는 방법 
  
  ```html
  <a href="https://bakcoding.github.io/" target="_blank">blog</a>
  ```  
  <a href="https://bakcoding.github.io/" target="_blank">blog</a>

  target으로 새 탭을 대상으로 주소를 열었다.  

  속성의 순서는 상관이 없으며 여러개를 작성할 수 있다.  


* 링크에 대한 설명 추가  

  마우스 커서를 링크 위에 올렸을 때 작은 텍스트로 대략적인 설명을 표시한다.  

  ```html
  <a href="https://bakcoding.github.io/" target="_blank" title="내 블로그">blog</a>
  ```
  <a href="https://bakcoding.github.io/" target="_blank" title="내 블로그">blog</a>

  