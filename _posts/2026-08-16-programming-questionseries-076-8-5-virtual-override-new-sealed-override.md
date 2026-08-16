---
title: "[궁금시리즈] 8-5. virtual, override, new, sealed override는 무엇이 다를까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-5-virtual-override-new-sealed-override/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:04 +0900
last_modified_at: 2026-08-16 12:00:04 +0900
---

## 들어가며

상속 관계에서 부모와 자식 클래스가 같은 이름의 메서드를 가지면 어떤 메서드가 실행되는지 혼동하기 쉽다.

```cs
public class Character
{
    public void Attack()
    {
        Console.WriteLine("Character Attack");
    }
}

public class Warrior : Character
{
    public void Attack()
    {
        Console.WriteLine("Warrior Attack");
    }
}
```

컴파일러는 `Warrior.Attack()`이 상속받은 멤버를 숨긴다는 경고를 표시한다.

이때 `virtual`, `override` 또는 `new`를 붙이면 경고를 없앨 수 있다. 하지만 세 키워드는 같은 문제를 해결하는 문법이 아니다.

```cs
Character character = new Warrior();
character.Attack();
```

실행할 메서드를 변수의 타입으로 결정할지, 실제 객체의 타입으로 결정할지가 달라진다.

`sealed override`는 한 단계 더 나아가 재정의된 동작을 이후 파생 클래스에서 변경하지 못하게 만든다.

이 차이를 이해하려면 메서드 이름보다 상속 계층의 가상 메서드 슬롯이 어떻게 연결되는지 확인해야 한다.

---

## 개념 설명

### virtual

`virtual`은 파생 클래스가 메서드의 동작을 재정의할 수 있도록 기반 클래스가 확장 지점을 여는 키워드이다.

```cs
public class Character
{
    public virtual void Attack()
    {
        Console.WriteLine("기본 공격");
    }
}
```

`virtual` 메서드에도 기본 구현을 작성할 수 있다. 파생 클래스가 재정의하지 않으면 이 구현이 실행된다.

```cs
Character character = new Character();
character.Attack(); // 기본 공격
```

모든 메서드가 기본적으로 가상 메서드인 것은 아니다. C#에서는 기반 클래스가 의도적으로 `virtual`을 선언해야 파생 클래스가 같은 가상 호출 관계에 참여할 수 있다.

### override

`override`는 기반 클래스의 `virtual` 또는 `abstract` 멤버를 파생 클래스가 재정의하는 키워드이다.

```cs
public class Warrior : Character
{
    public override void Attack()
    {
        Console.WriteLine("검 공격");
    }
}
```

기반 타입 변수로 호출해도 실제 객체가 Warrior이면 재정의된 메서드가 실행된다.

```cs
Character character = new Warrior();
character.Attack(); // 검 공격
```

`override`는 이름이 같은 새 메서드를 추가하는 것이 아니다. 기반 클래스가 만든 가상 메서드 계약에 Warrior의 구현을 연결한다.

재정의할 때는 메서드 이름과 매개변수 목록, 반환형이 기반 멤버와 호환되어야 한다. 접근 수준도 기반 멤버보다 임의로 좁힐 수 없다.

### new

`new`는 상속받은 멤버와 같은 이름의 새로운 멤버를 선언하여 기반 멤버를 숨긴다는 의도를 나타낸다.

```cs
public class Warrior : Character
{
    public new void Attack()
    {
        Console.WriteLine("Warrior의 새 공격");
    }
}
```

메서드 숨김(Method Hiding)은 오버라이딩과 다르다. 어떤 메서드를 호출할지는 참조 변수의 컴파일 시점 타입에 따라 결정된다.

```cs
Warrior warrior = new Warrior();
Character character = warrior;

warrior.Attack();   // Warrior의 새 공격
character.Attack(); // 기본 공격
```

두 변수는 같은 Warrior 객체를 가리키지만 서로 다른 메서드가 호출된다.

`new`는 객체를 생성하는 연산자와 철자가 같지만 여기서는 상속 멤버를 의도적으로 숨긴다는 의미이다.

