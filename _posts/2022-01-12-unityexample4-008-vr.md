---
title:  "[왕초보도 할 수 있는 VR] 타워디펜스 6 - VR UI"
excerpt: "unity3d, vr, ui"

categories:
  - UnityExample
tags:
  - [unity3d, vr, ui]

toc: true
toc_sticky: true
 
date: 2022-01-12 
last_modified_at: 2022-01-12
---  

***  
<a href="https://www.gseek.kr/member/rl/studyRoom/studyRoomMain.do?courseSeq=2069&courseCsSeq=1&stuSeq=&subjSeq=5&pageNum=1">VR 강의</a>

Unity version 2018.1.1f1

### VR UI

VR에서는 현실감이 중요하다. 이 현실감이 깨지게 되면 게임에 대한 몰입도 뿐만 아니라 괴리감에서 오는 멀미를 유발하기도 한다.  

따라서 일반게임 처럼 2D UI를 만들어 고정시키게 되면 이러한 문제가 생기기 때문에 UI또한 3D로 만들어야 한다.  

<br>

### 적 UI

드론 프리팹을 씬에 추가하여 수정작업을 한다. 

프리팹을 만들고 나면 수정이 다소 불편하기 때문에 씬에 복사를 하여 오브젝트를 만들고 수정한 다음 override를 통해 프리팹을 갱신시키는게 편하다.  

#### UI 생성

Create > UI > Slider 오브젝트 생성

**슬라이더 설정**

*   Slider 오브젝트

    위치 : 중앙에 배치한다. Pos X = 0, Pos Y = 0

    Max Value : 100

*   Fill Arer > Fill

    Color : red
    

유니티에서 UI는 2D로 표현되기 때문에 3D인 다른 게임 오브젝트와 별도의 영역에 생성된다. 

이 2D UI를 3D로 전환시켜주는 작업이 필요하다.


*   Canvas 오브젝트

    Render Mode : World Space

슬라이더의 위치와 스케일을 변경한다.

Pos X : 0, Pos Y : 0

Scale : 0.01, 0.01, 0.01

### 적 UI 추가

설정한 Slider가 있는 부모 오브젝트인 Canvas 오브젝트를 Drone 오브젝트에 추가한다. 

드론의 자식으로 되어있는 Canvas의 위치를 0, 0.7, 0으로 변경한다.  

UI가 추가된 Drone 프리팹을 누르고 인스펙터 창에 Prefab 에서 Override > Apply All을 실행시킨다.  

<br>

### 타워 UI

타워의 체력바도 동일하게 만들어준다.  

Create > UI > Slider 이름 TowerHP로 변경

* Slider

    Fill Area > Fill : Green

    Slider : Max Value 100

* Canvas 

    Render Mode : World Space


높이를 적절하게 배치하여 준다.

