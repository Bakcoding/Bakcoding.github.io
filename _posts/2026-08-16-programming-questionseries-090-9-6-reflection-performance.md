---
title: "[궁금시리즈] 9-6. Reflection은 정말 느릴까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/9-6-reflection-performance/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:18 +0900
last_modified_at: 2026-08-16 12:00:18 +0900
---

## 들어가며

Reflection은 일반 호출보다 느리다고 알려져 있다.

```cs
player.TakeDamage(20);
```

```cs
MethodInfo method = typeof(Player)
    .GetMethod(nameof(Player.TakeDamage))!;

method.Invoke(player, [20]);
```

두 코드는 같은 메서드를 실행하지만 두 번째 코드는 타입에서 멤버를 찾고, 인수를 `object` 배열로 전달하며, 런타임에 호출 조건을 검사한다.

그렇다고 Reflection을 사용한 모든 코드가 실제 성능 문제를 만드는 것은 아니다.

게임 시작 시 Skill 타입을 한 번 등록하는 작업과 `Update()`에서 수천 개 객체의 메서드를 매 프레임 호출하는 작업은 영향이 전혀 다르다.

```text
초기화 시 1회 검색
└─ 대부분 큰 문제가 되지 않음

매 프레임 반복 검색과 Invoke
└─ CPU 비용과 GC Alloc 누적 가능
```

Reflection 성능을 판단하려면 기능 전체를 느리다고 묶는 대신 어떤 API를 얼마나 자주 호출하며 어떤 할당이 발생하는지 나누어 봐야 한다.

---

## 개념 설명

Reflection 작업은 비용이 모두 같지 않다.

### 런타임 타입 확인

```cs
Type type = player.GetType();
```

`GetType()`은 객체가 가진 런타임 타입 정보를 반환한다. Assembly 전체에서 문자열로 타입을 검색하는 작업과 같지 않다.

```cs
Type? type = Type.GetType(typeName);
```

이름 해석, Assembly 확인과 타입 검색이 필요한 API는 더 많은 작업을 수행할 수 있다.

### 멤버 조회

```cs
MethodInfo? method = type.GetMethod("TakeDamage");
```

Runtime은 타입의 메서드에서 이름, 접근 범위와 시그니처가 맞는 항목을 찾는다.

모든 메서드를 열거하고 LINQ로 다시 검색하면 불필요한 결과 배열과 순회가 추가된다.

```cs
MethodInfo? method = type
    .GetMethods()
    .FirstOrDefault(item => item.Name == "TakeDamage");
```

찾으려는 멤버를 API 인수로 직접 지정하는 편이 의도와 비용이 명확하다.

```cs
MethodInfo? method = type.GetMethod(
    "TakeDamage",
    BindingFlags.Public | BindingFlags.Instance,
    binder: null,
    types: [typeof(int)],
    modifiers: null);
```

### Attribute 조회

```cs
SkillAttribute? attribute =
    type.GetCustomAttribute<SkillAttribute>();
```

Attribute Metadata를 찾고 실제 Attribute 객체를 생성할 수 있다.

선언 정보만 필요하다면 객체를 생성하지 않는 API를 선택할 수 있다.

```cs
IList<CustomAttributeData> data =
    type.GetCustomAttributesData();
```

### 동적 호출

```cs
method.Invoke(player, [20]);
```

동적 호출에는 대상 객체, 인수 개수와 타입 검사, `object` 변환과 예외 Wrapper 처리가 포함될 수 있다.

일반 호출보다 JIT가 최적화하기 어려운 경계도 생긴다.

### 동적 객체 생성

```cs
object? instance = Activator.CreateInstance(type);
```

생성 가능한 타입인지 확인하고 호환되는 생성자를 찾아 호출한다.

객체 생성 자체의 메모리 비용에 Reflection 탐색과 호출 비용이 추가될 수 있다.

```text
비용이 작은 편
GetType(), typeof
↓
Metadata와 멤버 조회
↓
Attribute 객체 생성
↓
MethodInfo.Invoke(), ConstructorInfo.Invoke
```