### sealed override

`sealed override`는 상속받아 재정의한 메서드를 이후 파생 클래스에서 다시 재정의하지 못하게 한다.

```cs
public class Boss : Character
{
    public sealed override void Attack()
    {
        Console.WriteLine("Boss 고정 공격");
    }
}
```

```cs
public class FinalBoss : Boss
{
    public override void Attack() // 컴파일 오류
    {
    }
}
```

Boss 클래스 자체가 `sealed`인 것은 아니다. FinalBoss는 Boss를 상속할 수 있지만 `Attack()`의 가상 동작은 더 이상 변경할 수 없다.

---

## 코드 예제

네 키워드의 차이는 같은 객체를 서로 다른 타입의 변수로 호출할 때 분명하게 나타난다.

### override를 사용한 경우

```cs
public class Monster
{
    public virtual void Move()
    {
        Console.WriteLine("Monster.Move");
    }
}

public class Slime : Monster
{
    public override void Move()
    {
        Console.WriteLine("Slime.Move");
    }
}
```

```cs
Slime slime = new Slime();
Monster monster = slime;

slime.Move();   // Slime.Move
monster.Move(); // Slime.Move
```

참조 변수의 타입이 달라도 실제 객체가 Slime이므로 같은 재정의 메서드가 실행된다.

### new를 사용한 경우

```cs
public class Monster
{
    public void Move()
    {
        Console.WriteLine("Monster.Move");
    }
}

public class Slime : Monster
{
    public new void Move()
    {
        Console.WriteLine("Slime.Move");
    }
}
```

```cs
Slime slime = new Slime();
Monster monster = slime;

slime.Move();   // Slime.Move
monster.Move(); // Monster.Move
```

실제 객체는 같지만 변수의 타입에 따라 호출 결과가 달라진다.

```text
override
└─ 실제 객체 타입을 기준으로 호출

new
└─ 참조 변수 타입을 기준으로 호출
```

### base로 기반 구현 호출하기

재정의한 메서드에서 기반 클래스의 구현을 유지하면서 기능을 추가할 수 있다.

```cs
public class Character
{
    public virtual void TakeDamage(int damage)
    {
        Console.WriteLine($"{damage} 피해 처리");
    }
}

public class Player : Character
{
    public override void TakeDamage(int damage)
    {
        base.TakeDamage(damage);
        Console.WriteLine("피격 UI 갱신");
    }
}
```

```cs
Character character = new Player();
character.TakeDamage(20);
```

실행 순서는 다음과 같다.

```text
20 피해 처리
피격 UI 갱신
```

`base.TakeDamage()`는 가상 디스패치를 다시 수행하지 않고 현재 클래스의 바로 위 기반 구현을 명시적으로 호출한다.

기반 구현을 반드시 호출해야 하는지는 메서드의 계약에 따라 달라진다. 기반 클래스가 필수 초기화나 상태 변경을 담당한다면 누락할 때 버그가 발생할 수 있다.

### 여러 단계에서 override하기

가상 메서드는 여러 상속 단계에서 다시 재정의할 수 있다.

```cs
public class Character
{
    public virtual void Attack() =>
        Console.WriteLine("Character");
}

public class Monster : Character
{
    public override void Attack() =>
        Console.WriteLine("Monster");
}

public class Boss : Monster
{
    public override void Attack() =>
        Console.WriteLine("Boss");
}
```

```cs
Character character = new Boss();
character.Attack(); // Boss
```

런타임은 상속 단계에서 가장 가까운 최종 재정의 구현을 선택한다.

Monster에서 재정의를 막으려면 `sealed override`를 사용한다.

```cs
public class Monster : Character
{
    public sealed override void Attack() =>
        Console.WriteLine("Monster");
}
```

---

## 내부 동작

`virtual` 메서드는 타입의 가상 메서드 테이블에서 슬롯을 가진다.

```cs
public class Character
{
    public virtual void Attack() { }
}
```

