---
title:  "[레트로의 유니티] 좀비서바이벌16 - 아이템 생성기"
excerpt: "unity3d, retro, example, zombie, item, spawner"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, item, spawner]

toc: true
toc_sticky: true
 
date: 2021-12-08 
last_modified_at: 2021-12-08
---  

***  

### 아이템 생성기

플레이어 캐릭터가 사용할 수 있는 아이템을 추가하고 아이템 생성기를 사용해 실시간으로 아이템을 생성한다.  

<br>

#### 생성기 추가  

* 빈 게임 오브젝트 생성 

  Create > Create Empty

* 생성된 오브젝트의 이름을 Item Spawner로 변경

* Scripts > ItemSpawner 스크립트 추가해준다.  

<br>

### 스크립트  

#### ItemSpawner 

```cs
public GameObject[] items; // 생성할 아이템들
public Transform playerTransform; // 플레이어의 트랜스폼

public float maxDistance = 5f; // 플레이어 위치로부터 아이템이 배치될 최대 반경

public float timeBetSpawnMax = 7f; // 최대 시간 간격
public float timeBetSpawnMin = 2f; // 최소 시간 간격
private float timeBetSpawn; // 생성 간격

private float lastSpawnTime; // 마지막 생성 시점
```

* 배열로 생성할 아이템의 목록으로 할당한다.  

* 아이템은 플레이어의 위치를 기준으로 생성되기 때문에 트랜스폼 변수를 받는다.  

* 최대, 최소 시간 간격을 정한다.  

* 마지막 생성 시점을 기준으로 아이템 생성이 갱신 된다.  

<br>

#### Start() 

```cs
private void Start() {
    // 생성 간격과 마지막 생성 시점 초기화
    timeBetSpawn = Random.Range(timeBetSpawnMin, timeBetSpawnMax);
    lastSpawnTime = 0;
}
```

초기화

생성 간격은 최소와 최대 사이의 랜덤 값으로 초기화 된다. 

<br>

#### Update()

```cs
// 주기적으로 아이템 생성 처리 실행
private void Update() {
    // 현재 시점이 마지막 생성 시점에서 생성 주기 이상 지남
    // && 플레이어 캐릭터가 존재함
    if (Time.time >= lastSpawnTime + timeBetSpawn && playerTransform != null)
    {
        // 마지막 생성 시간 갱신
        lastSpawnTime = Time.time;
        // 생성 주기를 랜덤으로 변경
        timeBetSpawn = Random.Range(timeBetSpawnMin, timeBetSpawnMax);
        // 아이템 생성 실행
        Spawn();
    }
}
```

생성 간격이 충족될 때 진행된다.  

내부에서 생성 시간을 갱신하고, 생성 주기를 새로 랜덤하게 변경한 뒤 아이템의 생성을 실행한다.

<br>

#### Spawn()

```cs
private void Spawn() {
    // 플레이어 근처에서 내비메시 위의 랜덤 위치 가져오기
    Vector3 spawnPosition =
        GetRandomPointOnNavMesh(playerTransform.position, maxDistance);
    // 바닥에서 0.5만큼 위로 올리기
    spawnPosition += Vector3.up * 0.5f;

    // 아이템 중 하나를 무작위로 골라 랜덤 위치에 생성
    GameObject selectedItem = items[Random.Range(0, items.Length)];
    GameObject item = Instantiate(selectedItem, spawnPosition, Quaternion.identity);

    // 생성된 아이템을 5초 뒤에 파괴
    Destroy(item, 5f);
}
``` 

GetRandomPointOnNavMesh로 플레이어 위치를 기준으로 maxDistance 반경 내부에서 랜덤 위치로 아이템이 생성될 곳을 정한다.  

아이템의 종류는 배열에서 랜덤으로 지정하여 생성한다.  

<br>

#### GetRandomPointOnNavMesh()

아이템이 생성될 위치를 지정하는 메서드이다.  

```cs
private Vector3 GetRandomPointOnNavMesh(Vector3 center, float distance) {
        // center를 중심으로 반지름이 maxDistance인 구 안에서의 랜덤한 위치 하나를 저장
        // Random.insideUnitSphere는 반지름이 1인 구 안에서의 랜덤한 한 점을 반환하는 프로퍼티
        Vector3 randomPos = Random.insideUnitSphere * distance + center;

        // 내비메시 샘플링의 결과 정보를 저장하는 변수
        NavMeshHit hit;

        // maxDistance 반경 안에서, randomPos에 가장 가까운 내비메시 위의 한 점을 찾음
        NavMesh.SamplePosition(randomPos, out hit, distance, NavMesh.AllAreas);

        // 찾은 점 반환
        return hit.position;
    }
```

<br>

### 컴포넌트 설정  

ItemSpawner 

* Items 필드 > Size : 3

  Prfabs > AmmoPack, Coin, HealthPack 프리팹을 각 원소에 할당

* Player Character 오브젝트를 PlayerTransform 필드로 할당
