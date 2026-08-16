---
title: "[궁금시리즈] 9-2. Reflection은 내부적으로 어떻게 동작할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/9-2-reflection-internals/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:14 +0900
last_modified_at: 2026-08-16 12:00:14 +0900
---

## 들어가며

Reflection으로 타입의 메서드를 조회하면 `MethodInfo`가 반환된다.

```cs
MethodInfo? method =
    typeof(Player).GetMethod("TakeDamage");
```

`MethodInfo`는 메서드 이름만 담은 문자열 객체가 아니다.

선언 타입, 매개변수, 반환형, 접근 제한자, Generic 정보와 실제 호출에 필요한 런타임 정보를 나타낸다.

```cs
Console.WriteLine(method?.Name);
Console.WriteLine(method?.ReturnType);

foreach (ParameterInfo parameter in method!.GetParameters())
{
    Console.WriteLine(parameter.ParameterType);
}
```

컴파일러가 소스 코드를 Assembly로 만들 때 타입과 멤버 구조를 Metadata Table에 기록한다. CLR은 Assembly를 로드하면서 이 정보를 런타임 타입 시스템과 연결한다.

Reflection은 소스 코드 파일을 다시 읽거나 C# 문법을 분석하는 기능이 아니다.

```text
C# Source
↓ 컴파일
IL + Metadata
↓ Assembly 로드
CLR Runtime Type System
↓ Reflection
Type, MethodInfo, FieldInfo
```

Reflection의 동작과 비용을 이해하려면 Assembly Metadata가 런타임 객체로 연결되는 과정을 확인해야 한다.

---

## 개념 설명

.NET Assembly에는 실행 코드인 IL과 코드의 구조를 설명하는 Metadata가 함께 들어 있다.

```text
Game.Core.dll
├─ PE Header
├─ CLR Header
├─ IL Code
├─ Metadata
└─ Resource
```

Metadata에는 타입과 멤버를 설명하는 여러 Table이 있다.

```text
Metadata Table
├─ TypeDef
├─ TypeRef
├─ MethodDef
├─ Field
├─ Property
├─ Param
├─ InterfaceImpl
├─ CustomAttribute
└─ AssemblyRef
```

### TypeDef와 TypeRef

현재 Assembly가 정의한 타입은 TypeDef에 기록된다.

```cs
namespace Game.Characters;

public class Player
{
}
```

Player의 이름, Namespace, 접근 수준, 기반 타입과 멤버 목록을 찾는 데 필요한 정보가 들어간다.

다른 Assembly에 정의된 타입을 사용하면 TypeRef와 AssemblyRef 같은 참조 정보가 필요하다.

```cs
public class Player : UnityEngine.MonoBehaviour
{
}
```

Player를 정의한 Assembly가 `MonoBehaviour` 자체를 다시 정의하지 않는다. UnityEngine Assembly의 타입을 참조한다.

```text
Game Assembly
├─ TypeDef: Player
└─ TypeRef: UnityEngine.MonoBehaviour
       ↓
UnityEngine Assembly
└─ TypeDef: MonoBehaviour
```

### Metadata Token

Metadata Table의 항목은 Metadata Token으로 식별할 수 있다.

```cs
MethodInfo method = typeof(Player)
    .GetMethod(nameof(Player.TakeDamage))!;

Console.WriteLine(method.MetadataToken);
```

Token은 어떤 Metadata Table의 몇 번째 항목인지를 나타내는 식별자 역할을 한다.

```text
Metadata Token
├─ Table 종류
└─ Table Row 번호
```

Token만으로 모든 Assembly에서 전역적으로 같은 멤버를 식별할 수 있는 것은 아니다. 해당 Token이 속한 Module의 문맥이 함께 필요하다.

```cs
Module module = method.Module;
int token = method.MetadataToken;

MethodBase? resolved = module.ResolveMethod(token);
```