정확한 비용은 .NET Runtime, 호출 형태, 타입 구조와 JIT 또는 AOT 환경에 따라 달라진다. 고정된 배율로 단정할 수 없다.

---

## 코드 예제

매번 메서드를 검색하고 호출하는 코드는 반복 비용을 만든다.

```cs
public void ApplyDamage(object target, int damage)
{
    MethodInfo? method = target
        .GetType()
        .GetMethod("TakeDamage");

    method?.Invoke(target, [damage]);
}
```

같은 타입의 객체에 반복 호출한다면 MethodInfo를 캐시할 수 있다.

```cs
public sealed class DamageInvoker
{
    private readonly Dictionary<Type, MethodInfo> cache = new();

    public void Apply(object target, int damage)
    {
        Type type = target.GetType();

        if (!cache.TryGetValue(type, out MethodInfo? method))
        {
            method = type.GetMethod(
                "TakeDamage",
                [typeof(int)])
                ?? throw new MissingMethodException(
                    type.FullName,
                    "TakeDamage");

            cache.Add(type, method);
        }

        method.Invoke(target, [damage]);
    }
}
```

멤버 탐색은 타입마다 한 번으로 줄어든다.

하지만 매 호출의 `object` 인수 배열과 `Invoke()` 경계는 남는다.

### Delegate 캐시

시그니처가 정해져 있다면 Delegate로 변환할 수 있다.

```cs
public delegate void DamageHandler(
    object target,
    int damage);
```

타입마다 Open Delegate를 구성하려면 대상 타입 시그니처와 호환되는 Wrapper가 필요할 수 있다. 공통 인터페이스를 사용할 수 있다면 구조가 더 단순해진다.

```cs
public interface IDamageable
{
    void TakeDamage(int damage);
}
```

```cs
public void ApplyDamage(
    IDamageable target,
    int damage)
{
    target.TakeDamage(damage);
}
```

Reflection은 등록 단계에서 객체가 `IDamageable`을 구현하는지 찾는 데 사용하고 반복 호출은 인터페이스로 수행할 수 있다.

```text
초기화
Reflection으로 타입 검색
↓
IDamageable 구현 객체 등록

게임 루프
IDamageable.TakeDamage() 직접 호출
```

동적 구조가 꼭 필요하지 않다면 Reflection을 더 빠르게 만드는 것보다 정적 계약으로 전환하는 편이 효과가 크다.

### Attribute 캐시

타입별 Attribute 정보를 캐시할 수 있다.

```cs
public sealed record SkillMetadata(
    string Id,
    int Priority);
```

```cs
private readonly Dictionary<Type, SkillMetadata> metadataCache
    = new();

public SkillMetadata GetMetadata(Type type)
{
    if (metadataCache.TryGetValue(
            type,
            out SkillMetadata? metadata))
    {
        return metadata;
    }

    SkillAttribute attribute =
        type.GetCustomAttribute<SkillAttribute>()
        ?? throw new InvalidOperationException(type.FullName);

    metadata = new SkillMetadata(
        attribute.Id,
        attribute.Priority);

    metadataCache.Add(type, metadata);
    return metadata;
}
```

Attribute 객체 자체보다 필요한 값만 별도 Metadata 객체로 변환해 저장한다.

### 캐시 Key

문자열만 Key로 사용하면 Namespace와 오버로드 충돌을 처리해야 한다.

```cs
Dictionary<string, MethodInfo> cache;
```

타입과 메서드 시그니처를 포함한 Key를 사용할 수 있다.

```cs
public readonly record struct MethodCacheKey(
    Type DeclaringType,
    string Name,
    Type ArgumentType);
```

조회 조건이 다른 결과를 같은 Cache Entry로 잘못 재사용하지 않도록 `BindingFlags`, Generic 인수와 매개변수 타입까지 고려해야 한다.

---

## 내부 동작

Reflection 성능 비용은 크게 검색, 객체화와 동적 호출에서 발생한다.

### Metadata 검색

```cs
type.GetMethods();
```

Runtime은 타입과 상속 계층의 Metadata에서 조건에 맞는 메서드를 찾아 결과를 구성한다.

```text
Runtime Type 확인
↓
멤버 Metadata 탐색
↓
BindingFlags 적용
↓
MethodInfo 결과 구성
↓
결과 배열 반환
```

