---
title: "[궁금시리즈] 9-7. Unity의 IL2CPP 환경에서 Reflection은 어떻게 동작할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/9-7-unity-il2cpp-reflection/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:19 +0900
last_modified_at: 2026-08-16 12:00:19 +0900
---

## 들어가며

Editor에서는 정상적으로 찾은 타입이 IL2CPP Player 빌드에서만 사라지거나, `Activator.CreateInstance()`와 Generic 메서드 호출이 실패하는 경우가 있다.

```cs
Type? type = Type.GetType("Game.Skills.FireballSkill");
object? skill = Activator.CreateInstance(type!);
```

이런 문제가 생기면 IL2CPP가 Reflection을 지원하지 않는다고 생각하기 쉽다.

하지만 IL2CPP에서도 `Type`, `MethodInfo`, Attribute 조회와 `Invoke()` 같은 Reflection API를 사용할 수 있다. 실제 원인은 주로 다음 두 과정에 있다.

```text
Managed Code Stripping
└─ 사용되지 않는다고 판단한 타입과 멤버 제거

AOT 컴파일
└─ 빌드 시점에 필요한 Native 코드 생성
```

Reflection으로 접근하는 코드는 일반 호출처럼 참조 관계가 명확하지 않다. UnityLinker가 사용 여부를 발견하지 못하거나 IL2CPP가 필요한 Generic 조합을 미리 생성하지 못하면 Editor와 Player의 결과가 달라질 수 있다.

---

## 개념 설명

### IL2CPP 빌드 과정

IL2CPP 빌드는 C# 코드를 실행 중에 기계어로 바꾸는 JIT 방식이 아니다.

```text
C# 소스 코드
↓
Managed Assembly와 IL
↓
UnityLinker의 Managed Code Stripping
↓
IL2CPP의 C++ 코드 변환
↓
플랫폼 Native 컴파일
```

빌드 시점에 실행 코드를 준비하는 AOT 방식이므로 런타임에 새로운 코드를 생성하는 `System.Reflection.Emit`은 사용할 수 없다.

반면 이미 빌드에 포함된 타입과 멤버의 Metadata를 읽고 호출하는 일반 Reflection은 가능하다.

### Code Stripping과 AOT는 다른 문제다

Code Stripping은 Player에 필요하지 않은 Managed 코드를 제거해 빌드 크기를 줄인다.

```cs
public sealed class FireballSkill
{
    public void Cast()
    {
        Debug.Log("Fireball");
    }
}
```

다른 코드에서 `new FireballSkill()`이나 `typeof(FireballSkill)`처럼 직접 참조하지 않고 문자열로만 찾는다면 UnityLinker가 이 타입을 사용하지 않는다고 판단할 수 있다.

AOT 문제는 필요한 코드가 빌드에 남아 있어도 빌드 시점에 구체적인 실행 형태를 결정하지 못하는 상황과 관련된다. 특히 런타임에 만들어지는 Generic 조합과 Generic Virtual Method는 주의가 필요하다.

### Reflection 자체가 제거 원인은 아니다

UnityLinker는 일부 일반적인 Reflection 패턴을 분석한다.

```cs
MethodInfo? method = typeof(Player)
    .GetMethod(nameof(Player.TakeDamage));
```

이처럼 타입과 멤버가 코드에 명확히 나타나면 필요한 대상을 발견할 가능성이 높다.

```cs
Type? type = Type.GetType(savedTypeName);
```

외부 데이터에서 받은 문자열처럼 빌드 시점에 값을 알 수 없는 패턴은 정적 분석만으로 실제 대상을 결정할 수 없다. 이때 필요한 코드를 직접 보존해야 한다.

---

## 코드 예제

Attribute를 가진 Skill 타입을 Reflection으로 찾아 생성한다고 가정한다.

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

```cs
public interface ISkill
{
    void Cast();
}

[Skill("fireball")]
public sealed class FireballSkill : ISkill
{
    public void Cast()
    {
        Debug.Log("Fireball");
    }
}
```

```cs
IEnumerable<Type> skillTypes = AppDomain.CurrentDomain
    .GetAssemblies()
    .SelectMany(assembly => assembly.GetTypes())
    .Where(type =>
        typeof(ISkill).IsAssignableFrom(type) &&
        !type.IsAbstract &&
        type.GetCustomAttribute<SkillAttribute>() != null);
```

검색 결과만으로 생성되는 타입은 정적 호출 경로가 없을 수 있다.

### Preserve Attribute 사용

Unity가 제공하는 `[Preserve]`를 필요한 타입에 지정할 수 있다.

```cs
using UnityEngine.Scripting;

[Preserve]
[Skill("fireball")]
public sealed class FireballSkill : ISkill
{
    public FireballSkill()
    {
    }

    public void Cast()
    {
        Debug.Log("Fireball");
    }
}
```

타입에 `[Preserve]`를 붙이면 타입과 기본 생성자가 보존된다. 필요한 멤버 범위를 더 세밀하게 지정하려면 `link.xml`이 적합하다.

