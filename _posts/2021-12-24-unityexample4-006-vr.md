---
title:  "[왕초보도 할 수 있는 VR] 타워디펜스 4 - 적"
excerpt: "unity3d, vr"

categories:
  - UnityExample
tags:
  - [unity3d, vr]

toc: true
toc_sticky: true
 
date: 2021-12-24 
last_modified_at: 2021-12-24
---  

***  
<a href="https://www.gseek.kr/member/rl/studyRoom/studyRoomMain.do?courseSeq=2069&courseCsSeq=1&stuSeq=&subjSeq=5&pageNum=1">VR 강의</a>

Unity version 2018.1.1f1

### 적 추가

Workshop > etc > Models > Drone 프리팹을 씬에 추가한다. 네비메시를 사용해 플레이어를 추적시킬것이므로 테스트를 위해서 플레이어와 멀리 떨어뜨려 배치한다.

* 네비게이션

    두 지점 사이를 움직이기 위한 최적의 경로를 찾는다.

* 네비게이션 메시

    길 찾기를 쉽게 할 수 있도록 지형 데이터를 재구성하여 이동 공간을 계산한다.

<br>

#### 네비메시

Enviroment 게임오브젝트는 지금 네비메시를 굽기위해서 static으로 만들었다.  

* Static

    정적, 움직이지 않는 상태, 고정

맵을 정적으로 만들어야 네비메시를 구워서 맵의 정보를 계산할 때 변화가 발생하지 않아 적이 올바르게 길을 찾을 수 있게된다.

Window > AI > Navigation 으로 창을 연다.  

Bake 탭을 누르고 Bake를 눌러 맵을 구워준다.

<img src="/assets/images/20211224_Posting/bakemap.png" title="eulerAngle" width="400px">

구워진 맵을 보면 푸른색 장판이 깔려있다 자세히보면 지형지물 아래는 채워지지 않았는데 이 장판에 AI가 움직일 수 있는 경로를 계산할 결과이다.

<br>

#### 드론AI

드론 오브젝트가 네비메시를 사용할 수 있게 한다.

* Add Component > Nav Mesh Agent 컴포넌트를 추가

플레이어를 추적하도록 만드는 스크립트를 추가한다.  

* Workshop > Scripts > Drone 스크립트 드론 오브젝트에 추가

이렇게 생성된 드론은 장애물을 피해서 플레이어를 찾아 최단 거리로 오게된다.

그런데 지금 상태에서 드론이 너무 가까이 다가와서 타워에 겹쳐지게 되는데 이 문제는 Drone 오브젝트의 Nav Mesh Agent 컴포넌트의 설정값으로 해결할 수 있다.

* Nav Mash Agent

    Stopping Distance : 원하는 거리 

    지정한 거리에서 더 이상 다가오지않고 멈추게 된다.

<br>

#### Dron.cs

```cs
using UnityEngine;
using System.Collections;

// NavMeshAgent 컴포넌트가 반드시 포함되도록 만든다.
[RequireComponent(typeof(UnityEngine.AI.NavMeshAgent))]
public class Drone : MonoBehaviour {
    // agent 저장할 변수
	UnityEngine.AI.NavMeshAgent agent;
    // 타워의 위치
	Transform tower;

    void Start () {
        // Nav Mesh Agent 컴포넌트 가져온다.
		agent = GetComponent<UnityEngine.AI.NavMeshAgent>();
        // 씬에서 Tower 오브젝트를 찾아서 위치를 가져온다.
        tower = GameObject.Find("Tower").transform;
        // 목적지를 타워의 위치로 지정한다.
		agent.destination = tower.position;
	}
```

