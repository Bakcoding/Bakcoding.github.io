---
title:  "Mirror Example - Pong"
excerpt: "Network, Mirror, Example, Pong"

categories:
  - Mirror
tags:
  - [Network, Mirror, Example, Pong]

toc: true
toc_sticky: true
 
date: 2022-03-18
last_modified_at: 2022-03-18
---  

***

<br>

## Pong Example

Assets > Mirror > Example > Pong > Scenes > Scene

고전 게임 Pong을 유니티 엔진으로 구현한 게임이다.

W, S (UpArrow, DownArrow) 로 움직인다.

<br>

### Hierarchy 

![hierarchy](/assets/images/20220318_Posting/pong_hierarchy.png)

<br>

*   NetworkManager

    Network Manager를 상속한 Network Manager Pong 스크립트를 가지고 있다. 

    Pong은 2인용 게임이기 때문에 Max Connections 를 2로 해준다.

    Player Prefab에는 플레이어인 Racket 프리팹이 등록되어있고 Registered Spawnable Prefabs에는 공 Ball 프리팹이 등록되어있다.

*   Table 

    게임의 맵이다.

*   RacketSpawnLeft/RacketSpawnRight

    플레이어 Spawn 지점이다.


게임을 플레이하면 플레이어(Racket)이 생성된다.

![hierarchy](/assets/images/20220318_Posting/pong_play.png)

<br>

### Network Manager Pong Script

NetworkManager를 상속받은 스크립트로 게임의 전반적인 네트워크 동작을 구현한다.

플레이어의 스폰지점인 leftRacketSpawn, rightRacketSpawn 을 참조하여 플레이어를 Spawn한다.

그리고 게임을 플레이하는데 중요한 Ball 오브젝트의 생성도 처리한다.

```cs
using UnityEngine;

/*
	Documentation: https://mirror-networking.gitbook.io/docs/components/network-manager
	API Reference: https://mirror-networking.com/docs/api/Mirror.NetworkManager.html
*/

namespace Mirror.Examples.Pong
{
    // Custom NetworkManager that simply assigns the correct racket positions when
    // spawning players. The built in RoundRobin spawn method wouldn't work after
    // someone reconnects (both players would be on the same side).
    [AddComponentMenu("")]
    public class NetworkManagerPong : NetworkManager
    {
        public Transform leftRacketSpawn;
        public Transform rightRacketSpawn;
        GameObject ball;
```

OnServerAddPlayer는 서버에 클라이언트가 추가될 때마다 호출된다.

클라이언트가 참가를하게되면 해당 플레이어를 생성한다. 생성 위치는 left, right Spawn지점으로 처음 입장시 leftRacketSpawn으로 생성한다.

NetworkServer.AddPlayerForConnection은 AddPlayer 메시지를 서버에 보낸 후 서버에서 호출하여 연결 플레이어를 추가한다.

연결을 위한 플레이어가 추가될 때 해당 클라이언트는 자동으로 Ready 상태가 된다. 플레이어 오브젝트는 자동으로 Spawn되기 때문에 NetworkServer.Spawn을 호출할 필요가 없다.

만약 해당 playerControllerId의 플레이어가 이미 존재한다면 이 동작은 실패하게된다. 따라서 플레이어를 교체하는 작업으로 사용할 수 없다. (이 경우 replace 사용)

```cs
        public override void OnServerAddPlayer(NetworkConnectionToClient conn)
        {
            // add player at correct spawn position
            Transform start = numPlayers == 0 ? leftRacketSpawn : rightRacketSpawn;
            GameObject player = Instantiate(playerPrefab, start.position, start.rotation);
            NetworkServer.AddPlayerForConnection(conn, player);
```

<br>

플레이어가 2명이 되면 ball을 네트워크 상에서 생성한다.

```cs
            // spawn ball if two players
            if (numPlayers == 2)
            {
                ball = Instantiate(spawnPrefabs.Find(prefab => prefab.name == "Ball"));
                NetworkServer.Spawn(ball);
            }
        }
```

<br>

OnServerDisconnect는 서버의 연결이 해제되면 호출된다.

ball을 파괴하고 base.OnServerDisconnect를 호출한다.

