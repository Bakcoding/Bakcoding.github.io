---
title: "[궁금시리즈] 9-3. Attribute는 Reflection과 어떻게 연결될까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/9-3-attribute-reflection/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:15 +0900
last_modified_at: 2026-08-16 12:00:15 +0900
---

## 들어가며

C# 코드에는 대괄호로 작성하는 표현이 자주 등장한다.

```cs
[Serializable]
public class PlayerData
{
}
```

```cs
[Obsolete("Use NewAttack instead.")]
public void OldAttack()
{
}
```

Unity에서도 같은 형태를 사용한다.

```cs
[SerializeField]
private int health;

[Range(0, 100)]
private int volume;
```

이 코드는 일반 주석과 다르다.

주석은 보통 컴파일 결과에서 사라지지만 Attribute는 타입과 멤버에 연결된 Metadata로 Assembly에 기록된다.

Compiler, CLR, Framework와 사용자 코드가 이 정보를 읽고 동작을 바꿀 수 있다.

```text
Attribute 선언
↓ 컴파일
Assembly Metadata에 기록
↓
Compiler 또는 Runtime이 해석
↓
경고, 직렬화, 등록, Editor UI 등에 사용
```

Reflection은 실행 중에 Attribute 정보를 찾고 읽는 대표적인 방법이다.

Attribute는 그 자체만으로 기능을 실행하지 않는다. 해당 Attribute의 의미를 아는 코드가 Metadata를 조회하고 필요한 처리를 수행할 때 실제 동작이 만들어진다.

---

## 개념 설명

Attribute는 `System.Attribute`를 상속하는 클래스이다.

```cs
public class SkillAttribute : Attribute
{
}
```

이름 끝의 `Attribute`는 관례이며 사용할 때 생략할 수 있다.

```cs
[Skill]
public class FireballSkill
{
}
```

컴파일러는 `Skill` 또는 `SkillAttribute` 이름을 기준으로 Attribute 타입을 찾는다.

```cs
[SkillAttribute]
public class HealSkill
{
}
```

두 표현은 같은 Attribute를 의미한다.

### 생성자 인수와 이름 있는 인수

Attribute 생성자로 필수 정보를 전달할 수 있다.

```cs
public sealed class SkillAttribute : Attribute
{
    public string Id { get; }

    public SkillAttribute(string id)
    {
        Id = id;
    }
}
```

```cs
[Skill("fireball")]
public class FireballSkill
{
}
```

공개 Setter가 있는 프로퍼티나 공개 필드는 이름 있는 인수로 지정할 수 있다.

```cs
public sealed class SkillAttribute : Attribute
{
    public string Id { get; }
    public int Priority { get; set; }

    public SkillAttribute(string id)
    {
        Id = id;
    }
}
```

```cs
[Skill("fireball", Priority = 10)]
public class FireballSkill
{
}
```

Attribute 인수에는 컴파일 시점에 Metadata로 표현할 수 있는 제한된 값만 사용할 수 있다.

- 기본 숫자 타입
- `bool`, `char`, `string`
- `Type`
- `enum`
- 지원되는 타입의 1차원 배열
- `object`로 표현 가능한 지원 값

런타임에 계산되는 일반 객체를 생성자 인수로 전달할 수 없다.

```cs
[Skill(CreateId())] // 사용할 수 없음
```

### AttributeUsage

`AttributeUsage`는 사용자 Attribute를 어디에 붙일 수 있고 어떻게 상속할지 정의한다.

```cs
[AttributeUsage(
    AttributeTargets.Class,
    AllowMultiple = false,
    Inherited = true)]
public sealed class SkillAttribute : Attribute
{
}
```

`AttributeTargets`로 적용 대상을 지정한다.

```text
Class
Method
Property
Field
Parameter
ReturnValue
Assembly
Module
All
```

여러 대상을 조합할 수 있다.

```cs
[AttributeUsage(
    AttributeTargets.Class |
    AttributeTargets.Method)]
```

`AllowMultiple`이 `true`이면 같은 대상에 여러 개를 붙일 수 있다.

```cs
[AttributeUsage(
    AttributeTargets.Method,
    AllowMultiple = true)]
public sealed class RequirePermissionAttribute : Attribute
{
    public string Permission { get; }

    public RequirePermissionAttribute(string permission)
    {
        Permission = permission;
    }
}
```

```cs
[RequirePermission("Admin")]
[RequirePermission("GameMaster")]
public void BanPlayer()
{
}
```

