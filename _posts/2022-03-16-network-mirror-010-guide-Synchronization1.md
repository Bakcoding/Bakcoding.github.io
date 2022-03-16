---
title:  "Mirror Guide Synchronization 1/3"
excerpt: "Network, Mirror, Synchronization"

categories:
  - Mirror
tags:
  - [Network, Mirror, Synchronization]

toc: true
toc_sticky: true
 
date: 2022-03-16
last_modified_at: 2022-03-16
---  

***

<br>

### Synchronization

상태 동기(State synchronization)는 스크립트에 속하는 정수, 부동 소수점 번호, 문자열, boolean 등의 값들을 동기화하는 것을 말한다.

서버에서 원격 클라이언트로 실행되며 로컬 클라이언트는 씬을 서버와 공유하기 때문에 직렬화된 데이터가 없다.

단 SyncVar hooks는 로컬 클라이언트에서 호출된다.

데이터는 원격 클라이언트에서 서버 방향으로 동기화 되지 않기 때문에 이를 수행하려면 명령어를 사용해야한다. 

* \[SyncVars\] 

  SyncVars는 NetworkBehaviour에서 상속받은 스크립트의 변수이며 서버에서 클라이언트로 동기화된다.

* \[SyncLists\]

  SyncLists 는 값의 리스트를 포함하고 있으며 서버에서 클라이언트로 데이터를 동기화한다.

* \[SyncDictionary\]

  순서없는 key와 value의 pair로된 리스트를 포함하고 있는 연관 배열이다. 

* \[SyncHashSet\]

  반복되지 않는 값들의 Unordered Set이다.

* \[SyncSortedSet\]

  반복되지 않는 값들의 Sorted Set이다.

<br>

### Sync To Owner

일부 플레이어의 데이터를 다른 플레이어에게 표시하지 않으려는 경우 인스펙터 창에서 Network Sync Mode에 기본값인 Observers를 Owner로 변경하면 Mirror가 데이터를 소유하는 클라이언트만 동기화하도록 알린다.

예)

인벤토리 시스템을 만들고 있다고 할 때 플레이어 A, B, C가 같은 영역에 있으며 네트워크 전체에는 총 12개의 오브젝트가 있다.

(A, B, C, 서버 에서 각각이 존재한다.)

이 때 A가 아이템을 줍는다면 서버는 SyncLists가 A의 인벤토리에 아이템을 추가하는데 기본적으로 Mirror는 A의 인벤토리를 전부에게 동기화시키지만 이는 낭비이다.

A의 인벤토리에 대해서 B, C의 화면에 표시 되지 않으며 또 보안상으로 알 필요가 없는 정보이다. 이런 경우 인벤토리의 컴포넌트 중 Network Sync Mode를 Owner로 하면 A의 인벤토리는 A와만 동기화 된다.

이 문제는 한 지역에 사람이 모여 있을수록 성능에도 큰 영향을 많이 미치게 된다.

일반적으로 동일하게 적용되는 사항에는 퀘스트, 스킬, 경험치, 카드 게임에서 플레이어의 손 등이 해당된다.

<br>

### Advanced State Synchronization

대부분의 경우 SyncVars를 사용하는것으로 게임 스크립트가 클라이언트에 상태를 직렬화하기에 충분하다. 

그러나 경우에 따라서 보다 복잡한 직렬화 코드가 필요할 수 있으며 이는 SyncVar 기능을 넘어서 맞춤형 동기화 솔루션으로 사용할 수 있다.

<br>

#### Custom Serialization Functions

커스틈 직렬화를 수행하기 위해서는 SyncVar 직렬화에서 사용되는 가상 함수를 NetworkBehaviour에서 구현할 수 있다.

```cs
public virtual bool OnSerialize(NetworkWriter writer, bool initialState);
public virtual void OnDeserialize(NetworkReader reader, bool initialState);
```

