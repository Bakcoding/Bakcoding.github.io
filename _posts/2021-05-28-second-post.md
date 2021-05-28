---
title:  "포스팅하기"
excerpt: "Github, Jekyll, Blog, Ruby, VScode"

categories:
  - Blog
tags:
  - [Github, Blog]

toc: true
toc_sticky: true
 
date: 2021-05-28
last_modified_at: 2021-05-28
---  
**Github 저장소에서 직접 파일을 생성하고 업로드해도 블로그를 수정하고 포스팅을 할 수 있지만**  
  
**조금 더 Git을 활용하기 위해서 로컬에서 클론을 생성해서 수정하고 푸쉬하는 식으로 포스팅 해본다.**  
<br/>
<br/>  

###1. Ruby 설치  
  
Jekyll에서 사용하는 언어인 Ruby의 설치부터 해준다.
  
[https://rubyinstaller.org/downloads](https://rubyinstaller.org/downloads/)  
  
 ![1](/assets/images/20210528_Posting/1.png)  

Ruby설치가 끝나면 추가로 Bundler로 Jekyll을 설치해준다.  
  
>Bundler는 프로젝트에 필요한 gem들의 올바른 버전을 추적하고 설치해서 일관된 환경을 제공하는 도구이다.  
  
명령 프롬프트 창을 열어서 명령어 입력한다.  
`gem install jekyll bundler` 동작이 끝나고  설치가 잘되었는지 `jekyll -v` 명령어를 통해 버전을 확인해 본다.  

<br/><br/><br/>

***  

###2. Github Clone 생성  
  
Github에 생성한 저장소를 내 컴퓨터 로컬에 받아서 관리한다.  
  
Git이 설치되어 있지 않다면 Git설치부터 해준다.  
 ![1](/assets/images/20210528_Posting/2.png)  
  
블로그 테마를 설치했던 Github저장소를 열어서 클론으로 만들 URL을 복사해 놓는다.  

 ![1](/assets/images/20210528_Posting/3.png)  
  
클론을 저장할 위치에 폴더를 미리 만들어 놓거나 명령어를 통해 만들어준다.
  
GitBash를 켜서 명령어들을 입력해 준다.  
  
```
cd ..           #상위 폴더로 이동
cd 폴더이름     #해당 폴더로 이동
mkdir 폴더이름  #폴더 생성

git add .               #변경이 일어난 파일을 추적한다.
git clon 복사한 URL     #로컬에서의 git init에 해당하는 명령어, 원격에서 저장소를 최초로 가져올 때 git pull 대신 git clone을 쓴다. 
git push origin master  #변경 사항들을 원격 Github 저장소에 반영한다.
```  
  
해당 폴더를 찾아가보면 github 저장소의 이름으로 폴더가 생성되있는걸 볼 수 있다.  

<br/><br/><br/>

***  

###3. VScode를 이용하여 git commit/push  
  
[Visual Studio Code](https://code.visualstudio.com/)  
  
VScode를 열고 클론을 저장한 폴더를 열어준다.  
  
 ![1](/assets/images/20210528_Posting/4.png)  
  
클론 폴더 안에 _post 폴더가 없다면 폴더를 만들어 준다.  
포스팅 글은 _post 안에 Markdown으로 작성된 md 파일을 불러오기 때문에 꼭 해주어야한다.  
  
 ![1](/assets/images/20210528_Posting/5.png)  
  
폴더안에 파일을 생성해주고 이름은 `yyyy-mm-dd-title.md` 형식으로 만들어 준다.  
  
```
--- #타이틀 영역 지정
title:  "제목"
excerpt: "요점"

categories:
  - Blog    #카테고리 설정
tags:
  - [Github, Blog]  #태그 설정
 
date: 2021-05-28    #작성날짜
last_modified_at: 2021-05-28    #최종 수정 날짜
---  #여기까지 내용이 타이틀 내용
```  
  
포스팅에 익숙해지려면 Markdown를 한번 공부할 필요가 있는거 같다.