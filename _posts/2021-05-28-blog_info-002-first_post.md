---
title:  "Github 블로그 포스팅"
excerpt: "Github, Jekyll, Blog, Ruby, VScode"

categories:
  - Blog-Info
tags:
  - [Github, Blog]

toc: true
toc_sticky: true
 
date: 2021-05-28
last_modified_at: 2023-06-04
---  

***

### git page posting
github에 올린 블로그 데이터를 관리를 로컬에서 수정하고 업데이트를 시켜본다.  

<br/>  

### 1. Ruby 설치  
  
Jekyll에서 사용하는 언어인 Ruby의 설치부터 해준다.
  
[Ruby Download](https://rubyinstaller.org/downloads/)  
  
 ![ruby installer page](/assets/images/posting/20210528/ruby_installer_page.png)  

Ruby설치가 끝나면 추가로 Bundler로 Jekyll을 설치해준다.  
  
>Bundler는 프로젝트에 필요한 gem들의 올바른 버전을 추적하고 설치해서 일관된 환경을 제공하는 도구이다.  
  
명령 프롬프트 창을 열어서 명령어 입력한다.  
`gem install jekyll bundler` 동작이 끝나고  설치가 잘되었는지 `jekyll -v` 명령어를 통해 버전을 확인해 본다.  

<br/>
 
### 2. Github Clone 생성  
  
Github에 생성한 저장소를 내 컴퓨터 로컬에 받아서 관리한다.  
  
Git이 설치되어 있지 않다면 Git설치부터 해준다.  

 ![git_installer_page](/assets/images/posting/20210528/git_installer_page.png)  
  
블로그 테마를 설치했던 Github저장소를 열어서 클론으로 만들 URL을 복사해 놓는다.  

 ![github_clone_repository](/assets/images/posting/20210528/github_clone_repository.png)  
  
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

다운받은 데이터를 수정하고 commit과 push를 하면 github의 저장소에 기록이 되기 때문에 관리에 용이하다. 하지만 빈번하게 글을 올리고 수정하는 블로그 같은 경우에는 불편하다.

<br/> 

### 3. VScode를 이용하여 git commit/push    
VSCode를 사용하면 Git Bash보다 간편하게 블로그 관리를 할 수 있다.
  
[Visual Studio Code](https://code.visualstudio.com/)  
  
VScode를 열고 생성한 클론 폴더를 연다.  
  
 ![vs_open_blog_folder](/assets/images/posting/20210528/vs_open_blog_folder.png)  
  
Jekyll 테마를 사용하게 되면 블로그에 포스팅되는 글들은 _post 폴더 내부에 md 확장자의 파일을 생성하고 
해당 파일에 글을 작성해야하는 규칙이 있다. 
  
 ![create_blog_file](/assets/images/posting/20210528/create_blog_file.png)  
  
포스팅할 파일의 이름은 `yyyy-mm-dd-title.md` 형식으로 만들어야한다.  
  
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

실질적으로 블로그에 나타나는 정보들은 Github 저장소에 있는 파일들의 내용이기 때문에 이 정보들을 수정해야 페이지의 정보들도 수정된다. 프로젝트를 클론할 필요없이 원본 파일들을 직접 수정해도 가능은 하지만 이렇게 할 경우 작업을 되돌리는 등의 버전 관리가 어려워지기 때문에 수정작업용 프로젝트를 클로닝할 필요가 있다.

클론한 이후 파일을 수정하거나 추가한 다음에 원본에 반영하기 위해서는 commit & push를 해준다.

 ![vscode_git_commit](/assets/images/posting/20210528/vscode_git_commit.png)
 ![vscode_git_push](/assets/images/posting/20210528/vscode_git_push.png)

commit을 실행하면 경로를 설정하는 창이 뜨고 한 번 경로를 잡아주면 이후에는 간단하게 클릭으로 commit과 push가 가능하다.  

포스팅을 할때는 마크다운 언어를 통해서 작성해야하기 때문에 기본적인 언어에 대한 학습이 필요하다.
다행히도 마크다운은 아주 간단한 언어이기 때문에 크게 무리없이 진행할 수 있다. 일부분은 html을 사용할 수 있기도 하지만 너무 활용을 많이 하려다보면 짜여진 틀과 겹치거나 충돌될 수 있어 의도하지 않게 동작할 수 있어 마크다운을 사용하는게 추천된다.