반환되는 배열과 일부 Reflection 표현 객체가 관리되는 메모리 할당에 영향을 줄 수 있다.

Runtime 내부에 Metadata 캐시가 있더라도 호출자가 요청한 결과 배열과 후속 LINQ 처리는 별도 비용을 만들 수 있다.

### Boxing과 인수 배열

```cs
method.Invoke(player, [20]);
```

값 타입 `20`은 `object` 배열에 들어가면서 Boxing될 수 있다.

```text
int 20
↓ Boxing
object
↓
object[]
```

반환값이 값 타입이면 다시 Boxing된 `object`로 제공될 수 있다.

```cs
int result = (int)method.Invoke(target, arguments)!;
```

짧은 호출 하나에서도 배열과 Boxed Value 할당이 발생할 수 있어 매우 빈번한 경로에서는 GC 압력을 높인다.

### JIT 최적화 경계

직접 호출은 JIT가 실제 메서드를 분석하고 Inline, 상수 전파와 Devirtualization을 적용할 가능성이 있다.

```cs
player.TakeDamage(20);
```

`MethodInfo.Invoke()`는 런타임 Metadata를 통한 간접 호출이므로 호출자의 코드와 대상 메서드를 같은 방식으로 최적화하기 어렵다.

Delegate 호출도 직접 호출과 완전히 같지는 않지만 `object` 배열과 Reflection Binder를 거치지 않는 타입이 지정된 호출 경로를 제공한다.

### 캐시의 비용

캐시는 검색을 줄이지만 무료가 아니다.

```text
Reflection Cache
├─ Dictionary 조회 비용
├─ Key와 Entry 메모리
├─ 초기 구성 시간
├─ Thread 동기화
└─ 캐시 무효화 문제
```

동적으로 Assembly를 로드하고 해제하는 환경에서 `Type`과 `MethodInfo`를 Static Cache에 보관하면 해당 로딩 문맥이 해제되지 못할 수 있다.

Unity의 일반 Player 환경에서는 Assembly를 자주 Unload하지 않지만 Editor Domain Reload와 Play Mode 설정에서는 Cache 초기화 시점을 고려해야 한다.

Thread 여러 개가 동시에 캐시를 수정한다면 `ConcurrentDictionary`나 초기화 잠금이 필요할 수 있다.

---

## 실제 Unity에서는?

Unity에서 Reflection 비용이 문제가 되기 쉬운 위치는 반복되는 Player Loop이다.

```cs
private void Update()
{
    MethodInfo? method = target
        .GetType()
        .GetMethod("Tick");

    method?.Invoke(target, null);
}
```

매 프레임 타입 조회 이후 이름 검색과 동적 호출이 반복된다.

초기화 단계에서 인터페이스 참조를 확보할 수 있다.

```cs
private ITickable tickable;

private void Awake()
{
    tickable = target as ITickable
        ?? throw new InvalidOperationException();
}

private void Update()
{
    tickable.Tick();
}
```

### Editor와 Runtime 분리

Custom Inspector와 자동 등록 Tool은 Editor에서만 실행할 수 있다.

```text
Editor
├─ Assembly 전체 검색
├─ Attribute 분석
└─ Tool Metadata 생성

Runtime
└─ 생성된 결과 또는 캐시 사용
```

빌드 전에 필요한 Registry 데이터를 Asset이나 생성 코드로 만들어 Runtime Reflection을 제거하는 방식도 사용할 수 있다.

### Unity Profiler

성능을 확인할 때는 실제 Target과 호출 빈도를 재현해야 한다.

확인할 항목은 다음과 같다.

- Reflection API 자체 CPU 시간
- 호출 횟수
- `GC.Alloc`
- 초기화 Frame의 Spike
- Editor와 Player Build 차이
- Mono와 IL2CPP 차이

Editor Profiler에는 Editor 자체 작업과 Deep Profile Overhead가 섞일 수 있다. 최종 판단은 Target Platform의 Development Build에서 확인하는 것이 좋다.

### IL2CPP와 생성 코드

