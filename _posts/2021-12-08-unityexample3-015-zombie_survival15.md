---
title:  "[레트로의 유니티] 좀비서바이벌15 - 적 생성기"
excerpt: "unity3d, retro, example, zombie, enemy, spawner"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, enemy, spawner]

toc: true
toc_sticky: true
 
date: 2021-12-08 
last_modified_at: 2021-12-08
---  

***  

### 적 생성기

* 새로운 웨이브가 시작될 때 적을 한꺼번에 생성한다.

* 현재 웨이브의 적이 모두 사망해야 다음 웨이브로 넘어간다.  

* 웨이브가 증가할 때마다 한 번에 생성되는 적의 수가 증가한다.  

* 적을 생성할 때 전체 능력치를 0 ~ 100 사이에서 랜덤 설정

* 게임오버 시 적 생성 중단

<br>

#### 생성 위치  

Prefabs > Spawn Points 를 Hierarchy 창에 드래그앤드롭

Spawn Points의 자식 명단을 펼친다.  

모두 빈 오브젝트로 단순히 적을 생성할 위치의 기준점 역할만 한다.  

<br>

#### 생성기  

* 빈 오브젝트 생성 

  Create > Create Empty

  이름 : Enemy Spawner

* 스크립트 추가  

  Assets > Scripts > EnemySpawner 스크립트 추가

<br>

### 스크립트  

실제로 적을 생성하는 역할을 한다.  

생성될 적의 정보를 담고 있다.

#### variable

```cs
public Enemy enemyPrefab; // 생성할 적 AI

public Transform[] spawnPoints; // 적 AI를 소환할 위치들

public float damageMax = 40f; // 최대 공격력
public float damageMin = 20f; // 최소 공격력

public float healthMax = 200f; // 최대 체력
public float healthMin = 100f; // 최소 체력

public float speedMax = 3f; // 최대 속도
public float speedMin = 1f; // 최소 속도

public Color strongEnemyColor = Color.red; // 강한 적 AI가 가지게 될 피부색

private List<Enemy> enemies = new List<Enemy>(); // 생성된 적들을 담는 리스트
private int wave; // 현재 웨이브
```

<br>

#### Update() 

```cs
private void Update() {
        // 게임 오버 상태일때는 생성하지 않음
        if (GameManager.instance != null && GameManager.instance.isGameover)
        {
            return;
        }

        // 적을 모두 물리친 경우 다음 스폰 실행
        if (enemies.Count <= 0)
        {
            SpawnWave();
        }

        // UI 갱신
        UpdateUI();
    }
```

매 프레임 조건을 검사하고 적 생성 웨이브를 실행한다.  

게임 매니저에서 상태를 받아 진행여부가 결정된다.  

<br>

#### UpdateUI() 

```cs
private void UpdateUI() {
        // 현재 웨이브와 남은 적의 수 표시
        UIManager.instance.UpdateWaveText(wave, enemies.Count);
    }
```

남은 적과 현재 웨이브를 표시한다.  

<br>

#### SpawnWave()  

```cs
// 현재 웨이브에 맞춰 적을 생성
private void SpawnWave() {
    // 웨이브 1 증가
    wave++;

    // 현재 웨이브 * 1.5를 반올림한 수만큼 적 생성
    int spawnCount = Mathf.RoundToInt(wave * 1.5f);

    // spawnCount 만큼 적 생성
    for (int i = 0; i < spawnCount; i++)
    {
        // 적의 세기를 0 ~ 100 사이에서 랜덤 결정
        float enemyIntensity = Random.Range(0f, 1f);
        // 적 생성 처리 실행
        CreateEnemy(enemyIntensity);
    }
}
```  

먼저 새로운 웨이브를 시작하면서 wave를 1 증가시킨다. 그다음 wave에 1.5를 곱하고 반올림한 값을 생성할 적의 수인 spawnCount의 값으로 사용한다.  

<br>

#### CreateEnemy()

```cs
// 적을 생성하고 생성한 적에게 추적할 대상을 할당
private void CreateEnemy(float intensity) {
    // intensity를 기반으로 적의 능력치 결정
    float health = Mathf.Lerp(healthMin, healthMax, intensity);
    float damage = Mathf.Lerp(damageMin, damageMax, intensity);
    float speed = Mathf.Lerp(speedMin, speedMax, intensity);

    // intensity를 기반으로 하얀색과 enemyStrength 사이에서 적의 피부색 결정
    Color skinColor = Color.Lerp(Color.white, strongEnemyColor, intensity);

    // 생성할 위치를 랜덤으로 결정
    Transform spawnPoint = spawnPoints[Random.Range(0, spawnPoints.Length)];

    // 적 프리팹으로부터 적 생성
    Enemy enemy = Instantiate(enemyPrefab, spawnPoint.position, spawnPoint.rotation);

    // 생성한 적의 능력치와 추적 대상 설정
    enemy.Setup(health, damage, speed, skinColor);

    // 생성된 적을 리스트에 추가
    enemies.Add(enemy);

    // 적의 onDeath 이벤트에 익명 메서드 등록
    // 사망한 적을 리스트에서 제거
    enemy.onDeath += () => enemies.Remove(enemy);
    // 사망한 적을 10초 뒤에 파괴
    enemy.onDeath += () => Destroy(enemy.gameObject, 10f);
    // 적 사망 시 점수 상승
    enemy.onDeath += () => GameManager.instance.AddScore(100);
}
```

랜덤한 능력치를 결정한 다음 색과 위치를 결정하고 적을 생성한다. 

생성한 적은 리스트에 추가해서 일괄적으로 관리할 수 있게 한다.  

**익명함수**

익명 함수는 미리 정의하지 않고 인라인에서 즉석 생성할 수 있는 메서드이다.  

실시간으로 생성할 수 있으며, 변수에 저장할 값이나 오브젝트로 취급되며, 생성된 익명 함수는 델리게이트 타입의 변수에 저장할 수 있다.  

미리 정의하지 않고 대부분 일회용으로 생성해서 사용하기 때문에 스코프 외부에 따로 지칭할 수 있는 이름을 가지지 않는다.  

() => enemies.Remove(enemy); 자체가 메서드이자 오브젝트이다.  

이 메서드를 즉석으로 생성하여 onDeath 이벤트에 할당된다.  

여기서 익명 함수를 만드는데 사용한 표현을 람다식 또는 람다 표현식이라고 부른다.  

<br>

### 컴포넌트 설정  

* EnemySpawner 컴포넌트의 Enemy Prefab 필드에 Prefabs 폴더의 Zombie 프리팹 할당  

* SpawnPoints 필드에 삼각형 버튼 클릭 > Size 4로 변경

* SpawnPoints 필드의 각 원소에 Spawn Point 1, 2, 3, 4 할당