Character 타입에는 `Attack()` 호출을 Character의 구현과 연결하는 슬롯이 만들어진다.

```text
Character VTable
└─ Attack 슬롯 → Character.Attack
```

파생 클래스가 `override`하면 같은 슬롯의 구현이 교체된다.

```text
Warrior VTable
└─ Attack 슬롯 → Warrior.Attack
```

기반 타입 참조로 호출해도 런타임은 실제 객체의 타입 정보에서 해당 슬롯을 확인한다.

```cs
Character character = new Warrior();
character.Attack();
```

```text
Character.Attack 슬롯 확인
↓
실제 객체 타입은 Warrior
↓
Warrior 슬롯에 연결된 구현 호출
```

### new는 새 슬롯을 만든다

`new`로 숨긴 메서드는 기반 메서드의 가상 슬롯을 재정의하지 않는다. 파생 타입에 별도의 멤버가 추가된다.

```text
Character
└─ Attack → Character.Attack

Warrior
├─ 상속된 Attack → Character.Attack
└─ 숨긴 Attack   → Warrior.Attack
```

컴파일러는 변수의 정적 타입을 보고 어느 멤버 호출을 코드에 기록할지 결정한다. 그래서 같은 객체를 가리켜도 Character 변수와 Warrior 변수의 결과가 달라진다.

기반 메서드가 `virtual`이어도 파생 클래스가 `new`를 사용할 수 있다.

```cs
public class Warrior : Character
{
    public new void Attack() { }
}
```

이 경우 Warrior의 새 메서드는 기존 가상 슬롯과 연결되지 않는다. 기반 타입을 통한 호출은 Character 계층의 가상 슬롯을 계속 사용한다.

### sealed override의 의미

`sealed override`도 기반 가상 슬롯을 재정의한다. 다만 메타데이터에 이후 재정의를 허용하지 않는 정보가 추가된다.

```text
Character.Attack: virtual
↓
Boss.Attack: override + sealed
↓
FinalBoss: 같은 슬롯 재정의 불가
```

호출 자체는 여전히 가상 메서드 계층에 속한다. 컴파일러와 JIT는 더 이상 파생 구현이 생기지 않는다는 사실을 최적화에 활용할 가능성이 있다.

실제 호출 코드는 JIT의 Devirtualization 여부에 따라 일반 호출로 최적화될 수 있으므로 모든 `virtual` 호출이 항상 동일한 비용을 가진다고 단정할 수는 없다.

---

## 실제 Unity에서는?

Unity에서 공통 Component의 동작을 확장할 때 `virtual`과 `override`를 사용할 수 있다.

```cs
public class CharacterHealth : MonoBehaviour
{
    [SerializeField] private int maxHealth = 100;

    public int Health { get; private set; }

    protected virtual void Awake()
    {
        Health = maxHealth;
    }
}
```

```cs
public class PlayerHealth : CharacterHealth
{
    protected override void Awake()
    {
        base.Awake();
        UpdateHealthUI();
    }

    private void UpdateHealthUI()
    {
    }
}
```

PlayerHealth가 기반 초기화를 유지해야 한다면 `base.Awake()` 호출이 필요하다.

### Unity 메시지는 자동으로 override되는 것이 아니다

`Awake()`, `Start()`, `Update()`와 같은 Unity 메시지 메서드는 `MonoBehaviour`에 선언된 가상 메서드를 재정의하는 문법이 아니다.

```cs
private void Update()
{
}
```

Unity가 정해진 이름과 시그니처를 가진 메서드를 찾아 호출하는 메시지 체계이다.

사용자 기반 클래스에서 명시적으로 `virtual`을 선언하면 그때부터 일반 C# 오버라이딩 구조를 만들 수 있다.

```cs
public class BaseController : MonoBehaviour
{
    protected virtual void Update()
    {
    }
}
```

```cs
public class PlayerController : BaseController
{
    protected override void Update()
    {
        base.Update();
    }
}
```

