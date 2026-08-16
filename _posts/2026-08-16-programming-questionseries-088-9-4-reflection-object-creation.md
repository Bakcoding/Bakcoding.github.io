---
title: "[궁금시리즈] 9-4. Reflection으로 객체는 어떻게 생성할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/9-4-reflection-object-creation/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:16 +0900
last_modified_at: 2026-08-16 12:00:16 +0900
---

## 들어가며

일반적인 객체 생성은 컴파일 시점에 타입을 알고 있다.

```cs
FireballSkill skill = new FireballSkill();
```

컴파일러는 생성할 타입과 호출할 생성자를 확인한다.

Plugin, 설정 파일과 Editor Tool에서는 실행 중에 타입이 결정될 수 있다.

```json
{
  "skillType": "Game.Skills.FireballSkill"
}
```

문자열을 읽은 시점에는 C# 코드에 `new FireballSkill()`을 직접 작성하기 어렵다.

```cs
Type? type = Type.GetType(typeName);
```

`Type` 정보를 찾았더라도 아직 객체는 없다. 해당 타입의 생성자를 선택하고 호출해야 한다.

Reflection은 런타임 타입 정보로 생성자를 조회하고 객체를 동적으로 만들 수 있게 한다.

```cs
object? instance = Activator.CreateInstance(type);
```

동적 객체 생성은 Plugin Loader, Serializer, DI Container와 Factory 구현에 사용된다.

대신 생성자 오류가 컴파일 시점에 확인되지 않고 실행 중에 나타나며 일반 `new`보다 타입 검사와 생성자 탐색 과정이 추가된다.

---

## 개념 설명

### Activator.CreateInstance

`Activator.CreateInstance()`는 `Type`을 이용해 객체를 생성하는 대표적인 API이다.

```cs
Type type = typeof(FireballSkill);
object? instance = Activator.CreateInstance(type);
```

반환형은 `object`이므로 필요한 타입으로 변환해야 한다.

```cs
ISkill skill = instance as ISkill
    ?? throw new InvalidOperationException();
```

Generic Overload를 사용하면 컴파일 시점 타입이 있는 객체를 만들 수 있다.

```cs
FireballSkill skill =
    Activator.CreateInstance<FireballSkill>();
```

하지만 Generic 타입을 이미 알고 있다면 일반 `new`가 더 단순하다. Activator의 가치는 실행 중에 `Type`이 결정되는 경우에 있다.

### 기본 생성자

인수 없이 호출하면 매개변수가 없는 생성자가 필요하다.

```cs
public class FireballSkill
{
    public FireballSkill()
    {
    }
}
```

기본 생성자가 없다면 객체를 만들 수 없다.

```cs
public class FireballSkill
{
    public FireballSkill(int damage)
    {
    }
}
```

```cs
Activator.CreateInstance(typeof(FireballSkill));
// MissingMethodException
```

생성자 인수를 전달할 수 있다.

```cs
object? instance = Activator.CreateInstance(
    typeof(FireballSkill),
    [30]);
```

Runtime은 전달된 인수에 맞는 생성자를 찾는다.

```text
FireballSkill Type
↓
인수: int 30
↓
FireballSkill(int damage) 검색
↓
생성자 호출
```

일치하는 생성자가 없거나 여러 후보가 모호하면 런타임 예외가 발생할 수 있다.

### ConstructorInfo

생성자도 Reflection 멤버이며 `ConstructorInfo`로 표현된다.

```cs
ConstructorInfo? constructor =
    typeof(FireballSkill).GetConstructor([typeof(int)]);
```

찾은 생성자를 직접 호출한다.

```cs
object? instance = constructor?.Invoke([30]);
```

생성자 목록을 분석할 수도 있다.

```cs
ConstructorInfo[] constructors =
    typeof(FireballSkill).GetConstructors();

foreach (ConstructorInfo constructor in constructors)
{
    foreach (ParameterInfo parameter
             in constructor.GetParameters())
    {
        Console.WriteLine(parameter.ParameterType);
    }
}
```

DI Container는 이런 생성자와 매개변수 정보를 이용해 필요한 객체를 재귀적으로 해결할 수 있다.

### 생성할 수 없는 타입

모든 `Type`으로 객체를 만들 수 있는 것은 아니다.

```text
Interface
└─ 구현이 없어 직접 생성 불가

Abstract Class
└─ 미완성 타입이라 직접 생성 불가

Open Generic Type
└─ 타입 인수가 결정되지 않아 생성 불가

Static Class
└─ 인스턴스 생성 불가
```

