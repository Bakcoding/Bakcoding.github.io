---
title:  "Mirror Guide GameObjects - Spawning GameObjects"
excerpt: "Network, Mirror, GameObjects, Spawning-GameObjects"

categories:
  - Mirror
tags:
  - [Network, Mirror, GameObjects, Spawning-GameObjects]

toc: true
toc_sticky: true
 
date: 2022-03-17
last_modified_at: 2022-03-17
---  

***

<br>

### Spawning GameObjects

Unity에서 Spawn은 보통 새로운 게임 오브젝트를 Instantiate 하는것을 뜻한다. 하지만 Mirror에서는 Spawn은 더 구체적이다. 

#### Spawning system

Mirror의 server-authoritative model에서 Spawn은 서버상의 게임오브젝트를 뜻한다. 그리고 서버상의 게임 오브젝트는 서버와 연결된 클라이언트에서 생성되고 Spawning system의 관리를 받는 게임 오브젝트를 말한다. 이 시스템을 사용하여 게임 오브젝트가 생성되면 서버 상에서 게임 오브젝트가 변경될 때마다 클라이언트에 상태 갱신이 전송된다. Mirror는 서버상의 게임 오브젝트를 파괴하면 클라이언트상의 게임 오브젝트도 파괴한다. 

서버는 생성된 게임 오브젝트를 다른 모든 네트워크 게임 오브젝트와 함께 관리하고 다른 클라이언트가 나중에 게임에 참여하게 되면 서버는 해당 클라이언트에서 게임 오브젝트를 생성할 수 있다.

<br>

#### netId

생성된 게임 오브젝트는 netId라는 고유한 인스턴스 ID를 가지며 이는 각 게임 오브젝트마다 서버와 클라이언트가 동일한 값을 가진다. 이 ID는 네트워크를 통해 설정된 메시지를 게임 오브젝트에 라우팅하고 게임 오브젝트를 식별하기 위해 사용된다.

서버가 Network Identity 컴포넌트를 사용해서 게임 오브젝트를 생성할 때 게임 오브젝트는 클라이언트와 동일한 상태가 된다. 즉 서버상의 게임 오브젝트와 동일하단 것은 Transform, movement state(Network Transform이나 SyncVars 사용하는 경우)와 동기 변수가 동일하다는 것이다.

따라서 클라이언트 게임 오브젝트는 Mirror가 게임 오브젝트를 만들 때 항상 최신 상태가 된다. 이렇게 하면 게임 오브젝트가 잘못된 초기 위치에서 생성된 다음 상태 업데이트가 도착했을 때 올바른 위치에 다시 나타나는 등의 문제를 피할 수 있다.

<br>

### Spawning Without Network Manager

숙련된 사용자라면 NetworkManager 컴포넌트를 사용하지 않고 프리팹을 등록하고 게임 오브젝트를 생성할 수 있다.


예)

NetworkManager를 사용하지 않고 게임 오브젝트를 생성하려면 우선 스크립트를 통해 프리팹 등록을 직접 처리할 수 있어야한다. NetworkClient.RegisterPrefab 메서드를 사용해서 프리팹을 NetworkManager에 등록한다.

```cs
using UnityEngine;
using Mirror;

public class MyNetworkManager : MonoBehaviour 
{
    public GameObject treePrefab;

    // Register prefab and connect to the server  
    public void ClientConnect()
    {
        NetworkClient.RegisterPrefab(treePrefab);
        NetworkClient.RegisterHandler<ConnectMessage>(OnClientConnect);
        NetworkClient.Connect("localhost");
    }

    void OnClientConnect(ConnectMessage msg)
    {
        Debug.Log("Connected to server: " + conn);
    }
}
```

<br>

여기서 Networkanager의 기능을 하는 빈 게임 오브젝트를 만든 후 MyNetworkManager 스크립트를 생성하여 해당 게임 오브젝트에 붙인다. Network Identity 컴포넌트가 있는 프리팹을 생성하여 인스펙터 창의 MyNetwork Manager 컴포넌트에 있는 treePrefab 슬롯으로 드래그한다. 이렇게 하면 서버가 트리 게임 오브젝트를 생성할 때 클라이언트상에 같은 종류의 게임 오브젝트를 작성할 수 있게 된다.


예)

프리팹을 등록하면 에셋을 생성하기 위한 시간 지연이나 로딩 시간이 발생하지 않는 장점이 있다. 스크립트가 제대로 작동하려면 서버의 코드도 추가해야한다.

