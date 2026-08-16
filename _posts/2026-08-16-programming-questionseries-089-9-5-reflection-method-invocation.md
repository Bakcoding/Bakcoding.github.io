---
title: "[궁금시리즈] 9-5. Reflection으로 메서드는 어떻게 호출할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/9-5-reflection-method-invocation/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:17 +0900
last_modified_at: 2026-08-16 12:00:17 +0900
---

## 들어가며

일반적인 메서드 호출은 컴파일 시점에 호출 대상을 알고 있다.

```cs
player.TakeDamage(20);
```

컴파일러는 다음 내용을 미리 검사한다.

- Player에 `TakeDamage()`가 존재하는가
- 인수 `20`을 매개변수 타입으로 전달할 수 있는가
- 메서드에 접근할 수 있는가
- 반환값을 어떤 타입으로 처리할 것인가

Console Command나 자동 테스트 도구에서는 메서드 이름이 실행 중에 문자열로 주어질 수 있다.

```cs
string commandName = input.Command;
```

이름을 코드에 직접 호출문으로 작성할 수 없으므로 타입에서 `MethodInfo`를 찾고 동적으로 실행해야 한다.

```cs
MethodInfo? method =
    player.GetType().GetMethod(commandName);

method?.Invoke(player, [20]);
```

Reflection 호출은 런타임에 메서드를 선택할 수 있는 유연성을 제공한다.

대신 컴파일러가 보장하던 이름, 인수와 반환형 검사의 일부를 직접 처리해야 하며 잘못된 호출은 실행 시점 예외가 된다.

---

## 개념 설명

`MethodInfo.Invoke()`는 대상 객체와 인수 배열을 받아 메서드를 호출한다.

```cs
object? result = method.Invoke(target, arguments);
```

첫 번째 인수는 인스턴스 메서드를 실행할 대상 객체이다.

두 번째 인수는 메서드에 전달할 값의 `object` 배열이다.

```cs
MethodInfo method = typeof(Player)
    .GetMethod(nameof(Player.TakeDamage))!;

method.Invoke(player, [20]);
```

### 인스턴스 메서드

인스턴스 메서드는 대상 객체가 필요하다.

```cs
public class Player
{
    public void Heal(int amount)
    {
    }
}
```

```cs
MethodInfo method = typeof(Player)
    .GetMethod(nameof(Player.Heal))!;

method.Invoke(player, [10]);
```

대상 객체가 `null`이거나 선언 타입과 호환되지 않으면 호출에 실패한다.

```cs
method.Invoke(null, [10]); // 인스턴스 대상 없음
method.Invoke(monster, [10]); // 대상 타입이 다름
```

### 정적 메서드

정적 메서드는 인스턴스가 필요하지 않으므로 대상에 `null`을 전달한다.

```cs
public static class DamageUtility
{
    public static int Calculate(int attack, int defense)
    {
        return Math.Max(0, attack - defense);
    }
}
```

```cs
MethodInfo method = typeof(DamageUtility)
    .GetMethod(nameof(DamageUtility.Calculate))!;

object? result = method.Invoke(null, [30, 10]);
```

### 반환값

`Invoke()`의 반환형은 `object?`이다.

```cs
int damage = (int)result!;
```

메서드가 `void`를 반환하면 결과는 `null`이다.

```cs
object? result = healMethod.Invoke(player, [10]);
Console.WriteLine(result is null); // True
```

실제 반환형은 `MethodInfo.ReturnType`으로 확인할 수 있다.

```cs
Type returnType = method.ReturnType;
```

값 타입 반환값은 `object`로 제공되는 과정에서 Boxing될 수 있다.

### 오버로드 선택

같은 이름의 메서드가 여러 개 존재할 수 있다.

```cs
public void Attack(Character target) { }
public void Attack(Character target, Skill skill) { }
```

이름만 전달하면 어떤 메서드를 의미하는지 모호할 수 있다.

```cs
typeof(Player).GetMethod("Attack");
```

매개변수 타입을 지정해 정확한 오버로드를 찾는다.

```cs
MethodInfo? basicAttack = typeof(Player).GetMethod(
    "Attack",
    [typeof(Character)]);

MethodInfo? skillAttack = typeof(Player).GetMethod(
    "Attack",
    [typeof(Character), typeof(Skill)]);
```

메서드 이름만으로 Registry를 구성하면 오버로드 충돌이 발생할 수 있다. 전체 시그니처 또는 별도 Attribute ID를 Key로 사용해야 한다.

---

## 코드 예제

