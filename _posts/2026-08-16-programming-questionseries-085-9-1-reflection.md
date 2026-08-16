---
title: "[궁금시리즈] 9-1. Reflection은 왜 필요할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/9-1-reflection/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:13 +0900
last_modified_at: 2026-08-16 12:00:13 +0900
---

## 들어가며

C# 코드는 일반적으로 컴파일 시점에 사용할 타입과 멤버를 알고 있다.

```cs
Player player = new Player();

player.TakeDamage(20);
Console.WriteLine(player.Health);
```

컴파일러는 Player에 `TakeDamage()`와 `Health`가 존재하는지 검사한다. 잘못된 이름이나 타입은 실행 전에 오류로 찾을 수 있다.

하지만 프로그램이 실행되기 전에는 어떤 타입을 사용할지 알 수 없는 경우도 있다.

- Assembly에서 특정 Attribute가 붙은 타입 찾기
- 설정 파일의 문자열로 클래스 선택하기
- 테스트 메서드를 자동으로 수집하기
- 객체의 멤버를 분석해 직렬화하기
- Unity Editor에서 Custom Tool 만들기

```cs
string typeName = config.SkillType;
```

`typeName`이 `"FireballSkill"`인지 `"HealSkill"`인지 컴파일 시점에는 정해지지 않을 수 있다.

Reflection은 실행 중인 프로그램이 Assembly의 타입과 멤버 Metadata를 조사하고 필요하면 객체 생성, 값 접근과 메서드 호출까지 수행할 수 있게 하는 기능이다.

```text
실행 중인 코드
↓
Assembly Metadata 조회
↓
Type, Method, Property, Field 정보 획득
↓
필요한 동작 수행
```

Reflection을 사용하면 코드가 자신의 구조를 실행 중에 확인할 수 있다.

---

## 개념 설명

Reflection의 시작점은 `Type`이다.

`Type` 객체는 특정 타입의 이름, Namespace, 기반 타입, 인터페이스와 멤버 정보를 제공한다.

```cs
Type type = typeof(Player);

Console.WriteLine(type.Name);      // Player
Console.WriteLine(type.Namespace); // 타입의 Namespace
Console.WriteLine(type.BaseType);  // 기반 타입
```

`typeof`는 컴파일 시점에 알고 있는 타입의 `Type` 정보를 가져온다.

```cs
Type playerType = typeof(Player);
```

이미 생성된 객체에서는 `GetType()`을 사용할 수 있다.

```cs
Character character = new Player();
Type actualType = character.GetType();

Console.WriteLine(actualType.Name); // Player
```

변수의 선언 타입은 Character이지만 `GetType()`은 실제 런타임 객체인 Player의 타입을 반환한다.

문자열로 타입을 찾을 수도 있다.

```cs
Type? type = Type.GetType(
    "Game.Skills.FireballSkill, Game.Core");
```

문자열에는 Namespace를 포함한 전체 타입 이름과 필요한 경우 Assembly 이름이 들어간다. 이름이 잘못되거나 Assembly를 찾지 못하면 `null`이 반환될 수 있다.

### MemberInfo

타입의 멤버 정보는 `System.Reflection`의 여러 객체로 표현된다.

```text
MemberInfo
├─ FieldInfo
├─ PropertyInfo
├─ MethodInfo
├─ ConstructorInfo
├─ EventInfo
└─ Type
```

Player의 공개 메서드를 조회할 수 있다.

```cs
Type type = typeof(Player);
MethodInfo[] methods = type.GetMethods();

foreach (MethodInfo method in methods)
{
    Console.WriteLine(method.Name);
}
```

특정 프로퍼티를 이름으로 찾을 수도 있다.

```cs
PropertyInfo? healthProperty =
    type.GetProperty("Health");
```

Reflection API는 멤버가 없을 때 `null`을 반환하는 경우가 많다. 조회 결과가 존재하는지 확인해야 한다.

### BindingFlags

기본 조회는 주로 공개 멤버를 대상으로 한다. 비공개 멤버, 인스턴스 멤버와 정적 멤버의 범위를 지정하려면 `BindingFlags`를 사용한다.

```cs
FieldInfo? healthField = typeof(Player).GetField(
    "health",
    BindingFlags.Instance |
    BindingFlags.NonPublic);
```

```text
BindingFlags.Instance
└─ 인스턴스 멤버

BindingFlags.Static
└─ 정적 멤버

BindingFlags.Public
└─ 공개 멤버

BindingFlags.NonPublic
└─ 비공개 멤버
```

