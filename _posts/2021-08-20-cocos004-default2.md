---
title:  "프로젝트 기본 세팅하기"
excerpt: "cocos, 2dx, hello"

categories:
  - Cocos
tags:
  - [cocos, 2dx, hello]

toc: true
toc_sticky: true
 
date: 2021-08-20  
last_modified_at: 2021-08-20
---  

***

### 기본 세팅하기
나만의 작업을 진행하기 위해서 아무것도 없는 상태로 만든다.
우선 HelloWorld h, cpp 파일을 지워준다. 프로젝트 안에서 지울경우 
폴더 내에 파일은 그대로 남아 있을 수 있기 때문에 폴더에서 지워 준다.

폴더를 연김에 Resources 폴더도 열어서 폰트는 쓸 수 도 있으니 나두고 이미지는 지운다.

다시 프로젝트로 들어가서 몇 가지를 수정해준다.

AppDelegate.h  
```cpp
#include "HelloWorldScene.h"    // 26 line 삭제

director->setDisplayStats(true);    // 84 line true -> false

auto scene = HelloWorld::createScene();   // 111 line 삭제
director->runWithScene(scene);    // 114 line 삭제
```

이제 실행시키면 아무것도 없는 까만 창만 뜬다.
작업할 준비는 끝났고 한 번 게임을 만들어 보도록한다.