### link.xml 사용

`link.xml`은 `Assets` 폴더 또는 그 하위 폴더에 둔다.

```xml
<linker>
  <assembly fullname="Game.Runtime">
    <type fullname="Game.Skills.FireballSkill" preserve="all" />
  </assembly>
</linker>
```

특정 메서드만 보존할 수도 있다.

```xml
<linker>
  <assembly fullname="Game.Runtime">
    <type fullname="Game.Skills.FireballSkill">
      <method name="Cast" />
    </type>
  </assembly>
</linker>
```

Assembly 이름과 Namespace를 포함한 전체 타입 이름이 실제 프로젝트와 일치해야 한다.

### 명시적 등록으로 전환

대상이 정해져 있다면 Reflection 검색 대신 생성 함수를 직접 등록할 수 있다.

```cs
public static class SkillFactory
{
    private static readonly Dictionary<string, Func<ISkill>> creators
        = new()
        {
            ["fireball"] = () => new FireballSkill(),
            ["heal"] = () => new HealSkill()
        };

    public static ISkill Create(string id)
    {
        if (!creators.TryGetValue(id, out Func<ISkill>? creator))
        {
            throw new KeyNotFoundException(id);
        }

        return creator();
    }
}
```

정적 참조가 생기므로 Stripping과 AOT가 필요한 코드를 판단하기 쉬워지고, 잘못된 문자열을 실행 전에 확인하기도 편해진다.

---

## 내부 동작

### UnityLinker의 정적 분석

UnityLinker는 Player 진입점과 보존 대상으로 표시된 Root에서 분석을 시작한다.

```text
Root 표시
↓
Root가 참조하는 타입과 멤버 추적
↓
필요한 Dependency 표시
↓
표시되지 않은 코드 제거
```

일반 메서드 호출은 IL에 대상이 기록되므로 참조를 따라가기 쉽다.

```cs
FireballSkill skill = new();
skill.Cast();
```

문자열이나 설정 파일을 통해 결정되는 타입은 IL에 직접 참조가 남지 않을 수 있다.

```cs
Type? type = Type.GetType(config.SkillTypeName);
```

UnityLinker가 모든 동적 값을 예측할 수 없기 때문에 `[Preserve]`, `link.xml` 또는 직접 참조로 필요한 대상을 알려줘야 한다.

### IL2CPP의 Metadata와 Native 코드

Reflection 조회에는 타입 이름, 멤버와 Attribute 같은 Metadata가 필요하다. 실제 메서드 실행에는 IL2CPP가 생성한 Native 코드가 필요하다.

따라서 다음 조건을 나눠서 확인해야 한다.

```text
타입을 찾지 못함
└─ Metadata 또는 타입이 Stripping되었는지 확인

타입은 찾지만 호출 실패
└─ 생성자, 메서드 보존 범위와 AOT 제약 확인

특정 Generic 조합만 실패
└─ 해당 조합의 Native 코드 생성 여부 확인
```

### Generic과 AOT

런타임에만 결정되는 Generic 타입은 빌드 과정이 실제 조합을 발견하지 못할 수 있다.

```cs
Type closedType = typeof(JsonBox<>).MakeGenericType(runtimeType);
object? box = Activator.CreateInstance(closedType);
```

특히 Reflection 기반 Serializer, DI Container와 메시지 시스템이 Generic 타입을 동적으로 조립할 때 문제가 드러날 수 있다.

필요한 조합을 코드에서 명시적으로 참조하거나, 코드 생성 단계에서 등록 코드를 만들거나, 사용하는 라이브러리가 제공하는 AOT 설정을 적용하는 방식으로 대응한다.

```cs
private static void AotReferences()
{
    _ = new JsonBox<PlayerData>();
    _ = new JsonBox<InventoryData>();
}
```

단순히 Metadata를 보존하는 것과 가능한 모든 Generic Native 코드를 생성하는 것은 같은 작업이 아니다.

---

## 실제 Unity에서는?

### Editor 결과만으로 판단하지 않는다

Editor와 최종 Player는 Scripting Backend와 Code Stripping 과정이 다를 수 있다.

```text
Editor에서 기능 확인
↓
대상 플랫폼의 Development Build 확인
↓
Release 조건과 동일한 Stripping Level 확인
↓
실제 기기에서 실행 경로 검증
```

iOS, WebGL처럼 IL2CPP가 중요한 플랫폼은 Reflection 기능을 사용하는 시점까지 실제로 실행해 봐야 한다.

### Managed Stripping Level을 낮추는 것으로 끝내지 않는다

Stripping Level을 낮추면 사라지는 코드가 줄어 증상이 없어질 수 있다. 하지만 빌드 크기가 늘고 필요한 보존 관계가 코드에 드러나지 않은 상태는 그대로 남는다.

원인을 확인한 뒤 필요한 타입과 멤버만 `[Preserve]` 또는 `link.xml`로 보존하고 원래 빌드 조건에서 다시 검증하는 편이 안전하다.

