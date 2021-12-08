---
title:  "[레트로의 유니티] 좀비서바이벌2 - 라이팅 설정"
excerpt: "unity3d, retro, example, zombie, lighting, bake"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, lighting, bake]

toc: true
toc_sticky: true
 
date: 2021-12-06 
last_modified_at: 2021-12-06
---  

***

### 새로운 씬 만들기  

프로젝트 Assets 폴더에 Scenes 이름으로 폴더를 생성한다.  

프로젝트 저장(ctrl + s), 현재 씬을 Main 이름으로 Scenes 폴더에 저장한다.  

<br> 

### 레벨 아트 추가하기  

Prefabs 폴더에서 미리 제작된 Level Art 프리팹을 씬에 추가한다.  

Prefabs > Level Art 현재 씬 Hierarchy 창에 드래그앤드롭한다.  

아트에는 Lighting이 따로 적용되어 있기 때문에 이를 적용시키기 위해 기본적으로 프로젝트에 생성되어있는 Lighting을 삭제한다.  

Hierarchy > Directional Light > delete  

<br>

#### 라이트맵  

라이팅은 연산 비용이 비싸기 때문에 유니티에서는 연산량을 줄이기 위해 미리 라이팅 정보를 포함한 데이터 에셋을 굽는(baking) 작업을 한다.  

이 작업을 통해 실시간 작업량을 줄이며 씬에 변화가 감지될 때마다 매번 새로운 라이팅 데이터 에셋을 생성하게 된다.  

<br>

#### 라이팅 설정  

Windows > Rendering > Lighting Settings  

* Auto Generate

  창의 하단에 라이팅맵을 자동 생성여부를 정하는 옵션  

  체크를 해제 해준다.  

* 환경광 설정  

  Environment Lighting의 Source를 Color로 변경  

  Ambient Color의 컬러 필드 > 컬러를 (65, 23, 12)로 변경  

<br>

**글로벌 일루미네이션(GI)**   

물체의 표면에 직접 들어오는 빛뿐만 아니라 다른 물체의 표면에서 반사되어 들어온 간접광까지 표현한다.  

* Realtime Lighting > Realtime Global Illumination

  실시간 글로벌 일루미네이션

  빛의 세기와 방향 등이 달라졌을 때 그 변화를 간접광에 실시간으로 반영한다.  

  라이트맵을 여러 방향에 대해서 생성하고 여러 가지 경우에 대한 빛의 예상 반사 방향과 광원의 예상 이동 경로 등의 정보를 미리 계산해서 저장한다.  

  미리 저장된 정보를 통해서 게임 도중에도 실시간으로 표면에 들어오는 빛의 방향에 따라 반사되는 간접광의 세기의 계산한다.  

  실시간 글로벌 일루미네이션을 사용해도 결국엔 미리 계산해야 하는 정보가 있으므로 라이팅 에셋을 베이킹하는 것이 필요하다.  

* Mixed Lighting > Baked Global Illumination  

  고정된 빛에 의한 간접광을 라이트맵으로 구워 게임 오브젝트 위에 미리 입힌다. 반영된 간접광 효과는 게임 도중에 실시간으로 변하지 않는다.  

  실시간 GI 보다 표현의 질과 런타임 성능이 더 좋지만 실시간으로 반영되지 않기 때문에 게임 도중 갑자기 주변이 밝아지거나 어두워지는 이질감이 발생할 수 있다.  

<br>

#### 라이트맵 굽기  

* Mixed Lighting > Baked Global Illumination, 체크 해제

* Lighting Settings > Indirect Resolution, 0.5로 변경  

  라이트맵의 텍스쳐 해상도 조절옵션, 2 -> 0.5 로 줄이게 되면 라이팅 효과의 정교함은 떨어지지만 현재 아트의 경우 로우 폴리이므로 육안으로는 거의 티나지 않지만 연산량은 차이가 난다.  

Generate Lighting을 클릭해 바뀐 설정값으로 라이팅을 구워준다.

베이킹이 완료되면 Main 씬을 저장한 폴더에 씬과 같은 이름으로 라이팅 정보를 저장한 폴더가 생성된다.  