동적 생성 전에 타입 조건을 검사할 수 있다.

```cs
if (type.IsInterface || type.IsAbstract)
{
    return null;
}

if (type.ContainsGenericParameters)
{
    return null;
}
```

Value Type은 기본값 형태로 생성할 수 있다.

```cs
object damage = Activator.CreateInstance(typeof(Damage));
```

반환 과정에서 값 타입이 `object`로 Boxing된다.

---

## 코드 예제

문자열 ID로 Skill 객체를 생성하는 Factory를 만들 수 있다.

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

모든 Skill은 생성에 필요한 설정을 받는다.

```cs
public sealed class SkillContext
{
    public Character Owner { get; }

    public SkillContext(Character owner)
    {
        Owner = owner;
    }
}
```

```cs
public interface ISkill
{
    void Execute(Character target);
}
```

구체 Skill은 같은 생성자 계약을 제공한다.

```cs
[Skill("fireball")]
public sealed class FireballSkill : ISkill
{
    private readonly SkillContext context;

    public FireballSkill(SkillContext context)
    {
        this.context = context;
    }

    public void Execute(Character target)
    {
        target.TakeDamage(30);
    }
}
```

Factory는 초기화 시점에 타입과 생성자를 등록한다.

```cs
public sealed class SkillFactory
{
    private readonly Dictionary<string, ConstructorInfo> constructors
        = new();

    public void RegisterFrom(Assembly assembly)
    {
        foreach (Type type in assembly.GetTypes())
        {
            Register(type);
        }
    }

    private void Register(Type type)
    {
        if (type.IsAbstract ||
            !typeof(ISkill).IsAssignableFrom(type))
        {
            return;
        }

        SkillAttribute? attribute =
            type.GetCustomAttribute<SkillAttribute>();

        if (attribute is null)
        {
            return;
        }

        ConstructorInfo constructor =
            type.GetConstructor([typeof(SkillContext)])
            ?? throw new InvalidOperationException(
                $"{type.Name}에 SkillContext 생성자가 필요하다.");

        constructors.Add(attribute.Id, constructor);
    }
}
```

객체 생성 시 캐시한 생성자를 호출한다.

```cs
public ISkill Create(
    string id,
    SkillContext context)
{
    if (!constructors.TryGetValue(
            id,
            out ConstructorInfo? constructor))
    {
        throw new KeyNotFoundException(id);
    }

    object instance = constructor.Invoke([context]);

    return (ISkill)instance;
}
```

```cs
SkillFactory factory = new SkillFactory();
factory.RegisterFrom(typeof(ISkill).Assembly);

ISkill skill = factory.Create(
    "fireball",
    new SkillContext(player));
```

새로운 Skill 타입은 Attribute와 생성자 계약을 지키면 Factory의 조건문 수정 없이 등록된다.

### Generic Type 생성

Open Generic Type에 실제 타입 인수를 적용해 Closed Generic Type을 만들 수 있다.

```cs
Type openType = typeof(List<>);
Type closedType = openType.MakeGenericType(typeof(Item));

object? instance = Activator.CreateInstance(closedType);
```

결과 객체의 실제 타입은 `List<Item>`이다.

```cs
Console.WriteLine(instance?.GetType());
// System.Collections.Generic.List`1[Item]
```

타입 인수가 Generic 제약 조건을 만족하지 않으면 `MakeGenericType()`에서 예외가 발생할 수 있다.

컴파일 시점에 타입을 알고 있다면 다음 코드가 더 안전하다.

```cs
List<Item> items = new List<Item>();
```

동적 Generic 생성은 Serializer, Container와 Tooling처럼 타입이 런타임 데이터로 주어지는 경우에 사용한다.

---

## 내부 동작

일반 `new`는 컴파일 시점에 호출할 생성자가 결정된다.

```cs
FireballSkill skill = new FireballSkill(context);
```

IL에는 객체 메모리를 확보하고 특정 생성자를 호출하는 명령이 기록된다.

```text
newobj FireballSkill::.ctor(SkillContext)
```

JIT 또는 AOT Compiler는 이 정보를 바탕으로 직접 생성 코드를 준비할 수 있다.

### Activator의 생성 과정

```cs
Activator.CreateInstance(type, [context]);
```

Runtime에 `Type`과 `object` 배열이 전달된다.

개념적인 과정은 다음과 같다.

```text
Type이 생성 가능한지 확인
↓
인수와 호환되는 생성자 탐색
↓
접근 수준과 매개변수 검사
↓
객체 메모리 확보
↓
생성자 호출
↓
object 참조 반환
```

생성자 선택에는 Runtime Binder가 관여할 수 있다. 전달된 인수 타입과 생성자의 매개변수를 비교하고 가능한 변환을 검사한다.

```cs
Activator.CreateInstance(
    typeof(Skill),
    [30]);