Attribute가 붙은 Console Command를 검색하고 동적으로 호출할 수 있다.

```cs
[AttributeUsage(AttributeTargets.Method)]
public sealed class CommandAttribute : Attribute
{
    public string Name { get; }

    public CommandAttribute(string name)
    {
        Name = name;
    }
}
```

```cs
public sealed class PlayerCommands
{
    [Command("heal")]
    public void Heal(Player player, int amount)
    {
        player.RestoreHealth(amount);
    }

    [Command("name")]
    public string GetName(Player player)
    {
        return player.Name;
    }
}
```

Registry는 Command 이름과 호출 대상을 저장한다.

```cs
public sealed record CommandEntry(
    object Target,
    MethodInfo Method);
```

```cs
public sealed class CommandRegistry
{
    private readonly Dictionary<string, CommandEntry> entries
        = new();

    public void Register(object target)
    {
        Type type = target.GetType();

        foreach (MethodInfo method in type.GetMethods(
            BindingFlags.Public |
            BindingFlags.NonPublic |
            BindingFlags.Instance))
        {
            CommandAttribute? attribute =
                method.GetCustomAttribute<CommandAttribute>();

            if (attribute is null)
            {
                continue;
            }

            entries.Add(
                attribute.Name,
                new CommandEntry(target, method));
        }
    }
}
```

실행할 때 문자열 인수를 실제 매개변수 타입으로 변환해야 한다.

```cs
public object? Execute(
    string name,
    string[] rawArguments)
{
    if (!entries.TryGetValue(
            name,
            out CommandEntry? entry))
    {
        throw new KeyNotFoundException(name);
    }

    ParameterInfo[] parameters =
        entry.Method.GetParameters();

    if (parameters.Length != rawArguments.Length)
    {
        throw new ArgumentException(
            "인수 개수가 일치하지 않는다.");
    }

    object?[] arguments = new object?[parameters.Length];

    for (int i = 0; i < parameters.Length; i++)
    {
        arguments[i] = ConvertArgument(
            rawArguments[i],
            parameters[i].ParameterType);
    }

    return entry.Method.Invoke(entry.Target, arguments);
}
```

문자열 변환 규칙을 별도 메서드로 둔다.

```cs
private static object ConvertArgument(
    string value,
    Type targetType)
{
    if (targetType == typeof(string))
    {
        return value;
    }

    if (targetType.IsEnum)
    {
        return Enum.Parse(targetType, value, ignoreCase: true);
    }

    return Convert.ChangeType(value, targetType);
}
```

실제 게임 객체인 Player를 Command 인수로 전달하려면 문자열 변환만으로 부족하다. ID로 객체를 찾는 Resolver나 호출 Context가 추가로 필요하다.

Command 시스템은 허용하는 매개변수 타입과 변환 규칙을 명확하게 제한해야 한다.

### ref와 out 매개변수

Reflection 호출의 인수 배열은 `ref`와 `out` 결과를 다시 전달하는 통로로 사용된다.

```cs
public static bool TryParseLevel(
    string text,
    out int level)
{
    return int.TryParse(text, out level);
}
```

```cs
MethodInfo method = typeof(LevelParser)
    .GetMethod(nameof(LevelParser.TryParseLevel))!;

object?[] arguments = ["10", null];

bool success = (bool)method.Invoke(null, arguments)!;
int level = (int)arguments[1]!;
```

호출이 끝난 뒤 `out level` 값은 `arguments[1]`에 반영된다.

```text
호출 전 arguments
├─ [0] "10"
└─ [1] null

호출 후 arguments
├─ [0] "10"
└─ [1] 10
```

`ParameterInfo.ParameterType.IsByRef`로 `ref/out` 형태를 확인할 수 있고 `IsOut`으로 출력 매개변수 여부를 구분할 수 있다.

### Generic 메서드

Generic 메서드 정의는 타입 인수가 결정되지 않아 그대로 호출할 수 없다.

```cs
public static T Create<T>()
    where T : new()
{
    return new T();
}
```

```cs
MethodInfo definition = typeof(Factory)
    .GetMethod(nameof(Factory.Create))!;

Console.WriteLine(definition.IsGenericMethodDefinition); // True
```

`MakeGenericMethod()`로 실제 타입 인수를 적용한다.

```cs
MethodInfo closedMethod =
    definition.MakeGenericMethod(typeof(Player));

Player player = (Player)closedMethod.Invoke(null, null)!;
```

타입 인수가 Generic 제약 조건을 만족하지 않으면 메서드를 구성하는 단계에서 예외가 발생할 수 있다.

