---
title:  "[레트로의 유니티] 좀비서바이벌24 - 네트워크 - 아이템"
excerpt: "unity3d, retro, example, zombie, multiplayer, photon"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, multiplayer, photon]

toc: true
toc_sticky: true
 
date: 2021-12-09 
last_modified_at: 2021-12-09
---  

***  

### Item

MonoBehaviour 대신 MonoBehaviourPun 를 상속받는다.

Prefabs 폴더의 아이템 프리팹(Coin, AmmoPack, HealthPack)는 여러 클라이언트 사이에서 정보를 동기화하기 위한 식별자가 필요하기 때문에 Photon View 컴포넌트가 추가되어있다.  

<br>

### AmmoPack

플레이어의 탄알을 추가하고 효과 적용 후 스스로를 파괴한다. 이 기능을 모든 클라이언트에서 실행되도록한다. 

#### Use()

```cs
public void Use(GameObject target) {
    // 전달 받은 게임 오브젝트로부터 PlayerShooter 컴포넌트를 가져오기 시도
    PlayerShooter playerShooter = target.GetComponent<PlayerShooter>();

    // PlayerShooter 컴포넌트가 있으며, 총 오브젝트가 존재하면
    if (playerShooter != null && playerShooter.gun != null)
    {
        // 총의 남은 탄환 수를 ammo 만큼 더하기, 모든 클라이언트에서 실행
        playerShooter.gun.photonView.RPC("AddAmmo", RpcTarget.All, ammo);
    }

    // 모든 클라이언트에서의 자신을 파괴
    PhotonNetwork.Destroy(gameObject);
}
```

기존 AmmoPack 스크립트는 플레이어 캐릭터가 가지고 있는 Gun 게임 오브젝트의 Gun 스크립트로 접근하여 남은 탄알 수를 증가시켰다.

그대로 사용한다면 PlayerHealth 스크립트에서 아이템들의 Use() 메서드가 호스트에서만 실행되도록 했기 때문에 호스트에서만 총의 남은 탄알이 증가하게 된다.  

또한 Gun 스크립트는 로컬에서 리모트 방향으로 남은 탄알을 항상 동기화하지만 호스트에서 다른 클라이언트 방향으로는 자동 동기화를 하지 않는다. 

따라서 모든 클라이언트에서 원격으로 AddAmmo() 메서다가 실행되도록 코드를 변경한다. 

즉 아이템 사용 자체는 호스트에서 이루어지고 탄알이 증가되는 효과는 모든 클라이언트에서 동일하게 적용된다. 

<br>

**PhotonNetwork.Destroy()**  

게임 오브젝트를 파괴할 때 메서드가 변경되었다. 기존의 Destroy()는 해당 클라이언트에서만 파괴되고 다른 클라이언트에서는 그대로 존재하기 때문에 모든 클라이언트에서 동일하게 파괴되도록 이 메서드를 사용한다.  

<br>

### HealthPack

모든 클라이언트에서 스스로 파괴되도록한다.  

#### Use()

```cs
public void Use(GameObject target) {
    // 전달받은 게임 오브젝트로부터 LivingEntity 컴포넌트 가져오기 시도
    LivingEntity life = target.GetComponent<LivingEntity>();

    // LivingEntity컴포넌트가 있다면
    if (life != null)
    {
        // 체력 회복 실행
        life.RestoreHealth(health);
    }

    // 모든 클라이언트에서의 자신을 파괴
    PhotonNetwork.Destroy(gameObject);
}
```

AmmoPack과 달리 RPC를 사용할 필요가 없다. LivingEntity의 RestoreHealth() 메서드를 사용하기 때문에 자동으로 다른 클라이언트에서도 원격으로 실행되기 때문이다. 

모든 클라이언트에서 파괴되도록 PhotonNetwork.Destroy()를 사용해준다.

<br>

### Coin

모든 클라이언트에서 파괴되도록한다.  

#### Use()

```cs
public int score = 200; // 증가할 점수

public void Use(GameObject target) {
    // 게임 매니저로 접근해 점수 추가
    GameManager.instance.AddScore(score);
    // 모든 클라이언트에서의 자신을 파괴
    PhotonNetwork.Destroy(gameObject);
}
```

점수는 GameManager에서 호스트가 점수를 갱신하면 자동으로 모든 클라이언트의 점수가 갱신되도록 작성될것이기 때문에 Coin에서도 모든 클라이언트에서 파괴되도록 처리해주기만 한다.

<br>

### PhotonNetwork.Instantiate()

파괴와 마찬가지로 생성도 역시 모든 클라이언트에 적용시키기 위한 메서드를 사용해야한다.  

이 메서드를 사용하기 위해서는 생성할 프리팹들이 Resources 폴더상에 존재해야 하므로 모두 이동시켜 준다.  

* Resources 폴더 생성

* Prefabs > AmmoPack, Coin, HealthPack, Player Character, Zombie 를 모두 Resources 폴더로 이동시킨다. 

<br>

### ItemSpawner

플레이어 중심에 아이템을 생성하던 기능을 맵 중심에 아이템이 생성되도록 변경한다. 

기존에 플레이어 위치 주변에 생성되어서 위치값을 받던 playerTransform 변수를 사용하지 않으며 생성 위치는 Vector3.zero 를 사용한다.

#### Update()

```cs
// 주기적으로 아이템 생성 처리 실행
private void Update() {
    // 호스트에서만 아이템 직접 생성 가능
    if (!PhotonNetwork.IsMasterClient)
    {
        return;
    }

    if (Time.time >= lastSpawnTime + timeBetSpawn)
    {
        // 마지막 생성 시간 갱신
        lastSpawnTime = Time.time;
        // 생성 주기를 랜덤으로 변경
        timeBetSpawn = Random.Range(timeBetSpawnMin, timeBetSpawnMax);
        // 실제 아이템 생성
        Spawn();
    }
}
```

아이템을 생성하는 Update() 메서드를 호스트에서만 실행되도록 한다.  

<br>

#### Spawn()

```cs
// 실제 아이템 생성 처리
private void Spawn() {
    // (0,0,0)을 기준으로 maxDistance 안에서 내비메시위의 랜덤 위치 지정
    Vector3 spawnPosition = GetRandomPointOnNavMesh(Vector3.zero, maxDistance);
    // 바닥에서 0.5만큼 위로 올리기
    spawnPosition += Vector3.up * 0.5f;

    // 생성할 아이템을 무작위로 하나 선택
    GameObject itemToCreate = items[Random.Range(0, items.Length)];

    // 네트워크의 모든 클라이언트에서 해당 아이템 생성
    GameObject item =
        PhotonNetwork.Instantiate(itemToCreate.name, spawnPosition,
            Quaternion.identity);

    // 생성한 아이템을 5초 뒤에 파괴
    StartCoroutine(DestroyAfter(item, 5f));
}
```

실제 생성 처리를 하는 Instantiate를 PhotonNetwork.Instantiate()로 변경해 모든 클라이언트에서 생성되도록 한다. 

하지만 PhotonNetwork.Instantiate() 메서드는 프리팹을 직접 받지 못하기 때문에 이름으로 생성할 프리팹을 지정해준다.

생성된 아이템이 자동 파괴되는 부분도 모든 클라이언트에 반영되도록한다. 여기서 PhotonNetwork.Destroy() 메서드는 지연시간을 받지 않기 때문에 코루틴으로 한번 메서드를 감싼 다음 실행시켜주는 방법을 사용한다.  