initialState flag를 사용해서 게임 오브젝트가 처음 직렬화된 시점과 점진적 업데이트를 전송할 수 있는 시점을 구분한다. 게임 오브젝트가 클라이언트에 처음 전송될 때는 full state 스냅샷이 포함되어 있어야 하지만 후속 업데이트에서는 점진적 변경만 포함하면 대역폭을 절약할 수 있다.

OnSerialize 함수는 업데이트를 전송해야 함을 나타내려면 true를 반환해야한다. true가 반환되면 해당 스크립트의 dirty bits는 0으로 설정된다.
false가 반환된 경우 dirty bits는 변경되지 않는다. 이를 통해 스크립트에 대한 업데이트를 매 프레임하지않고 여러 변경 사항을 시간에 따라 누적하여 시스템이 준비되었을 때 전송할 수 있다.

OnSerialize 함수는 initialState 또는 NetworkBehaviour가 변경된 경우에만 호출된다. NetworkBehaviour는 마지막 OnSerialize 호출 이후에 SyncVar 또는 SyncObject(SyncList 등)이 변경된 경우에만 더티 비트가 발생한다. 데이터가 전송된 후 다음 syncInterval(인스펙터 설정)까지 NetworkBehaviour는 다시 dirty하지 않는다. NetworkBehaviour는 SetDirtyBit를 수동으로 호출하여 dirty로 마킹할 수 있다. (syncInterval 제한을 우회하지 않는다.)

이 방법은 작동하지만 일반적으로 Mirror가 메서드를 생성하고 특정 필드에 대한 사용자 지정 직렬화 기능을 제공하도록 하는 것이 좋다.

<br>

### Serialization Flow

Network Identity 컴포넌트가 연결된 게임 오브젝트는 Network Behaviour에서 파생된 여러 스크립트를 가질 수 있다. 이러한 게임 오브젝트를 직렬화하기 위한 흐름은 다음과 같다.

**서버**  

* 각 NetworkBehaviour에는 dirty mask가 있다. 이 mask는 OnSerialize 내에서 syncVarDirtyBits로 사용할 수 있다.

* NetworkBehaviour 스크립트의 각 SyncVar에는 dirty mask내의 비트가 할당된다.

* SyncVars 값을 변경하면 해당 SyncVar의 비트가 dirty mask로 설정된다. 또는 SetDirtyBit를 호출하여 dirty mask에 직접 쓴다.

* NetworkIdentity 게임 오브젝트는 업데이트 루프의 일부로 서버에서 체크된다.

* NetworkIdentity 상의 NetworkBehaviours가 dirty해진 경우 해당 게임 오브젝트의 UpdateVars 패킷이 생성된다.

* UpdateVars 패킷은 게임 객체의 각 NetworkBehaviour에서 OnSerialize를 호출하여 입력된다.

* NetworkBehaviours가 dirty하지 않다면 dirty bits에 대해서 패킷에 0을 작성한다.

* NetworkBehaviours가 dirty하다면 dirty mask를 작성하고 다음으로 변경된 SyncVars 값을 작성한다.

* OnSerialize가 NetworkBehaviour에 대해 true를 반환하는 경우 dirty mask는 해당 NetworkBehaviour에 대해 초기화되므로 값이 변경될 때까지 다시 전송되지 않는다.

* UpdateVars 패킷은 게임 오브젝트를 감시하고 있는 준비된 클라이언트로 전송된다.

<br>

**클라이언트**

* 게임 오브젝트에 대한 UpdateVars 패킷 수신

* OnDeserialize 함수는 게임 오브젝트의 각 NetworkBehaviour 스크립트에 대해 호출된다.

* 게임 오브젝트의 각 Network Behaviour 스크립트는 dirty mask를 읽는다..

* NetworkBehaviour의 dirty mask가 0인 경우 OnDeserialize 함수는 더 이상 읽지 않고 반환된다.

