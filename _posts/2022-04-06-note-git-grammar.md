---
title:  "Git 로컬에 덮어쓰기"
excerpt: "git, fetch, reset"

categories:
  - Note
tags:
  - [git, fetch, reset]

toc: true
toc_sticky: true
 
date: 2022-04-06
last_modified_at: 2022-04-06
---  

***

<br>

### 덮어쓰기

로컬 저장소의 저장된 자료를 원격 저장소에 자료들로 덮어쓰는 방법

1. fetch

  우선 로컬 저장소를 원격 저장소의 최신 자료들로 갱신시킨다.

  ```git
  git fetch --all
  ```

2. reset

  갱신된 자료들을 로컬에 덮어쓴다.

  ```git
  git reset --hard origin/main
  ```

  