---
title:  "[레트로의 유니티] 닷지3"
excerpt: "unity3d, retro, example, dodge"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, dodge]

toc: true
toc_sticky: true
 
date: 2021-10-20 
last_modified_at: 2023-06-04
---  

***

### 1. 프로젝트 정리
프로젝트 창을 정리해준다.  

Create > Folder

Scripts, Materials, Prefabs 이름의 폴더를 생성해 에셋을 폴더에 구분해서 담는다.  

앞으로 추가되는 에셋들도 해당하는 위치에 생성해준다.

<br/>

### 2. 바닥회전
게임의 난이도와 재미요소를 추가하기 위해서 바닥을 회전시킨다.  

```c#
// Rotator
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotator : MonoBehaviour
{
    public float rotationSpeed = 60f;

    private void Update()
    {
        transform.Rotate(0f, rotationSpeed * Time.deltaTime, 0f);
    }
}
```

<br/>

### 3. 게임 UI 제작  
생존 시간, 게임오버, 최고 기록을 표현하는 UI를 만든다.  

* 생존 시간 텍스트 제작  
  
  Create > UI > Text  

  Text 오브젝트 이름은 Time Text으로 변경한다.  
  
* 인스펙터창 설정  

  Rect Transform 컴포넌트  
  앵커프리셋은 alt 누르고 top-center로 변경해준다.  
  PosY, -30으로 변경

  Text 컴포넌트  
  Text, Time : 0  
  Alignment, 가운데로 정렬해준다.  
  Color, 색상은 (255, 255, 255)로 변경  
  Font Size, 42로 변경  
  Horizontal Overflow와 Vertical Overflow를 overflow로 변경

* 그림자 효과 추가  

  Shadow 컴포넌트를 추가해준다.  

  Add Component > UI > Effects > Shadow

* 게임오버 텍스트와 최고 기록 텍스트  


  게임오버텍스트  
  Time Text를 복제하고 오브젝트 이름을 Gameover Text로 변경  
  Text를 Press R to Restart로 변경  
  앵커프리셋은 alt를 누르고 middle-center로 변경

  최고 기록 텍스트  
  Gameover Text를 복제, 오브젝트 이름을 Record Text로 변경  
  위치 Pos Y를 -40으로 변경  
  Text는 Best Record: 0, Font Size는 30으로 변경  

  Record Text는 Gameover Text의 자식으로 만들고 Gameover Text는 비활성화 시켜 게임오버시 활성화되도록 한다.  

<br/>

### 4. 게임 매니저 제작

게임오버와 생존 시간 등 수치를 관리하고 UI를 갱신한다.  

* GameManager 스크립트 준비  

  GameManager이름의 스크립트를 생성하고 코드 작성  

  ```c#
  using System.Collections;
  using System.Collections.Generic;
  using UnityEngine;
  // UI 관련 라이브러리
  using UnityEngine.UI;
  // 씬 관리 관련 라이브러리 
  using UnityEngine.SceneManagement;
  public class GameManager : MonoBehaviour
  {
      // 게임오버 시 활성화할 텍스트 게임 오브젝트
      public GameObject gameoverText;
      // 생존 시간을 표시할 텍스트 컴포넌트  
      public Text timeText;
      // 최고 기록을 표실할 텍스트 컴포넌트
      public Text recordText;
      // 생존 시간
      private float surviveTime;
      // 게임오버 상태
      private bool isGameover;

      private void Start()
      {
          // 생존 시간과 게임오버 상태 초기화
          surviveTime = 0;
          isGameover = false;
      }

      private void Update()
      {
          // 게임오버가 아닌 동안
          if (!isGameover)
          {
              // 생존 시간 갱신
              surviveTime += Time.deltaTime;
              // 갱신한 생존 시간을 timeText 텍스트 컴포넌트를 이용해 표시
              timeText.text = "Time: " + (int)surviveTime;
          }
          else
          {
              // 게임오버인 상태에서 R 키를 누른 경우
              if (Input.GetKeyDown(KeyCode.R))
              {
                  // SampleScene 씬을 로드
                  SceneManager.LoadScene("SampleScene");
              }
          }
      }

      // 현재 게임을 게임오버 상태로 변경하는 메서드
      public void EndGame()
      {
          // 현재 상태를 게임오버 상태로 전환
          isGameover = true;
          // 게임오버 텍스트 게임 오브젝트를 활성화
          gameoverText.SetActive(true);
          // BestTime 키로 저장된 이전까지의 최고 기록 가져오기
          float bestTime = PlayerPrefs.GetFloat("BestTime");
          // 이전까지의 최고 기록보다 현재 생존 시간이 더 크면
          if (surviveTime > bestTime)
          {
              // 최고 기록 값을 현재 생존 시간 값으로 변경
              bestTime = surviveTime;
              // 변경된 최고 기록을 BestTime키로 저장
              PlayerPrefs.SetFloat("BestTime", bestTime);
          }

          // 최고 기록을 recordText 텍스트 컴포넌트를 이용해 표시
          recordText.text = "Best Time: " + (int)bestTime;
      }
  }
  ```
  
  PlayerController.cs 수정  

  ```c#
  public void Die()
  {
      gameObject.SetActive(false);
      // 씬에 존재하는 GameManager 타입의 오브젝트를 찾아서 가져오기
      GameManager gameManager = FindObjectOfType<GameManager>();
      // 가져온 GameManager 오브젝트의 EndGame() 메서드 실행
      gameManager.EndGame();
  }  
  ```

  빈 오브젝트를 생성해 이름을 GameManager로 바꾸어주고 스크립트를 추가해준다.  

  그리고 Gameover Text, Time Text, Record Text에 오브젝트를 등록해준다.  

  ![play](/assets/images/posting/20211020/play.gif)

  재시작시 화면이 어두워지는 문제가 있다. 이는 조명이 구워지지 않았기 때문에 씬을 다시 실행할 때 Light가 생성되지않아서 발생한다.  

  빌드를하면 이 문제가 해결되기 때문에 신경쓰지 않아도 된다.