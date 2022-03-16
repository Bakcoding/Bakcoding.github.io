---
title:  "Mirror Guide Serialization"
excerpt: "Network, Mirror, Serialization"

categories:
  - Mirror
tags:
  - [Network, Mirror, Serialization]

toc: true
toc_sticky: true
 
date: 2022-03-16
last_modified_at: 2022-03-16
---  

***

<br>

### Serialization

직렬화

Mirror는 Weaver를 사용해서 타입을 위한 직렬화와 역직렬화 함수를 만든다.

유니티가 Mono.Cecil 을 사용하여 컴파일 한 후에 Weaver는 dll을 편집한다.

이를 통해 사용자가 모든 것을 수동으로 설정할 필요 없이 SyncVar, ClientRpc, Message Serialization 등 많은 복잡한 함수를 Mirror가 제공한다.

<br>

### Ruels & Tip

Weaver가 할 수 있는 일에는 몇 가지 규칙과 제한이 있다. 일부 타입에 대한 함수는 복잡성이 가중되고 유지보수가 어려워 구현되지 않았다. 구현이 불가능한 것이 아니기 때문에 수요가 많은 경우 함수가 추가될 수 있다.

* 모든 타입이 커스텀 Read/Write 함수를 쓸 수 있어야 Weaver가 사용한다.

  즉 지원되지 않는 int\[\]\[\] 같은 타입을 커스텀 Read/Write 를 만들면 SyncVar, ClientRpc 등으로 int\[\]\[\] 를 동기화 할 수 있다.

* 직렬화할 수 없는 필드가 있는 타입이 포함되어 있는 경우 해당 필드를 \[System.NonSerialized\] 으로 표시하면 Weaver가 무시하게 된다.

<br>

### Unsupported Types

사용자가 커스텀 write를 가질 수 있다. 

* 들쭉날쭉한 다차원 배열

* UnityEngine.Component에서 상속되는 타입
 
* UnityEngine.Object

* UnityEngine.ScriptableObject

* My Data와 같은 범용 타입

  커스텀 Read/Write는 반드시 T로 선언해야한다.

* Interface

* 자신을 참조하는 타입

<br>

### Built-in Read/Write Functions

Mirror는 몇개의 Read/Write 함수가 내장되어 있으며 NetworkReaderExtension, NetworkWriterExtensions에서 찾을 수 있다.

* <a href="https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/builtin-types/built-in-types">C# primitive types</a> 

* Common Unity structs
  
  Vector3, Quaternion, Rect, Ray, Guid

* NetworkIdentity, GameObject, Transform

  오브젝트의 netId가 네트워크를 통해 전송되고 동일한 netId를 가진 오브젝트가 반대편으로 반환된다.

  netId가 0이거나 오브젝트를 찾지 못한 경우 null을 반환한다.

<br>

### Generated Read/Write Functions

Weaver가 Read/Write 함수를 생성한다.

* Classis 또는 Structs

* Enums

* Arrays (int[] ...)

* ArraySegments (ArraySegment ...)

* Lists (List ... )

<br>

### Classes & Structs

Weaver는 \[System.NonSerialized\] 가 표시된 것을 제외한 모든 public 필드에 있는 타입을 Read/Write 한다.

클래스 또는 구조체에 지원되지 않는 유형이 있는 경우 Weaver는 해당 유형에 대한 Read/Write 함수를 만들지 못한다.

>주의할 점) Weaver는 프로퍼티는 확인하지 않는다.

<br>

### Enums

Weaver는 기본 열거형을 사용하여 해당 항목을 Read/Write 하며 기본적으로는 int이다.

예)

```cs
public enum Switch : byte
{
  Left,
  Middle,
  Right,
}
```

<br>

### Collections

Weaver는 위의 나열된 콜렉션들에 대한 Write를 생성한다.

Weaver는 요소의 Read/Write 함수를 사용하기 때문에 요소는 반드시 Read/Write 함수를 가지고 있어야하고 지원되는 타입이거나 커스텀 Read/Write 함수도 있어야한다. 

예)

* float[]

  Mirror는 float에 대한 Read/Write 함수를 내장하고 있기 때문에 float[]은 지원가능한 타입이다.

