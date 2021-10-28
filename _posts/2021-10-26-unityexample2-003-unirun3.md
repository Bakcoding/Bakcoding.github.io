---
title:  "[레트로의 유니티] 유니런3"
excerpt: "unity3d, retro, example, unirun"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, unirun]

toc: true
toc_sticky: true
 
date: 2021-10-26 
last_modified_at: 2021-10-26
---  

***

### 1. 캔버스 만들기  

UI를 만들기 위해서 Canvas를 생성한다.  

Create > UI > Canvas  

Canvas Scaler 컴포넌트의 UI Scale Mode를 Scale with Screen Size로 변경

Reference Resolution은 (640, 360)  

<br/>

### 2. UI 추가

* Score 텍스트  

  점수를 표시하는 UI를 만든다.  

  Text 오브젝트를 생성, 이름 Score Text, Rect (300, 80), Anchor Preset을 alt+shift - bottom-center로 변경한다.  

  Text 필드 : Score : 0  
  Font : Kenny Mini Square  
  Font Size : 50  
  Alignment : Center, Middle  
  Color : 255, 255, 255  

  선명하게 보이기 위해서 Shadow 컴포넌트를 추가해준다.  

* Gameover 텍스트  

  Score Text를 복제해서 사용한다.  

  이름을 Gameover Text로 변경, Anchor Preset은 top-center  

  Text 필드 : Gameover!  
  Color : 255, 66, 85   

* Restart 텍스트  

  Gameover Text를 복제, Restart Text 이름 변경한다.  
  
  Rect Transform의 X : -40
  Text 필드 : Jump To Restart  
  Font Size : 33

  Restart Text오브젝트는 Gameover Text의 자식으로 만들고 Gameover Text를 비활성화 시킨다.  

<br/>

### 3. 게임매니저  

점수 저장, 게임오버 처리 및 표현, UI 관리 등의 기능을 다루기 위해서 게임매니저를 만든다.  

GameManager 이름의 빈 오브젝트를 만들고 GameManager 스크립트를 추가한다.  


* 싱글턴  
  
  게임매니저는 싱글턴 패턴을 사용해서 만들어 일괄적인 데이터 관리와 처리를 한다.  


```c#
// GameManager.cs  
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

// 게임 오버 상태를 표현하고, 게임 점수와 UI를 관리하는 게임 매니저
// 씬에는 단 하나의 게임 매니저만 존재할 수 있다.
public class GameManager : MonoBehaviour {
    public static GameManager instance; // 싱글톤을 할당할 전역 변수

    public bool isGameover = false; // 게임 오버 상태
    public Text scoreText; // 점수를 출력할 UI 텍스트
    public GameObject gameoverUI; // 게임 오버시 활성화 할 UI 게임 오브젝트

    private int score = 0; // 게임 점수

    // 게임 시작과 동시에 싱글톤을 구성
    void Awake() {
        // 싱글톤 변수 instance가 비어있는가?
        if (instance == null)
        {
            // instance가 비어있다면(null) 그곳에 자기 자신을 할당
            instance = this;
        }
        else
        {
            // instance에 이미 다른 GameManager 오브젝트가 할당되어 있는 경우

            // 씬에 두개 이상의 GameManager 오브젝트가 존재한다는 의미.
            // 싱글톤 오브젝트는 하나만 존재해야 하므로 자신의 게임 오브젝트를 파괴
            Debug.LogWarning("씬에 두개 이상의 게임 매니저가 존재합니다!");
            Destroy(gameObject);
        }
    }

    void Update() {
        // 게임 오버 상태에서 게임을 재시작할 수 있게 하는 처리
    }

    // 점수를 증가시키는 메서드
    public void AddScore(int newScore) {
        
    }

    // 플레이어 캐릭터가 사망시 게임 오버를 실행하는 메서드
    public void OnPlayerDead() {
        
    }
}
```

씬 전환을 위해서 업데이트를 통해서 입력을 확인해서 처리한다.  

```c#
void Update() {
    // 게임 오버 상태에서 게임을 재시작할 수 있게 하는 처리
    if (isGameover && Input.GetMouseButtonDown(0))
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }
}
```

점수를 관리하고 Score Text를 갱신한다. AddScore 메서드에 동작 추가  

```c#
public void AddScore(int newScore) {
    if (!isGameover)
    {
        // 점수를 증가
        score += newScore;
        scoreText.text = "Score : " + score;
    }
}
```

플레이어 사망을 감지해서 처리할 메서드이다. OnPlayerDead  

```c#
public void OnPlayerDead() {
    isGameover = true;
    gameoverUI.SetActive(true);
}
```

* PlayerController 스크립트 수정  

  플레이어와 상호작용 시키기 위해서 스크립트를 수정해준다.  

  ```c#
  // PlayerController.cs
  // 게임매니저의 게임오버 처리 실행하는 코드 추가
  GameManager.instance.OnPlayerDead();
  ```

* ScrollingObject 스크립트 수정  

  게임오버시 움직이는 배경과 발판의 동작을 멈추도록 한다.  

  ```c#
  private void Update() {
    // 게임오버가 아닐 때만 동작
    if (!GameManager.instance.isGameover)
    {
        transform.Translate(Vector3.left * speed * Time.deltaTime);
    }
  }
  ```

* GameManager 컴포넌트 추가  

  GameManager 스크립트에 오브젝트를 드래그앤드롭으로 등록시켜준다.  

  Score Text = Score Text 오브젝트  
  Gameover UI = GameManager Text 오브젝트  

  ![play](/assets/images/20211026_Posting/5.gif)