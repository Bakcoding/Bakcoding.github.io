---
title:  "Mirror Example - Tanks"
excerpt: "Network, Mirror, Example, Tanks"

categories:
  - Mirror
tags:
  - [Network, Mirror, Example, Tanks]

toc: true
toc_sticky: true
 
date: 2022-03-18
last_modified_at: 2023-06-05
---  

***

<br>

## Tanks Example

Asset > Mirror > Example > Tanks > Scenes > Scene

마우스와 A, W, D, Spacebar를 사용해서 상대 탱크를 공격하는 게임이다.

<br>

### Hierarchy

하이어라키 창

* Ground : 맵

* NetworkManager : 네트워크 매니저

* Spawn : 플레이어 스폰지점

게임을 플레이해서 host를 연결하면 Tank오브젝트가 생성된다. Tank는 플레이어 오브젝트로 자식으로 체력바 UI를 가지고 잇다.

체력바 UI는 Text Mesh를 사용하고 FaceCamera 스크립트로 항상 카메라를 바라보도록 만들어졌다.

![play](/assets/images/posting/20220318/gameplay.png)

```cs
// FaceCamera.cs
// Useful for Text Meshes that should face the camera.
using UnityEngine;

namespace Mirror.Examples.Tanks
{
    public class FaceCamera : MonoBehaviour
    {
        // LateUpdate so that all camera updates are finished.
        void LateUpdate()
        {
            transform.forward = Camera.main.transform.forward;
        }
    }
}
```

<br>

### NetworkManager

![networkmanager](/assets/images/posting/20220318/networkmanager.png)

따로 상속해서 사용하지 않고 Mirror의 NetworkManager 그대로 사용한다.

Player Prefab에 플레이어의 프리팹을 등록하고 Registered Spawnable Prefabs에는 탱크의 탄환 프리팹을 등록한다.

#### Tank Prefab

![tank](/assets/images/posting/20220318/tank-prefab.png)

*   Network Identity 

*   Network Transform

*   Network Transform Child

    Tank 오브젝트 자식의 Transform 값을 서버에 업데이트 한다.

    마우스를 회전하면 탱크의 상단부분이 움직이게 되는데 이 부위의 Transform의 변화도 동기화를 해주기 위해서 필요한 컴포넌트이다.

    ![turret](/assets/images/posting/20220318/turret.png)

    컴포넌트의 Target 필드에 해당 부위를 등록하면 값을 업데이트 한다.

*   Tank Script

    플레이어의 조작과 네트워크 동기화를 위한 스크립트이다.

*   Animator

*   Nav Mesh Agent

    플레이어의 움직임에 Nav Mesh Agent를 사용한다.

*   Sphere Collider

<br>

#### Tank Script

NetworkBehaviour를 상속한다.

사용할 변수들 중 health만 서버와 동기화하여 체력이 0이 될 때 즉시 처리될 수 있게 한다.

```cs
using UnityEngine;
using UnityEngine.AI;

namespace Mirror.Examples.Tanks
{
    public class Tank : NetworkBehaviour
    {
        [Header("Components")]
        public NavMeshAgent agent;
        public Animator animator;
        public TextMesh healthBar;
        public Transform turret;

        [Header("Movement")]
        public float rotationSpeed = 100;

        [Header("Firing")]
        public KeyCode shootKey = KeyCode.Space;
        public GameObject projectilePrefab;
        public Transform projectileMount;

        [Header("Stats")]
        [SyncVar] public int health = 4;
```


업데이트를 통해서 health의 값을 체력바에 갱신한다.


```cs
        void Update()
        {
            // always update health bar.
            // (SyncVar hook would only update on clients, not on server)
            healthBar.text = new string('-', health);
```

플레이어의 조작은 각 클라이언트에서 자신의 로컬 플레이어만 조작할 수 있게한다.

isLocalPlayer 플래그를 검사해서 조작 여부를 판단한다.


```cs
            // movement for local player
            if (isLocalPlayer)
            {
                // rotate
                float horizontal = Input.GetAxis("Horizontal");
                transform.Rotate(0, horizontal * rotationSpeed * Time.deltaTime, 0);

                // move
                float vertical = Input.GetAxis("Vertical");
                Vector3 forward = transform.TransformDirection(Vector3.forward);
                agent.velocity = forward * Mathf.Max(vertical, 0) * agent.speed;
                animator.SetBool("Moving", agent.velocity != Vector3.zero);

                // shoot
                if (Input.GetKeyDown(shootKey))
                {
                    CmdFire();
                }

                RotateTurret();
            }
        }
```

