---
title: "[궁금시리즈] 9-8. Reflection을 사용할 때 자주 하는 실수 총정리"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/9-8-reflection-common-mistakes/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:20 +0900
last_modified_at: 2026-08-16 12:00:20 +0900
---

## 들어가며

Reflection은 컴파일 시점에 알 수 없는 타입과 멤버를 런타임에 다룰 수 있게 한다.

```cs
Type type = target.GetType();
MethodInfo? method = type.GetMethod("TakeDamage");
method?.Invoke(target, [20]);
```

짧은 코드로 동적인 기능을 만들 수 있지만 잘못 사용했을 때 드러나는 문제도 늦다.

```text
문자열 오타
└─ 컴파일 성공, 실행 중 실패

반복 검색
└─ 기능 정상, 실행 중 비용 누적

Private 멤버 의존
└─ 내부 구현 변경 후 실패

IL2CPP 빌드
└─ Editor 정상, Player에서 실패
```

Reflection에서 자주 생기는 실수는 API 사용법보다 경계를 정하지 않은 설계에서 시작한다. 어디에서 검색하고, 어떤 결과를 저장하며, 실패를 언제 발견할지 결정해야 한다.

---

## 개념 설명

### 문자열을 계약처럼 사용한다

다음 코드는 컴파일러가 메서드 이름을 확인하지 않는다.

```cs
MethodInfo? method = typeof(Player)
    .GetMethod("TakeDamge");
```

오타가 있어도 빌드는 성공하고 `null`만 반환한다.

가능하면 `nameof`를 사용한다.

```cs
MethodInfo? method = typeof(Player)
    .GetMethod(nameof(Player.TakeDamage));
```

외부 설정에서 이름을 받아야 한다면 문자열을 여러 위치에서 직접 사용하지 않고 등록 단계에서 한 번 검증한다.

### 검색과 실행을 섞는다

Reflection 기반 기능은 두 단계로 나누는 편이 좋다.

```text
초기화 단계
타입과 멤버 검색 → 조건 검증 → 캐시 등록

실행 단계
검증된 정보 조회 → 호출
```

실행할 때마다 Assembly와 멤버를 다시 검색하면 오류가 반복 실행 중에 나타나고 비용도 누적된다.

### 실패를 무시한다

Null 조건 연산자는 예외를 막지만 필수 기능의 누락까지 숨길 수 있다.

```cs
method?.Invoke(target, arguments);
```

선택 기능이라면 건너뛸 수 있지만 반드시 존재해야 하는 메서드라면 초기화 중 명확한 예외를 발생시켜야 한다.

```cs
MethodInfo method = type.GetMethod(methodName)
    ?? throw new MissingMethodException(type.FullName, methodName);
```

---

## 코드 예제

문자열로 지정한 메서드를 매번 검색하는 Invoker가 있다.

```cs
public void Execute(object target, string methodName)
{
    MethodInfo? method = target
        .GetType()
        .GetMethod(methodName);

    method?.Invoke(target, null);
}
```

이 코드는 다음 정보를 확인하지 않는다.

```text
메서드가 실제로 존재하는가?
인스턴스 메서드인가?
매개변수가 없는가?
반환 타입이 기대한 형태인가?
동일한 이름의 Overload가 있는가?
```

### 조회 조건을 명시한다

```cs
public static MethodInfo FindCommand(
    Type type,
    string methodName)
{
    MethodInfo? method = type.GetMethod(
        methodName,
        BindingFlags.Public | BindingFlags.Instance,
        binder: null,
        types: Type.EmptyTypes,
        modifiers: null);

    if (method == null)
    {
        throw new MissingMethodException(
            type.FullName,
            methodName);
    }

    if (method.ReturnType != typeof(void))
    {
        throw new InvalidOperationException(
            $"{type.FullName}.{methodName} must return void.");
    }

    return method;
}
```

이름만 찾지 않고 접근 범위, 인스턴스 여부, 매개변수와 반환 타입을 계약으로 확인한다.