* dirty mask가 0이 아닌 경우 OnDeserialize 함수는 설정된 dirty bits에 해당하는 SyncVars 값을 읽는다.

* SyncVar hooks 함수가 있는 경우 이런 함수는 스트림에서 읽은 값으로 호출된다.

  ```cs
  public class data : NetworkBehaviour
  {
    [SyncVar(hook = nameof(OnInt1Changed))]
    public int int1 = 66;

    [SyncVar]
    public int int2 = 23487;

    [SyncVar]
    public string MyString = "Example string";

    void OnInt1Changed(int oldValue, int newValue)
    {
      // do something here
    }
  }
  ```

<br>

다음 샘플은 직렬화를 위해 Mirror의 NetworkBehaviour.OnSerialize 내부에서 호출되는 SerializeSyncVars 함수 의해서 생성되는 코드를 나타낸다.

```cs
public override bool SerializeSyncVars(NetworkWriter writer, bool initialState)
{
    // Write any SyncVars in base class
    bool written = base.SerializeSyncVars(writer, forceAll);

    if (initialState)
    {
        // The first time a game object is sent to a client, send all the data (and no dirty bits)
        writer.WritePackedUInt32((uint)this.int1);
        writer.WritePackedUInt32((uint)this.int2);
        writer.Write(this.MyString);
        return true;
    }
    else 
    {
        // Writes which SyncVars have changed
        writer.WritePackedUInt64(base.syncVarDirtyBits);

        if ((base.get_syncVarDirtyBits() & 1u) != 0u)
        {
            writer.WritePackedUInt32((uint)this.int1);
            written = true;
        }

        if ((base.get_syncVarDirtyBits() & 2u) != 0u)
        {
            writer.WritePackedUInt32((uint)this.int2);
            written = true;  
        }

        if ((base.get_syncVarDirtyBits() & 4u) != 0u)
        {
            writer.Write(this.MyString);
            written = true;     
        }

        return written;
    }
}
```

다음 샘플은 역직렬화를 위해 생성하는 코드이다.

```cs
public override void DeserializeSyncVars(NetworkReader reader, bool initialState)
{
    // Read any SyncVars in base class
    base.DeserializeSyncVars(reader, initialState);

    if (initialState)
    {
        // The first time a game object is sent to a client, read all the data (and no dirty bits)
        int oldInt1 = this.int1;
        this.int1 = (int)reader.ReadPackedUInt32();
        // if old and new values are not equal, call hook
        if (!base.SyncVarEqual(num, ref this.int1))
        {
            this.OnInt1Changed(num, this.int1);
        }

        this.int2 = (int)reader.ReadPackedUInt32();
        this.MyString = reader.ReadString();
        return;
    }

    int dirtySyncVars = (int)reader.ReadPackedUInt32();
    // is 1st SyncVar dirty
    if ((dirtySyncVars & 1) != 0)
    {
        int oldInt1 = this.int1;
        this.int1 = (int)reader.ReadPackedUInt32();
        // if old and new values are not equal, call hook
        if (!base.SyncVarEqual(num, ref this.int1))
        {
            this.OnInt1Changed(num, this.int1);
        }
    }

    // is 2nd SyncVar dirty
    if ((dirtySyncVars & 2) != 0)
    {
        this.int2 = (int)reader.ReadPackedUInt32();
    }

    // is 3rd SyncVar dirty
    if ((dirtySyncVars & 4) != 0)
    {
        this.MyString = reader.ReadString();
    }
}
```

NetworkBehaviour이 직렬화 함수가 있는 베이스 클래스를 가지고 있다면 베이스 클래스의 함수가 호출된다.

>주의, UpdateVar은 클라이언트에 전송되기 전에 게임 오브젝트 상태 업데이트를 위해 생성된 패킷은 퍼버에 집약될 수 있다. 따라서 단일 전송 계층 패킷은 다수의 게임 오브젝트에 대한 업데이트를 포함하고 잇다.