`Inherited`는 파생 타입이나 재정의된 멤버에서 기반 Attribute를 상속 대상으로 취급할지 제어한다.

실제 조회 결과는 대상 종류와 사용하는 Reflection API의 `inherit` 인수에도 영향을 받는다.

### Attribute는 누가 처리할까?

Attribute가 붙었다는 사실만으로 메서드가 자동 실행되지는 않는다.

```cs
[Skill("fireball")]
public class FireballSkill
{
}
```

Registry가 Reflection으로 이 Attribute를 찾고 등록해야 의미가 생긴다.

```cs
SkillAttribute? attribute =
    type.GetCustomAttribute<SkillAttribute>();
```

다른 Attribute는 다른 주체가 처리할 수 있다.

```text
[Obsolete]
└─ Compiler가 경고 생성

[Serializable]
└─ Runtime과 관련 Framework가 의미 사용

[Test]
└─ Test Framework가 메서드 검색

[SerializeField]
└─ Unity 직렬화 시스템과 Editor가 처리

[Range]
└─ Unity Inspector가 입력 UI 구성
```

Attribute는 처리할 코드와 함께 사용할 때 확장 지점이 된다.

---

## 코드 예제

게임의 Console Command를 Attribute로 등록할 수 있다.

```cs
[AttributeUsage(
    AttributeTargets.Method,
    AllowMultiple = false,
    Inherited = false)]
public sealed class GameCommandAttribute : Attribute
{
    public string Name { get; }
    public string Description { get; set; } = string.Empty;

    public GameCommandAttribute(string name)
    {
        Name = name;
    }
}
```

Command 메서드에 정보를 기록한다.

```cs
public static class PlayerCommands
{
    [GameCommand(
        "heal",
        Description = "Player의 체력을 회복한다.")]
    public static void Heal(Player player, int amount)
    {
        player.RestoreHealth(amount);
    }

    [GameCommand(
        "damage",
        Description = "Player에게 피해를 준다.")]
    public static void Damage(Player player, int amount)
    {
        player.TakeDamage(amount);
    }
}
```

Scanner는 Attribute가 붙은 메서드만 등록한다.

```cs
public sealed class GameCommandRegistry
{
    private readonly Dictionary<string, GameCommand> commands
        = new();

    public void RegisterFrom(Assembly assembly)
    {
        foreach (Type type in assembly.GetTypes())
        {
            RegisterMethods(type);
        }
    }

    private void RegisterMethods(Type type)
    {
        MethodInfo[] methods = type.GetMethods(
            BindingFlags.Public |
            BindingFlags.NonPublic |
            BindingFlags.Static);

        foreach (MethodInfo method in methods)
        {
            GameCommandAttribute? attribute =
                method.GetCustomAttribute<GameCommandAttribute>();

            if (attribute is null)
            {
                continue;
            }

            Register(attribute, method);
        }
    }
}
```

등록 전에 시그니처를 검사한다.

```cs
public delegate void GameCommand(
    Player player,
    int value);
```

```cs
private void Register(
    GameCommandAttribute attribute,
    MethodInfo method)
{
    GameCommand command =
        method.CreateDelegate<GameCommand>();

    commands.Add(attribute.Name, command);
}
```

실행 시에는 캐시된 Delegate를 사용한다.

```cs
public void Execute(
    string name,
    Player player,
    int value)
{
    if (!commands.TryGetValue(name, out GameCommand? command))
    {
        throw new KeyNotFoundException(name);
    }

    command(player, value);
}
```

```cs
registry.Execute("heal", player, 20);
```

Attribute는 Command의 이름과 설명을 선언 위치에 가깝게 기록한다. Registry는 이 Metadata를 읽어 실행 구조를 구성한다.

### CustomAttributeData 사용

`GetCustomAttribute<T>()`는 Attribute 객체를 생성하고 생성자와 이름 있는 인수를 적용한다.

Attribute를 인스턴스화하지 않고 Metadata 값만 조사하려면 `CustomAttributeData`를 사용할 수 있다.

```cs
IList<CustomAttributeData> attributes =
    method.GetCustomAttributesData();

foreach (CustomAttributeData data in attributes)
{
    Console.WriteLine(data.AttributeType.Name);

    foreach (CustomAttributeTypedArgument argument
             in data.ConstructorArguments)
    {
        Console.WriteLine(argument.Value);
    }
}
```

Plugin 검사, Metadata 분석과 Tooling처럼 Attribute 생성자 코드를 실행하지 않고 선언 정보만 확인해야 하는 상황에 유용하다.