### 검색 결과를 캐시한다

```cs
public sealed class CommandInvoker
{
    private readonly Dictionary<(Type, string), MethodInfo> cache
        = new();

    public void Register(Type type, string methodName)
    {
        MethodInfo method = FindCommand(type, methodName);
        cache.Add((type, methodName), method);
    }

    public void Execute(object target, string methodName)
    {
        if (!cache.TryGetValue(
                (target.GetType(), methodName),
                out MethodInfo? method))
        {
            throw new InvalidOperationException(
                $"Command is not registered: {methodName}");
        }

        try
        {
            method.Invoke(target, null);
        }
        catch (TargetInvocationException exception)
        {
            throw new InvalidOperationException(
                $"Command failed: {methodName}",
                exception.InnerException ?? exception);
        }
    }
}
```

`MethodInfo.Invoke()` 안에서 대상 메서드가 던진 예외는 `TargetInvocationException`으로 감싸질 수 있다. 로그에는 바깥 예외만 남기지 않고 `InnerException`을 함께 확인해야 실제 원인을 찾을 수 있다.

### Attribute를 계약으로 사용한다

모든 Public 메서드를 이름으로 노출하는 대신 실행을 허용할 메서드만 표시할 수 있다.

```cs
[AttributeUsage(AttributeTargets.Method)]
public sealed class GameCommandAttribute : Attribute
{
    public string Id { get; }

    public GameCommandAttribute(string id)
    {
        Id = id;
    }
}
```

```cs
public sealed class PlayerCommands
{
    [GameCommand("heal")]
    public void Heal()
    {
        Debug.Log("Heal");
    }

    private void ResetInternalState()
    {
    }
}
```

Attribute가 붙은 메서드만 초기화 단계에서 수집하면 내부 메서드가 의도치 않게 호출 대상이 되는 일을 줄일 수 있다.

### 정적 계약으로 대체한다

모든 구현이 같은 기능을 제공한다면 Reflection보다 Interface가 목적에 맞다.

```cs
public interface IGameCommand
{
    string Id { get; }
    void Execute();
}
```

```cs
public sealed class HealCommand : IGameCommand
{
    public string Id => "heal";

    public void Execute()
    {
        Debug.Log("Heal");
    }
}
```

Reflection은 구현 타입을 한 번 발견해 등록하는 데만 사용하고 실제 호출은 Interface로 수행할 수 있다.

---

## 내부 동작

### GetMethod는 이름만 비교하지 않는다

타입에는 같은 이름을 가진 여러 Overload가 존재할 수 있다.

```cs
public void Load(string path) { }
public void Load(int slot) { }
```

```cs
MethodInfo? method = typeof(SaveSystem)
    .GetMethod("Load");
```

조회 조건이 모호하면 `AmbiguousMatchException`이 발생할 수 있다. 매개변수 타입을 함께 전달하면 대상을 확정할 수 있다.

```cs
MethodInfo? method = typeof(SaveSystem)
    .GetMethod("Load", [typeof(int)]);
```

### BindingFlags는 기본 동작을 바꾼다

`GetMethod(string)`은 기본적으로 Public 멤버를 검색한다. NonPublic이나 Static 멤버가 필요하다면 범위를 명시해야 한다.

```cs
BindingFlags flags =
    BindingFlags.NonPublic |
    BindingFlags.Instance;
```

`BindingFlags`를 사용할 때 `Instance` 또는 `Static`, `Public` 또는 `NonPublic`을 빠뜨리면 예상한 결과가 나오지 않을 수 있다.

상속된 Private 멤버는 파생 타입 조회에서 자동으로 모두 반환되지 않는다. 선언 타입을 따라 올라가며 검색해야 하는 구조라면 그 규칙도 명확히 정의해야 한다.

### Invoke는 호출 경계를 만든다

```cs
method.Invoke(target, [damage]);
```

Runtime은 대상 객체, 인수 개수, 타입 호환성과 접근 가능 여부를 검사한다. Value Type 인수가 `object`로 전달될 때 Boxing이 생길 수 있고 인수 배열도 할당될 수 있다.

