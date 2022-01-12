---
title:  "[왕초보도 할 수 있는 VR] 타워디펜스 5 - 적 생성"
excerpt: "unity3d, vr, spawner"

categories:
  - UnityExample
tags:
  - [unity3d, vr, spawner]

toc: true
toc_sticky: true
 
date: 2022-01-12 
last_modified_at: 2022-01-12
---  

***  
<a href="https://www.gseek.kr/member/rl/studyRoom/studyRoomMain.do?courseSeq=2069&courseCsSeq=1&stuSeq=&subjSeq=5&pageNum=1">VR 강의</a>

Unity version 2018.1.1f1

### 적 오브젝트

다수의 동일한 기능을 가진 적을 만들기 위해서 게임 오브젝트를 프리팹화 한다.

<br>

#### 적 프리팹

만들었던 드론을 프리팹으로 만든다. 

우선 에셋을 정리해서 관리하기 위해 Prefabs 폴더를 만든 다음 드론 오브젝트를 

폴더로 드래그앤드롭한다.  

Assets > Create > Folder 폴더명 Prefabs

<br>
<img src="/assets/images/20220112_Posting/prefabs.png" title="prefabs" width="300px">
<br>


이제 드론 오브젝트의 원본은 Prefabs 폴더에 있는 오브젝트이며 하이어라키 창에 있는 드론 오브젝트는 삭제하여도 문제가 없다.

이렇게 프리팹을 사용하여 원본을 만들어 두면 동일한 게임 오브젝트를 여러개 사용시 유리하다.

<br>

### 적 생성기

적을 생성하는 기능을 구현한다.  

<br>

#### 빈오브젝트 생성

Hierachy > Create Empty 오브젝트의 이름은 DroneSpawner로 한다.

* 빈 오브젝트의 위치

    빈 오브젝트는 씬에서 위치를 파악하기 어렵기 때문에 아이콘을 지정한다.  

    <br>
    <img src="/assets/images/20220112_Posting/object-icon.png" title="object-icon" width="300px">
    <br>


    이렇게 설정한 아이콘은 실제 게임에는 반영되지 않는다.  


<br>

#### 적 생성 스크립트

Workshop > Scripts > DroneSpawn 스크립트를 DronSpawner 오브젝트에 추가한다. 

스크립트 인스펙터 창에는 MIN_TIME으로 최소시간 MAX_TIME으로 최대시간을 지정해서 생성되는 시간 간격을 설정할 수 있다.

비어있는 Drone 필드에 Drone 프리팹을 추가해 준다. 

다양한 장소에서 적이 생성되도록 DroneSpawner 오브젝트를 복사해서 맵 여기저기에 배치한다.  

```cs
using UnityEngine;
using System.Collections;

public class DroneSpawn : MonoBehaviour {
    // 생성할 게임 오브젝트
	public GameObject drone;
    // 최소시간
	public float MIN_TIME = 1;
    // 최대시간
    public float MAX_TIME = 5;

    // 코루틴 실행
    void Start () {
		StartCoroutine("CreateDrone");
	}
	
	IEnumerator CreateDrone()
	{
        // 앱이 실행될 때동안 반복
		while(Application.isPlaying)
		{
            // 최소시간과 최대시간 사이의 무작위 시간 간격으로 적을 생성한다. 
			float createTime = Random.Range(MIN_TIME, MAX_TIME);
            // 무작위로 정해진 시간 간격만큼 대기
			yield return new WaitForSeconds(createTime);
            // 게임 오브젝트 생성함수 실행
			Instantiate(drone, transform.position, Quaternion.identity);
		}
	}
}
```