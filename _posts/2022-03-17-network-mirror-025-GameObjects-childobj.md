---
title:  "Mirror Guide GameObjects - Child"
excerpt: "Network, Mirror, GameObjects, Child"

categories:
  - Mirror
tags:
  - [Network, Mirror, GameObjects, Child]

toc: true
toc_sticky: true
 
date: 2022-03-17
last_modified_at: 2023-06-05
---  

***

<br>

### Pickups, Drops, and Child Objects

Mirror에서는 오브젝트의 계층 내에서 복수의 Network Identity 컴포넌트를 지원할 수 없다. 따라서 플레이어 오브젝트는 무조건 Network Identity를 가져야하므로 그 자식들은 Network Identity를 가질 수 없다.  

그렇다면 어떤 무기가 장착되어 있는지 또는 네트워크에 연결된 씬 오브젝트를 집어들거나 떨어뜨리는 등 모든 클라이언트가 알아야 하고 동기화해야할 필요가 있는 오브젝트는 어떤식으로 처리해야하는지 살펴본다.

<br>

### Child Objects

우선 간단하게 플레이어의 팔 끝에 있는 손과 같이 플레이어 계층 아래 쪽에 있는 단일 연결 지점부터 살펴본다. 

플레이어 프리펩의 NetworkBehaviour에서 상속된 스크립트에는 인스펙터 창에서 할당할이 가능한 게임 오브젝트 참조, 플레이어가 보유하고 있는 것을 다양하게 선택할 수 있는 SyncVar와 새로운 값에 따라 보유 중인 아이템의 기술을 아트를 변경할 수 있는 Hook이 있다.

>주의
>아이템 프리팹은 아트일 뿐이다. 스크립트도 없고 네트워킹 컴포넌트도 없어야한다. 물론 플레이어 프리팹의 ClientRpc에서 참조와 호출이 가능한 MonoBehaviour 기반의 스크립트는 가능하다.

예)

아래의 이미지에서 카일은 빈 게임 오브젝트인 RightHand를 손목에 추가하고 몇 개의 프리팹(Ball, Box, Cylinder)을 장착하고 이를 처리하기 위한 플레이어 장비 스크립트를 가지고 있다. 

![kyle](/assets/images/posting/20220317/kyle.png)

<br>

인스펙터는 Player Equipment 스크립트, Network Transform Child 컴포넌트 이 두 곳의 Target에 할당된 RightHand를 표시하므로 필요에 따라 모든 클라이언트에 대해 접속 포인트의 상대적인 위치를 조정할 수 있다.

다음은 장착된 아이템의 변경을 처리하기 위한 플레이어 장비 스크립트와 몇 가지 고려해야할 사항들이다.

* 모든 아트 아이템을 디자인 타임에 첨부해 열거형을 근거로 활성화/ 비활성화할 수 있지만 이 방법은 수 많은 아이템에 대해서 잘 확장되지 않는다. 또한 애니메이션이나 특수 효과 등 게임에서의 동작에 관한 스크립트가 포함되어 있는 경우는 매우 빨리 볼 수 있기 때문에 이 예에서는 로컬로 인스턴스화와 파괴할 수 있다. 

* 항목과 부착점 사이의 위치 간격 띄우기를 다루지 않는다. 이 문제는 설계자가 설정할 수 있는 로컬 위치와 회전에 대한 public 필드 및 부모 부착점에 상대적인 로컬 좌표에 이러한 값을 적용하기 위한 Start에 약간의 코드가 있는 항목에 대한 단일 설명 스크립트에서 가장 잘 해결된다.

```cs
using UnityEngine;
using System.Collections;
using Mirror;

public enum EquippedItem : byte
{
    nothing,
    ball,
    box,
    cylinder
}

public class PlayerEquip : NetworkBehaviour
{
    public GameObject sceneObjectPrefab;

    public GameObject rightHand;

    public GameObject ballPrefab;
    public GameObject boxPrefab;
    public GameObject cylinderPrefab;

    [SyncVar(hook = nameof(OnChangeEquipment))]
    public EquippedItem equippedItem;

    void OnChangeEquipment(EquippedItem oldEquippedItem, EquippedItem newEquippedItem)
    {
        StartCoroutine(ChangeEquipment(newEquippedItem));
    }

    // Since Destroy is delayed to the end of the current frame, we use a coroutine
    // to clear out any child objects before instantiating the new one
    IEnumerator ChangeEquipment(EquippedItem newEquippedItem)
    {
        while (rightHand.transform.childCount > 0)
        {
            Destroy(rightHand.transform.GetChild(0).gameObject);
            yield return null;
        }

        switch (newEquippedItem)
        {
            case EquippedItem.ball:
                Instantiate(ballPrefab, rightHand.transform);
                break;
            case EquippedItem.box:
                Instantiate(boxPrefab, rightHand.transform);
                break;
            case EquippedItem.cylinder:
                Instantiate(cylinderPrefab, rightHand.transform);
                break;
        }
    }

    void Update()
    {
        if (!isLocalPlayer) return;

        if (Input.GetKeyDown(KeyCode.Alpha0) && equippedItem != EquippedItem.nothing)
            CmdChangeEquippedItem(EquippedItem.nothing);
        if (Input.GetKeyDown(KeyCode.Alpha1) && equippedItem != EquippedItem.ball)
            CmdChangeEquippedItem(EquippedItem.ball);
        if (Input.GetKeyDown(KeyCode.Alpha2) && equippedItem != EquippedItem.box)
            CmdChangeEquippedItem(EquippedItem.box);
        if (Input.GetKeyDown(KeyCode.Alpha3) && equippedItem != EquippedItem.cylinder)
            CmdChangeEquippedItem(EquippedItem.cylinder);
    }

    [Command]
    void CmdChangeEquippedItem(EquippedItem selectedItem)
    {
        equippedItem = selectedItem;
    }
}
```