반복 호출에서는 `MethodInfo`만 캐시해도 검색 비용은 줄지만 `Invoke()`의 검사와 인수 전달 비용은 남는다. 호출 빈도가 높다면 Delegate나 Interface 전환을 검토해야 한다.

### Metadata는 코드의 공개 계약과 다르다

Reflection으로 Private 필드를 읽을 수 있다는 사실이 해당 필드가 안정적인 계약이라는 뜻은 아니다.

```cs
FieldInfo? field = typeof(ThirdPartyComponent)
    .GetField("cachedValue", BindingFlags.NonPublic | BindingFlags.Instance);
```

라이브러리 내부 이름, 타입과 초기화 순서는 버전 업데이트에서 바뀔 수 있다. 컴파일러가 이 의존성을 확인하지 못하므로 문제가 런타임까지 미뤄진다.

---

## 실제 Unity에서는?

### Update에서 전체 Assembly를 검색하지 않는다

```cs
void Update()
{
    Type[] types = AppDomain.CurrentDomain
        .GetAssemblies()
        .SelectMany(assembly => assembly.GetTypes())
        .ToArray();
}
```

Assembly 열거, 타입 배열 생성과 LINQ 결과 할당이 매 프레임 반복된다. 타입 검색은 시작 시점이나 별도 등록 시점에 수행하고 결과를 캐시한다.

```cs
void Awake()
{
    commandRegistry.Initialize();
}
```

초기화 비용도 프로젝트 규모가 크면 Frame Drop을 만들 수 있으므로 필요하면 Loading 구간으로 옮기거나 Editor에서 등록 코드를 생성한다.

### MonoBehaviour 생성을 Activator로 처리하지 않는다

```cs
MonoBehaviour component =
    (MonoBehaviour)Activator.CreateInstance(componentType)!;
```

`MonoBehaviour`는 일반 C# 객체처럼 생성하지 않는다. Unity 객체 수명 주기를 거치도록 `GameObject.AddComponent(Type)`을 사용한다.

```cs
Component component = gameObject.AddComponent(componentType);
```

`ScriptableObject`도 `Activator.CreateInstance()` 대신 `ScriptableObject.CreateInstance(Type)`을 사용한다.

### Serialized Field 이름 의존을 관리한다

Editor Tool에서 `SerializedObject.FindProperty()`를 사용할 때도 문자열 이름은 변경에 취약하다.

```cs
SerializedProperty? health =
    serializedObject.FindProperty("health");
```

필드 이름을 변경하면 Custom Inspector가 조용히 동작하지 않을 수 있다. 반환값을 검사하고 관련 Editor Test를 두며, 직렬화 데이터 이름 변경에는 `[FormerlySerializedAs]`를 함께 검토한다.

### Domain Reload 설정을 고려한다

Reflection 결과를 Static Dictionary에 캐시하면 Enter Play Mode 설정에 따라 이전 Play Session의 상태가 남을 수 있다.

```cs
[RuntimeInitializeOnLoadMethod(
    RuntimeInitializeLoadType.SubsystemRegistration)]
private static void ResetCache()
{
    cache.Clear();
}
```

캐시를 만드는 시점뿐 아니라 언제 무효화할지도 정해야 한다.

### IL2CPP와 Stripping을 확인한다

Editor에서 검색되는 타입이 IL2CPP Player에서는 제거될 수 있다. 문자열이나 Attribute로만 접근하는 대상에는 필요한 범위의 `[Preserve]` 또는 `link.xml`을 적용하고 실제 플랫폼에서 테스트한다.

Generic 타입을 런타임에 조립한다면 Metadata 보존과 AOT 코드 생성 문제를 따로 확인해야 한다.

---

## 실무에서 자주 하는 오해

### Reflection은 한 번만 사용해도 느리다

초기화에서 소수 타입을 한 번 조회하는 비용과 매 프레임 반복하는 비용은 다르다. API의 존재보다 호출 빈도, 검색 범위와 할당을 기준으로 판단해야 한다.

