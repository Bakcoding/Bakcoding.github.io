---
title:  "Mirror Guide GameObjects - Custom Spawn Functions"
excerpt: "Network, Mirror, GameObjects, Custom-Spawn"

categories:
  - Mirror
tags:
  - [Network, Mirror, GameObjects, Custom-Spawn]

toc: true
toc_sticky: true
 
date: 2022-03-17
last_modified_at: 2022-03-17
---  

***

<br>

### Custom Spawn Functions

클라이언트에 생성된 게임 오브젝트를 만들 때 기본 동작을 커스터마이즈하기 위해 Spawn handler 함수를 사용할 수 있다. Spawn handler 함수는 게임 오브젝트를 생성하는 방법과 파괴하는 방법을 완전히 제어한다.

NetworkClient.RegisterSpawnHandler 또는 NetworkClient.RegisterPrefab은 클라이언트 게임 오브젝트를 생성과 파괴하는 기능을 등록한다. 서버는 게임 오브젝트를 직접 생성하고 이 함수를 통해 클라이언트에서 생성한다. 이 함수는 에셋ID 또는 프리팹과 2개의 함수 delegate를 사용한다. 하나는 클라이언트의 게임 오브젝트 작성, 다른 하나는 클라이언트의 게임 오브젝트 파괴를 처리한다. 에셋ID는 동적ID이거나 생성하는 프리팹 게임 오브젝트에서 발견된 에셋ID일 수 있다.

<br>

예)

Spawn/Unspawn delegate는 다음과 같다.

**Spawn Handler**

```cs
GameObject SpawnDelegate(Vector3 position, System.Guid assetId)
{
    // do stuff here
}
```

또는 

```cs
GameObject SpawnDelegate(SpawnMessage msg)
{
    // do stuff here
}
```

<br>

**UnSpawn Handler**

```cs
void UnSpawnDelegate(GameObject spawned)
{
    // do stuff here
}
```

Prefab이 저장되면 assetId 필드가 자동으로 설정된다. 실행 시 프리팹을 작성하려면 새로운 GUID를 생성해야한다.

<br>

### Generate Prefab At Runtime

```cs
// generate a new unique assetId 
System.Guid creatureAssetId = System.Guid.NewGuid();

// register handlers for the new assetId
NetworkClient.RegisterSpawnHandler(creatureAssetId, SpawnCreature, UnSpawnCreature);
```

#### Use existing prefab

```cs
// register prefab you'd like to custom spawn and pass in handlers
NetworkClient.RegisterPrefab(coinAssetId, SpawnCoin, UnSpawnCoin);
```

#### Spawn on Server

```cs
// spawn a coin - SpawnCoin is called on client
NetworkServer.Spawn(gameObject, coinAssetId);
```

생성 함수 자체는 delegate signature와 함께 구현된다.

예)

코인 생성기, SpawnCreature와 모습은 같지만 서로 다른 생성 로직을 가지고 있다.

```cs
public GameObject SpawnCoin(SpawnMessage msg)
{
    return Instantiate(m_CoinPrefab, msg.position, msg.rotation);
}

public void UnSpawnCoin(GameObject spawned)
{
    Destroy(spawned);
}
```

커스텀 spawn 함수를 사용할 때는 게임 오브젝트를 파괴하지 않고 Unspawn하는 것이 유용할 수 있다. 이를 수행하려면 NetworkServer.UnSpawn으로 호출해야한다. 이것에 의해 서버상에서 오브젝트가 초기화 되어 클라이언트에 ObjectDestroyMessage가 송신된다. ObjectDestroyMessage는 클라이언트에서 커스텀 unspawn 함수를 호출하는데 unspawn 함수가 없는 경우 오브젝트는 Destroy된다.

게임 오브젝트는 서버에 이미 존재하기 때문에 호스트에서는 로컬 클라이언트용으로 생성되지 않는다. 이는 spawn 또는 unspawn 핸들러 함수가 호출되지 않음을 의미한다.

<br>

### Pooling Game Objects

custom spawn handler를 사용하여 간단한 게임 오브젝트 풀링 시스템을 설정할 수 있다.

예)

spawn과 unspawn 게임 오브젝트를 수영장에 넣거나 수영장 밖으로 내보낸다.