---

## 내부 동작

Attribute를 작성하면 Compiler는 대상 Metadata 항목과 Attribute 생성 정보를 `CustomAttribute` Metadata Table에 기록한다.

```cs
[Skill("fireball", Priority = 10)]
public class FireballSkill
{
}
```

개념적인 Metadata 관계는 다음과 같다.

```text
TypeDef: FireballSkill
       │
       └─ CustomAttribute
          ├─ Attribute Type: SkillAttribute
          ├─ Constructor: SkillAttribute(string)
          └─ Value Blob
             ├─ "fireball"
             └─ Priority = 10
```

생성자 인수와 이름 있는 인수는 Metadata Blob 형태로 인코딩된다.

### Attribute 조회와 생성

```cs
SkillAttribute? attribute =
    type.GetCustomAttribute<SkillAttribute>();
```

Runtime은 대상에 연결된 CustomAttribute Metadata를 찾고 요청한 타입과 일치하는 항목을 확인한다.

그다음 Attribute 객체를 생성하고 Metadata에 기록된 값을 적용한다.

```text
대상 Type의 CustomAttribute 조회
↓
SkillAttribute 항목 찾기
↓
생성자 인수 Decode
↓
SkillAttribute 객체 생성
↓
이름 있는 Property와 Field 값 적용
↓
객체 반환
```

Attribute 인스턴스가 Assembly 안에 미리 저장되어 있는 것은 아니다. Metadata에는 타입과 인수 정보가 기록되고 Reflection 조회 시 객체가 생성될 수 있다.

반복적으로 Attribute 객체를 조회할 예정이라면 결과를 캐시하는 편이 좋다.

### CustomAttributeData의 차이

`CustomAttributeData`는 Attribute 객체를 생성하지 않고 Metadata에 기록된 생성자와 인수 정보를 표현한다.

```text
GetCustomAttribute<T>()
└─ 실제 Attribute 객체 생성

GetCustomAttributesData()
└─ Metadata 선언 정보 제공
```

Attribute 생성자에 코드가 있다면 일반 조회 과정에서 실행될 수 있다.

```cs
public SkillAttribute(string id)
{
    Console.WriteLine("Attribute Created");
    Id = id;
}
```

Attribute 생성자에는 외부 상태 변경이나 무거운 로직을 넣지 않는 편이 안전하다.

### 상속 조회

기반 타입에 Attribute가 있고 `Inherited = true`라면 파생 타입 조회에서 포함될 수 있다.

```cs
[AttributeUsage(
    AttributeTargets.Class,
    Inherited = true)]
public sealed class EnemyAttribute : Attribute
{
}

[Enemy]
public class Monster
{
}

public class Slime : Monster
{
}
```

```cs
bool inherited = typeof(Slime).IsDefined(
    typeof(EnemyAttribute),
    inherit: true);
```

Attribute 종류, 적용 대상과 Reflection API에 따라 상속 처리 규칙이 다를 수 있다. 특히 Property와 Event는 메서드와 다른 Metadata 구조를 가지므로 원하는 결과를 실제 API로 확인해야 한다.

---

## 실제 Unity에서는?

Unity는 Attribute를 직렬화와 Inspector 확장에 폭넓게 사용한다.

### SerializeField

```cs
[SerializeField]
private int health = 100;
```

필드는 C# 접근 수준을 `private`으로 유지하면서 Unity 직렬화 대상으로 표시된다.

`SerializeField`가 필드를 `public`으로 바꾸는 것은 아니다. Unity 직렬화 시스템이 Metadata 표시를 해석해 저장 대상으로 취급한다.

### PropertyAttribute

```cs
[Range(0, 100)]
[SerializeField]
private int volume = 100;
```

`RangeAttribute`는 값 자체를 자동으로 모든 상황에서 제한하는 비즈니스 규칙이 아니다. Inspector가 Slider UI를 표시할 때 사용하는 정보이다.

Runtime 코드에서 직접 값을 변경하면 별도의 검증이 필요하다.

```cs
volume = 1000;
```

### 사용자 PropertyAttribute

사용자 Attribute와 PropertyDrawer를 조합해 Inspector 표현을 확장할 수 있다.

```cs
public sealed class ReadOnlyAttribute
    : PropertyAttribute
{
}
```

```cs
[ReadOnly]
[SerializeField]
private int currentHealth;
```

