---
title:  "Mirror Guide Data Types"
excerpt: "Network, Mirror, Data-Types"

categories:
  - Mirror
tags:
  - [Network, Mirror, Data-Types]

toc: true
toc_sticky: true
 
date: 2022-03-16
last_modified_at: 2022-03-16
---  

***

<br>

### Data Types

클라이언트와 서버는 서로 Remote Actions, State Synchronization, Network Messages를 통해서 데이터를 보낼 수 있다.

여기서 사용이 가능한 자료형은 Mirror에서 다음과 같이 지원된다.

* Basic C# types

* Built-in Unity match type

* 통합 자원 식별자 (URI, Uniform Resource Identifier)

* NetworkIdentity

* NetworkIdentity 컴포넌트를 가지고 있는 게임오브젝트

* 위의 내용 중 어느 하나라도 포함하는 구조체

  IEquatable을 구현하여 boxing을 피하고 필드 중 하나를 수정해도 재동기화가 발생하지 않으므로 읽기 전용으로 하는것이 좋다.

* Classes as long as each field has a supported data type 

* 필드에 지원되는 자료형이 있는 클래스

  이 클래스들은 가비지를 할당해서 송신할 때마다 수신측에서 새롭게 인스턴스화 된다.

* 각 필드에 지원되는 데이터 유형이 있는 ScriptableObject인 경우

  클래스와 마찬가지로 인스턴스화 된다.

* 위의 내용 중 하나라도 포함된 배열

  SyncVars 또는 SyncLists 에서는 지원되지 않는다.

* 위의 내용 중 하나라도 포함된 ArraySegment\<T\>

  SyncVars 또는 SyncLists 에서는 지원되지 않는다.

  <br>

### Game Objects

게임 오브젝트는 SyncVars, SyncLists 그리고 SyncDictionaries는 몇몇 상황에서 취약하기 때문에 주의해서 사용해야한다.

* 게임 오브젝트가 서버와 클라이언트 양쪽에 이미 존재한다면 참조에 문제가 없다.

동기 데이터가 클라이언트에 도착하면 참조된 게임 오브젝트가 아직 그 클라이언트에 존재하지 않을 수 있으며 그 결과 동기 데이터에 null 값이 표시된다. 

이는 내부적으로 Mirror가 NetworkIdentity에서 netId를 전달하고 클라이언트의 NetworkIdentity.spawned 딕셔너리에서 검색하려고 하기 때문이다.

클라이언트에서 오브젝트가 아직 생성되지 않았다면 일치하는 항목을 찾을 수 없다. 같은 payload일 때 특히, 클라이언트에 참가하는 경우라면 있을 수 있지만 다른 오브젝트로부터의 동기 데이터 이후에 있을 수 있다. 그것 또한 네트워크 가시성(NetworkProximityChecker) 때문에 게임 오브젝트가 클라이언트에서 제외되어서 null일 수 있다.

NetworkIdentity.netID로 동기화하는 것보다 NetworkIdentity.spawned과 코루틴을 사용해서 오브젝트를 가져오는 것이 더 안정적이다.

```cs
public GameObject target;

[SyncVar (hook = nameof(OnTargetChanged))]
public uint targetID;

void OnTargetChanged(uint _, uint newValue)
{
  if (NetworkIdentity.spawned.TryGetValue(
    targetID, out NetworkIdentity identity))
    target = identity.gameobject;
  else
    StartCoroutine(SetTarget());
}

IEnumerator SetTarget()
{
  while (target == null)
  {
    yield return null;
    if (NetworkIdentity.spawned.TryGetValue(
      targetID, out NetworkIdentity identity
    ))
      target = identity.gameObject;
  }
}
```

<br>

### Custom Data Types

경우에 따라서 Mirror에서 커스텀 자료형을 직렬화 생성하지 않을 수 있다.

예를 들어서 퀘스트 데이터를 직렬화하는 대신 퀘스트 ID만 직렬화하고 수신자는 미리 정의된 목록에서 id별로 퀘스트를 조회할 수 있다.

경우에 따라서 DataTime이나 System.URI 같이 Mirror에서 지원되지 않는 다른 유형을 사용하는 데이터를 직렬화 할 수 도 있다.

NetworkWriter 와 NetworkReader에 확장 메서드를 추가하여 모든 유형의 지원을 추가할 수 있다.

예를 들어 DateTime을 추가하려면 프로젝트 어딘가에 다음을 추가한다.

```cs
public static class DateTimeReaderWriter
{
  public static void WriteDateTime(
    this NetworkWriter, DateTime dateTime)
  {
    writer.WriteInt64(dateTime.Ticks);
  }

  public static DateTime ReadDateTime(
    this NetworkReader reader)
  {
    return new DateTime(reader.ReadInt64());
  }   
}
```

