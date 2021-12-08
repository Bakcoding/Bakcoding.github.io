---
title:  "[레트로의 유니티] 좀비서바이벌13 - UI"
excerpt: "unity3d, retro, example, zombie, ui"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, ui]

toc: true
toc_sticky: true
 
date: 2021-12-08 
last_modified_at: 2021-12-08
---  

***  

### HUD Canvas

게임의 전반적인 상태를 표시하는 UI를 가진 캔버스이다.  

게임 오브젝트와 HUD Canvas의 여러 UI 요소에 즉시 접근하여 표시 상태를 변경할 수 있는 UIManager 스크립트를 추가한다.  

#### 추가 

Prefabs > HUD Canvas 프리팹을 Hierarchy 창에 드래그앤드롭  

HUD Canvas의 모든 자식요소를 펼친다. (alt + click 펼치기)

* HUD Canvas 

    * Canvas Scaler 

        Render Mode : Scale with Screen Size

        Screen Size : 1280 x 720  

<br>

#### 재시작 버튼

Restart Button 오브젝트 선택  

* Button 컴포넌트의 On Click() 추가 ( + 클릭)

* 생성된 슬롯에 HUD Canvas 오브젝트 드래그앤드롭

* 이벤트 리스너 등록

    No Function > UIManager > GameRestart()

<br>

#### Gameover UI

Gameover UI 오브젝트는 게임오버시 활성화 되기 때문에 기본 비활성화 상태로 한다.