---
title:  "Mirror Guide Synchronization 3/3"
excerpt: "Network, Mirror, Synchronization, SyncDictionary, SyncHashSet, SyncSortedSet"

categories:
  - Mirror
tags:
  - [Network, Mirror, Synchronization, SyncDictionary, SyncHashSet, SyncSortedSet]

toc: true
toc_sticky: true
 
date: 2022-03-16
last_modified_at: 2022-03-16
---  

***

<br>

### SyncDictionary

Key와 Value의 쌍으로 순서가 매겨지지 않는 List를 포함하는 연관 배열이다. Key와 Value는 Mirror에서 지원되는 타입 어느것이라도 가능하다.

기본적으로 .Net의 Dictionaty를 사용하며 Key와 Value에 대해서 추가적으로 제한을 걸 수 있다.

SyncDictionary는 SyncLists와 동일하게 서버에서 변경을 하면 변경 내용이 모든 클라이언트에 전파되고 콜백이 호출된다.

<br>

#### Usage

SyncDictionary 유형의 NetworkBehaviour 클래스에 필드를 추가한다.

>주의1
>SyncDictionary는 readonly로 선언되고 생성자에서 초기화되어야 한다.

>주의2
>콜백을 Subscribe할 때 Dictionary는 이미 초기화되므로 초기 데이터에 대한 호출은 수신되지 않고 업데이트만 수신된다.

<br>

예)

```cs
using UnityEngine;
using Mirror;

public struct Item
{
    public string name;
    public int hitPoints;
    public int durability;
}

public class ExamplePlayer : NetworkBehaviour
{
    public readonly SyncDictionary<string, Item> Equipment = new SyncDictionary<string, Item>();

    public override void OnStartServer()
    {
        Equipment.Add("head", new Item { name = "Helmet", hitPoints = 10, durability = 20 });
        Equipment.Add("body", new Item { name = "Epic Armor", hitPoints = 50, durability = 50 });
        Equipment.Add("feet", new Item { name = "Sneakers", hitPoints = 3, durability = 40 });
        Equipment.Add("hands", new Item { name = "Sword", hitPoints = 30, durability = 15 });
    }

    public override void OnStartClient()
    {
        // Equipment is already populated with anything the server set up
        // but we can subscribe to the callback in case it is updated later on
        equipment.Callback += OnEquipmentChange;

        // Process initial SyncDictionary payload
        foreach (KeyValuePair<string, Item> kvp in equipment)
            OnEquipmentChange(SyncDictionary<string, Item>.Operation.OP_ADD, kvp.Key, kvp.Value);
    }

    void OnEquipmentChange(SyncDictionary<string, Item>.Operation op, string key, Item item)
    {
        switch (op)
        {
            case SyncIDictionary<string, Item>.Operation.OP_ADD:
                // entry added
                break;
            case SyncIDictionary<string, Item>.Operation.OP_SET:
                // entry changed
                break;
            case SyncIDictionary<string, Item>.Operation.OP_REMOVE:
                // entry removed
                break;
            case SyncIDictionary<string, Item>.Operation.OP_CLEAR:
                // Dictionary was cleared
                break;
        }
    }
}
```

<br>

예)

기본적으로 SyncDictionary는 Dictionary를 사용하여 데이터를 저장한다. SortedList나 SortedDictionary와 같은 IDictionary를 구현하려면 SyncIDictionary에 사용하려는 dictionary 인스턴스를 전달한다. 

```cs
public class ExamplePlayer : NetworkBehaviour
{
    public readonly SyncIDictionary Equipment = 
        new SyncIDictionary(new SortedList());
}
```

<br>

### SyncHashSet

SyncHashSet은 C# HashSet과 유사하며 서버에서 클라이언트로 콘텐츠를 동기화한다. SyncHashSet은 Mirror에서 지원되는 어떠한 타입도 포함할 수 있다.

<br>

#### Usage

>주의
>SyncHashSet은 반드시 readonly로 선언되며 생성자에서 초기화 되어야 한다.

예)

NetworkBehaviour 클래스 필드에 SyncHashSet을 추가한다.

