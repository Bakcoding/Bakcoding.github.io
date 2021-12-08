---
title:  "[레트로의 유니티] 좀비서바이벌14 - 게임매니저"
excerpt: "unity3d, retro, example, zombie, gamemanager"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, gamemanager]

toc: true
toc_sticky: true
 
date: 2021-12-08 
last_modified_at: 2021-12-08
---  

***  

### 게임 매니저

게임의 전반적인 규칙을 관리하고 상태를 표시하는 역할을 한다. 

* 싱글턴으로 존재

* 점수 관리

* 게임오버 상태 관리

* UIManager를 이용해 점수와 게임오버 UI 갱신

#### 생성  

* 씬에 빈오브젝트를 생성

  Create > Create Empty  

  빈 오브젝트 이름 : Game Manager,

* 스크립트 추가

  Assets > Scripts > GameManager 스크립트를 Game Manager 오브젝트에 추가

<br>

### 스크립트

#### 싱글턴 프로퍼티  

외부에서 즉시 접근할 수 있도록 만든다.  

```cs
// 싱글톤 접근용 프로퍼티
public static GameManager instance
{
    get
    {
        // 만약 싱글톤 변수에 아직 오브젝트가 할당되지 않았다면
        if (m_instance == null)
        {
            // 씬에서 GameManager 오브젝트를 찾아 할당
            m_instance = FindObjectOfType<GameManager>();
        }

        // 싱글톤 오브젝트를 반환
        return m_instance;
    }
}
```
싱글턴으로 만든 클래스는 씬에서 유일하게 존재해야하기 때문에 중복 존재를 방지한다.  

```cs
private void Awake() {
      // 씬에 싱글톤 오브젝트가 된 다른 GameManager 오브젝트가 있다면
      if (instance != this)
      {
          // 자신을 파괴
          Destroy(gameObject);
      }
  }
```

<br>

#### Start()

사망시 이벤트 등록

플레이어가 사망하면 게임오버 처리를 위해 이벤트에 등록한다.  

```cs
private void Start() {
      // 플레이어 캐릭터의 사망 이벤트 발생시 게임 오버
      FindObjectOfType<PlayerHealth>().onDeath += EndGame;
  }
```

<br>

#### AddScore()

점수를 입력받아 현재 점수에 추가하고 점수 UI를 갱신한다.  

```cs
// 점수를 추가하고 UI 갱신
public void AddScore(int newScore) {
    // 게임 오버가 아닌 상태에서만 점수 증가 가능
    if (!isGameover)
    {
        // 점수 추가
        score += newScore;
        // 점수 UI 텍스트 갱신
        UIManager.instance.UpdateScoreText(score);
    }
}
```

게임오버가 아닌 상태에서만 점수를 추가하고 UI 텍스트를 갱신한다. 

GameManager 내에서 UI 오브젝트를 직접 수정하지 않고 UIManager 싱글턴을 거쳐 점수 UI를 갱신하기 때문에 GameManager 스크립트는 UI 갱신이 처리되는 세부 구현을 신경 쓸 필요가 없다.  

<br>

#### EndGame()  

현재 게임 상태를 게임오버 상태로 전환하고 게임오버 UI를 활성화한다.  

```cs
// 게임 오버 처리
public void EndGame() {
    // 게임 오버 상태를 참으로 변경
    isGameover = true;
    // 게임 오버 UI를 활성화
    UIManager.instance.SetActiveGameoverUI(true);
}
```

EndGame에서도 마찬가지로 UIManager 싱글턴을 거쳐 UI를 갱신한다.