* MyData[]

  MyData에 대한 Read/Write 함수를 Weaver가 만들 수 있기 때문에 MyData[]는 지원되는 타입이다.

```cs
public struct MyData
{
  public int someValue;
  public float anotherValue;
}
```

<br>

### Adding Custon Read Write Functions

Read/Write 함수는 정적 메서드이다.

```cs
public static void WriteMyType(this NetworkWriter writer, MyType value)
{
  // write MyType data here
}

public static MyType ReadMyType(this NetworkReader reader)
{
  // read MyType data here
}
```

Read/Write 함수 확장 메서드는 다음과 같이 호출할 수 있도록 만드는것이 좋다.

```cs
writer.WriteMyType(value);
```

ReadMyType 이나 WriteMyType 처럼 어떤 타입인지 알수있도록 명칭을 하는게 좋다.

함수명은 아무렇게 지어도 Weaver가 찾을 수 있기 때문에 상관이 없다.

<br>

### Properties Example

Weaver는 프로퍼티를 Write 할 수 없지만 커스텀 Writer를 사용하여 네트워크를 통해 프로퍼티를 전송할 수 있다. 이것은 프로퍼티를 private로 설정하고 싶을 때 유용한 방법이다.

```cs
public struct MyData
{
  public int someValue {get; private set;}
  public float anotherValue {get; private set;}

  public MyData(int someValue, float anotherValue)
  {
    this.someValue = someValue;
    this.anotherValue = anotherValue;
  }
}

public static class CustomReadWriteFunctions
{
  public static void WriteMyType(this NetworkWriter writer, MyData value)
  {
    writer.WriteIn32(value.someValue);
    writer.WriteSingle(value.anotherValue);
  }

  public static MyData ReadMyType(this NetworkReader reader)
  {
    return new MyData(reader.ReadInt32(), reader.ReadSingle());
  }
}
```

<br>

### Unsupported type Example

Rigidbody는 Component로부터 상속되기 때문에 지원되지 않는 타입이다.

다만 커스텀 Writer를 추가할 수 있기 때문에 NetworkIdentity가 접속되어 있는 경우는 그걸 사용해 동기화할 수 있다.

```cs
public struct MyCollision
{
    public Vector3 force;
    public Rigidbody rigidbody;
}

public static class CustomReadWriteFunctions
{
    public static void WriteMyCollision(this NetworkWriter writer, MyCollision value)
    {
        writer.WriteVector3(value.force);

        NetworkIdentity networkIdentity = value.rigidbody.GetComponent<NetworkIdentity>();
        writer.WriteNetworkIdentity(networkIdentity);
    }

    public static MyCollision ReadMyCollision(this NetworkReader reader)
    {
        Vector3 force = reader.ReadVector3();

        NetworkIdentity networkIdentity = reader.ReadNetworkIdentity<NetworkIdentity>();
        Rigidbody rigidBody = networkIdentity != null
            ? networkIdentity.GetComponent()
            : null;

        return new MyCollision
        {
            force = force,
            rigidbody = rigidBody,
        };
    }
}
```

위 코드는 MyCollision용 커스텀 Read/Write 함수이다. 여기에 Rigidbody를 위한 함수를 추가하면 Weaver는 MyCollision용 Writer를 생성할 수 있다.

```cs
public static class CustomReadWriteFunctions
{
    public static void WriteRigidbody(this NetworkWriter writer, Rigidbody rigidbody)
    {
        NetworkIdentity networkIdentity = rigidbody.GetComponent<NetworkIdentity>();
        writer.WriteNetworkIdentity(networkIdentity);
    }

    public static Rigidbody ReadRigidbody(this NetworkReader reader)
    {
        NetworkIdentity networkIdentity = reader.ReadNetworkIdentity();
        Rigidbody rigidBody = networkIdentity != null
            ? networkIdentity.GetComponent<Rigidbody>()
            : null;

        return rigidBody;
    }
}
```

<br>

### Debugging

<a href="https://github.com/icsharpcode/ILSpy">ILSpy</a>나 <a href="https://github.com/dnSpy/dnSpy">dnSpy</a>를 사용하면 컴파일 후 Weaver에 의해서 변경된 코드를 볼 수 있다. 
이것을 통해서 Mirror와 Weaver의 기능을 이해하고 디버깅할 수 있다.