---

## 내부 동작

일반 호출은 컴파일된 코드에 대상 메서드 정보가 직접 기록된다.

```cs
player.TakeDamage(20);
```

JIT는 호출 대상을 분석하고 Inline 같은 최적화를 적용할 수 있다.

Reflection 호출은 `MethodInfo`와 `object` 배열을 거쳐 런타임에 호출을 준비한다.

```text
MethodInfo.Invoke()
↓
정적·인스턴스 메서드 확인
↓
대상 객체 타입 검사
↓
매개변수 개수와 타입 검사
↓
ref/out과 값 타입 변환 준비
↓
실제 메서드 호출
↓
반환값 Boxing 또는 null 처리
```

Runtime 구현은 반복 호출을 위해 내부 호출 Stub을 캐시할 수 있지만 `object` 기반 경계와 인수 검사는 일반적으로 남는다.

### 인수 배열

```cs
method.Invoke(player, [20]);
```

배열 생성과 `int` Boxing이 발생할 수 있다.

```text
int 20
↓ Boxing
object
↓
object[] arguments
```

대량 반복에서 매번 배열을 만들면 GC Alloc이 누적될 수 있다.

인수 배열을 재사용할 수 있는 경우도 있지만 `ref/out` 호출은 배열 내용이 변경되므로 상태를 주의해야 한다.

### 호출 예외

호출된 메서드가 예외를 던지면 Reflection 경계에서 `TargetInvocationException`으로 감싸질 수 있다.

```cs
try
{
    method.Invoke(target, arguments);
}
catch (TargetInvocationException exception)
{
    Exception original = exception.InnerException
        ?? exception;

    Console.WriteLine(original.Message);
}
```

인수 타입이나 개수가 잘못된 경우에는 실제 메서드가 실행되기 전에 Reflection API 자체에서 예외가 발생한다.

```text
호출 준비 오류
└─ TargetParameterCountException, ArgumentException 등

호출된 메서드 내부 오류
└─ TargetInvocationException.InnerException
```

두 종류를 구분해야 정확한 오류 원인을 기록할 수 있다.

### Delegate 변환

시그니처를 알고 있고 반복 호출한다면 `CreateDelegate()`로 Reflection 호출 경계를 줄일 수 있다.

```cs
public delegate void DamageCommand(
    Player player,
    int damage);
```

정적 메서드라면 다음처럼 변환할 수 있다.

```cs
DamageCommand command =
    method.CreateDelegate<DamageCommand>();
```

인스턴스 메서드는 대상 객체를 고정한 Closed Delegate를 만들 수 있다.

```cs
Action<int> command =
    method.CreateDelegate<Action<int>>(player);

command(20);
```

```text
초기화
MethodInfo 검색
↓
Delegate 생성

반복 실행
타입이 지정된 Delegate 호출
```

Delegate 생성 시 시그니처가 맞지 않으면 오류가 발생하므로 초기 등록 단계에서 문제를 찾을 수 있다.

---

## 실제 Unity에서는?

Unity에는 문자열로 메서드를 호출하는 `SendMessage()`가 있다.

```cs
gameObject.SendMessage(
    "TakeDamage",
    20,
    SendMessageOptions.DontRequireReceiver);
```

호출하는 코드는 Component의 구체 타입을 몰라도 된다. 하지만 메서드 이름이 문자열이므로 이름 변경과 인수 오류를 컴파일러가 확인하지 못한다.

```cs
gameObject.SendMessage("TakeDamge", 20); // 오타
```

가능하다면 인터페이스와 직접 호출을 사용하는 편이 안전하다.

```cs
if (gameObject.TryGetComponent(out IDamageable target))
{
    target.TakeDamage(20);
}
```

Reflection과 `SendMessage()`는 타입이 실행 중에만 결정되고 명시적인 계약을 만들기 어려운 Tooling이나 확장 시스템에 제한적으로 사용하는 것이 좋다.

### Animation Event

Animation Event도 설정된 함수 이름을 기준으로 Component 메서드를 호출할 수 있다.

```text
Animation Clip Event
└─ Function: OnAttackHit
```

메서드 이름을 바꾸면 Clip 설정이 자동으로 안전하게 변경된다고 보장하기 어렵다.

Animation Event 진입 메서드는 작은 Adapter로 유지하고 실제 로직은 타입이 지정된 메서드에 위임할 수 있다.

```cs
private void OnAttackHit()
{
    attackController.ApplyHit();
}
```

### Editor Command

