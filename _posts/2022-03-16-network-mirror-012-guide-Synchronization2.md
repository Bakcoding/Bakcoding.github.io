---
title:  "Mirror Guide Synchronization 2/3"
excerpt: "Network, Mirror, Synchronization, SyncVars, Hooks, SyncLists"

categories:
  - Mirror
tags:
  - [Network, Mirror, Synchronization, SyncVars, Hooks, SyncLists]

toc: true
toc_sticky: true
 
date: 2022-03-16
last_modified_at: 2022-03-16
---  

***

<br>

### SyncVars

NetworkBehaviours에서 상속받은 클래스의 속성으로 서버에서 클라이언트로 동기화된다. 

게임 오브젝트가 생성되거나 새로운 플레이어가 진행 중인 게임에 참여하면 네트워크 상에 보여지는 오브젝트의 모든 SyncVars가 최신 상태로 전송된다. SyncVar 커스텀 특성을 사용하면 스크립트에서 동기화할 변수를 지정한다.

SyncVars의 상태는 OnStartClient()가 호출되기 전에 클라이언트의 게임 오브젝트에 적용되므로 오브젝트의 상태는 항상 OnStartClient() 내에서 최신 상태로 유지된다. 

SyncVars는 Mirror에서 지원하는 모든 유형을 사용할 수 있다. SyncLists를 포함한 하나의 NetworkBehaviour 스크립트로 최대 64개의 SyncVar를 설정할 수 있다.

SyncVar 값이 변경되면 서버가 자동으로 SyncVar 업데이트를 전송하므로 사용자가 직접 변경 또는 변경에 대한 정보를 전송할 필요가 없다. 인스펙터에서 값이 변경돼도 업데이트가 트리거되지 않는다.

>SyncVar hooks 속성을 사용하여 SyncVar가 클라이언트에서 값을 변경할 때 호출되는 메서드를 지정할 수 있다.


<br>

#### SyncVars Example

예)

Enemy라는 네트워크 오브젝트가 있다.

```cs
public class Enemy : NetworkBehaviour
{
    [SyncVar]
    public int health = 100;

    void OnMouseUp()
    {
        NetworkIdentity ni = NetworkClient.connection.identity;
        PlayerController pc = ni.GetComponent<PlayerController>();
        pc.currentTarget = gameObject;
    }
}
```

PlayerController는 다음과 같다.

```cs
public class PlayerController : NetworkBehaviour
{
    public GameObject currentTarget;

    void Update()
    {
        if (isLocalPlayer)
            if (currentTarget != null &&currentTarget.tag == "Enemy")
                if (Input.GetKeyDown(KeyCode.X))
                    CmdShoot(currentTarget);
    }

    [Command]
    public void CmdShoot(GameObject enemy)
    {
        // Do your own shot validation here because this runs on the server
        enemy.GetComponent<Enemy>().health -= 5;
    }
}
```

이 예에서는 플레이어가 Enemy를 클릭하면 네트워크 에너미 게임 오브젝트가 PalyerController.currentTarget에 할당된다. 플레이어가 올바른 타겟을 선택한 상태에서 X를 누르면 서버에서 실행되는 Command를 통해 해당 타겟이 전달되어 상태 health SyncVar가 감소한다. 모든 클라이언트는 이 새로운 값으로 갱신되고 그 다음 적의 UI에 현재 값을 표시할 수 있다.

<br>

#### Class inheritance

SyncVars는 클래스 상속과 함께 동작한다.

```cs
class Pet : NetworkBehaviour
{
  [SyncVar]
  string name;
}

class Cat : Pet
{
  [SyncVar]
  public Color32 color;
}
```

Cat 컴포넌트를 Cat Prefab에 부착하면 Cat 컴포넌트는 Pet으로부터 상속된 name과 Cat에 작성된 color가 동기화된다.

>Warning!
>Cat과 Pet은 같은 어셈블리에 위치해야한다. 만일 어셈블리가 분리되어 있다면 Cat 내부에서 직접 이름을 변경하지 말고 Pet에 메서드를 추가한다.

<br>

### SyncVar Hooks

hook 속성을 사용하여 SyncVar 값이 클라이언트로 변경되었을 때 호출되는 함수를 지정할 수 있다.

* Hook 메서드에는 SyncVar 속성과 동일한 유형으로 하는 이전 값, 다른 하나는 새 값인 두 개의 매개변수가 있어야 한다. 

* Hook은 항상 속성 값이 설정된 후에 호출되므로 직접 설정할 필요는 없다.

* Hook은 변경된 값에 대해서만 부팅되며 인스펙터에서 값을 변경해도 업데이트가 트리거되지 않는다.