원하는 범위를 정확하게 지정하지 않으면 멤버를 찾지 못하거나 예상보다 많은 결과를 가져올 수 있다.

### Attribute 조회

Reflection은 타입과 멤버에 기록된 Attribute도 읽을 수 있다.

```cs
[AttributeUsage(AttributeTargets.Class)]
public class SkillAttribute : Attribute
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

```cs
SkillAttribute? attribute =
    typeof(FireballSkill)
        .GetCustomAttribute<SkillAttribute>();
```

Attribute는 Assembly Metadata에 기록되고 Reflection을 통해 실행 중에 읽을 수 있다.

---

## 코드 예제

특정 Attribute가 붙은 Skill 타입을 자동으로 등록하는 구조를 만들 수 있다.

```cs
[AttributeUsage(AttributeTargets.Class)]
public sealed class SkillAttribute : Attribute
{
    public string Id { get; }

    public SkillAttribute(string id)
    {
        Id = id;
    }
}
```

모든 Skill은 공통 인터페이스를 구현한다.

```cs
public interface ISkill
{
    void Execute(Character target);
}
```

구체 Skill에 식별자를 표시한다.

```cs
[Skill("fireball")]
public class FireballSkill : ISkill
{
    public void Execute(Character target)
    {
        target.TakeDamage(30);
    }
}
```

```cs
[Skill("heal")]
public class HealSkill : ISkill
{
    public void Execute(Character target)
    {
        target.RestoreHealth(20);
    }
}
```

Registry는 Assembly의 타입을 조회한다.

```cs
public class SkillRegistry
{
    private readonly Dictionary<string, Type> types = new();

    public void RegisterFrom(Assembly assembly)
    {
        foreach (Type type in assembly.GetTypes())
        {
            Register(type);
        }
    }

    private void Register(Type type)
    {
        if (type.IsAbstract || type.IsInterface)
        {
            return;
        }

        if (!typeof(ISkill).IsAssignableFrom(type))
        {
            return;
        }

        SkillAttribute? attribute =
            type.GetCustomAttribute<SkillAttribute>();

        if (attribute is null)
        {
            return;
        }

        types.Add(attribute.Id, type);
    }
}
```

`IsAssignableFrom()`은 해당 타입의 객체를 ISkill 변수에 대입할 수 있는지 확인한다.

```text
Assembly의 타입 순회
↓
추상 타입과 인터페이스 제외
↓
ISkill 구현 여부 확인
↓
SkillAttribute 읽기
↓
Id와 Type 등록
```

등록한 타입으로 객체를 생성할 수 있다.

```cs
public ISkill Create(string id)
{
    if (!types.TryGetValue(id, out Type? type))
    {
        throw new KeyNotFoundException(id);
    }

    object? instance = Activator.CreateInstance(type);

    return instance as ISkill
        ?? throw new InvalidOperationException(id);
}
```

```cs
SkillRegistry registry = new SkillRegistry();
registry.RegisterFrom(typeof(ISkill).Assembly);

ISkill skill = registry.Create("fireball");
skill.Execute(target);
```

새로운 Skill 클래스에 Attribute를 붙이면 Registry의 조건문을 수정하지 않고 검색 대상에 포함할 수 있다.

### 멤버 값 읽기와 변경

PropertyInfo를 사용해 객체의 값을 읽을 수 있다.

```cs
Player player = new Player();

PropertyInfo? property =
    typeof(Player).GetProperty("Health");

object? value = property?.GetValue(player);
Console.WriteLine(value);
```

Setter가 접근 가능한 프로퍼티는 값을 설정할 수도 있다.

```cs
property?.SetValue(player, 100);
```

Reflection은 컴파일 시점 타입 검사의 일부를 실행 시점으로 미룬다. 잘못된 타입의 값을 전달하면 런타임 예외가 발생한다.

```cs
property?.SetValue(player, "Full"); // 런타임 오류
```

### 메서드 호출

MethodInfo를 통해 메서드를 호출할 수 있다.

```cs
MethodInfo? method =
    typeof(Player).GetMethod("TakeDamage");