Stripping Level을 높일수록 더 적극적으로 코드가 제거되므로 프로젝트에서 사용하는 Reflection 경로를 Player 빌드 테스트에 포함해야 한다.

### Addressables와 외부 데이터

Addressables의 Prefab이나 Scene에서만 참조하는 타입은 Player 빌드 시점에 직접 보이지 않을 수 있다. Addressables는 빌드 순서에 따라 필요한 보존 정보를 생성하지만, 별도로 제작한 AssetBundle이나 원격 설정 기반 타입 로딩은 자동 분석 범위를 벗어날 수 있다.

다음 항목을 함께 확인한다.

```text
콘텐츠와 Player의 빌드 순서
Assembly Definition 이름
link.xml의 위치와 타입 전체 이름
플랫폼별 코드 분기
실제 배포 조건의 Stripping Level
```

### 보존 범위는 작게 유지한다

Assembly 전체를 보존하면 문제는 빠르게 가려질 수 있지만 빌드 크기와 변환 시간이 늘어날 수 있다.

```xml
<assembly fullname="Game.Runtime" preserve="all" />
```

원인을 찾는 임시 진단에는 사용할 수 있어도 최종 설정은 Reflection으로 접근하는 타입과 멤버 범위에 맞추는 편이 좋다.

---

## 실무에서 자주 하는 오해

### IL2CPP에서는 Reflection을 사용할 수 없다

IL2CPP에서도 빌드에 포함된 Metadata를 이용하는 Reflection은 가능하다. 런타임 코드 생성이 필요한 `Reflection.Emit`과 일반 Reflection 조회 및 호출을 구분해야 한다.

### Preserve를 붙이면 모든 AOT 문제가 해결된다

`[Preserve]`는 UnityLinker가 코드를 제거하지 않도록 표시하는 수단이다. 런타임에만 만들어지는 모든 Generic 조합의 실행 코드를 자동으로 준비한다는 의미는 아니다.

### Stripping Level을 낮추면 근본적으로 해결된다

코드가 제거되어 생긴 문제라면 증상은 사라질 수 있다. 하지만 어떤 타입이 동적으로 사용되는지 명시하지 않은 구조와 Generic AOT 문제는 남을 수 있다.

### Assembly 전체를 보존해도 비용이 없다

보존 범위가 넓을수록 제거할 수 있는 코드가 줄어 Player 크기와 빌드 처리량에 영향을 줄 수 있다. 필요한 범위를 기준으로 설정해야 한다.

### Editor에서 성공하면 Player에서도 성공한다

Editor 실행은 최종 플랫폼의 UnityLinker 결과와 IL2CPP Native 코드를 그대로 재현하지 않는다. Reflection 경로는 대상 플랫폼 Player 빌드를 기준으로 확인해야 한다.

### Type을 찾았으니 모든 메서드도 남아 있다

타입 Metadata가 존재하는 것과 내부의 모든 생성자와 메서드가 보존된 것은 별개다. 실제로 Reflection 호출하는 멤버까지 보존 범위를 확인해야 한다.

---

## 마무리

IL2CPP가 Reflection을 막는 것은 아니다.

문제는 빌드 시점의 정적 분석이 런타임에 결정되는 타입과 멤버를 항상 예측할 수 없고, AOT 환경이 필요한 실행 코드를 미리 준비해야 한다는 점에서 생긴다.

Reflection 관련 Player 오류를 발견하면 Code Stripping과 AOT를 분리해서 확인한다.

```text
대상이 빌드에 남아 있는가?
↓
필요한 멤버까지 보존되었는가?
↓
런타임 Generic 조합이 필요한가?
↓
실제 플랫폼과 Stripping 조건에서 재현되는가?
```

`[Preserve]`와 `link.xml`은 동적 참조를 빌드 과정에 전달하는 도구다. 대상이 고정되어 있다면 명시적 등록이나 코드 생성을 사용해 정적 참조를 만드는 편이 유지보수와 빌드 안정성까지 높일 수 있다.

---

## 핵심 정리

- IL2CPP에서도 Metadata가 보존된 타입과 멤버에는 Reflection을 사용할 수 있다.
- Managed Code Stripping은 사용되지 않는다고 판단한 코드를 제거하고, AOT는 빌드 시점에 Native 실행 코드를 준비한다.
- 문자열과 외부 데이터로만 접근하는 타입은 UnityLinker가 정적으로 발견하지 못할 수 있다.
- `[Preserve]`와 `link.xml`로 Reflection 대상의 타입, 생성자와 메서드를 보존할 수 있다.
- `Reflection.Emit`처럼 런타임 코드 생성이 필요한 기능은 AOT 환경에서 사용할 수 없다.
- 동적으로 구성하는 Generic 타입과 Generic 메서드는 보존 여부와 별도로 AOT 코드 생성을 확인해야 한다.
- Editor 성공만으로 판단하지 않고 실제 대상 플랫폼과 배포용 Stripping 조건에서 테스트해야 한다.
- 대상이 고정되어 있다면 명시적 Factory 등록이나 코드 생성이 더 예측 가능한 구조다.