Generic 타입과 메서드에서는 실제 타입 인수 문맥도 필요할 수 있다.

### Type과 RuntimeType

`System.Type`은 런타임 타입 정보를 사용하는 공개 추상 API이다.

```cs
Type type = typeof(Player);
```

실제 .NET 런타임은 로드된 타입을 나타내는 내부 구현 객체를 반환한다. 일반적인 .NET 환경에서는 이를 `RuntimeType` 계열 구현으로 설명할 수 있다.

개발 코드는 내부 구현에 직접 의존하지 않고 `Type` API를 사용한다.

```text
typeof(Player)
↓
CLR이 관리하는 Player 타입 정보
↓
Type API를 통해 노출
```

`Type` 객체에는 타입 이름만 있는 것이 아니다.

- 기반 타입
- 구현 인터페이스
- Generic 인수
- 배열과 포인터 여부
- 값 타입과 참조 타입 여부
- 멤버 조회 기능
- Runtime Type Handle

같은 로딩 문맥에서 같은 런타임 타입을 가리키는 Type 정보는 반복해서 재사용된다.

---

## 코드 예제

Assembly에서 명령 메서드를 검색하고 Metadata를 분석할 수 있다.

```cs
[AttributeUsage(AttributeTargets.Method)]
public sealed class ConsoleCommandAttribute : Attribute
{
    public string Name { get; }

    public ConsoleCommandAttribute(string name)
    {
        Name = name;
    }
}
```

```cs
public static class PlayerCommands
{
    [ConsoleCommand("heal")]
    public static void Heal(Player player, int amount)
    {
        player.RestoreHealth(amount);
    }
}
```

Scanner는 Assembly의 타입과 정적 메서드를 조회한다.

```cs
public sealed class CommandScanner
{
    public IReadOnlyList<MethodInfo> Scan(Assembly assembly)
    {
        List<MethodInfo> result = new();

        foreach (Type type in assembly.GetTypes())
        {
            MethodInfo[] methods = type.GetMethods(
                BindingFlags.Public |
                BindingFlags.NonPublic |
                BindingFlags.Static);

            foreach (MethodInfo method in methods)
            {
                if (method.IsDefined(
                    typeof(ConsoleCommandAttribute),
                    inherit: false))
                {
                    result.Add(method);
                }
            }
        }

        return result;
    }
}
```

Metadata를 사용해 지원하는 시그니처인지 검사할 수 있다.

```cs
private static bool IsSupported(MethodInfo method)
{
    if (method.ReturnType != typeof(void))
    {
        return false;
    }

    ParameterInfo[] parameters = method.GetParameters();

    return parameters.Length == 2 &&
           parameters[0].ParameterType == typeof(Player) &&
           parameters[1].ParameterType == typeof(int);
}
```

잘못된 메서드는 등록 단계에서 제외한다.

```cs
[ConsoleCommand("invalid")]
public static string InvalidCommand()
{
    return "Invalid";
}
```

호출 직전에 오류를 발견하는 것보다 초기 Scanner 단계에서 계약을 검사하는 편이 안전하다.

### MethodInfo를 Delegate로 변환

반복 호출할 Command는 Delegate로 변환해 보관할 수 있다.

```cs
public delegate void PlayerCommand(
    Player player,
    int value);
```

```cs
PlayerCommand command =
    method.CreateDelegate<PlayerCommand>();
```

Registry는 문자열 이름과 타입이 지정된 Delegate를 저장한다.

```cs
public sealed class CommandRegistry
{
    private readonly Dictionary<string, PlayerCommand> commands
        = new();

    public void Register(MethodInfo method)
    {
        ConsoleCommandAttribute attribute =
            method.GetCustomAttribute<ConsoleCommandAttribute>()!;

        PlayerCommand command =
            method.CreateDelegate<PlayerCommand>();

        commands.Add(attribute.Name, command);
    }

    public void Execute(
        string name,
        Player player,
        int value)
    {
        commands[name](player, value);
    }
}
```

