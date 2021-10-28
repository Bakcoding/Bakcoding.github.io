---
title:  "[레트로의 유니티] 유니런4"
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

### 1. 발판 생성  

플레이어가 생존할 수 있도록 발판을 계속해서 생성해준다.  

* 프리팹  

  Prefabs > Platform 프리팹을 하이어라키로 가져온다.  

  발판의 Sorting Layer는 Foreground로 바꾸어서 배경에 가리지 않게 한다.  

  Platform 오브젝트의 자식들은 방해물로 플레이어와 겹쳤을 때 플레이어가 가려지지 않게 모두 Middleground로 해준다.  

* 스크립트  

  Platform 스크립트를 오브젝트에 추가해준다.  

  ```c#
  // Platform.cs
  using UnityEngine;

  // 발판으로서 필요한 동작을 담은 스크립트
  public class Platform : MonoBehaviour {
    public GameObject[] obstacles; // 장애물 오브젝트들
    private bool stepped = false; // 플레이어 캐릭터가 밟았었는가

    // 컴포넌트가 활성화될때 마다 매번 실행되는 메서드
    private void OnEnable() {
        // 발판을 리셋하는 처리
    }

    void OnCollisionEnter2D(Collision2D collision) {
        // 플레이어 캐릭터가 자신을 밟았을때 점수를 추가하는 처리
    }
  }
  ```

  OnEnable를 사용해서 오브젝트의 스크립트를 활성/비활성 시킨다. 발판의 상태는 재활성화시 초기화 된다.  

  ```c#
  private void OnEnable() {
    stepped = false;

    // 장애물의 수만큼 루프
    for (int i = 0; i < obstacles.Length; i++)
    {
        // 헌재 순번의 장애물을 1/3의 확률로 활성화
        if (Random.Range(0, 3) == 0)
        {
            obstacles[i].SetActive(true);
        }
        else
        {
            obstacles[i].SetActive(false);
        }
    }
  }
  ```

  장애물의 생성을 랜덤으로 해서 매번 재활성화 할 때마다 다른 위치에 장애물이 생성될 수 있게 한다.  

  발판을 밟을 때 마다 점수가 추가되도록 처리해준다.  

  ```c#
  void OnCollisionEnter2D(Collision2D collision) {
    // 플레이어 캐릭터가 자신을 밟았을때 점수를 추가하는 처리
    if (collision.collider.tag == "Player" && !stepped)
    {
        // 점수를 추가하고 밟힘 상태를 참으로 변경
        stepped = true;
        GameManager.instance.AddScore(1);
    }
  }
  ```

  플레이어와 충돌을 감지하고 점수를 갱신시킨다.  

* Platform 컴포넌트에 오브젝트를 등록해준다.  

  Platform 오브젝트의 자식을 모두 선택하고 Obstacle에 드래그앤드롭하여 등록한다.  

  수정된 프리팹은 overrides로 갱신해준다.  

<br/>

### 2. 발판 생성기  

발판은 미리 생성해 놓고 계속해서 재활용하는 오브젝트 풀링 방식을 사용한다.  

PlatformSpawner 빈 오브젝트 생성, PlatformSpawner 스크립트 추가한다.  

하이어라키에 생성된 Platform 오브젝트는 지워준다.  

```c#
// PlatformSpawner.cs
using UnityEngine;

// 발판을 생성하고 주기적으로 재배치하는 스크립트
public class PlatformSpawner : MonoBehaviour {
    public GameObject platformPrefab; // 생성할 발판의 원본 프리팹
    public int count = 3; // 생성할 발판의 개수

    public float timeBetSpawnMin = 1.25f; // 다음 배치까지의 시간 간격 최솟값
    public float timeBetSpawnMax = 2.25f; // 다음 배치까지의 시간 간격 최댓값
    private float timeBetSpawn; // 다음 배치까지의 시간 간격

    public float yMin = -3.5f; // 배치할 위치의 최소 y값
    public float yMax = 1.5f; // 배치할 위치의 최대 y값
    private float xPos = 20f; // 배치할 위치의 x 값

    private GameObject[] platforms; // 미리 생성한 발판들
    private int currentIndex = 0; // 사용할 현재 순번의 발판

    private Vector2 poolPosition = new Vector2(0, -25); // 초반에 생성된 발판들을 화면 밖에 숨겨둘 위치
    private float lastSpawnTime; // 마지막 배치 시점


    void Start() {
        // 변수들을 초기화하고 사용할 발판들을 미리 생성
    }

    void Update() {
        // 순서를 돌아가며 주기적으로 발판을 배치
    }
}
```

임의의 발판을 생성해놓고 화면을 벗어날 때 마다 새로운 위치에서 활성화 시킨다.  

```c#
void Start() {
    // 변수들을 초기화하고 사용할 발판들을 미리 생성
    platforms = new GameObject[count];
    // count 만큼 루프하면서 발판 생성  
    for (int i = 0; i < count; i++)
    {
        // platformPrefab을 원본으로 새 발판을 poolPosition 위치에 복제 생성  
        // 생성된 발판을 platforms 배열에 할당  
        platforms[i] = Instantiate(platformPrefab, poolPosition, Quaternion.identity);
    }
    // 마지막 배치 시점 초기화
    lastSpawnTime = 0f;
    // 다음번 배치까지의 시간 간격을 0으로 초기화
    timeBetSpawn = 0f;
}
```

count만큼 발판을 생성하고 배열에 담는다.  
그리고 업데이트를 통해서 배열에서 발판을 꺼내 사용한다.  

```c#
void Update() {
    // 순서를 돌아가며 주기적으로 발판을 배치
    if (GameManager.instance.isGameover)
    {
        return;
    }
    // 마지막 배치 시점에서 timeBetSpawn 이상 시간이 흘렀다면  
    if (Time.time >= lastSpawnTime + timeBetSpawn)
    {
        // 기록된 마지막 배치 시점을 현재 시점으로 갱신
        lastSpawnTime = Time.time;
        // 다음 배치까지의 시간 간격을 timeBetSpawnMin, timeBetSpawnMax 사이에서 랜덤 설정
        timeBetSpawn = Random.Range(timeBetSpawnMin, timeBetSpawnMax);
        // 배치할 위치의 높이를 yMin과 yMax 사이에서 랜덤 설정
        float yPos = Random.Range(yMin, yMax);
        // 사용할 현재 순번의 발판을 비활성화하고 즉시 다시 활성화
        // OnEnable 통해서 변수값 초기화
        platforms[currentIndex].SetActive(false);
        platforms[currentIndex].SetActive(true);
        // 현재 순번의 발판을 화면 오른쪽에 재배치
        platforms[currentIndex].transform.position = new Vector2(xPos, yPos);
        // 순번 넘기기
        currentIndex++;
        // 마지막 순번에 도달했다면 순번을 리셋
        if (currentIndex >= count)
        {
            currentIndex = 0;
        }
    }
}
```
비활성화 후에 다시 활성화 할 때 동작하는 OnEnable 함수를 통해서 초기화시켜서 발판을 새로운 위치에 생기도록 한다.  

Prefabs폴더에 있는 Platform 프리팹을 PlatformSpawner 스크립트에 등록시킨다.  

<br/>

### 3. 배경음악 추가  

Assets > Audio 폴더에 music 파일을 하이어라키 창으로 드래그앤드롭해준다.  

반복해서 재생될 수 있도록 Audio Source 컴포넌트의 Loop 옵션을 체크해준다.  

![run](/assets/images/20211026_Posting/6.gif)