Command를 사용해서 서버에서 메서드가 호출되도록 한다.
탱크의 탄환은 서버에서 Spawn 된다.

```cs
        // this is called on the server
        [Command]
        void CmdFire()
        {
            GameObject projectile = Instantiate(projectilePrefab, projectileMount.position, projectileMount.rotation);
            NetworkServer.Spawn(projectile);
            RpcOnFire();
        }
```

Tank의 발사 애니메이션은 클라이언트에서 호출되도록 ClientRpc를 사용한다. RpcOnFire를 ClientRpc로 호출하게 되면 다른 모든 플레이어들 화면에서도 해당 탱크의 발사애니메이션 트리거가 동작한다.

```cs
        // this is called on the tank that fired for all observers
        [ClientRpc]
        void RpcOnFire()
        {
            animator.SetTrigger("Shoot");
        }
```

탄환의 충돌검사는 서버상에서 처리한다. 현재 스크립트의 탱크가 다른 플레이어가 발사한 탄환과 충돌했다면 health를 감소시킨다.

만약 health 값이 0이 된다면 서버상에서 해당 플레이어의 게임 오브젝트를 파괴시킨다.

```cs
        [ServerCallback]
        void OnTriggerEnter(Collider other)
        {
            if (other.GetComponent<Projectile>() != null)
            {
                --health;
                if (health == 0)
                    NetworkServer.Destroy(gameObject);
            }
        }
```

탱크의 상단부를 회전시킨다. 방식은 마우스의 위치에서 ray를 발사시켜 맵과 충돌하는 지점을 바라보도록 회전시킨다.

따라서 지형이 없는 위치에서 마우스를 움직여도 포신은 회전하지 않는다.




```cs
        void RotateTurret()
        {
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit, 100))
            {
                Debug.DrawLine(ray.origin, hit.point);
                Vector3 lookRotation = new Vector3(hit.point.x, turret.transform.position.y, hit.point.z);
                turret.transform.LookAt(lookRotation);
            }
        }
    }
}
```

<br>

#### Projectile Prefab

![projectile](/assets/images/posting/20220318/projectile.png)

<br>

*   Network Identity

    서버상에서 Spawn되기 때문에 필요하다.

*   Projectile Script

    탄환의 충돌과 라이프 사이클을 다룬다.

*   Capsule Collider

*   Rigidbody

<br>


#### Projectile Script

NetworkBehaviour를 상속한다.

탄환은 생성되는 순간 정면을 향해서 날라간다. 그리고 충돌이 없다면 일정시간 후 알아서 파괴되도록 처리한다.

탄환의 움직임은 Rigidbody를 사용해서 힘을 작용한다.

```cs
using UnityEngine;

namespace Mirror.Examples.Tanks
{
    public class Projectile : NetworkBehaviour
    {
        public float destroyAfter = 2;
        public Rigidbody rigidBody;
        public float force = 1000;
```

Projectile 스크립트는 탄환이 생성될 때 시작된다. 

따라서 플레이어가 발사를 누르게 되면 서버상에서 탄환이 Spawn되고 탄환은 NetworkBehaviour를 상속했기 때문에 바로 OnStartServer 가 호출된다.

즉 탄환의 라이프 사이클은 생성과 동시에 어떠한 충돌이 없어도 2초 뒤에 파괴된다. 탄환이 사라지지 않고 무한히 맵을 뻗어나가는것을 방지한다.

```cs
        public override void OnStartServer()
        {
            Invoke(nameof(DestroySelf), destroyAfter);
        }

        // set velocity for server and client. this way we don't have to sync the
        // position, because both the server and the client simulate it.
```

탄환은 생성되자마자 정면 방향으로 움직인다.

```cs
        void Start()
        {
            rigidBody.AddForce(transform.forward * force);
        }
```

Tank 스크립트에서 Command를 사용해서 플레이어가 발사시 네트워크상에서 탄환이 Spawn되도록 하였다.

따라서 총알의 파괴도 서버상에서 이루어진다.


```cs
        // destroy for everyone on the server
        [Server]
        void DestroySelf()
        {
            NetworkServer.Destroy(gameObject);
        }
```

탄환은 일단 무엇이든지 충돌이 있으면 파괴된다. 체력에 관한 처리는 Tank 스크립트에서 이루어진다.

```cs
        // ServerCallback because we don't want a warning
        // if OnTriggerEnter is called on the client
        [ServerCallback]
        void OnTriggerEnter(Collider co)
        {
            NetworkServer.Destroy(gameObject);
        }
    }
}
```
