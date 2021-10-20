---
title:  "[레트로의 유니티] 닷지1"
excerpt: "unity3d, retro, example, dodge"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, dodge]

toc: true
toc_sticky: true
 
date: 2021-10-20 
last_modified_at: 2021-10-20
---  

***

### 1. 레벨 만들기
먼저 레벨의 바닥과 벽을 만든다.  

* 바닥 만들기  
  
  Create > 3D Object > Plane  

  생성된 오브젝트의 위치는 (0, 0, 0), 스케일은 (2, 1, 2)

  ![1](/assets/images/20211020_Posting/1.png)


* 머티리얼 만들기  

  Create > Material  

  생성된 머티리얼 이름은 PlaneColor로 변경  

  머티이얼의 albedo 값은 (0, 0 ,0)으로 변경, 플랜 오브젝트에 드래그앤드롭해서 머티리얼을 적용해준다.  

  ![2](/assets/images/20211020_Posting/2.png)

* 벽 만들기  

  Create > 3D Object > Cube  

  큐브의 이름은 Wall로 해준다. 위치는 (0, 0.5, 10), 스케일은 (20, 1, 1)로 변경한다.  

  생성한 Wall을 복사해서 4면을 막아준다.  

  Wall (1) 위치 (0, 0.5, -10)  
  Wall (2) 위치 (10, 0.5, 0), 스케일 (1, 1, 20)
  wall (3) 위치 (-10, 0.5, 0), 스케일 (1, 1, 20)

  ![3](/assets/images/20211020_Posting/3.png)  

* Level 게임 오브젝트 만들기  

  빈 게임 오브젝트를 생성해서 현재 생성한 맵을 하나의 오브젝트로 묶어준다.  

  Create > Create Empty  

  이름은 Level로 해주고, Treansform 컴포넌트를 리셋해준다.  

  바닥과 벽을 Level 오브젝트의 자식으로 만들어준다.  

  ![4](/assets/images/20211020_Posting/4.png)   

  하이어라키 창을 정리하기 위해 Level은 접어둔다.  


<br/>

### 2. 카메라 설정하기  
게임 창에서 레벨 전체가 한눈에 보이도록 배경색을 변경하고 카메라를 배치한다.  

* 카메라 위치 변경  

  Main Camera 오브젝트의 위치를 (0, 15, -10), 회전을 (60, 0, 0)으로 변경  

* 배경색 변경  

  Main Camera 오브젝트의 Camera 컴포넌트에서 Clear Flags의 값을 Solid Color로 변경하고, Background의 컬러를 (36, 36, 36)으로 변경한다.  

  ![5](/assets/images/20211020_Posting/5.png) 


<br/>

### 3. 플레이어 제작

조작이 가능한 플레이어 오브젝트를 만든다.  

1\. 플레이어는 캡슐 모양에 파란색으로 한다.  

2\. 상하좌우 또는 WASD 키로 움직인다.  

3\. 플레이어는 탄알에 맞으면 죽는다.  

* 플레이어 게임 오브젝트 만들기  

  Create > 3D Object > Capsule  

  오브젝트 이름은 Player, 위치는 (0, 1, 0)로 변경한다.  

* Player 머티리얼 만들기  

  Create > Material  

  생성된 머티리얼 이름은 PlayerColor, albedo 컬러는 (0, 100, 164)로 변경해준 뒤 드래그앤드롭으로 적용시킨다.  

  ![6](/assets/images/20211020_Posting/6.png)

* 태그 할당  

  충돌 처리를 하기 위해서 태그를 할당한다.  

  Player 오브젝트의 인스펙터 창 Tag를 눌러 Player 태그 지정해준다.  

* 컴포넌트 추가  
  
  물리를 적용시키기 위해서 리지드바디 컴포넌트를 추가한다.

  Add Component > Physics > Rigidbody  

  리지드바디 컴포넌트에서 Constraints 필드를 펼치고 옵션을 바꾸어준다.  

  ![7](/assets/images/20211020_Posting/7.png)

  플레이어의 Y축의 이동과 X, Z축의 회전을 제한한다.  


* Player 스크립트 생성  

  실질적으로 Player 오브젝트의 조작하는 역할을 한다.  

  Create > C# Script  

  PlayerController 이름의 스크립트를 생성하고 오브젝트에 드래그앤드롭한다.  

  ```c#
  // PlayerController.cs
  using System.Collections;
  using System.Collections.Generic;
  using UnityEngine;

  public class PlayerController : MonoBehaviour
  {
      // 리지드바디에 접근해서 이동시킨다.  
      public Rigidbody playerRigidbody;
      // 이동 속력
      public float speed = 8f;

      private void Update()
      {
          // 해당 키입력을 받으면 Player 오브젝트를 특정 방향으로 힘을 준다.  
          if (Input.GetKey(KeyCode.UpArrow) == true)
          {
              playerRigidbody.AddForce(0f, 0f, speed);
          }

          if (Input.GetKey(KeyCode.DownArrow) == true)
          {
              playerRigidbody.AddForce(0f, 0f, -speed);
          }

          if (Input.GetKey(KeyCode.RightArrow) == true)
          {
              playerRigidbody.AddForce(speed, 0f, 0f);
          }

          if (Input.GetKey(KeyCode.LeftArrow) == true)
          {
              playerRigidbody.AddForce(-speed, 0f, 0f);
          }
      }

      // 게임오버, 오브젝트를 비활성화 시킨다.
      public void Die()
      {
          gameObject.SetActive(false);
      }
  }
  ```     
  Player를 드래그앤드롭으로 스크립트에 등록시켜준다.  

  ![8](/assets/images/20211020_Posting/8.png)

  에디터창에서 게임을 실행시켜 움직이는지 테스트 해본다.  

  ![1](/assets/images/20211020_Posting/1.gif)

  AddForce를 통한 조작은 관성이 적용되어 움직임에 무게감이 느껴진다.  

* 스크립트 개선하기  

  에디터에서 드래그앤드롭으로 오브젝트를 등록하지 않고 코드를 통해 할당하도록 한다.  

  ```c#
  //public Rigidbody playerRigidbody;
  private Rigidbody playerRigidbody

  private void Start()
  {
    playerRigidbody = GetComponent<Rigidbody>();
  }
  ```

  플레이어 조작 코드를 간결하게 만들고 움직임에 관성이 적용되지 않게 한다.  

  GetAxis로 입력값을 받고 Velocity로 조작한다.  

  ```c#
  private void Update()
  {
      // 수평축과 수직축의 입력값을 감지하여 저장
      float xInput = Input.GetAxis("Horizontal");
      float zInput = Input.GetAxis("Vertical");

      // 실제 이동 속도를 입력값과 이동 속력을 사용해 결정
      float xSpeed = xInput * speed;
      float zSpeed = zInput * speed;

      // Vector3 속도를 (xSpeed, 0, zSpeed)로 생성
      Vector3 newVelocity = new Vector3(xSpeed, 0f, zSpeed);
      // 리지드바디의 속도에 newVelocity 할당  
      playerRigidbody.velocity = newVelocity;
  }
  ```

  ![2](/assets/images/20211020_Posting/2.gif)

  방향전환이 바로 이어진다.  