Attribute만 선언하면 Inspector가 자동으로 읽기 전용이 되는 것은 아니다. 해당 Attribute를 처리하는 `PropertyDrawer` 구현이 필요하다.

```text
[ReadOnly] Metadata
↓
Unity Editor가 PropertyDrawer 검색
↓
ReadOnly 전용 UI 출력
```

### RuntimeInitializeOnLoadMethod

Unity는 특정 Attribute가 붙은 정적 메서드를 Player 초기화 시점에 호출할 수 있다.

```cs
[RuntimeInitializeOnLoadMethod]
private static void Initialize()
{
    Debug.Log("Initialize");
}
```

호출문이 코드에 직접 보이지 않지만 Unity가 Attribute 정보를 기반으로 실행 지점을 구성한다.

Build 환경에서는 Attribute 기반으로만 참조되는 타입과 멤버가 Code Stripping의 영향을 받을 수 있다. Unity가 공식적으로 인식하는 Attribute와 사용자 Reflection Scanner는 보존 처리 방식이 다를 수 있으므로 실제 Player Build에서 확인해야 한다.

---

## 실무에서 자주 하는 오해

### Attribute를 붙이면 기능이 자동으로 생긴다는 오해

Attribute는 Metadata를 제공한다. 이를 해석하는 Compiler, Framework 또는 사용자 코드가 없으면 아무 동작도 일어나지 않는다.

사용자 Attribute를 설계할 때는 누가 언제 조회하고 어떤 처리를 수행할지도 함께 구현해야 한다.

### Attribute는 주석과 같다는 오해

주석은 사람을 위한 설명이고 일반적으로 컴파일 결과에서 제거된다.

Attribute는 Compiler와 Runtime Tool이 읽을 수 있도록 Assembly Metadata에 구조화된 형태로 기록된다.

### Attribute 객체는 하나만 존재한다는 오해

Metadata에 Attribute 인스턴스가 영구적으로 저장되어 있는 것이 아니다. Reflection API로 조회할 때 Attribute 객체가 생성될 수 있다.

객체 동일성을 기대하지 말고 필요한 값만 사용하며 반복 조회 결과는 직접 캐시해야 한다.

### Attribute에 복잡한 로직을 넣어도 된다는 오해

Attribute 생성자는 Reflection 조회 과정에서 실행될 수 있다.

외부 파일 접근, 전역 상태 변경과 무거운 계산을 넣으면 단순 Metadata 조회가 예상하지 못한 부작용과 비용을 만들 수 있다.

### Inherited가 모든 멤버에서 같은 방식으로 동작한다는 오해

타입, 메서드, Property와 Event는 Reflection에서 상속 Metadata를 조회하는 방식이 다를 수 있다.

`AttributeUsage.Inherited`만 보고 가정하지 말고 사용하는 Reflection API와 `inherit` 인수를 함께 확인해야 한다.

---

## 마무리

Attribute는 타입과 멤버에 구조화된 정보를 연결하여 Assembly Metadata에 기록하는 C# 기능이다.

Compiler, CLR, Framework와 사용자 Reflection 코드가 이 정보를 해석해 경고, 직렬화, 자동 등록과 Editor UI 같은 동작을 구성한다.

`AttributeUsage`로 적용 위치, 중복 허용과 상속 여부를 제한할 수 있고 Reflection을 통해 실제 Attribute 객체 또는 `CustomAttributeData` 형태의 선언 정보를 읽을 수 있다.

Attribute는 기능을 자동으로 실행하는 마법이 아니다. Metadata를 선언하는 코드와 이를 읽어 의미를 부여하는 처리 코드가 함께 있어야 한다.

---

## 핵심 정리

- Attribute는 `System.Attribute`를 상속하는 Metadata 클래스이다.
- Attribute 이름의 `Attribute` 접미사는 사용할 때 생략할 수 있다.
- 생성자 인수는 필수 정보를, 이름 있는 인수는 공개 Property와 Field 값을 지정한다.
- `AttributeUsage`로 적용 대상, 중복 허용과 상속 여부를 정의한다.
- Attribute는 Assembly의 CustomAttribute Metadata에 기록된다.
- `GetCustomAttribute<T>()`는 Metadata를 바탕으로 Attribute 객체를 생성할 수 있다.
- `CustomAttributeData`는 Attribute를 인스턴스화하지 않고 선언 정보를 제공한다.
- Attribute 자체는 동작하지 않으며 이를 해석하는 코드가 필요하다.
- Unity는 직렬화, Inspector와 Runtime 초기화에 Attribute를 활용한다.