Reflection Command Registry는 Runtime보다 Editor 개발 도구에서 유용할 수 있다.

초기화 시 Attribute 메서드를 검색하고 Delegate로 캐시하면 Editor 버튼이나 Debug Console에서 동적으로 기능을 실행할 수 있다.

Runtime Build에 포함할 필요가 없다면 Editor 전용 Assembly로 분리하여 IL2CPP와 Code Stripping 영향을 줄일 수 있다.

### IL2CPP

Reflection으로만 호출되는 메서드는 정적 호출 관계가 보이지 않아 Code Stripping 대상이 될 수 있다.

Attribute Scanner와 문자열 호출을 사용하는 기능은 필요한 타입과 메서드를 `[Preserve]`, `link.xml` 또는 명시적 코드 참조로 보존해야 할 수 있다.

Generic 메서드를 `MakeGenericMethod()`로 동적으로 구성하는 경우 필요한 AOT 코드가 생성되었는지도 실제 Target Build에서 확인해야 한다.

---

## 실무에서 자주 하는 오해

### 이름만 같으면 메서드를 호출할 수 있다는 오해

오버로드가 여러 개라면 이름만으로 호출 대상을 결정하기 어렵다.

매개변수 타입과 Generic 인수까지 포함한 시그니처를 확인하거나 별도 Attribute ID로 호출 대상을 명확히 해야 한다.

### Invoke가 인수를 자동으로 안전하게 변환한다는 오해

일부 호환 변환이 적용될 수 있지만 문자열을 모든 사용자 타입으로 자동 변환해 주는 Serializer가 아니다.

Command와 Tooling에서는 허용 타입과 변환 규칙을 직접 정의해야 한다.

### 메서드 예외가 그대로 전달된다는 오해

호출된 메서드 내부 예외는 `TargetInvocationException`으로 감싸질 수 있다.

로그와 오류 처리에서는 `InnerException`을 확인해야 원래 Stack Trace와 원인을 찾을 수 있다.

### MethodInfo를 캐시하면 성능 문제가 끝난다는 오해

검색 비용은 줄지만 `Invoke()`의 인수 배열, Boxing과 타입 검사는 남을 수 있다.

반복 호출에서는 타입이 지정된 Delegate로 변환하는 방법을 고려해야 한다.

### 문자열 호출이 결합도를 제거한다는 오해

컴파일 시점 타입 참조는 사라질 수 있지만 호출자는 메서드 이름, 인수 규칙과 실행 결과라는 암묵적 계약에 의존한다.

문자열 결합은 Compiler가 확인할 수 없어 일반 인터페이스보다 더 취약할 수 있다.

---

## 마무리

Reflection 메서드 호출은 `MethodInfo`에 대상 객체와 `object` 인수 배열을 전달하여 런타임에 메서드를 실행하는 방식이다.

인스턴스와 정적 메서드, 오버로드, 반환값, `ref/out`과 Generic 메서드를 처리할 수 있지만 호출 계약을 직접 검사해야 한다.

`Invoke()`에는 인수 배열, Boxing, 타입 검사와 예외 Wrapper 비용이 존재한다. 초기화 단계에서 MethodInfo를 찾고 반복 실행에서는 타입이 지정된 Delegate로 변환하면 안전성과 호출 비용을 개선할 수 있다.

Unity에서는 `SendMessage`, Animation Event와 Reflection 기반 Tooling의 문자열 계약을 주의해야 한다. 일반 게임 로직에는 인터페이스와 직접 호출을 우선하고 동적 호출이 필요한 경계에서만 Reflection을 사용하는 것이 좋다.

---

## 핵심 정리

- `MethodInfo.Invoke()`는 대상 객체와 `object` 인수 배열로 메서드를 호출한다.
- 인스턴스 메서드는 대상 객체가 필요하고 정적 메서드는 대상에 `null`을 전달한다.
- 반환값은 `object`로 제공되며 `void` 메서드는 `null`을 반환한다.
- 오버로드는 이름뿐 아니라 매개변수 타입을 지정해 정확하게 선택해야 한다.
- `ref/out` 결과는 호출 후 인수 배열에 반영된다.
- Generic 메서드 정의는 `MakeGenericMethod()`로 타입 인수를 적용한 뒤 호출한다.
- 내부 메서드 예외는 `TargetInvocationException`으로 감싸질 수 있다.
- 반복 호출에서는 `MethodInfo`를 타입이 지정된 Delegate로 변환할 수 있다.
- Unity의 문자열 기반 호출보다 인터페이스와 직접 호출을 우선하는 것이 안전하다.
