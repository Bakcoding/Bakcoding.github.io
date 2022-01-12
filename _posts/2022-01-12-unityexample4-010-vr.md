---
title:  "[왕초보도 할 수 있는 VR] 타워디펜스 7 - 게임오버"
excerpt: "unity3d, vr, ui"

categories:
  - UnityExample
tags:
  - [unity3d, vr, ui]

toc: true
toc_sticky: true
 
date: 2022-01-12 
last_modified_at: 2022-01-12
---  

***  
<a href="https://www.gseek.kr/member/rl/studyRoom/studyRoomMain.do?courseSeq=2069&courseCsSeq=1&stuSeq=&subjSeq=5&pageNum=1">VR 강의</a>

Unity version 2018.1.1f1

### 게임오버 구현

#### UI

하이어라키 > Create > Text

오브젝트 이름 GameoverUI로 생성

* Text 오브젝트 설정

  <img src="/assets/images/20220112_Posting/gameoverui.png" title="gameover" width="400px">

  Pos : 0, 95, 0
  
  Text : GAME OVER
  
  Font Size : 20

  Alignment : center

  Color : white

* 효과 추가

  Add Component > Shadow 효과 추가

  Effect Distance : 3, -3  


게임오버시에만 보여지기 때문에 기본 비활성화 한다.  

<br>

#### 스크립트

플레이어인 Tower 오브젝트에 스크립트를 추가한다.  

Workshop > Scripts > Tower.cs

* Tower 컴포넌트

  MAX_HP로 체력을 설정할 수 있다.  

  Die : 죽을 때 보여지는 오브젝트, 게임오버 UI를 등록한다. 

```cs
using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
// UI를 다루기 위해 필요
using UnityEngine.UI;

public class Tower : MonoBehaviour {

	public static Tower Instance;
    // HP를 표시할 슬라이더
    public Slider hpSlider;
	public int MAX_HP = 10;
	int hp = 0;

	public GameObject die;

	void Awake()
	{
        
		if(Instance == null)
			Instance = this;
	}

	void Start()
	{
        
		hp = MAX_HP;
	}

	public void Damage()
	{
        // 1씩 감소
		hp--;
        // 슬라이더에 HP를 세팅
        hpSlider.value = hp;
		if(hp <= 0)
		{
            // 이미 죽은게 아니면
			if(die)
			{
                // 게임오버 UI 활성화
				die.SetActive(true);
			}
		}
	}
}
```

<br>

TowerHP 오브젝트의 설정을 수정한다.  

Max Value : 10

Value : 10

<br>

### 재시작

게임오버상태에서 클릭시 재시작한다.  

#### Tower 스크립트 수정

```cs
using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
// UI를 다루기 위해 필요
using UnityEngine.UI;
// 재시작 하기위해 추가
using UnityEngine.SceneManagement;
public class Tower : MonoBehaviour {

	public static Tower Instance;
    // HP를 표시할 슬라이더
    public Slider hpSlider;
	public int MAX_HP = 10;
	int hp = 0;
    // 게임오버 플래그
    bool gameOver = false;

	public GameObject die;

	void Awake()
	{
        
		if(Instance == null)
			Instance = this;
	}

	void Start()
	{
        
		hp = MAX_HP;
	}

    private void Update()
    {
        // gameOver가 true이고 버튼이 클릭되면 게임을 재시작한다.
        if (gameOver == true && Input.GetMouseButtonDown(0))
        {
            // 새 게임 로드
            SceneManager.LoadScene(0);
        }
    }

    public void Damage()
	{
        // 1씩 감소
		hp--;
        // 슬라이더에 HP를 세팅
        hpSlider.value = hp;
		if(hp <= 0)
		{
            // hp가 0이하면 게임오버
            gameOver = true;
            // 이미 죽은게 아니면
			if(die)
			{
                // 게임오버 UI 활성화
				die.SetActive(true);
			}
		}
	}
}
```

LoadScene(0)은 0번 씬을 로드한다. 

씬을 0번으로 설정

File > Build Settings 의 기본으로 등록된 Sample 씬을 삭제하고 

Add Open Scene으로 현재 씬을 추가한다.