```cs
public void ServerListen()
{
    NetworkServer.RegisterHandler<ConnectMessage>(OnServerConnect);
    NetworkServer.RegisterHandler<ReadyMessage>(OnClientReady);

    // start listening, and allow up to 4 connections
    NetworkServer.Listen(4);
}

// When client is ready spawn a few trees  
void OnClientReady(NetworkConnection conn, ReadyMessage msg)
{
    Debug.Log("Client is ready to start: " + conn);
    NetworkServer.SetClientReady(conn);
    SpawnTrees();
}

void SpawnTrees()
{
    int x = 0;
    for (int i = 0; i < 5; ++i)
    {
        GameObject treeGo = Instantiate(treePrefab, new Vector3(x++, 0, 0), Quaternion.identity);
        NetworkServer.Spawn(treeGo);
    }
}

void OnServerConnect(NetworkConnection conn, ConnectMessage msg)
{
    Debug.Log("New client connected: " + conn);
}
```

서버는 생성되는 게임 오브젝트를 알고 있기 때문에 아무것도 등록할 필요가 없다. (에셋 ID가 생성 메시지로 전송된다.) 클라이언트는 게임 오브젝트를 조회할 수 있어야 하므로 클라이언트에 등록해야한다.

자신만의 네트워크 매니저를 작성할 때는 서버에서 spawn command를 호출하기 전에 클라이언트가 상태 업데이트를 수신할 수 있도록 하는 것이 중요하다. 그렇지 않으면 업데이트가 전송되지 않는다. Mirror가 기본적으로 제공하는 Network Manager 컴포넌트를 사용할 경우에는 이 작업이 자동으로 수행된다.

더 숙련된 사용자라면 NetworkClient.RegisterSpawnHandler 메서드를 통해 오브젝트 풀 이나 동적으로 에셋을 생성하는 것처럼 클라이언트 측에서 생성을 위한 콜백 함수를 등록하는것도 가능하다.

<br>


예)

게임 오브젝트가 동기 변수와 같은 네트워크 상태를 가지고 있는 경우 그 상태는 생성 메시지와 동기화 된다. 

```cs
using UnityEngine;
using Mirror;

class Tree : NetworkBehaviour
{
    [SyncVar]
    public int numLeaves;

    public override void OnStartClient()
    {
        Debug.Log("Tree spawned with leaf count " + numLeaves);
    }
}
```

<br>

여기서 numLeaves 변수와 pawnTree 함수를 변경하는 코드를 추가하면 클라이언트에 정확하게 반영되도록 할 수 있다.

```cs
void SpawnTrees()
{
    int x = 0;
    for (int i = 0; i < 5; ++i)
    {
        GameObject treeGo = Instantiate(treePrefab, new Vector3(x++, 0, 0), Quaternion.identity);
        Tree tree = treeGo.GetComponent<Tree>();
        tree.numLeaves = Random.Range(10,200);
        Debug.Log("Spawning leaf with leaf count " + tree.numLeaves);
        NetworkServer.Spawn(treeGo);
    }
}
```

<br>

### Game Object Creation Flow

게임 오브젝트의 생성 흐름은 다음과 같다.

* Network Identity 컴포넌트를 포함하고 있는 프리팹은 생성가능한 것으로 등록된다.

* 서버의 프리팹으로 게임 오브젝트는 인스턴스화된다.

* 게임 코드는 인스턴스의 초기 값을 설정한다. (3D 물리는 즉시 적용되지 않는다.)

* NetworkServer.Spawn은 인스턴스와 함께 호출된다.

* 서버상의 인스턴스의 SyncVars의 상태는 \[NetworkBehaviour\] 컴포넌트에서 OnSerialize를 호출하여 수집된다.  

* ObjectSpawn 타입의 네트워크 메시지는 SyncVar 데이터를 포함하는 연결된 클라이언트로 전송된다.

* OnStartServer는 서버의 인스턴스에서 호출되며 isServer는 true로 설정된다.

* 클라이언트는 ObjectSpawn 메시지를 수신하고 등록된 프리팹에 새 인스턴스를 만든다.

* SyncVar 데이터는 NetworkBehaviour 컴포넌트의 OnDeserialize에 의해서 호출되며 클라이언트의 새 인스턴스에 적용된다. 

* OnStartClient는 각 클라이언트의 인스턴스에서 호출되며 isClient는 true로 설정된다.

* 게임 플레이가 진행됨에 따라 SyncVar 값에 대한 변경 내용이 클라이언트에 자동으로 동기화된다. 이것은 게임이 끝날 때까지 계속된다.