method?.Invoke(player, [20]);
```

일반 호출과 달리 메서드 이름과 인수가 런타임 데이터로 전달된다.

가능하다면 Reflection은 등록과 초기화 단계에서만 사용하고 반복 실행에서는 인터페이스나 Delegate로 변환해 호출하는 편이 좋다.

---

## 내부 동작

C# 코드는 컴파일되면 IL과 함께 타입 Metadata를 Assembly에 기록한다.

```text
Assembly
├─ IL Code
├─ Type Metadata
│  ├─ 타입 이름과 Namespace
│  ├─ 기반 타입과 인터페이스
│  ├─ Field와 Property
│  ├─ Method와 Constructor
│  └─ Attribute
└─ 기타 Resource
```

Reflection은 이 Metadata를 조회해 `Type`, `MethodInfo`와 `PropertyInfo` 같은 관리 객체로 제공한다.

### Type 객체

런타임은 로드된 각 타입의 구조와 실행 정보를 관리한다.

```cs
Type first = typeof(Player);
Type second = player.GetType();
```

두 표현이 같은 Player 타입을 가리킨다면 동일한 런타임 타입 정보를 나타낸다.

`typeof(Player)`가 호출될 때마다 Assembly 파일을 처음부터 분석해 새로운 타입 정의를 만드는 방식은 아니다. 로드된 타입 시스템의 정보를 나타내는 `Type` 객체를 사용한다.

### 조회와 호출 비용

일반 메서드 호출은 컴파일러와 JIT가 대상 메서드를 직접 확인하고 최적화할 수 있다.

```cs
player.TakeDamage(20);
```

Reflection 호출은 추가 작업이 필요하다.

```text
이름으로 멤버 탐색
↓
BindingFlags와 시그니처 검사
↓
인수 배열과 타입 확인
↓
접근 검사
↓
대상 메서드 호출
↓
반환 값을 object로 처리
```

값 타입 인수와 반환 값은 `object` 경계를 거치며 Boxing이 발생할 수 있다.

```cs
method.Invoke(player, [20]);
```

인수 배열도 할당될 수 있다. 반복 루프에서 매번 멤버를 검색하고 `Invoke()`하면 일반 호출보다 비용이 커진다.

### Metadata 캐시

같은 멤버를 반복해서 사용한다면 조회 결과를 캐시할 수 있다.

```cs
private static readonly MethodInfo TakeDamageMethod =
    typeof(Player).GetMethod(nameof(Player.TakeDamage))
    ?? throw new MissingMethodException();
```

더 자주 호출해야 한다면 MethodInfo에서 Delegate를 만들어 사용할 수 있다.

```cs
Action<Player, int> takeDamage =
    TakeDamageMethod.CreateDelegate<Action<Player, int>>();

takeDamage(player, 20);
```

초기 탐색은 Reflection으로 수행하고 실제 반복 호출은 타입이 지정된 Delegate로 처리할 수 있다.

Reflection 최적화의 첫 단계는 무조건 캐시를 추가하는 것이 아니라 해당 코드가 실제 반복 경로에 있는지 측정하는 것이다.

---

## 실제 Unity에서는?

Unity Editor 도구에서는 Reflection이 유용하다.

특정 Attribute가 붙은 메서드를 찾아 Editor 메뉴나 테스트 도구에 등록할 수 있다.

```cs
[AttributeUsage(AttributeTargets.Method)]
public sealed class DebugCommandAttribute : Attribute
{
    public string Name { get; }

