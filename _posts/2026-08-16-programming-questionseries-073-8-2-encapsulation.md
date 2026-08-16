---
title: "[궁금시리즈] 8-2. 캡슐화는 왜 필요할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-2-encapsulation/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:01 +0900
last_modified_at: 2026-08-16 12:00:01 +0900
---

## 들어가며

Player의 체력을 다음과 같이 공개할 수 있다.

```cs
public class Player
{
    public int Health;
}
```

외부에서는 이 필드에 자유롭게 접근할 수 있다.

```cs
player.Health -= 30;
player.Health = 999999;
player.Health = -100;
```

코드는 간단하지만 Player가 자신의 체력을 통제하지 못한다.

어떤 객체든 체력을 음수로 만들 수 있고, 최대 체력을 무시하거나 사망 처리를 건너뛸 수도 있다. 체력 규칙이 바뀌면 필드를 수정하는 모든 코드를 찾아야 한다.

캡슐화(Encapsulation)는 객체의 상태와 동작을 하나로 묶고, 외부에서 내부 상태에 접근하는 방식을 제한하는 객체지향 원리이다.

핵심은 데이터를 무조건 숨기는 것이 아니다.

객체가 유효한 상태를 스스로 유지하도록 상태 변경의 통로를 관리하는 데 있다.

---

## 개념 설명

객체에는 항상 지켜야 하는 규칙이 존재할 수 있다.

Player의 체력을 예로 들면 다음과 같다.

- 체력은 0보다 작아질 수 없다.
- 체력은 최대 체력을 넘을 수 없다.
- 체력이 0이 되면 사망 상태가 된다.
- 이미 사망한 Player는 추가 피해를 받지 않는다.

이처럼 객체가 항상 만족해야 하는 조건을 불변식(Invariant)이라고 한다.

필드를 외부에 공개하면 객체는 이 규칙을 보장할 수 없다.

```cs
player.Health = -100;
```

반면 필드를 숨기고 상태 변경 메서드를 제공하면 모든 변경이 같은 규칙을 거치게 된다.

```cs
public class Player
{
    private int health;

    public void TakeDamage(int damage)
    {
        health = Math.Max(0, health - damage);
    }
}
```

외부 객체는 체력 값을 직접 계산하지 않고 Player에게 피해 처리를 요청한다.

```cs
player.TakeDamage(30);
```

호출하는 쪽은 체력이 어떤 필드에 저장되는지, 방어력이나 무적 상태가 적용되는지 알 필요가 없다.

### 접근 제한자

C#은 멤버의 접근 범위를 제한하기 위해 접근 제한자를 제공한다.

| 접근 제한자 | 접근 범위 |
|---|---|
| `public` | 모든 코드에서 접근 가능 |
| `private` | 선언한 타입 내부에서만 접근 가능 |
| `protected` | 선언한 타입과 파생 타입에서 접근 가능 |
| `internal` | 같은 Assembly에서 접근 가능 |
| `protected internal` | 같은 Assembly 또는 파생 타입에서 접근 가능 |
| `private protected` | 같은 Assembly에 있는 파생 타입에서 접근 가능 |

캡슐화에서 가장 자주 사용하는 조합은 내부 상태를 `private`으로 두고 필요한 동작만 `public`으로 공개하는 방식이다.

```cs
public class Inventory
{
    private readonly List<Item> items = new();

    public void Add(Item item)
    {
        items.Add(item);
    }
}
```

접근 제한자는 캡슐화를 구현하는 도구이지만 접근 제한자를 사용했다는 사실만으로 좋은 캡슐화가 완성되는 것은 아니다.

### 필드와 프로퍼티

프로퍼티는 필드처럼 접근할 수 있으면서 읽기와 쓰기 방식을 제어한다.

```cs
public int Health { get; private set; }
```

외부에서는 값을 읽을 수 있지만 직접 변경할 수 없다.

```cs
Console.WriteLine(player.Health); // 가능
player.Health = 100;              // 컴파일 오류
```

프로퍼티의 Setter에 검증 로직을 넣을 수도 있다.

```cs
private int health;

public int Health
{
    get => health;
    private set => health = Math.Clamp(value, 0, MaxHealth);
}
```

다만 중요한 상태 변경에는 Setter보다 의미가 드러나는 메서드가 더 적절한 경우가 많다.

```cs
player.TakeDamage(20);
player.Heal(10);
```

다음 코드는 결과만 보여 준다.

```cs
player.Health = 80;
```

반면 `TakeDamage()`는 왜 상태가 변경되는지 표현하며 방어력, 피격 이벤트와 사망 처리 같은 규칙을 한곳에 둘 수 있다.

---

## 코드 예제

