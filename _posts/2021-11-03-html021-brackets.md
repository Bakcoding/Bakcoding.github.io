---
title:  "brackets 에디터"
excerpt: "html, bracket, opensource, editor"

categories:
  - HTML
tags:
  - [html, bracket, opensource, editor]

toc: true
toc_sticky: true
 
date: 2021-11-03 
last_modified_at: 2021-11-07
---  

***

### brackets  

<a href="http://brackets.io/">brackets</a>  

오픈소스 에디터들 중에서 html 작업에 최적화되어 있다.  

**추천 플러그인**

* emmet

  코드의 작성과 편집에 편리한 기능들을 제공한다. 명령어를 사용해서 코드의 틀을 편리하게 만들 수 있다.  

* extract for bracket  

  psd파일을 추출해 레이어로 분류해주며 효율적으로 이미지를 사용한 웹 페이지를 만드는 작업을 할 수 있다.  


<br>

### 확장 기능 에러 해결  

<strong>확장 기능 레지스트리에 엑세스 할 수 없습니다. 나중에 다시 시도하십시오.

Unable to access the extensions registry. Please try again later.</strong>

확장 기능을 열면 이런 문구가 뜨면서 어떠한 기능을 검색도 사용도 할 수 없는 상태가 된다.  

<br>

**레지스트리 접근 경로를 수정**    

우선 메모장을 관리자 권한으로 열고 난 뒤, 

파일 > 열기 

brackets가 설치된 폴더/Brackets/www/config.json 파일을 열어준다.  

파일에서  

```json
// 찾기
"extension_registry": "https://s3.amazonaws.com/extend.brackets/registry.json",
// 바꾸기  
"extension_registry": "http://registry.brackets.s3.amazonaws.com/registry.json",

// 찾기  
"extension_url": "https://s3.amazonaws.com/extend.brackets/{0}/{0}-{1}.zip",
// 바꾸기
"extension_url": "http://registry.brackets.s3.amazonaws.com/{0}-{1}.zip",
```

각 경로를 수정해주고 저장한다.  

brackets의 확장 기능을 실행해보면 정상적으로 동작한다.  

참고 페이지 

<a href="https://stackoverflow.com/questions/69557907/brackets-unable-to-access-the-extension-registry">stackoverflow</a>  