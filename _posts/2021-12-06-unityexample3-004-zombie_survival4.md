---
title:  "[레트로의 유니티] 좀비서바이벌4 - 카메라"
excerpt: "unity3d, retro, example, zombie, cinemachine"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, cinemachine]

toc: true
toc_sticky: true
 
date: 2021-12-06 
last_modified_at: 2023-06-05
---  

***

### Cinemachine

**시네머신**  

카메라의 움직임을 손쉽게 제어하는 유니티 공식 패키지이다.  

**작동원리**  

게임 월드를 촬영하는 하나만 존재하는 브레인 카메라와 분신 역할을 하는 여러 개의 가상 카메라를 사용한다.  

가상 카메라는 실제 동작하지는 않고 카메라를 위한 설정값을 제공하는 기능을 한다. 이 설정값을 브레인 카메라가 사용하여 다양한 카메라 연출을 만들어 낼 수 있다.  

<br>

### 추적 카메라 만들기  

프로젝트의 Main Camera를 브레인 카메라로 사용하고 가상 카메라를 추가해 사용한다.  

Hierarchy > Main Camera > Cinemachine Brain 컴포넌트 추가  

새 가상 카메라 생성, Cinemachine > Create Virtual Camera  

새로 생성한 가상 카메라 이름은 Follow Cam으로 변경한다.  

실제로 씬을 촬영하는 역할은 브레인 카메라가 하지만 이 촬영하는 방법을 결정하는 것은 가상 카메라인 Follow Cam 게임 오브젝트이다.  

이 Follow Cam 플레이어 캐릭터를 추적하도록 설정한다.  

<br>
 
### 추적 대상 설정하기

Hierarchy > Follow Cam > Cinemachine Virtual Camera 컴포넌트 설정  

Follow 필드와 Look At 필드에 Player Character 게임 오브젝트를 드래그앤드롭

이제 가상 카메라는 Follow 필드에 할당된 게임 오브젝트를 따라다니기 위해 자신의 위치값을 변경한다.  

또 Look At 필드에 할당된 게임 오브젝트를 주시하기 위해 자신의 회전값을 변경한다.  


**guide line**

오브젝트를 할당하고 Game Window Guide 옵션이 체크가 된 상태라면 게임화면에 가이드 라인이 그려지는걸 볼 수 있다.

![guide_line.png](/assets/images/posting/20211206/guide_line.png)  


시네머신 카메라는 대상을 주시하는 동안 카메라 연출이 자연스럽게 느껴지도록 지연시간을 두고 카메라를 부드럽게 회전한다.  

각 단계는 주시하는 물체가 게임 화면 밖으로 벗어나지 않게 추적의 세기를 단계별로 설정한다.  

주시하는 대상이 데드존에 있다면 카메라는 회전하지 않는다. 소프트 존에 위치한다면 대상이 화면의 조준점에 오도록 카메라가 부드럽게 회전하며 물체가 너무 빠르게 움직여 소프트존을 벗어난 하드 리밋에 도달하게 되면 카메라를 격하게 회전시켜 주시하는 물체가 화면밖을 벗어나지 않도록 유지한다.  

각 단계별 영역의 크기를 조절해 카메라의 자연스러운 움직임을 연출할 수 있다.  

<br>

#### Body와 Aim 설정  

이 게임에서 플레이어의 이동속도는 빠르기 때문에 데드존과 소프트존을 최대한 작게 만들어 캐릭터를 빠르게 추적하도록 한다.  

**Body**

* Lens > Field Of View : 20  

  카메라가 한 번에 볼 수 있는 각도를 설정한다.  

* Body > Binding Mode > World Space  

  추적할 대상을 카메라의 몸체로 보고 머리에 해당하는 카메라가 어떻게 매달려서 얼마나 떨어져 있을지 결정한다.  

  World Space는 카메라와 몸체 사이의 간격을 전역 공간을 기준으로 계산하도록 변경한다.  

* Follow Offset : -8, 16, -8

  카메라와 대상 사이의 간격을 설정한다.  

* X Damping, Y Damping, Z Damping : 0.1  

  Damping은 값이 급격하게 변할 때 이전 값과 이후 값을 부드럽게 이어주는 비율이다.  

  Damping 값이 커질수록 카메라 위치의 급격한 변화는 줄어들지만 위치가 신속하게 변경되지 않고 지연시간이 늘어난다.  

**Aim**

* Tracked Object Offset : 0, 0.5, 0  

  원래 추적 대상에서 얼마나 더 떨어진 곳을 조준할지 결정한다.  

* Horizontal Damping, Vertical Damping : 0  

  회전 속도애 대한 제동값을 가로와 세로 방향 모두 0으로 변경한다.  

* Soft Zone Width, Height : 0  

  소프트존을 없앤다.  


이 설정으로 카메라는 플레이어를 즉각적으로 쫓아다니게 된다.  

<br>

![player_move.png](/assets/images/posting/20211206/player_move.gif);