추가했다면 이제 DateTime을 \[Command\]나 SyncList에서 사용할 수 있게된다.

<br>

### Inheritance & Polymorphism

다형성 자료형을 Commands로 보내고 싶을 수 있다.

Mirror는 메시지를 작게 유지하고 보안상의 이유로 자료형의 이름을 직력화하지 않는다. 따라서 Mirror는 메시지를 통해서 수신한 개체의 유형을 파악할 수 없다.

다음 코드는 동작하지 않는다.

```cs
class Item
{
  public string name;
}

class Weapon : Item
{
  public int hitPoints;
}

class Armor : Item
{
  public int hitPoints;
  public int level;
}

class Player : NetworkBehaviour
{
  [Command]
  void CmdEquip(Item item)
  {
    // IMPORTANT: this does not work.
    // Mirror will pass you an object of type item
    // even if you pass a weapon or an armor.
    if (item is Weapon weapon)
    {
      // The item is a weapon,
      // maybe you need to equip it in the end
    }
    else if (item is Armor armor)
    {
      // you might want to equip armor in the body
    }
  }

  [Command]
  void CmdEquipArmor(Armor armor)
  {
    // IMPORTANT: this does not work either, 
    // you will receive an armor, but the armor 
    // will not have a valid Item.name,
    // even if you passed an armor with name
  }
}
```

CmdEquip 메서드는 custom serializer를 제공하는 경우 작동한다.

```cs
public static class ItemSerializer
{
  const byte WEAPON = 1;
  const byte ARMOR = 2;

  public static void WriteItem(this NetworkWriter, Item item)
  {
    if (item is Weapon weapon)
    {
      writer.WriteByte(WEAPON);
      writer.WriteString(weapon.name);
      writer.WritePackedInt32(weapon.hitPoints);
    }
    else if (item is Armor armor)
    {
      writer.WriteByte(ARMOR);
      writer.WriteString(armor.name);
      writer.WritePackedInt32(armor.hitPoints);
      writer.WritePackedInt32(armor.level);
    }
  }

  public static Item ReadItem(this NetworkReader reader)
  {
    byte type = reader.ReadByte();
    switch(type)
    {
      case WEAPON:
        return new Weapon
        {
          name = reader.ReadString(),
          hitPoints = reader.ReadPackedInt32()
        };
      case ARMOR:
        return new Armor
        {
          name = reader.ReadString(),
          hitPoints = reader.ReadPackedInt32(),
          level = reader.ReadPackedInt32()
        };
        default:
          throw new Exception($"Invalid weapon type {type}");
    }
  }
}
```

<br>

### ScriptableObjects

예를 들어서 여러개의 검을 스크립트 가능한 오브젝트로 만들고 장비한 검을 SyncVar에 넣을 수 있다.

이 경우 ScriptableObject.CreateInstance를 호출해서 스크립트 가능한 오브젝트를 위한 reader와 writer를 생성하고 모든 데이터를 복사한다.

하지만 생성된 reader와 writer가 모든 경우에 적합한 것은 아니다.

* 스크립터블 오브젝트는 텍스쳐, 프리팹 등 직렬화할 수 없는 다른 데이터나 에셋을 참조하는 경우가 많다. 

* 스크립터블 오브젝트는 대부분 Resources 폴더에 저장되고, 이 오브젝트에는 대량의 데이터가 포함되는 경우도 있다.

이런 경우에는 생성된 reader와 writer가 제대로 동작하지 않거나 상황에 적합하지 않을 수 있다.

스크립터블 오브젝트를 데이터로 전달하는 대신 이름을 전달하고 다른 쪽에서 동일한 오브젝트를 이름으로 검색하는 방법이 있어 이렇게 사용하면 스크립터블 오브젝트에 모든 종류의 데이터를 포함시킬 수 있다. 

커스텀 reader와 writer로 위 작업을 수행하는 방법

```cs
[CreateAssetMenu(fileName = "New Armor", menuName = "Armor Data")]
class Armor : ScriptableObject
{
  public int Hitpoints;
  public int Weight;
  public string Description;
  public Texture2D Icon;
  //...
}

public static class ArmorSerializer
{
  public static void WriteArmor(this NetworkWirter writer, Armor armor)
  {
    // no need to serialize the data, just the name of the armor
    writer.WriteString(armor.name);
  }

  public static Armor ReadArmor(this NetworkReader reader)
  {
    // load the same armor by name. The data will come from the asset in Resources folder
    return Resources.Load(reader.ReadString());
  }
}
```