```cs
using System.Collections.Generic;
using Mirror;
using UnityEngine;

namespace Mirror.Examples
{
    public class PrefabPoolManager : MonoBehaviour
    {
        [Header("Settings")]
        public int startSize = 5;
        public int maxSize = 20;
        public GameObject prefab;

        [Header("Debug")]
        [SerializeField] Queue pool;
        [SerializeField] int currentCount;


        void Start()
        {
            InitializePool();

            NetworkClient.RegisterPrefab(prefab, SpawnHandler, UnspawnHandler);
        }

        void OnDestroy()
        {
            NetworkClient.UnregisterPrefab(prefab);
        }

        private void InitializePool()
        {
            pool = new Queue();
            for (int i = 0; i < startSize; i++)
            {
                GameObject next = CreateNew();

                pool.Enqueue(next);
            }
        }

        GameObject CreateNew()
        {
            if (currentCount > maxSize)
            {
                Debug.LogError($"Pool has reached max size of {maxSize}");
                return null;
            }

            // use this object as parent so that objects dont crowd hierarchy
            GameObject next = Instantiate(prefab, transform);
            next.name = $"{prefab.name}_pooled_{currentCount}";
            next.SetActive(false);
            currentCount++;
            return next;
        }

        // used by NetworkClient.RegisterPrefab
        GameObject SpawnHandler(SpawnMessage msg)
        {
            return GetFromPool(msg.position, msg.rotation);
        }

        // used by NetworkClient.RegisterPrefab
        void UnspawnHandler(GameObject spawned)
        {
            PutBackInPool(spawned);
        }

        /// 
        /// Used to take Object from Pool.
        /// Should be used on server to get the next Object
        /// Used on client by NetworkClient to spawn objects
        /// 
        /// 
        /// 
        /// 
        public GameObject GetFromPool(Vector3 position, Quaternion rotation)
        {
            GameObject next = pool.Count > 0
                ? pool.Dequeue() // take from pool
                : CreateNew(); // create new because pool is empty

            // CreateNew might return null if max size is reached
            if (next == null) { return null; }

            // set position/rotation and set active
            next.transform.position = position;
            next.transform.rotation = rotation;
            next.SetActive(true);
            return next;
        }

        /// 
        /// Used to put object back into pool so they can b
        /// Should be used on server after unspawning an object
        /// Used on client by NetworkClient to unspawn objects
        /// 
        /// 
        public void PutBackInPool(GameObject spawned)
        {
            // disable object
            spawned.SetActive(false);

            // add back to pool
            pool.Enqueue(spawned);
        }
    }
}
```

이 관리자를 사용하려면 빈 게임 오브젝트를 새로 만들고 PrefabPoolManager 컴포넌트(위 코드)를 추가한다. 그런 다음 생성할 Prefab을 만들고 싶은 만큼 필드에 올려 startSize와 maxSize필드를 설정한다. startSize는 게임을 시작할 때 생성되는 최대 수이며 maxSize에 도달하고 새로운 오브젝트를 생성하려고 하면 오류가 발생한다.

마지막으로 플레이어의 이동에 사용하는 스크립트로 PrefabPoolManager에 대한 참조를 설정한다.

예)

```cs
PrefabPoolManager prefabPoolManager;

void Start()
{
    prefabPoolManager = FindObjectOfType();
}
```

플레이어 로직에는 코인의 이동과 발사에 대한것이 포함되어있을 수 있다.

```cs
void Update()
{
    if (!isLocalPlayer)
        return;
    
    // move
    var x = Input.GetAxis("Horizontal") * 0.1f;
    var z = Input.GetAxis("Vertical") * 0.1f;
    transform.Translate(x, 0, z);

    // shoot
    if (Input.GetKeyDown(KeyCode.Space))
    {
        // Command function is called on the client, but invoked on the server
        CmdFire();
    }
}
```

플레이어의 fire 로직은 게임 오브젝트 풀을 사용한다.

```cs
[Command]
void CmdFire()
{
    // Set up bullet on server
    GameObject bullet = prefabPoolManager.GetFromPool(transform.position + transform.forward, Quaternion.identity);
    bullet.GetComponent<Rigidbody>().velocity = transform.forward * 4;

    // tell server to send SpawnMessage, which will call SpawnHandler on client
    NetworkServer.Spawn(bullet);

    // destroy bullet after 2 seconds
    StartCoroutine(Destroy(bullet, 2.0f));
}

public IEnumerator Destroy(GameObject go, float delay)
{
    yield return new WaitForSeconds(delay);

    // return object to pool on server
    prefabPoolManager.PutBackInPool(go);

    // tell server to send ObjectDestroyMessage, which will call UnspawnHandler on client
    NetworkServer.UnSpawn(go);
}
```

위 Destroy 메서드는 게임 오브젝트를 풀로 되돌리는 방법을 보여준다. 이것으로 게임 오브젝트를 재사용할 수 있게 된다.