* Hook은 가상 메서드가 되어 파생 클래스에서 재정의될 수 있다. (version 11.1.4, March 2020 이후)

<br>

#### SyncVar Hooks Example

서버에서 생성된 각 플레이어에 임의의 색상을 할당한다.
모든 클라이언트는 게임 도중에 참가하더라도 모든 플레이어 색상이 올바르게 표시된다.

```cs
using UnityEngine;
using Mirror;

public class PlayerController : NetworkBehaviour
{
    [SyncVar(hook = nameof(SetColor))]
    Color playerColor = Color.black;

    // Unity makes a clone of the Material every time GetComponent().material is used.
    // Cache it here and Destroy it in OnDestroy to prevent a memory leak.
    Material cachedMaterial;

    public override void OnStartServer()
    {
        base.OnStartServer();
        playerColor = Random.ColorHSV(0f, 1f, 1f, 1f, 0.5f, 1f);
    }

    void SetColor(Color oldColor, Color newColor)
    {
        if (cachedMaterial == null)
            cachedMaterial = GetComponent().material;

        cachedMaterial.color = newColor;
    }

    void OnDestroy()
    {
        Destroy(cachedMaterial);
    }
}
```

<br>

#### Hook Call order

Hook은 파일에 정의된 순서대로 SyncVars를 호출한다.

```cs
public class MyBehaviour : NetworkBehaviour
{
  [SyncVar]
  int X;

  [SyncVar(hook = nameof(Hook1))]
  int Y;

  [SyncVar(hook = nameof(Hook2))]
  int Z;
}
```

X, Y, Z가 모두 동시에 서버에 설정되어 있는 경우 순서

1. X value is set

2. Y value is set

3. Hook1 is called

4. Z value is set

5. Hook2 is called

<br>

### SyncLists

C# List와 유사한 배열 기반 List로 서버에서 클라이언트로 콘텐츠를 동기화한다.

Mirror에서 지원하는 모든 타입은 SyncList에 포함될 수 있다.

<br>

#### Usage

NetworkBehaviour 클래스에 SyncList 필드를 추가한다.

>주의
>SyncList는 읽기 전용으로 선언되고 생성자에서 초기화되어야 한다.

예)

```cs
public struct Item
{
  public string name;
  public int amount;
  public Color32 color;
}

public class Player : NetworkBehaviour
{
  public readonly SyncList<Item> inventory = new SyncList<Item>();

  public int coins = 100;

  [Command]
  public void CmdPurchase(string itemName)
  {
    if (coins > 10)
    {
      coints -= 10;
      Item item = new Item
      {
        name = "Sword",
        amount = 3,
        color = new Color32(125, 125, 125, 255)
      };

      // during next synchronization, all clients will see the item inventory.Add(item);
      inventory.Add(item);
    }
  }
}
```

<br>

그리고 클라이언트나 서버에서 SyncList가 변경되는 경우에도 감지할 수 있다. 이 기능은 장비를 추가할 때 캐릭터를 새로 고치거나 또는 데이터베이스를 업데이트해야 할 시기를 결정할 때 유용하다. 보통 Start, OnClientStart 또는 OnServerStart 중에 콜백이벤트를 Subscribe 한다.

>주의
>Subscribe할 때 List는 이미 입력되어 있기 때문에 초기 데이터에 대한 콜은 수신되지 않고 업데이트만 수신된다.

예)

```cs
class Player : NetworkBehaviour {

    public override void OnStartClient()
    {
        inventory.Callback += OnInventoryUpdated;
        
        // Process initial SyncList payload
        for (int index = 0; index < inventory.Count; index++)
            OnInventoryUpdated(SyncList<Item>.Operation.OP_ADD, index, new Item(), inventory[index]);
    }

    void OnInventoryUpdated(SyncList<Item>.Operation op, int index, Item oldItem, Item newItem)
    {
        switch (op)
        {
            case SyncList<Item>.Operation.OP_ADD:
                // index is where it was added into the list
                // newItem is the new item
                break;
            case SyncList<Item>.Operation.OP_INSERT:
                // index is where it was inserted into the list
                // newItem is the new item
                break;
            case SyncList<Item>.Operation.OP_REMOVEAT:
                // index is where it was removed from the list
                // oldItem is the item that was removed
                break;
            case SyncList<Item>.Operation.OP_SET:
                // index is of the item that was changed
                // oldItem is the previous value for the item at the index
                // newItem is the new value for the item at the index
                break;
            case SyncList<Item>.Operation.OP_CLEAR:
                // list got cleared
                break;
        }
    }
}
```