체력 규칙을 캡슐화한 Player는 다음과 같이 작성할 수 있다.

```cs
public class Player
{
    public int MaxHealth { get; }
    public int Health { get; private set; }
    public bool IsDead => Health == 0;

    public Player(int maxHealth)
    {
        if (maxHealth <= 0)
        {
            throw new ArgumentOutOfRangeException(nameof(maxHealth));
        }

        MaxHealth = maxHealth;
        Health = maxHealth;
    }

    public void TakeDamage(int damage)
    {
        if (damage <= 0 || IsDead)
        {
            return;
        }

        Health = Math.Max(0, Health - damage);
    }

    public void Heal(int amount)
    {
        if (amount <= 0 || IsDead)
        {
            return;
        }

        Health = Math.Min(MaxHealth, Health + amount);
    }
}
```

외부 코드는 Player의 규칙을 직접 구현하지 않는다.

```cs
Player player = new Player(100);

player.TakeDamage(30);
player.Heal(10);

Console.WriteLine(player.Health); // 80
```

체력이 최대치를 넘지 않고 0 아래로 내려가지 않는다는 규칙은 Player 내부에서 일관되게 적용된다.

### 컬렉션 캡슐화

필드를 `private`으로 만들었더라도 내부 컬렉션을 그대로 반환하면 상태가 다시 노출될 수 있다.

```cs
public class Inventory
{
    private readonly List<Item> items = new();

    public List<Item> Items => items;
}
```

외부에서 리스트를 직접 변경할 수 있다.

```cs
inventory.Items.Clear();
inventory.Items.Add(null);
```

그러면 인벤토리 용량 검사나 중복 아이템 규칙을 우회하게 된다.

읽기 전용 인터페이스를 공개하면 변경 통로를 제한할 수 있다.

```cs
public class Inventory
{
    private readonly List<Item> items = new();

    public IReadOnlyList<Item> Items => items;

    public bool Add(Item item)
    {
        if (item is null || items.Count >= 20)
        {
            return false;
        }

        items.Add(item);
        return true;
    }
}
```

외부에서는 아이템을 조회할 수 있지만 추가와 제거는 Inventory가 제공하는 메서드를 통해서만 수행한다.

`IReadOnlyList<T>`는 공개 API에서 변경 메서드를 감추지만 원본 리스트 자체의 변경을 막는 복사본은 아니다. Inventory 내부에서 리스트가 변경되면 외부에서 보는 내용도 달라진다.

완전한 스냅샷이 필요하다면 복사본이나 불변 컬렉션을 고려해야 한다.

---

## 내부 동작

캡슐화는 CLR이 객체의 상태를 자동으로 보호하는 기능이 아니다. 컴파일러와 런타임이 접근 제한 규칙을 확인하고, 개발자가 공개한 API를 통해 상태 변경 경로를 설계하는 방식이다.

```cs
private int health;
```

`private` 정보는 컴파일된 Assembly의 메타데이터에 남는다. C# 컴파일러는 외부 코드가 해당 필드에 직접 접근하면 컴파일 오류를 발생시킨다.

```cs
player.health = 10; // 접근 불가
```

프로퍼티도 내부적으로는 메서드 형태로 표현된다.

```cs
public int Health { get; private set; }
```

개념적으로 다음 접근자 메서드를 가진다.

```text
get_Health()
set_Health(int value)
```

Getter는 공개되고 Setter는 `private`이므로 외부 코드는 `get_Health()`에 해당하는 읽기만 수행할 수 있다.

자동 구현 프로퍼티를 사용하면 컴파일러는 값을 보관할 숨겨진 Backing Field도 생성한다.

```text
Health 프로퍼티
├─ <Health>k__BackingField
├─ get_Health()
└─ set_Health(int value)
```

따라서 프로퍼티는 단순한 공개 필드가 아니다. 접근 지점을 메서드로 유지하기 때문에 나중에 검증이나 계산 로직을 추가할 수 있다.

### Reflection은 private에 접근할 수 있다

Reflection을 사용하면 설정에 따라 비공개 멤버를 찾고 접근할 수 있다.

이 사실이 캡슐화를 무의미하게 만들지는 않는다. 캡슐화는 보안 경계가 아니라 정상적인 코드가 객체를 사용하는 규칙과 의도를 표현하는 설계 경계이다.

외부 입력으로부터 데이터를 보호하거나 권한을 통제해야 한다면 접근 제한자 외에 별도의 보안 검증이 필요하다.

---

## 실제 Unity에서는?

Unity에서는 Inspector에 값을 노출하기 위해 필드를 `public`으로 만드는 코드를 자주 볼 수 있다.

```cs
public int maxHealth = 100;
```

하지만 Inspector 노출과 외부 코드 접근은 서로 다른 목적이다.