```text
초기 등록
Reflection으로 Type과 Method 검색
↓
시그니처 검사
↓
Delegate 생성과 캐시

반복 실행
캐시된 Delegate 직접 호출
```

동적인 탐색은 초기화 단계로 제한하고 실제 반복 호출은 정적 타입이 있는 경로로 전환한다.

### 안전한 타입 로딩

`Assembly.GetTypes()`는 Assembly의 모든 타입을 반환한다. 일부 의존 Assembly나 타입을 로드할 수 없는 환경에서는 예외가 발생할 수 있다.

```cs
Type[] types;

try
{
    types = assembly.GetTypes();
}
catch (ReflectionTypeLoadException exception)
{
    types = exception.Types
        .Where(type => type is not null)
        .Cast<Type>()
        .ToArray();
}
```

예외의 `LoaderExceptions`에는 어떤 의존성을 불러오지 못했는지에 대한 정보가 포함될 수 있다.

Plugin이나 Editor 확장처럼 여러 Assembly를 검색하는 도구에서는 하나의 타입 로드 실패가 전체 검색을 중단하지 않게 처리할 필요가 있다.

---

## 내부 동작

Reflection 조회는 Metadata와 런타임 타입 구조를 단계적으로 사용한다.

```cs
MethodInfo? method = typeof(Player).GetMethod(
    "TakeDamage",
    BindingFlags.Public | BindingFlags.Instance);
```

개념적인 과정은 다음과 같다.

```text
Player의 Runtime Type 정보 확인
↓
요청한 멤버 종류는 Method
↓
이름이 TakeDamage인지 비교
↓
Public + Instance 조건 적용
↓
상속 계층과 시그니처 검사
↓
MethodInfo 반환
```

실제 Runtime은 성능을 위해 내부 캐시와 인덱스를 사용할 수 있다. 하지만 이름 비교, 범위 검사와 결과 객체 처리가 일반적인 직접 호출보다 추가된다.

### BindingFlags와 상속 계층

멤버 조회는 선언 타입뿐 아니라 상속된 멤버까지 포함할 수 있다.

```cs
typeof(Player).GetMethods(
    BindingFlags.Public |
    BindingFlags.Instance);
```

Player가 직접 선언한 메서드와 기반 클래스에서 상속한 공개 인스턴스 메서드가 함께 반환될 수 있다.

현재 타입이 직접 선언한 멤버만 필요하면 `DeclaredOnly`를 사용한다.

```cs
BindingFlags.Public |
BindingFlags.Instance |
BindingFlags.DeclaredOnly
```

기반 클래스의 `private` 멤버는 파생 타입 조회에서 일반적으로 직접 반환되지 않는다. 각 기반 타입을 따라가며 별도로 조회해야 할 수 있다.

```cs
for (Type? current = type;
     current is not null;
     current = current.BaseType)
{
    FieldInfo[] fields = current.GetFields(
        BindingFlags.Instance |
        BindingFlags.NonPublic |
        BindingFlags.DeclaredOnly);
}
```

Reflection 조회 결과는 사용한 API, BindingFlags와 상속 규칙에 따라 달라진다.

### MethodInfo.Invoke 과정

```cs
method.Invoke(player, [20]);
```

`Invoke()`는 대상 객체와 `object` 배열을 받는다.

런타임은 호출 전에 여러 조건을 확인해야 한다.

```text
대상 객체가 선언 타입과 호환되는가
↓
인수 개수가 맞는가
↓
각 인수 타입을 변환할 수 있는가
↓
접근과 호출 규칙을 만족하는가
↓
실제 메서드 실행
↓
반환 값을 object로 제공
```

호출된 메서드 내부에서 예외가 발생하면 Reflection 호출 경계에서 `TargetInvocationException`으로 감싸질 수 있다.

