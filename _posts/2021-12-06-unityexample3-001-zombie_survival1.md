---
title:  "[레트로의 유니티] 좀비서바이벌1 - 프로젝트 준비"
excerpt: "unity3d, retro, example, zombie"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie]

toc: true
toc_sticky: true
 
date: 2021-12-06 
last_modified_at: 2021-12-06
---  

***

### 좀비 서바이벌  

#### 개요
웨이브형 좀비 탑 다운 슈터 게임  

플레이어는 기관총으로 끊임없이 몰려오는 좀비들을 막는다.  

좀비를 죽일 때 마다 점수를 모을 수 있으며 최대한 오래 살아남는게 목표이다.  

<br>

#### 내용  

**좀비**  

* 좀비는 일정 주기로 생성된다. 플레이 시간이 길어질수록 한 번에 생성되는 좀비 수가 늘어난다.  

* 좀비는 플레이어 위치를 주기적으로 파악하고 언제나 최적의 경로를 찾아 플레이어를 추적한다.  

* 좀비의 이동 속도와 공격력, 체력은 랜덤으로 지정된다.  

* 강하고 빠른 좀비일수록 피부색이 붉어진다.  

**플레이어**  

* 플레이어의 체력은 캐릭터를 따라다니는 원형의 게이지바로 확인할 수 있다.  

* 플레이어는 탄알과 체력을 보충하기 위해 아이템을 찾아다녀야 한다.  

* 아이템은 주기적으로 플레이어 근처의 랜덤한 위치에 생성된다. 생성된 아이템은 일정 시간 뒤에 사라진다.  

**배경**  

* 후처리 효과를 사용해 게임 화면을 보정하여 게임의 아트 분위기를 개선한다.    

<br>

#### 조작법  

|조작|키|
|------|---|
|캐릭터 회전|←, → 또는 A, D|
|캐릭터 전진/후진|↑, ↓ 또는 W, S|
|발사|마우스 좌 클릭|
|재장전|R|  

<br>

### 프로젝트 세팅

[프로젝트 예제) 14 폴더](https://github.com/IJEMIN/Unity-Programming-Essence.git_)  

**Assets 폴더**  

* Animation : 캐릭터 애니메이션  

* Audios : 효과음과 음악 오디오 클립

* Fonts : 폰트  

* Gizmos : 시네머신이 사용하는 기즈모 아이콘(시네머신 패키지 추가 시 자동 생성)

* Materials : 3D 모델에 사용할 머티리얼 

* Models : 3D 모델

* Post-Process Profile : 후처리에 사용할 프로파일(프리셋)

* Prefabs : 프리팹

* Scripts : 스크립트  

* Sprites : 2D 텍스쳐(스프라이트)

* Texture : 3D 모델의 텍스처  

<br>

**Package 폴더**  

패키지 매니저를 사용해 임포트한 패키지  

* Cinemachine : 스마트 추적 카메라와 복잡한 카메라 연출을 쉽게 구현  

* Package Manager UI : 패키지 매니저의 UI 창  

* Post-processing Stack : 후처리 효과를 구현