`[SerializeField]`를 사용하면 필드는 `private`으로 유지하면서 Inspector에서 직렬화할 수 있다.

```cs
public class PlayerHealth : MonoBehaviour
{
    [SerializeField] private int maxHealth = 100;

    public int CurrentHealth { get; private set; }

    private void Awake()
    {
        CurrentHealth = maxHealth;
    }
}
```

다른 Component는 `maxHealth`를 직접 수정하지 못하지만 Inspector에서는 초기 설정값을 지정할 수 있다.

체력 변경도 메서드로 제한한다.

```cs
public void TakeDamage(int damage)
{
    if (damage <= 0 || CurrentHealth == 0)
    {
        return;
    }

    CurrentHealth = Mathf.Max(0, CurrentHealth - damage);
}
```

Unity 직렬화는 일반 C# 프로퍼티보다 필드를 중심으로 동작한다. `public` 프로퍼티라고 해서 기본적으로 Inspector에 나타나는 것은 아니며, `private` 필드도 `[SerializeField]`가 있으면 직렬화 대상이 될 수 있다.

Inspector 값도 항상 유효하다고 가정할 수 없다. `OnValidate()`를 사용하면 Editor에서 설정되는 값의 범위를 제한할 수 있다.

```cs
private void OnValidate()
{
    maxHealth = Mathf.Max(1, maxHealth);
}
```

런타임 규칙은 `TakeDamage()` 같은 도메인 메서드에서 유지하고, Inspector 설정값은 `OnValidate()`로 보조 검증하는 방식이 안전하다.

---

## 실무에서 자주 하는 오해

### 모든 필드에 프로퍼티를 만들면 캡슐화된다는 오해

다음 코드는 필드 문법을 프로퍼티 문법으로 바꿨을 뿐이다.

```cs
public int Health { get; set; }
```

외부에서 어떤 값이든 저장할 수 있으므로 객체는 체력 규칙을 보장하지 못한다. 중요한 기준은 프로퍼티 사용 여부가 아니라 상태 변경 권한과 규칙의 위치이다.

### private을 많이 사용할수록 좋다는 오해

모든 기능을 숨기면 객체가 다른 객체와 협력할 수 없다.

외부에 필요한 동작은 `public`으로 명확하게 제공하고 구현 세부 사항만 감춰야 한다. 지나치게 제한된 API도 우회 코드와 불필요한 결합을 만들 수 있다.

### Getter는 항상 안전하다는 오해

가변 컬렉션이나 변경 가능한 객체를 Getter로 그대로 반환하면 외부에서 내부 상태를 수정할 수 있다.

```cs
public List<Item> Items => items;
```

읽기 전용 인터페이스, 복사본 또는 필요한 조회 메서드를 제공할지 데이터의 성격에 따라 결정해야 한다.

### 캡슐화는 보안을 위한 기능이라는 오해

`private`은 프로그램 내부의 접근 규칙이다. 악의적인 코드나 Reflection, 메모리 조작까지 막는 보안 기능은 아니다.

캡슐화의 목적은 객체의 유효한 상태를 유지하고 변경의 영향을 내부로 제한하는 데 있다.

---

## 마무리

캡슐화는 필드를 `private`으로 바꾸는 문법 규칙이 아니다.

객체가 자신의 상태와 변경 규칙을 책임지고 외부에는 필요한 동작만 공개하는 설계 원리이다.

상태 변경을 메서드로 모으면 검증, 이벤트와 후속 처리를 한곳에서 관리할 수 있다. 내부 구현이 바뀌어도 공개 API가 유지된다면 객체를 사용하는 코드는 영향을 덜 받는다.

좋은 캡슐화는 모든 것을 숨기는 것이 아니라 객체가 지켜야 할 규칙과 외부가 사용할 수 있는 기능 사이에 명확한 경계를 만든다.

---

## 핵심 정리

- 캡슐화는 상태와 동작을 묶고 내부 접근을 통제하는 객체지향 원리이다.
- 객체는 캡슐화를 통해 자신의 불변식을 유지할 수 있다.
- 접근 제한자는 캡슐화를 구현하는 도구이며 그 자체가 캡슐화의 목적은 아니다.
- 중요한 상태 변경은 공개 Setter보다 의미가 드러나는 메서드가 적합할 수 있다.
- 자동 구현 프로퍼티는 Backing Field와 접근자 메서드로 구성된다.
- 내부 컬렉션을 그대로 반환하면 변경 규칙이 우회될 수 있다.
- Unity에서는 `[SerializeField] private`으로 Inspector 노출과 외부 코드 접근을 분리할 수 있다.
- `private`은 보안 경계가 아니라 객체 사용 규칙을 표현하는 설계 경계이다.