IL2CPP에서는 동적 코드 생성에 제약이 있을 수 있다. JIT 환경에서 사용하는 Expression Compile 또는 Runtime Code Generation 최적화가 같은 방식으로 동작한다고 가정해서는 안 된다.

타입이 정해진 Factory와 Source Generation 형태는 AOT 환경에서도 호출 경로를 명시적으로 만들 수 있다.

```cs
private static readonly Dictionary<string, Func<ISkill>> factories =
    new()
    {
        ["fireball"] = () => new FireballSkill(),
        ["heal"] = () => new HealSkill()
    };
```

등록 코드가 늘어나는 대신 Reflection 탐색, Stripping과 AOT 불확실성을 줄일 수 있다.

---

## 실무에서 자주 하는 오해

### Reflection API는 모두 같은 속도라는 오해

`GetType()`, 멤버 열거, Attribute 객체 생성과 `MethodInfo.Invoke()`는 수행하는 작업이 다르다.

Reflection이라는 이름만 보고 전체를 금지하지 말고 실제로 사용하는 API와 빈도를 구분해야 한다.

### 한 번만 실행하면 최적화가 필요 없다는 오해

초기화 한 번이라도 수천 개 Assembly와 Type을 검색하면 로딩 시간이 길어질 수 있다.

사용자가 체감하는 시작 시간과 Editor Domain Reload에 영향을 준다면 검색 범위와 Cache를 개선할 가치가 있다.

### 캐시하면 무조건 빨라진다는 오해

한 번만 사용하는 결과를 캐시하면 Dictionary와 메모리 비용만 추가될 수 있다.

조회 횟수, Cache Hit 비율과 객체 수명을 측정한 뒤 적용해야 한다.

### MethodInfo만 캐시하면 직접 호출과 같다는 오해

멤버 검색은 줄지만 `Invoke()`의 인수 배열, Boxing, 타입 검사와 예외 경계가 남는다.

반복 호출에서는 Delegate, 인터페이스 또는 직접 Factory로 경로를 바꾸는 것이 더 효과적일 수 있다.

### Editor 측정 결과가 Player 성능과 같다는 오해

Editor에는 Tooling, Domain과 Profile Overhead가 추가된다. IL2CPP Player는 실행 방식과 Stripping 조건도 다르다.

실제 Target Build에서 CPU와 할당을 측정해야 한다.

---

## 마무리

Reflection은 일반 호출보다 추가 작업이 있지만 모든 사용이 실제 성능 문제를 만드는 것은 아니다.

`GetType()`, Metadata 조회, Attribute 생성과 `Invoke()`는 비용 특성이 다르며 호출 빈도와 실행 위치를 함께 봐야 한다.

초기화 단계에서 타입과 멤버를 검색하고 결과를 캐시한 뒤 반복 실행에서는 Delegate, 인터페이스와 직접 호출로 전환하면 Reflection의 유연성과 정적 호출의 효율을 함께 사용할 수 있다.

캐시도 메모리, 초기화와 수명 관리 비용을 가진다. 추측으로 최적화하지 않고 Unity Profiler와 실제 Target Build의 CPU 시간, 호출 횟수와 GC Alloc을 기준으로 판단해야 한다.

---

## 핵심 정리

- Reflection API는 수행하는 작업에 따라 비용이 다르다.
- `GetType()`과 이름 기반 타입·멤버 검색을 같은 비용으로 판단해서는 안 된다.
- `MethodInfo.Invoke()`에는 인수 검사, 배열, Boxing과 간접 호출 비용이 발생할 수 있다.
- 같은 타입과 멤버를 반복 검색한다면 Metadata 결과를 캐시할 수 있다.
- 반복 호출에서는 MethodInfo보다 Delegate나 인터페이스가 적합할 수 있다.
- Attribute 객체 대신 필요한 Metadata 값만 변환해 캐시할 수 있다.
- 캐시는 Dictionary, 메모리, 동기화와 수명 관리 비용을 가진다.
- Unity 반복 실행 경로에서는 초기화 시점에 Reflection 작업을 끝내는 것이 좋다.
- 최종 성능은 실제 Target Build에서 CPU 시간과 GC Alloc으로 확인해야 한다.
