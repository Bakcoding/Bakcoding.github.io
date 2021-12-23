---
title:  "[왕초보도 할 수 있는 VR] 타워디펜스 1 - 기본세팅"
excerpt: "unity3d, vr"

categories:
  - UnityExample
tags:
  - [unity3d, vr]

toc: true
toc_sticky: true
 
date: 2021-12-23 
last_modified_at: 2021-12-23
---  

***  
<a href="https://www.gseek.kr/member/rl/studyRoom/studyRoomMain.do?courseSeq=2069&courseCsSeq=1&stuSeq=&subjSeq=2">VR 강의</a>

Unity version 2018.1.1f1

### 타워디펜스  

몰려오는 적을 공격해 타워를 지킨다.

VR게임의 기초로 만들어 확장성이 좋기 때문에 응용해서 다양한 게임을 만들 수 있는 기반이 될 수 있다.

<br>

### 프로젝트 준비 

#### 씬 생성

프로젝트를 열고 새로운 씬을 생성해준다.  

씬 생성 후 저장할 때 이름은 TowerDefenceVR로 한다.  

<br>

#### 에셋

게임을 만드는 에셋을 준비한다.  

강의 페이지에 준비된 에셋 패키지 다운로드

다운로드한 파일 유니티 프로젝트로 드래그앤드롭 > import

<br>

게임의 기본 3요소는 플레이어, 적 그리고 맵이다. 가장 기본적인것으로 이것만 있어도 게임을 만들 수 있게 된다.  

<br>

### 맵 만들기

* 바닥 만들기

    프로젝트 창 > Workshop 폴더 > Terrain > Environment 프리팹을 씬에 추가한다.  

* 오브젝트 배치

    Workshop > Trees 프리팹을 활용해 나무를 배치한다.  

    Workshop > Buildings 건물을 배치한다.

배치한 오브젝트 들은 Environment 오브젝트의 자식으로 만들어준다. 

그리고 Environment 오브젝트는 static을 체크한 다음 Yes, Change Children 을 선택해 그 자식들도 동일하게 적용시킨다. 

<br>

* 이펙트 추가

    Effect 폴더의 Fire 오브젝트를 Obelisk 오브젝트 위에 위치하도록 추가해준다.  

<br>

### 플레이어 추가

* 타워 추가

    타워디펜스 게임에서 플레이어는 타워가 된다. 
    
    etc > Models > Tower 오브젝트 씬에 추가

    게임이 시작되면 적들은 타워로 몰려올것이기 때문에 맵의 가장자리에 배치해주도록 한다.  


    VR게임은 대부분 1인칭이기 때문에 카메라와 플레이어를 일치시켜서 만들게 된다.  

* 카메라 

    카메라를 Tower 오브젝트의 자식으로 만든다.

    그리고 카메라의 위치를 0, 0, 0 상태로 만들고 y 값을 올리면서 타워의 꼭대기에 위치하도록 적당히 이동시킨다.