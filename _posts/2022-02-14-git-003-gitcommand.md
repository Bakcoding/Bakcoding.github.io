---
title:  "Git 명령어"
excerpt: "git, gitbash"

categories:
  - Note
tags:
  - [git, gitbash]

toc: true
toc_sticky: true
 
date: 2022-02-14 
last_modified_at: 2022-02-14
---  

***

### 상태

git으로 관리되는 파일은 크게 3가지 상태로 구분된다.

#### Modified

로컬 영역에서만 수정된 상태이다.

#### Staged

현재 수정된 파일을 스냅샷을 만들고 .git 디렉토리(index)에 담아둔다.

이를 Staging area에 등록되었다고 한다.

#### Committed

staging area에 등록된 변경사항들이 로컬 영역에 확정된다.  

원격 저장소에 반영하기 직전의 상태이다.

<br>

### 명령어

github에서 파일을 관리할 때 필요한 기본적인 명령어들이 있다.  

<br>

* init

  ```cmd
  git init
  ```

  git으로 관리하고자 하는 디렉토리에서 실행하면 해당 디렉토리에 .git폴더가 생성되어 git으로 관리할 수 있는 상태가 된다. 

* git config

  ```cmd
  git config --list
  ```

  현재 디렉토리의 git 구성을 볼 수 있다.  

  <br>

  ```cmd
  git config user.name "Name"
  git config user.eamli "address@email.com"

  git config --global user.name "Name"
  git config --global user.eamli "address@email.com"
  ```

  git 저장소를 사용할 사용자의 이름과 이메일 주소를 설정한다. 

  컴퓨터 전역에서 사용자를 정한다면 --global을 붙이면된다.

* git clone

  ```cmd
  git clone 저장소 주소
  ```

  저장소에서 파일을 복제하여 로컬에 저장한다. 

* git status

  ```cmd
  git status
  ```

  현재 로컬 디렉토리의 파일의 변경사항을 확인한다.

  commit 변경사항과 Tracked/Untracked 상태가 있다.  

  Tracked는 git이 추적 및 관리하는 파일이며 Untracked의 파일은 수정이 되어도 git으로 관리되지 않는 파일이다.

  따라서 추적되지 않는 파일은 복구가 불가능하지만 불필요한 파일들이 commit되는걸 방지할 수 있다.

* git add

  ```cmd
  git add 파일
  ```

  파일을 staging area에 올린다.  

* git commit

  ```cmd
  git commit 
  git commit -m "메시지"
  ```

  staging area에 등록된 파일을 commit한다.  

  -m 명령어로 메시지를 남길 수 있다.

* git push

  ```cmd
  git push 저장소명 브랜치명 
  ```

  원격저장소에 변경된 사항을 반영한다.

<br>

일반적으로 저장소의 파일을 clone해서 사용하기 때문에 저장소명은 기본적으로 origin으로 되어있으며 

```git
git remote
git remote -v
```

명령어를 통해 정확한 저장소명을 알 수 있다. -v 명령어로 저장소 url까지 볼 수 있다.  

<br>

* git pull

  ```cmd
  git pull
  ```

  원격 저장소의 내용을 가져와 로컬 저장소의 파일과 병합 작업을 실행한다.

* git fetch

  ```cmd
  git fetch
  ```

  병합하지 않고 원격 저장소의 최신 이력을 확인할 수 있다. 

  