* NetworkServer.Destroy는 서버의 인스턴스에서 호출된다.

* OnStopServer는 서버의 인스턴에서 호출된다.

* ObjectDestroy 타입의 네트워크 메시지는 클라이언트에게 전송된다.

* OnStopClient는 클라이언트의 인스턴스에서 호출된다.

* 인스턴스의 파괴 또는 비활성화

<br>

### Player Game Object

HLAPI의 플레이어 게임 오브젝트는 none-player 게임 오브젝트와 다소 다르게 동작한다. Network Manager를 사용하여 플레이어 게임 오브젝트를 생성하는 흐름은 다음과 같다.

* NetworkIdentity를 가진 프리팹은 플레이어 프리팹으로 등록된다.

* 클라이언트는 서버와 연결된다.

* 클라이언트에서 AddPlayer를 호출하고 MsgType.AddPlayer 네트워크 메시지를 서버에 전송한다.

* 서버는 메시지를 받고 NetworkManager.OnServerAddPlayer를 호출한다.

* 게임 오브젝트는 서버의 플레이어 프리팹으로 인스턴스화된다.

* NetworkManager.AddPlayerForConnection은 서버에 새로운 플레이어의 인스턴스로 호출된다.

* 플레이어의 인스턴스가 생성된다. 플레이어 인스턴스를 위해서 NetworkServer.Spawn를 호출할 필요는 없다. Spanw Message는 일반 Spawn과 마찬가지로 모든 클라이언트에 전송된다.

* Owner 타입의 네트워크 메시지는 플레이어를 추가한 클라이언트로 전송된다. (해당 클라이언트에만 전송)

* 원래 클라이언트가 네트워크 메시지를 수신한다.

* OnStartLocalPlayer는 원래 클라이언트의 플레이어 인스턴스에서 호출되며 isLocalPlayer는 true로 설정된다.

<br>

OnStartLocalPlayer는 OnStartClient에서 호출된다. 이는 플레이어 게임 오브젝트가 생성된 후 서버에서 소유권 메시지가 도착했을 때만 발생하므로 OnStartClient에서 isLocalPlayer가 설정되지 않기 때문이다. 

OnStartLocalPlayer는 오직 클라이언트의 로컬 플레이어 게임 오브젝트에서만 호출되기 때문에 로컬 플레이어에서만 수행되어야 하는 초기화를 하기에 좋다. 여기에는 플레이어 게임 오브젝트에 대한 입력 처리 및 카메라 추적 활성화가 포함된다.

게임 오브젝트를 생성하고 해당 게임 오브젝트의 권한을 특정 클라이언트에 할당하려면 NetworkServer를 사용한다. 권한으로 하는 클라이언트의 NetworkConnection을 인자로 사용한다.

이러한 게임 오브젝트의 경우 권한이 있는 클라이언트에서 hasAuthority 속성이 true이고 OnStart가 true이다. 권한이 있는 클라이언트에서 권한이 호출된다. 해당 클라이언트는 게임 오브젝트에 Commands를 발행하고 다른 클라이언트 및 호스트에서는 hasAuthority가 false이다.


클라이언트의 권한으로 생성된 오브젝트에는 NetworkIdentity에 설정된 LocalPlayerAuthority가 있어야한다. 

예)

다음 클라이언트 권한을 트리에 부여하도록 변경할 수 있다. 게임 오브젝트를 소유하는 클라이언트의 연결을 위해 전달해야한다.

```cs
void SpawnTrees(NetworkConnection conn)
{
    int x = 0;
    for (int i = 0; i < 5; ++i)
    {
        GameObject treeGo = Instantiate(treePrefab, new Vector3(x++, 0, 0), Quaternion.identity);
        Tree tree = treeGo.GetComponent<Tree>();
        tree.numLeaves = Random.Range(10,200);
        Debug.Log("Spawning leaf with leaf count " + tree.numLeaves);
        NetworkServer.Spawn(treeGo, conn);
    }
}
```

위 스크립트를 수정하여 서버에 Command를 전송할 수 있도록 수정한다.

```cs
public override void OnStartAuthority()
{
    CmdMessageFromTree("Tree with " + numLeaves + " reporting in");
}

[Command]
void CmdMessageFromTree(string msg)
{
    Debug.Log("Client sent a tree message: " + msg);
}
```

CmdMessageFromTree 호출은 OnStartClient에 추가할 수 없다. 왜냐하면 그 시점에서 아직 권한이 설정되지 않았기 때문에 호출이 실패한다.

<br>