파생 클래스가 같은 이름의 Unity 메시지를 단순히 다시 선언하면 기반 메서드가 숨겨질 수 있다. 기반 동작과 파생 동작을 함께 실행해야 한다면 `virtual`, `override`와 `base` 호출을 명시하는 편이 의도가 분명하다.

Unity Component에서 재정의 지점을 많이 열면 파생 클래스가 기반 클래스의 생명 주기와 호출 순서에 강하게 의존할 수 있다. 독립적으로 교체해야 하는 기능은 상속보다 별도 Component로 분리하는 편이 안전하다.

---

## 실무에서 자주 하는 오해

### 경고를 없애기 위해 new를 사용한다는 오해

같은 이름의 멤버 경고에 `new`를 붙이면 경고는 사라진다. 하지만 동작이 오버라이딩으로 바뀌는 것은 아니다.

`new`는 기반 멤버와 다른 새 멤버를 선언한다는 설계 의사 표시이다. 참조 타입에 따라 결과가 달라져야 하는 명확한 이유가 없다면 메서드 이름이나 상속 구조를 다시 검토해야 한다.

### override하면 기반 메서드도 자동 호출된다는 오해

재정의된 메서드는 기반 구현을 자동으로 실행하지 않는다.

```cs
public override void Attack()
{
    // base.Attack()은 자동으로 호출되지 않는다.
}
```

기반 구현이 필요하면 `base.Attack()`을 직접 호출해야 한다.

### sealed override는 클래스 상속을 막는다는 오해

`sealed override`는 해당 멤버의 추가 재정의만 막는다. 클래스 자체의 상속을 막으려면 클래스 선언에 `sealed`를 사용해야 한다.

```cs
public sealed class Boss : Character
{
}
```

### 모든 메서드를 virtual로 만들면 유연하다는 오해

재정의 지점은 파생 클래스가 기반 클래스의 동작을 변경할 수 있다는 계약이다.

필요하지 않은 메서드까지 모두 `virtual`로 공개하면 객체가 유지해야 하는 규칙을 파생 클래스가 깨뜨릴 수 있고 동작을 추적하기도 어려워진다.

확장이 필요한 지점만 의도적으로 열고 변하지 않아야 할 규칙은 비가상 메서드나 `sealed override`로 유지하는 편이 안전하다.

---

## 마무리

`virtual`은 기반 클래스가 재정의 가능한 확장 지점을 선언하고, `override`는 파생 클래스가 같은 가상 메서드 계약에 새로운 구현을 연결한다.

`new`는 상속받은 멤버를 재정의하지 않고 같은 이름의 별도 멤버로 숨긴다. 따라서 실제 객체가 같아도 참조 변수의 타입에 따라 호출 결과가 달라질 수 있다.

`sealed override`는 한 번 재정의한 동작을 이후 상속 단계에서 다시 변경하지 못하게 하여 가상 메서드 계약의 마지막 구현을 만든다.

키워드 선택의 기준은 컴파일러 경고를 없애는 것이 아니다. 실제 객체에 따라 동작이 달라져야 하는지, 기반 멤버와 별개의 의미인지, 이후 확장을 허용할지를 기준으로 결정해야 한다.

---

## 핵심 정리

- `virtual`은 파생 클래스가 재정의할 수 있는 메서드를 선언한다.
- `override`는 기반 클래스의 가상 메서드와 같은 슬롯을 재정의한다.
- `new`는 기반 멤버를 숨기고 파생 타입에 별도의 멤버를 선언한다.
- `override` 호출은 실제 객체 타입을 기준으로 결정된다.
- `new`로 숨긴 멤버는 참조 변수의 컴파일 시점 타입에 따라 선택된다.
- 재정의한 메서드에서 기반 구현이 필요하면 `base`로 직접 호출해야 한다.
- `sealed override`는 클래스 상속이 아니라 해당 멤버의 추가 재정의를 막는다.
- Unity 메시지 메서드는 자동으로 C#의 가상 메서드가 되는 것이 아니다.
- 재정의 지점은 필요한 곳에만 의도적으로 제공해야 한다.
