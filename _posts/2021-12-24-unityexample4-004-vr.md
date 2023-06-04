---
title:  "[왕초보도 할 수 있는 VR] 타워디펜스 2 - 카메라 회전"
excerpt: "unity3d, vr"

categories:
  - UnityExample
tags:
  - [unity3d, vr]

toc: true
toc_sticky: true
 
date: 2021-12-24 
last_modified_at: 2023-06-05
---  

***  
<a href="https://www.gseek.kr/member/rl/studyRoom/studyRoomMain.do?courseSeq=2069&courseCsSeq=1&subjSeq=4">VR 강의</a>

Unity version 2018.1.1f1

### 카메라 조작

Workshop > Scripts > CamRotate 스크립트를 메인 카메라 오브젝트에 추가한다.

<br>

#### 회전축

물체의 회전은 각 축을 기준으로 회전하게 되며 이 때 x, y, z 세 축을 기준으로 회전하는것을 오일러 각이라고 한다.  

<img src="/assets/images/posting/20211224/eulerAngle.png" title="eulerAngle" width="400px">

* X 축 기준 회전 : Pitch

* Y 축 기준 회전 : Yaw

* Z 축 기준 회전 : Roll

대부분 게임의 경우 1인칭이라도 화면각의 회전은 마우스로 이루어지기 때문에 상하좌우, 즉 yaw, pitch만 존재한다.  

하지만 VR의 경우 사용자의 머리 움직임을 그대로 반영해야하기 때문에 roll 회전까지 구현이 필요하다.

#### CamRotate.cs
```cs
using UnityEngine;
using System.Collections;

public class CamRotate : MonoBehaviour {
	float RX;
	float RY;
	public float sensitivity = 500;

    // 초기화 함수
	void Start () {
	
	}
	
    // 업데이트 함수 per frame
	void Update () {
		#if UNITY_EDITOR
        // 유니티 InputManager를 사용해 마우스의 움직임을 입력받는다.
        // 마우스 y축 움직임 = 카메라의 x 축 회전 
		float mx = Input.GetAxis("Mouse Y");
        // 마우스 x축 움직임 = 카메라의 y 축 회전
		float my = Input.GetAxis("Mouse X");

        // 입력받은 값을 카메라의 회전에 사용한다.
        // 민감도 변수 sensitivity로 화면 회전 속도를 조절한다. 
		RX += mx * sensitivity * Time.deltaTime;
		RY += my * sensitivity * Time.deltaTime;

        // 
		RX = Mathf.Clamp(RX, -60, 60);

		transform.eulerAngles = new Vector3(-RX, RY, 0);
		#endif
	}
}
```