```cs
try
{
    method.Invoke(player, [20]);
}
catch (TargetInvocationException exception)
{
    Exception? original = exception.InnerException;
}
```

로그와 오류 처리에서는 Wrapper 예외뿐 아니라 `InnerException`도 확인해야 원래 원인을 찾을 수 있다.

### Runtime Handle

`Type`, `MethodInfo`와 `FieldInfo`는 런타임 내부 정보를 가리키는 Handle과 연결될 수 있다.

```cs
RuntimeTypeHandle typeHandle = typeof(Player).TypeHandle;
RuntimeMethodHandle methodHandle = method.MethodHandle;
```

Handle은 현재 프로세스의 Runtime 구조와 연결된 저수준 식별 정보이다. 영구 저장하거나 다른 실행 환경에서 재사용하는 ID로 사용해서는 안 된다.

Metadata Token은 Module 문맥의 Metadata 항목을 나타내고 Runtime Handle은 로드된 실행 환경의 Runtime 구조와 연결된다는 차이가 있다.

---

## 실제 Unity에서는?

Unity Editor에서는 여러 사용자 Assembly가 로드되며 Editor Tool이 타입을 검색하는 경우가 많다.

```cs
Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
```

모든 Assembly와 타입을 반복 검색하면 Editor Domain Reload나 Tool 초기화 시간이 길어질 수 있다.

검색 범위를 줄이고 결과를 캐시해야 한다.

```cs
Assembly gameplayAssembly = typeof(Player).Assembly;
Type[] gameplayTypes = gameplayAssembly.GetTypes();
```

Unity Editor API가 제공하는 Type 검색 도구를 사용할 수 있는 환경에서는 전체 Assembly를 직접 순회하는 것보다 해당 API가 적절한 경우도 있다.

### Domain Reload와 캐시

Editor에서 Script가 다시 컴파일되고 Domain Reload가 발생하면 정적 Reflection 캐시도 다시 만들어질 수 있다.

```cs
private static Dictionary<string, Type> typeCache = new();
```

Editor 설정에 따라 Domain Reload 동작이 달라질 수 있으므로 캐시가 항상 초기 상태라고 가정하면 안 된다.

Play Mode 진입과 Script Reload 시점에 캐시를 명확하게 초기화하거나 중복 등록을 안전하게 처리해야 한다.

### IL2CPP의 실행 코드

IL2CPP Build에서는 IL이 최종적으로 C++ 코드로 변환되고 네이티브 Binary가 만들어진다.

```text
C# Assembly
↓ IL2CPP
C++ Code
↓ Native Compiler
Player Binary
```

Reflection에 필요한 Metadata가 모두 사라지는 것은 아니다. Unity와 IL2CPP는 지원되는 Reflection 작업을 위해 Runtime Metadata를 유지한다.

하지만 정적 참조가 없는 타입과 멤버는 Managed Code Stripping 과정에서 제거될 수 있다.

```cs
Type.GetType(config.TypeName);
```

문자열만으로 접근하는 대상은 Build 분석기가 사용 여부를 판단하기 어렵다.

필요한 타입을 코드에서 참조하거나 `[Preserve]`, `link.xml`과 같은 보존 설정을 사용해야 할 수 있다.

Generic 조합과 동적 코드 생성은 AOT 환경에서 추가 제약을 받을 수 있다. Editor 실행 결과만으로 판단하지 않고 실제 Target의 Development Build에서 기능을 확인해야 한다.

### Runtime과 Editor 코드 분리

타입 검색이 Editor Tool에만 필요하다면 Editor 전용 Assembly로 분리하는 것이 좋다.

```text
Game.Runtime
└─ 실제 게임 코드

Game.Editor
└─ Reflection Scanner와 Editor Tool
```

Player Build에 필요하지 않은 검색 코드와 Metadata 의존성을 포함하지 않을 수 있고 Runtime 경로의 복잡성도 줄어든다.