    public DebugCommandAttribute(string name)
    {
        Name = name;
    }
}
```

```cs
[DebugCommand("Give Gold")]
private static void GiveGold()
{
}
```

Editor 시작 시 Assembly를 조회하여 Command 목록을 만들고 실제 실행 시 캐시한 MethodInfo나 Delegate를 사용할 수 있다.

### Component 검색

문자열이나 설정 데이터로 Component 타입을 결정해야 한다면 `Type`을 사용할 수 있다.

```cs
Type componentType = typeof(PlayerHealth);
Component? component = gameObject.GetComponent(componentType);
```

컴파일 시점에 타입을 알고 있다면 Generic API가 더 안전하고 간결하다.

```cs
PlayerHealth health = gameObject.GetComponent<PlayerHealth>();
```

Reflection은 타입이 동적으로 결정되는 경우에만 사용해야 한다.

### IL2CPP와 코드 스트리핑

Unity Player Build에서는 사용되지 않는다고 판단한 코드가 제거될 수 있다.

Reflection으로 문자열만 사용해 접근하는 타입이나 멤버는 정적 코드 참조가 보이지 않아 스트리핑 대상이 될 수 있다.

```cs
Type.GetType("Game.FireballSkill");
```

Editor와 Mono 환경에서는 찾았지만 IL2CPP Build에서 타입이나 멤버가 유지되지 않을 가능성이 있다.

필요한 코드는 직접 참조하거나 `[Preserve]`, `link.xml`과 같은 보존 설정을 고려해야 한다.

어떤 대상이 제거되는지는 Unity Version, Managed Stripping Level과 코드 참조 방식에 따라 달라질 수 있으므로 실제 Target Build에서 확인해야 한다.

### 매 프레임 Reflection 사용

```cs
private void Update()
{
    MethodInfo? method =
        target.GetType().GetMethod("Tick");

    method?.Invoke(target, null);
}
```

매 프레임 이름 검색과 Reflection 호출을 반복하면 CPU 비용과 할당이 누적될 수 있다.

초기화 시점에 타입을 찾고 인터페이스 또는 Delegate로 캐시하는 구조가 일반적으로 더 적합하다.

---

## 실무에서 자주 하는 오해

### Reflection은 private을 안전하게 공개한다는 오해

Reflection으로 비공개 멤버에 접근할 수 있다고 해서 해당 멤버가 공개 API가 되는 것은 아니다.

비공개 멤버는 구현 세부 사항이므로 이름과 구조가 언제든 바뀔 수 있다. 외부 코드가 이에 의존하면 캡슐화가 깨지고 변경에 취약해진다.

### Reflection은 동적 타이핑이라는 오해

C#의 타입 시스템이 사라지는 것은 아니다. Reflection API가 `Type`과 `object`를 통해 타입 정보를 런타임에 검사하고 사용하는 것이다.

잘못된 멤버 이름과 인수 타입 오류가 컴파일 시점이 아니라 실행 시점에 나타날 수 있다.

### GetType()은 매번 비싼 전체 검색이라는 오해

`GetType()`은 객체가 가진 런타임 타입 정보를 반환한다. Assembly 전체에서 이름으로 타입과 멤버를 탐색하는 작업과 같은 비용으로 볼 수 없다.

Reflection API마다 비용이 다르므로 `GetType()`, 멤버 열거와 `MethodInfo.Invoke()`를 모두 같은 작업으로 묶어 판단해서는 안 된다.

### Reflection은 항상 느려서 사용하면 안 된다는 오해

초기화, Editor Tool, 등록과 직렬화처럼 실행 빈도가 낮은 경로에서는 유연성이 더 큰 가치가 될 수 있다.

문제는 매 프레임이나 대량 반복 안에서 같은 검색과 호출을 수행하는 경우이다. 사용 위치를 구분하고 필요하면 결과를 캐시해야 한다.

### Editor에서 동작하면 Player Build에서도 같다는 오해

IL2CPP와 Managed Code Stripping 환경에서는 Reflection 대상이 제거될 수 있다. 플랫폼별 AOT 제약도 영향을 줄 수 있다.

Reflection을 사용하는 기능은 실제 배포 Target의 Player Build에서 검증해야 한다.

---

## 마무리

Reflection은 실행 중인 프로그램이 Assembly Metadata를 통해 타입, 멤버와 Attribute 정보를 조사하고 동적으로 객체를 생성하거나 동작을 호출할 수 있게 한다.

컴파일 시점에 타입을 알 수 없는 등록 시스템, 직렬화, 테스트 Framework와 Unity Editor Tool에 유용하다.

대신 문자열 기반 조회와 `object` 중심 호출로 일부 타입 오류가 실행 시점까지 늦어지고 일반 코드보다 검색, 호출과 할당 비용이 커질 수 있다.

Reflection은 일반 호출을 대체하는 기능이 아니다. 정적 타입으로 해결하기 어려운 초기 탐색과 연결 단계에 사용하고 반복 실행에서는 인터페이스, Generic과 Delegate 같은 타입이 지정된 구조로 전환하는 것이 안전하다.

---

## 핵심 정리

- Reflection은 실행 중에 Assembly의 타입과 멤버 Metadata를 조사하는 기능이다.
- `typeof`는 알고 있는 타입을, `GetType()`은 객체의 실제 런타임 타입을 반환한다.
- `FieldInfo`, `PropertyInfo`, `MethodInfo` 등으로 멤버 정보를 표현한다.
- `BindingFlags`로 공개 여부와 인스턴스·정적 멤버의 조회 범위를 지정한다.
- Attribute는 Metadata에 기록되며 Reflection으로 읽을 수 있다.
- `Activator`, `GetValue()`, `SetValue()`와 `Invoke()`로 런타임 동작을 수행할 수 있다.
- 반복 조회와 호출은 Metadata 또는 Delegate 캐시를 고려해야 한다.
- Unity Editor Tool과 동적 등록 시스템에서 Reflection이 유용하다.
- IL2CPP와 코드 스트리핑을 사용하는 기능은 실제 Player Build에서 검증해야 한다.