### MethodInfo를 캐시하면 일반 호출과 같다

캐시는 멤버 검색을 줄인다. `Invoke()`의 인수 검사, Boxing, 배열 할당과 예외 Wrapper 가능성은 그대로 남을 수 있다.

### null이면 건너뛰는 것이 안전하다

선택적 기능에는 맞을 수 있지만 필수 등록이 누락된 상황까지 숨긴다. 필수 계약은 초기화 단계에서 실패하도록 구성해야 원인을 빨리 찾을 수 있다.

### Private 멤버도 찾을 수 있으니 사용해도 된다

접근 가능성과 안정적인 계약은 다른 문제다. 자신의 코드라도 이름 변경을 컴파일러가 추적하지 못하며 외부 라이브러리의 내부 구현은 더 쉽게 바뀐다.

### Reflection을 사용하면 확장성이 항상 높아진다

타입 자동 발견은 등록 코드를 줄이지만 실행 흐름과 의존성을 숨길 수 있다. 구현 목록이 고정되어 있거나 공통 동작이 명확하면 Interface와 명시적 Factory가 더 단순하다.

### Editor에서 검증했으니 배포해도 된다

최종 Player는 Managed Code Stripping과 IL2CPP AOT 조건이 다르다. Reflection 기능은 실제 빌드 설정과 대상 플랫폼에서 호출까지 확인해야 한다.

### 예외를 Reflection 문제로만 처리하면 된다

`TargetInvocationException`은 호출된 메서드의 예외를 감싼다. `InnerException`을 확인하지 않으면 실제 게임 로직 오류를 Reflection 오류로 잘못 판단할 수 있다.

---

## 마무리

Reflection은 동적인 구조를 만드는 도구지만 동적이라는 이유로 계약까지 느슨해질 필요는 없다.

안정적인 Reflection 코드는 검색 범위와 시그니처를 명확히 제한하고, 초기화 단계에서 결과를 검증하며, 실행 단계에서는 캐시된 정보만 사용한다.

```text
검색 범위 제한
↓
타입과 시그니처 검증
↓
중복과 누락 확인
↓
결과 캐시
↓
실행 중 예외 원인 보존
↓
Player 빌드 검증
```

Reflection을 어디에 사용할지도 중요하다. Serializer, Editor Tool, Plugin 검색처럼 런타임 타입 정보가 필요한 영역에서는 유용하다. 반대로 게임 루프의 반복 호출이나 고정된 구현 간 통신은 Interface, Delegate와 명시적 등록이 더 예측 가능하다.

Reflection 사용을 없애는 것이 목표가 아니라 동적인 부분을 등록 경계 안에 가두고 나머지 코드를 정적인 계약으로 유지하는 것이 핵심이다.

---

## 핵심 정리

- 문자열 멤버 이름은 컴파일러가 검증하지 않으므로 `nameof`와 초기화 검증을 사용한다.
- 이름만 조회하지 않고 `BindingFlags`, 매개변수와 반환 타입으로 검색 조건을 확정한다.
- Assembly와 멤버 검색은 등록 단계에서 한 번 수행하고 결과를 캐시한다.
- `MethodInfo` 캐시는 검색 비용만 줄이며 `Invoke()` 비용까지 없애지는 않는다.
- `TargetInvocationException.InnerException`을 확인해 호출된 코드의 실제 오류를 보존한다.
- Private 멤버 접근은 안정적인 API 계약이 아니므로 변경 위험을 고려한다.
- Unity 객체는 `Activator.CreateInstance()`가 아니라 각 객체의 생성 API를 사용한다.
- Static Reflection 캐시는 Domain Reload 설정에 맞는 초기화와 무효화가 필요하다.
- IL2CPP에서는 Code Stripping과 Generic AOT 문제를 분리해 실제 Player에서 검증한다.
- 대상과 동작이 고정되어 있다면 Interface, Delegate 또는 명시적 Factory가 더 적합하다.