```

`30`은 `object` 배열에 들어갈 때 Boxing될 수 있다. 반환 값도 `object`이므로 실제 타입으로 검사하거나 변환해야 한다.

### ConstructorInfo.Invoke

생성자를 미리 찾아 캐시하면 매번 이름과 시그니처로 생성자를 탐색하는 비용을 줄일 수 있다.

```cs
ConstructorInfo constructor =
    typeof(FireballSkill)
        .GetConstructor([typeof(SkillContext)])!;
```

하지만 `ConstructorInfo.Invoke()`에도 인수 배열 생성, 타입 검사와 Reflection 호출 경계가 남는다.

반복해서 많은 객체를 생성해야 한다면 생성 Delegate 또는 Factory를 미리 만들 수 있다.

```cs
Func<SkillContext, ISkill> factory =
    context => new FireballSkill(context);
```

Reflection은 초기 등록 단계에서 Factory를 선택하고 실제 생성은 타입이 지정된 Delegate가 수행하도록 구성할 수 있다.

### 생성자 예외

Reflection으로 호출한 생성자 내부에서 예외가 발생하면 `TargetInvocationException`으로 감싸질 수 있다.

```cs
try
{
    constructor.Invoke([context]);
}
catch (TargetInvocationException exception)
{
    Exception? original = exception.InnerException;
}
```

생성 실패 원인을 기록할 때 내부 예외를 확인해야 한다.

### 생성자를 건너뛰는 생성

일부 직렬화용 저수준 API는 일반 생성자를 호출하지 않고 객체 메모리를 만들 수 있다.

이 방식은 필수 초기화와 불변식을 건너뛰어 정상적으로 사용할 수 없는 객체를 만들 수 있다.

```text
생성자 실행
└─ 객체 불변식과 필수 필드 초기화

생성자 우회
└─ 초기화되지 않은 상태가 남을 수 있음
```

일반 Factory와 게임 코드에서는 생성자 우회 방식을 객체 생성 대안으로 사용해서는 안 된다.

---

## 실제 Unity에서는?

일반 C# 클래스는 Reflection과 Activator로 생성할 수 있다.

```cs
ISkill skill = (ISkill)Activator.CreateInstance(skillType)!;
```

하지만 `MonoBehaviour`와 `ScriptableObject`는 Unity Native Object와 연결되는 특별한 타입이다.

### MonoBehaviour

`MonoBehaviour`를 Activator나 `new`로 생성하면 정상적인 Unity Component가 되지 않는다.

```cs
Activator.CreateInstance(typeof(PlayerController));
// Unity Component 생성 방식으로 사용할 수 없음
```

GameObject에 Component로 추가해야 한다.

```cs
Type componentType = typeof(PlayerController);
Component component = gameObject.AddComponent(componentType);
```

Unity가 Native Component 생성, GameObject 연결과 생명 주기 등록을 처리한다.

동적 타입이 실제로 `Component`이고 추상 타입이 아닌지 확인해야 한다.

```cs
if (!typeof(Component).IsAssignableFrom(componentType) ||
    componentType.IsAbstract)
{
    throw new InvalidOperationException();
}
```

### ScriptableObject

`ScriptableObject`도 Activator 대신 Unity API를 사용한다.

```cs
Type dataType = typeof(FireballData);
ScriptableObject data =
    ScriptableObject.CreateInstance(dataType);