```cs
        public override void OnServerDisconnect(NetworkConnectionToClient conn)
        {
            // destroy ball
            if (ball != null)
                NetworkServer.Destroy(ball);

            // call base functionality (actually destroys the player)
            base.OnServerDisconnect(conn);
        }
    }
}
```

<br>

### Player Script

NetworkBehaviour를 상속한다.

플레이어의 움직임을 관리한다. 

```cs
using UnityEngine;

namespace Mirror.Examples.Pong
{
    public class Player : NetworkBehaviour
    {
        public float speed = 30;
        public Rigidbody2D rigidbody2d;
```

FixedUpdate에서 로컬 플레이어를 검사하여 움직임을 처리한다. rigidbody2d의 velocity값을 조절하는 방식으로 움직인다.


```cs
        // need to use FixedUpdate for rigidbody
        void FixedUpdate()
        {
            // only let the local player control the racket.
            // don't control other player's rackets
            if (isLocalPlayer)
                rigidbody2d.velocity = new Vector2(0, Input.GetAxisRaw("Vertical")) * speed * Time.fixedDeltaTime;
        }
    }
}
```

<br>

### Ball Script

NetworkBehaviour를 상속한다.

ball이 생성되었을 때 그리고 플레이어와 충돌을 처리한다.


```cs
using UnityEngine;

namespace Mirror.Examples.Pong
{
    public class Ball : NetworkBehaviour
    {
        public float speed = 30;
        public Rigidbody2D rigidbody2d;
```

OnStartServer가 호출되면 base.OnStartServer를 호출하고 rigidbody2d.simulated 옵션을 true로 한다. 

**Simulated true**  

* 시뮬레이션을 통해 Rigidbody2D 이동(중력 및 물리력 적용)한다.

* 부착된 모든 Collider2D는 계속해서 새로운 접촉점이 생성되고 지속적으로 접촉점을 검사해야한다.

* 부착된 모든 Joint2D를 Simulated하고 Rigidbody2D부착을 강요한다.

* 리지드바디 2D, 충돌기 2D 및 조인트 2D의 모든 내부 물리학 물체가 메모리에 남아 있음

**Simulated false**

* 강체 2D는 시뮬레이션에 의해 움직이지 않는다(중력 및 물리력은 적용되지 않음)

* 강체 2D는 새로운 접점을 만들지 않으며, 부착된 모든 충돌체 2D 접점은 파괴된다.

* 부착된 조인트 2D는 시뮬레이션되지 않으며 부착된 강체 2Ds를 구속하지 않는다.

* 리지드바디 2D, 충돌기 2D 및 조인트 2D의 모든 내부 물리학 물체는 메모리에 남아 있다.

```cs
        public override void OnStartServer()
        {
            base.OnStartServer();

            // only simulate ball physics on server
            rigidbody2d.simulated = true;

            // Serve the ball from left player
            rigidbody2d.velocity = Vector2.right * speed;
        }

        float HitFactor(Vector2 ballPos, Vector2 racketPos, float racketHeight)
        {
            // ascii art:
            // ||  1 <- at the top of the racket
            // ||
            // ||  0 <- at the middle of the racket
            // ||
            // || -1 <- at the bottom of the racket
            return (ballPos.y - racketPos.y) / racketHeight;
        }

        // only call this on server
        [ServerCallback]
        void OnCollisionEnter2D(Collision2D col)
        {
            // Note: 'col' holds the collision information. If the
            // Ball collided with a racket, then:
            //   col.gameObject is the racket
            //   col.transform.position is the racket's position
            //   col.collider is the racket's collider

            // did we hit a racket? then we need to calculate the hit factor
            if (col.transform.GetComponent<Player>())
            {
                // Calculate y direction via hit Factor
                float y = HitFactor(transform.position,
                                    col.transform.position,
                                    col.collider.bounds.size.y);

                // Calculate x direction via opposite collision
                float x = col.relativeVelocity.x > 0 ? 1 : -1;

                // Calculate direction, make length=1 via .normalized
                Vector2 dir = new Vector2(x, y).normalized;

                // Set Velocity with dir * speed
                rigidbody2d.velocity = dir * speed;
            }
        }
    }
}
```