---

## 실무에서 자주 하는 오해

### Reflection은 소스 코드를 읽는다는 오해

Reflection은 `.cs` 파일의 문법과 주석을 읽는 기능이 아니다.

컴파일된 Assembly의 Metadata와 런타임 타입 정보를 사용한다. 일반 주석, 지역 변수 이름과 일부 소스 수준 정보는 Reflection 대상이 아니다.

### Metadata Token은 전역 고유 ID라는 오해

Metadata Token은 해당 Module 안에서 Metadata 항목을 식별한다.

다른 Assembly와 Module에서 같은 숫자의 Token이 존재할 수 있고 재컴파일 후 Table 배치가 달라질 수도 있다. 영구적인 저장 ID로 사용해서는 안 된다.

### MethodInfo를 캐시하면 일반 호출과 같다는 오해

멤버 검색 비용은 줄지만 `MethodInfo.Invoke()`의 인수 배열, 타입 검사와 호출 경계 비용은 남을 수 있다.

반복 호출에서는 시그니처가 맞는 Delegate를 생성해 캐시하는 방식까지 검토할 수 있다.

### GetMethods()의 결과 순서를 믿어도 된다는 오해

Reflection이 반환하는 멤버의 순서를 프로그램 의미로 사용해서는 안 된다.

실행 순서가 필요하면 별도의 순서 Attribute나 명시적인 정렬 기준을 정의해야 한다.

### 모든 Assembly를 검색해도 초기화 한 번이면 괜찮다는 오해

타입과 Attribute 수가 많은 Editor 환경에서는 한 번의 전체 검색도 Domain Reload와 Play Mode 진입 시간을 늘릴 수 있다.

대상 Assembly, 기반 타입과 Attribute 범위를 줄이고 변경 시점에만 캐시를 다시 구성해야 한다.

---

## 마무리

Reflection은 C# 소스 코드를 다시 분석하는 기능이 아니라 Assembly의 Metadata Table과 CLR의 런타임 타입 시스템을 사용하는 기능이다.

타입과 멤버는 TypeDef, MethodDef와 CustomAttribute 같은 Metadata 항목으로 기록되고 `Type`, `MethodInfo`와 `FieldInfo`가 이를 사용할 수 있는 API로 제공한다.

이름 기반 검색과 `Invoke()`에는 멤버 탐색, 인수 검사, Boxing과 예외 Wrapper 같은 추가 과정이 존재한다. 초기 검색 결과를 캐시하고 반복 실행에서는 Delegate와 정적 계약으로 전환하면 비용과 런타임 오류 가능성을 줄일 수 있다.

Unity에서는 Editor Domain Reload, Assembly 검색 범위와 IL2CPP Code Stripping을 함께 고려해야 한다. Reflection 기반 기능은 실제 Target Build에서 보존 여부와 실행 결과를 검증해야 한다.

---

## 핵심 정리

- Assembly에는 IL과 함께 타입과 멤버를 설명하는 Metadata Table이 저장된다.
- TypeDef는 현재 Assembly의 타입 정의를, TypeRef는 다른 위치의 타입 참조를 나타낸다.
- Metadata Token은 Module 문맥 안의 Metadata 항목을 식별한다.
- `Type`은 CLR이 관리하는 런타임 타입 정보를 공개 API로 제공한다.
- Reflection 조회는 이름, BindingFlags, 상속 계층과 시그니처를 검사한다.
- `MethodInfo.Invoke()`는 대상과 인수를 검사하며 원래 예외를 감싸서 전달할 수 있다.
- 반복 호출에서는 Reflection 조회 결과와 타입이 지정된 Delegate를 캐시할 수 있다.
- Runtime Handle은 현재 실행 환경의 저수준 정보이며 영구 ID가 아니다.
- Unity에서는 Assembly 검색, Domain Reload, IL2CPP와 Code Stripping을 함께 고려해야 한다.