```

Asset 파일을 생성하는 작업과 메모리에 ScriptableObject 인스턴스를 만드는 작업은 다르다. Editor에서 Asset으로 저장하려면 `AssetDatabase` 같은 Editor API가 추가로 필요하다.

### Prefab 생성

Enemy Type을 Reflection으로 찾았다고 Prefab의 Component 구성과 직렬화된 데이터를 새로 만들 수 있는 것은 아니다.

Unity 객체는 코드 타입뿐 아니라 Prefab과 Scene의 직렬화 데이터에 의존한다.

```cs
EnemyBehaviour enemy = Instantiate(enemyPrefab);
```

게임 객체 생성에서는 Reflection으로 Component 타입을 조합하기보다 미리 구성한 Prefab을 Factory나 Addressables로 선택하는 방식이 더 자연스러운 경우가 많다.

### IL2CPP와 AOT

Reflection으로만 접근하는 생성자와 Closed Generic 조합은 Code Stripping 또는 AOT 코드 생성의 영향을 받을 수 있다.

```cs
openType.MakeGenericType(runtimeType);
```

Editor에서 생성되더라도 Target Build에 필요한 코드가 포함되지 않을 수 있다. `[Preserve]`, `link.xml`, 명시적 타입 참조와 실제 Target Build 테스트를 고려해야 한다.

---

## 실무에서 자주 하는 오해

### Type만 있으면 모든 객체를 만들 수 있다는 오해

인터페이스, 추상 클래스, Static Class와 Open Generic Type은 직접 생성할 수 없다.

생성 가능한 구체 타입이어도 필요한 생성자를 찾지 못하거나 접근할 수 없으면 생성에 실패한다.

### Activator가 가장 유연한 Factory라는 오해

Runtime Type으로 모든 객체를 생성할 수 있지만 생성자 오류가 실행 시점으로 늦어지고 Reflection 비용이 발생한다.

가능한 타입이 정해져 있거나 컴파일 시점에 알 수 있다면 명시적인 Factory와 Delegate가 더 안전하다.

### 생성자를 캐시하면 생성 비용이 모두 사라진다는 오해

ConstructorInfo 탐색 비용은 줄어들지만 `Invoke()`의 인수 배열, 타입 검사와 Reflection 호출 비용은 남는다.

대량 생성 경로에서는 타입이 지정된 Factory Delegate나 직접 생성 코드를 고려해야 한다.

### MonoBehaviour도 일반 클래스처럼 만들 수 있다는 오해

MonoBehaviour는 Unity Native Component와 GameObject에 연결되어야 한다.

`new`나 Activator가 아닌 `AddComponent()` 또는 Prefab `Instantiate()`를 사용해야 한다.

### 생성자를 건너뛰면 더 빠르다는 오해

생성자는 객체가 유효한 상태를 만들기 위한 규칙을 실행한다.

이를 우회하면 필수 필드와 불변식이 초기화되지 않은 객체가 만들어질 수 있다. 특별한 직렬화 구현 외의 일반 코드에서 사용해서는 안 된다.

---

## 마무리

Reflection 기반 객체 생성은 실행 중에 얻은 `Type`과 생성자 Metadata를 이용해 구체 객체를 만드는 방식이다.

`Activator.CreateInstance()`는 간단한 동적 생성에 사용할 수 있고 `ConstructorInfo`는 생성자 시그니처를 검사하고 캐시할 수 있게 한다.

동적 생성은 Plugin, Serializer와 DI Container에 유용하지만 생성자 누락과 타입 오류가 실행 시점에 나타나며 일반 `new`보다 탐색과 호출 비용이 추가된다.

Unity에서는 일반 C# 객체와 Engine Object의 생성 방식을 구분해야 한다. `MonoBehaviour`는 `AddComponent()`나 Prefab, `ScriptableObject`는 `CreateInstance()`를 사용하고 IL2CPP Target에서 보존 및 AOT 제약을 검증해야 한다.

---

## 핵심 정리

- `Activator.CreateInstance()`는 런타임 `Type`으로 객체를 생성한다.
- 인수 없는 생성에는 기본 생성자가 필요하고 인수를 전달하면 호환되는 생성자를 탐색한다.
- `ConstructorInfo`로 생성자 시그니처를 조회하고 직접 호출할 수 있다.
- 인터페이스, 추상 클래스와 Open Generic Type은 직접 생성할 수 없다.
- `MakeGenericType()`으로 Open Generic에 타입 인수를 적용할 수 있다.
- Reflection 생성에는 생성자 탐색, 인수 배열, 타입 검사와 Boxing 비용이 발생할 수 있다.
- 반복 생성에서는 ConstructorInfo나 타입이 지정된 Factory를 캐시할 수 있다.
- `MonoBehaviour`는 `AddComponent()` 또는 Prefab으로 생성해야 한다.
- `ScriptableObject`는 Unity의 `CreateInstance()`를 사용해야 한다.
