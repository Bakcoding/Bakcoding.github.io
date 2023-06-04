---
title:  "Mirror Guide Communications - Remote Actions"
excerpt: "Network, Mirror, Communications, RPC"

categories:
  - Mirror
tags:
  - [Network, Mirror, Communications, RPC]

toc: true
toc_sticky: true
 
date: 2022-03-16
last_modified_at: 2023-06-05
---  

***

<br>

### Remote Actions

네트워크 시스템에는 네트워크 전체에서 작업을 수행하는 방법이 있다. 이러한 유형의 액션은 Remote Procedure Calls(RPC)라고 한다. 

RPC에는 2종류가 있다. 

* 클라이언트에서 호출되어 서버에서 실행되는 Command

* 서버에서 호출되어 클라이언트에서 실행되는 ClientRpc

![RPC](/assets/images/posting/20220316/RPC.png)

<br>

#### Commands

Commands는 플레이어 오브젝트에서 서버의 플레이어 오브젝트로 전송된다. 보안을 위해 Commands는 기본적으로 나의 플레이어 오브젝트로만 보내질 수 있으므로 다른 플레이어의 오브젝트를 제어할 수 없다. 

권하 확인을 생략할 수 있는 방법

```cs
[Command(requiresAuthority = false)]
```

함수를 Command로 만들려면 \[Command\] 사용자 지정 속성을 추가하고 선택적으로 명명 규칙을 위한 Cmd 접두사를 추가한다. 이 함수는 클라이언트에서 호출될 때 서버에서 실행된다. 이 때 허용되는 데이터 타입의 매개변수라면 Command를 사용하여 자동으로 서버에 전달된다. 

Commands 함수에는 접두사 Cmd가 있어야 하며 정적으로 선언될 수 없으며 Commands는 메서드를 호출하는 코드를 읽을 때 힌트이며 특수하고 일반 함수처럼 로컬에서 호출되지 않는다.

```cs
public class Player : NetworkBehaviour
{
    // assigned in inspector
    public GameObject cubePrefab;

    void Update()
    {
        if (!isLocalPlayer) return;

        if (Input.GetKey(KeyCode.X))
            CmdDropCube();
    }

    [Command]
    void CmdDropCube()
    {
        if (cubePrefab != null)
        {
            Vector3 spawnPos = transform.position + transform.forward * 2;
            Quaternion spawnRot = transform.rotation;
            GameObject cube = Instantiate(cubePrefab, spawnPos, spawnRot);
            NetworkServer.Spawn(cube);
        }
    }
}
```

프레임마다 클라이언트에서 명령을 보내기 때문에 많은 네트워크 트래픽이 발생할 수 있으니 주위해야한다.

<br>

#### ClientRpc Calls

ClientRpc Calls는 서버상의 오브젝트에서 클라이언트 상의 오브젝트로 전송된다. 생성된 NetworkIdentity를 가진 모든 서버 오브젝트에서 전송할 수 있다. 서버에 권한이 있기 때문에 서버 오브젝트가 이러한 호출을 송신할 수 있는 보안상의 문제는 없다.

함수를 ClientRpc 호출로 만들려면 \[ClientRpc\] 커스텀 속성을 추가하고 필요에 따라 명명 규칙을 위한 Rpc 프리픽스를 추가한다. 이 함수는 서버에서 호출될 때 클라이언트에서 실행된다. 허용된 데이터 타입의 매개변수는 ClientRpc 요청을 통해 클라이언트에 자동으로 전달된다.

ClientRpc 함수는 접두사 Rpc를 사용해야 하며 정적일 수 없다. Rpc는 메서드를 호출하는 코드를 읽을 때 힌트이며 특수하고 일반 함수처럼 로컬에서 호출되지 않는다.

```cs
public class Player : NetworkBehaviour
{
    int health;

    public void TakeDamage(int amount)
    {
        if (!isServer) return;

        health -= amount;
        RpcDamage(amount);
    }

    [ClientRpc]
    public void RpcDamage(int amount)
    {
        Debug.Log("Took damage:" + amount);
    }
}
```

게임을 로컬 클라이언트와 함께 호스트로서 실행하는 경우나 서버와 같은 프로세스에 있는 경우에도 ClientRpc는 로컬 클라이언트에서 호출된다. 따라서 로컬 클라이언트와 원격 클라이언트의 동작은 ClientRpc 호출과 동일하다.

<br>

#### Excluding Owner

ClientRpc 메시지는 오브젝트의 네트워크 가시성에 따라 오브젝트의 Observer에게만 전송된다. 플레이어 오브젝트는 항상 자신을 관찰한다. 경우에 따라서는 ClientRpc를 호출할 때 Owner 클라이언트를 제외할 수 있다. 

이 작업은 다음과 같이 수행된다. 

```cs
[ClientRpc(includeOwner = false)]
```

<br>

#### TargetRpc Calls

TargetRpc 함수는 서버상의 사용자 코드에 의해 호출되며 지정된 NetworkConnection 클라이언트의 대응하는 클라이언트 오브젝트에서 호출된다. RPC 호출에 대한 인수는 네트워크를 통해 직렬화되므로 클라이언트 함수는 서버상의 함수와 같은 값으로 호출된다. 이러한 함수는 명명 규칙의 접두사 Target으로 시작해야 하며 정적일 수 없다.

<br>

**Context에 대한 사항**  

* TargetRpc 메서드의 첫번째 매개변수가 NetworkConnection인 경우 Context에 관계없이 메시지를 수신하는 연결이다.

* 첫 번째 매개변수가 다른 타입일 경우 TargetRpc를 포함하는 스크립트를 가진 오브젝트를 가진 오브젝트의 Owner 클라이언트는 메시지를 받는다.

<br>

예)

클라이언트가 명령어를 사용하여 서버(CmdMagic)에 다른 플레이어의 요구를 포함하는 방법을 보여준다.

ConnectionToClient는 해당 명령에서 직접 호출된 TargetRpc의 매개변수 중 하나이다.

```cs
public class Player : NetworkBehaviour
{
    public int health;

    [Command]
    void CmdMagic(GameObject target, int damage)
    {
        target.GetComponent<Player>().health -= damage;

        NetworkIdentity opponentIdentity = target.GetComponent<NetworkIdentity>();
        TargetDoMagic(opponentIdentity.connectionToClient, damage);
    }

    [TargetRpc]
    public void TargetDoMagic(NetworkConnection target, int damage)
    {
        // This will appear on the opponent's client, not the attacking player's
        Debug.Log($"Magic Damage = {damage}");
    }

    // Heal thyself
    [Command]
    public void CmdHealMe()
    {
        health += 10;
        TargetHealed(10);
    }

    [TargetRpc]
    public void TargetHealed(int amount)
    {
        // No NetworkConnection parameter, so it goes to owner
        Debug.Log($"Health increased by {amount}");
    }
}
```

<br>

#### Arguments to Remote Actions

Commands와 ClientRpc 호출에 전달되는 인수는 직렬화되어 네트워크를 통해 전송된다. 인수는 Mirror에서 지원되는 타입 모든것을 사용할 수 있다.

Remote Actions에 대한 인수는 스크립트 인스턴스 또는 Transform과 같은 게임 오브젝트의 하위 구성 요소가 될 수 없다.