<br>

### Dropping Items

이제 장착한 아이템을 네트워크 아이템으로 월드에 드롭할 수 있는 방법이 필요하다.

예)

먼저 위의 Update 메서드에 Input을 하나 더 추가하고 CmdDropItem 메서드를 추가한다.

```cs
void Update()
    {
        if (!isLocalPlayer) return;

        if (Input.GetKeyDown(KeyCode.Alpha0) && equippedItem != EquippedItem.nothing)
            CmdChangeEquippedItem(EquippedItem.nothing);
        if (Input.GetKeyDown(KeyCode.Alpha1) && equippedItem != EquippedItem.ball)
            CmdChangeEquippedItem(EquippedItem.ball);
        if (Input.GetKeyDown(KeyCode.Alpha2) && equippedItem != EquippedItem.box)
            CmdChangeEquippedItem(EquippedItem.box);
        if (Input.GetKeyDown(KeyCode.Alpha3) && equippedItem != EquippedItem.cylinder)
            CmdChangeEquippedItem(EquippedItem.cylinder);

        if (Input.GetKeyDown(KeyCode.X) && equippedItem != EquippedItem.nothing)
            CmdDropItem();
    }

[Command]
void CmdDropItem()
    {
        // Instantiate the scene object on the server
        Vector3 pos = rightHand.transform.position;
        Quaternion rot = rightHand.transform.rotation;
        GameObject newSceneObject = Instantiate(sceneObjectPrefab, pos, rot);

        // set the RigidBody as non-kinematic on the server only (isKinematic = true in prefab)
        newSceneObject.GetComponent<Rigidbody>().isKinematic = false;

        SceneObject sceneObject = newSceneObject.GetComponent<SceneObject>();

        // set the child object on the server
        sceneObject.SetEquippedItem(equippedItem);

        // set the SyncVar on the scene object for clients
        sceneObject.equippedItem = equippedItem;

        // set the player's SyncVar to nothing so clients will destroy the equipped child item
        equippedItem = EquippedItem.nothing;

        // Spawn the scene object on the network for all to see
        NetworkServer.Spawn(newSceneObject);
    }   
```

위에서 본 이미지는 아이템 프리팹의 컨테이너로 기능하는 프리팹에 할당되어 있는 SceneObjectPrefab 필드가 있다. SceneObject 프리팹에는 Player Equip 스크립트와 같은 SyncVar, SetEmpled가 있는 SceneObject 스크립트가 있다. 공유 열거 값을 매개 변수로 사용하는 항목이다.


<br

```cs
using UnityEngine;
using System.Collections;
using Mirror;

public class SceneObject : NetworkBehaviour
{
    [SyncVar(hook = nameof(OnChangeEquipment))]
    public EquippedItem equippedItem;

    public GameObject ballPrefab;
    public GameObject boxPrefab;
    public GameObject cylinderPrefab;

    void OnChangeEquipment(EquippedItem oldEquippedItem, EquippedItem newEquippedItem)
    {
        StartCoroutine(ChangeEquipment(newEquippedItem));
    }

    // Since Destroy is delayed to the end of the current frame, we use a coroutine
    // to clear out any child objects before instantiating the new one
    IEnumerator ChangeEquipment(EquippedItem newEquippedItem)
    {
        while (transform.childCount > 0)
        {
            Destroy(transform.GetChild(0).gameObject);
            yield return null;
        }

        // Use the new value, not the SyncVar property value
        SetEquippedItem(newEquippedItem);
    }

    // SetEquippedItem is called on the client from OnChangeEquipment (above),
    // and on the server from CmdDropItem in the PlayerEquip script.
    public void SetEquippedItem(EquippedItem newEquippedItem)
    {
        switch (newEquippedItem)
        {
            case EquippedItem.ball:
                Instantiate(ballPrefab, transform);
                break;
            case EquippedItem.box:
                Instantiate(boxPrefab, transform);
                break;
            case EquippedItem.cylinder:
                Instantiate(cylinderPrefab, transform);
                break;
        }
    }
}
```

아래의 런타임 이미지에서 Ball은 RightHand 오브젝트에 연결되고 Box는 SceneObject에 연결되며 이는 인스펙터에 표시된다.

![runtime](/assets/images/posting/20220317/runtime.png)

<br>

### Pickup Items

이제 떨어진 상자를 줍는다. 이를 위해서 CmdPickupItem 메서드가 플레이어 장비 스크립트에 추가된다.

```cs
// CmdPickupItem is public because it's called from a script on the SceneObject
[Command]
public void CmdPickupItem(GameObject sceneObject)
{
    // set the player's SyncVar so clients can show the equipped item
    equippedItem = sceneObject.GetComponent<SceneObject>().equippedItem;

    // Destroy the scene object
    NetworkServer.Destroy(sceneObject);
}
```

이 메서드는 장면 오브젝트의 스크립트로 OnMouseDown에서 호출된다.

```cs
void OnMouseDown()
    {
        NetworkClient.localPlayer.GetComponent<PlayerEquip>().CmdPickupItem(gameObject);
    }
```

SceneObject는 네트워크에 연결되어 있으므로 플레이어 개체의 CmdPickItem으로 직접 전달하여 장착된 항목 SyncVar를 설정하고 장면 오브젝트를 파괴할 수 있다.

이 전체 예에서 플레이어 외에 Network Manager에 등록해야 하는 유일한 프리팹은 SceneObject프리팹이다.