```cs
public class Player : NetworkBehaviour 
{
  [SerializeField]
  public readonly SyncHashSet<string> skills = new SyncHashSet<string>();

  int skillPoints = 10;

  [Command]
  public void CmdLearnSkill(string skillName)
  {
    if (skillPoints > 1)
    {
      skillPoints--;
      skills.Add(skillName);
    }
  }
}
```

<br>

SyncHashSet이 변경되는 경우 감지할 수 있다. 클라이언트의 캐릭터를 새로 고치거나 데이터베이스를 갱신해야할 시기를 결정할 때 유용하다.

보통 Start, OnClientStart 또는 OnServerStart 중에 콜백 이벤트를 Subscribe한다.

>주의
>Subscribe 할 때는 Set은 이미 채워져 있기 때문에 초기 데이터에 대한 콜은 수신되지 않고 업데이트만 수신된다.

예)

```cs
public class Player : NetworkBehaviour
{
    [SerializeField]
    public readonly SyncHashSet<string> buffs = new SyncHashSet<string>();

    // this will add the delegate on the client.
    // Use OnStartServer instead if you want it on the server
    public override void OnStartClient()
    {
        buffs.Callback += OnBuffsChanged;

        // Process initial SyncHashSet payload
        foreach (string buff in buffs)
            OnBuffsChanged(SyncSet<string>.Operation.OP_ADD, buff);
    }

    // SyncHashSet inherits from SyncSet so use SyncSet here
    void OnBuffsChanged(SyncSet<string>.Operation op, string buff)
    {
        switch (op)
        {
            case SyncSet<string>.Operation.OP_ADD:
                // Added a buff to the character
                break;
            case SyncSet<string>.Operation.OP_REMOVE:
                // Removed a buff from the character
                break;
            case SyncSet<string>.Operation.OP_CLEAR:
                // Cleared all buffs from the character
                break;
        }
    }
}
```

<br>

### SyncSortedSet

SyncSortedSet은 C#의 SortedSet과 유사하며 서버에서 클라이언트로 콘텐츠를 동기화한다.

SyncHashset과 달리 SyncSortedSet의 모든 요소는 삽입 시 정렬되며 여기에는 몇 가지 성능 문제가 있다.

Mirror에서 지원되는 어떠한 타입도 SyncSortedSet에 포함될 수 있다.

<br>

#### Usage

>주의
>SyncSortedSet은 반드시 readonly로 선언하며 생성자로 초기화 되어야 한다.

예)

NetworkBehaviour 클래스 필드에 SyncSortedSet을 추가한다.

```cs
class Player : NetworkBehaviour
{
    public readonly SyncSortedSet<string> skills = new SyncSortedSet<string>();
    int skillPoints = 10;

    [Command]
    public void CmdLearnSkill(string skillName)
    {
        if (skillPoints > 1)
        {
            skillPoints--;
            skills.Add(skillName);
        }
    }
}
```

<br>

SyncSortedSet이 변경되는 경우에 감지할 수 있어 클라이언트의 캐릭터를 새로 고치거나 데이터베이스를 갱신해야 할 시기를 결정할 때 유용하다.

보통 Start, OnClientStart 또는 OnServerStart 중에 콜백 이벤트를 Subscribe한다.

>주의
>Subscribe할 때 Set은 이미 초기화되어 있기 때문에 초기 데이터에 대한 콜은 수신되지 않고 업데이트만 수신된다.


```cs
class Player : NetworkBehaviour
{
    [SerializeField]
    public readonly SyncSortedSet<string> buffs = new SyncSortedSet<string>();

    // this will add the delegate on the client.
    // Use OnStartServer instead if you want it on the server
    public override void OnStartClient()
    {
        buffs.Callback += OnBuffsChanged;

        // Process initial SyncSortedSet payload
        foreach (string buff in buffs)
            OnBuffsChanged(SyncSortedSet<string>.Operation.OP_ADD, buff);
    }

    // SyncSortedSet inherits from SyncSet so use SyncSet here
    void OnBuffsChanged(SyncSortedSet<string>.Operation op, string buff)
    {
        switch (op)
        {
            case SyncSortedSet<string>.Operation.OP_ADD:
                // Added a buff to the character
                break;
            case SyncSortedSet<string>.Operation.OP_REMOVE:
                // Removed a buff from the character
                break;
            case SyncSortedSet<string>.Operation.OP_CLEAR:
                // cleared all buffs from the character
                break;
        }
    }
}
```