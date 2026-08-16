---
title: "[궁금시리즈] 8-4. 다형성은 왜 필요할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-4-polymorphism/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:03 +0900
last_modified_at: 2026-08-16 12:00:03 +0900
---

## 들어가며

게임에는 서로 다른 공격 방식을 가진 캐릭터가 존재한다.

```cs
public class Warrior
{
    public void Attack()
    {
        Console.WriteLine("검으로 공격한다.");
    }
}
```

```cs
public class Archer
{
    public void Attack()
    {
        Console.WriteLine("활로 공격한다.");
    }
}
```

각 객체를 직접 사용하면 공격 기능을 호출할 수 있다.

```cs
Warrior warrior = new Warrior();
Archer archer = new Archer();

warrior.Attack();
archer.Attack();
```

하지만 전투에 참여하는 모든 캐릭터를 하나의 컬렉션에 저장하고 순서대로 공격시켜야 한다면 문제가 달라진다.

Warrior 목록과 Archer 목록을 따로 관리하거나 실제 타입을 검사하는 조건문이 필요해진다.

```cs
if (type == CharacterType.Warrior)
{
    warrior.Attack();
}
else if (type == CharacterType.Archer)
{
    archer.Attack();
}
```

새로운 Mage가 추가될 때마다 사용하는 쪽의 조건문도 수정해야 한다.

다형성(Polymorphism)은 서로 다른 객체를 공통된 타입으로 다루면서도 각 객체에 맞는 동작이 실행되도록 만드는 객체지향 특성이다.

```text
같은 요청
Attack()
   │
   ├─ Warrior → 검 공격
   ├─ Archer  → 활 공격
   └─ Mage    → 마법 공격
```

호출하는 코드는 구체적인 타입을 몰라도 된다. 객체가 공통된 약속에 따라 자신의 동작을 수행한다.

---

## 개념 설명

다형성은 하나의 타입이나 인터페이스가 여러 형태의 객체를 나타낼 수 있다는 의미이다.

상속 관계를 사용하면 파생 객체를 기반 타입 변수에 저장할 수 있다.

```cs
Character warrior = new Warrior();
Character archer = new Archer();
```

변수의 타입은 둘 다 Character이지만 실제 객체는 서로 다르다.

```text
변수의 컴파일 시점 타입       실제 런타임 타입

Character warrior    ──────▶ Warrior 객체
Character archer     ──────▶ Archer 객체
```

Character가 공통 동작을 정의하고 파생 클래스가 자신의 동작으로 재정의하면 같은 메서드 호출이 객체에 따라 다른 결과를 만든다.

```cs
public class Character
{
    public virtual void Attack()
    {
        Console.WriteLine("기본 공격을 한다.");
    }
}
```

```cs
public class Warrior : Character
{
    public override void Attack()
    {
        Console.WriteLine("검으로 공격한다.");
    }
}
```

```cs
public class Archer : Character
{
    public override void Attack()
    {
        Console.WriteLine("활로 공격한다.");
    }
}
```

기반 타입으로 호출해도 실제 객체의 메서드가 실행된다.

```cs
Character character = new Warrior();
character.Attack(); // 검으로 공격한다.
```

이러한 동작을 런타임 다형성 또는 동적 디스패치(Dynamic Dispatch)라고 한다.

### 사용하는 쪽과 구현하는 쪽의 분리

다형성이 없으면 사용하는 코드는 모든 구체 타입을 알아야 한다.

```cs
public void Attack(Character character)
{
    if (character is Warrior warrior)
    {
        warrior.SwingSword();
    }
    else if (character is Archer archer)
    {
        archer.ShootArrow();
    }
}
```

Mage가 추가되면 이 메서드도 변경해야 한다.

다형성을 사용하면 어떤 공격을 수행할지는 각 객체가 결정한다.

```cs
public void Attack(Character character)
{
    character.Attack();
}
```

새로운 파생 클래스가 추가되어도 이 코드는 바뀌지 않는다.

```cs
public class Mage : Character
{
    public override void Attack()
    {
        Console.WriteLine("마법으로 공격한다.");
    }
}
```

호출하는 쪽은 Character라는 공통 계약에 의존하고, 구체적인 공격 방식은 각 파생 클래스가 책임진다.

### 오버로딩도 다형성일까?

C#에서는 같은 이름의 메서드를 매개변수에 따라 여러 개 정의할 수 있다.

```cs
public void Attack(Monster target) { }
public void Attack(Monster target, Skill skill) { }
```

이를 메서드 오버로딩(Overloading)이라고 하며 컴파일 시점 다형성이라고 부르기도 한다.

컴파일러는 전달된 인수의 타입과 개수를 보고 호출할 메서드를 결정한다.

```text
오버로딩
└─ 컴파일 시점에 메서드 결정

오버라이딩
└─ 런타임의 실제 객체에 따라 메서드 결정
```

객체지향에서 다형성을 설명할 때는 주로 기반 타입을 통해 파생 객체의 재정의된 동작을 호출하는 런타임 다형성을 의미한다.

---

## 코드 예제

여러 Skill이 서로 다른 효과를 실행하는 구조를 만들 수 있다.

```cs
public abstract class Skill
{
    public string Name { get; }

    protected Skill(string name)
    {
        Name = name;
    }

    public abstract void Execute(Character target);
}
```

공격 Skill은 피해를 준다.

```cs
public class Fireball : Skill
{
    private readonly int damage;

    public Fireball(int damage)
        : base("Fireball")
    {
        this.damage = damage;
    }

    public override void Execute(Character target)
    {
        target.TakeDamage(damage);
    }
}
```

회복 Skill은 체력을 회복한다.

```cs
public class Heal : Skill
{
    private readonly int amount;

    public Heal(int amount)
        : base("Heal")
    {
        this.amount = amount;
    }

    public override void Execute(Character target)
    {
        target.RestoreHealth(amount);
    }
}
```

Skill을 사용하는 코드는 구체적인 효과를 알 필요가 없다.

```cs
public class SkillController
{
    public void Use(Skill skill, Character target)
    {
        Console.WriteLine($"{skill.Name} 사용");
        skill.Execute(target);
    }
}
```

```cs
SkillController controller = new SkillController();

Skill fireball = new Fireball(30);
Skill heal = new Heal(20);

controller.Use(fireball, monster);
controller.Use(heal, player);
```

`SkillController`는 Fireball이나 Heal을 직접 검사하지 않는다. Skill의 `Execute()`를 호출할 뿐이며 실제 효과는 런타임 객체가 결정한다.

새로운 Skill도 기존 Controller를 수정하지 않고 추가할 수 있다.

```cs
public class Stun : Skill
{
    public Stun() : base("Stun")
    {
    }

    public override void Execute(Character target)
    {
        target.ApplyStun();
    }
}
```

이 구조는 조건문을 단순히 여러 클래스로 옮긴 것이 아니다. 변경 이유가 다른 Skill 효과를 각 클래스가 책임지고 사용하는 코드는 공통 타입에만 의존하도록 만든다.

### 컬렉션과 다형성

서로 다른 Skill을 하나의 컬렉션에 저장할 수 있다.

```cs
List<Skill> skills =
[
    new Fireball(30),
    new Heal(20),
    new Stun()
];

foreach (Skill skill in skills)
{
    skill.Execute(target);
}
```

반복문은 구체 타입과 관계없이 동일한 코드를 사용한다. 각 요소가 실제로 어떤 Skill인지에 따라 다른 `Execute()`가 호출된다.

---

## 내부 동작

다형적 메서드 호출에는 두 가지 타입 정보가 관여한다.

```cs
Character character = new Warrior();
character.Attack();
```

- 컴파일 시점 타입: `Character`
- 런타임 실제 타입: `Warrior`

컴파일러는 Character에 호출 가능한 `Attack()`이 있는지 검사한다. 런타임은 실제 객체가 Warrior라는 사실을 확인하고 Warrior가 재정의한 메서드를 선택한다.

### 가상 메서드 테이블

가상 메서드를 가진 타입에는 어떤 실제 메서드를 호출해야 하는지 찾기 위한 정보가 구성된다. 일반적으로 이를 가상 메서드 테이블 또는 VTable이라고 설명한다.

```text
Character VTable
└─ Attack() → Character.Attack

Warrior VTable
└─ Attack() → Warrior.Attack

Archer VTable
└─ Attack() → Archer.Attack
```

Character 참조가 Warrior 객체를 가리키면 런타임은 Warrior 타입에 연결된 슬롯에서 `Attack()` 구현을 찾아 호출한다.

실제 CLR 구현은 JIT 최적화와 런타임 상태에 따라 더 복잡할 수 있다. 호출 대상이 확실하면 JIT가 가상 호출을 일반 호출처럼 최적화하는 Devirtualization을 적용할 수도 있다.

중요한 점은 기반 타입 변수에 저장했다고 해서 실제 객체의 타입이 Character로 바뀌지 않는다는 것이다.

```text
Character 참조
↓
실제 Warrior 객체와 타입 정보 유지
↓
재정의된 Warrior.Attack() 선택
```

### 업캐스팅과 다운캐스팅

파생 타입을 기반 타입으로 대입하는 것을 업캐스팅이라고 한다.

```cs
Warrior warrior = new Warrior();
Character character = warrior;
```

Warrior는 Character이므로 암시적으로 변환할 수 있다.

반대로 기반 타입 참조를 파생 타입으로 변환하는 것은 다운캐스팅이다.

```cs
Warrior warrior = (Warrior)character;
```

실제 객체가 Warrior가 아니라면 `InvalidCastException`이 발생한다.

```cs
Character character = new Archer();
Warrior warrior = (Warrior)character; // 예외
```

형식 검사가 필요하면 패턴 매칭을 사용할 수 있다.

```cs
if (character is Warrior warrior)
{
    warrior.UseShield();
}
```

하지만 구체 타입 검사가 반복된다면 공통 타입의 설계가 부족한지 먼저 확인해야 한다. 다형성의 목적은 다운캐스팅을 많이 사용하는 것이 아니라 다운캐스팅 없이 공통 계약으로 협력하게 만드는 데 있다.

---

## 실제 Unity에서는?

Unity에서는 다양한 Component를 공통 기반 타입으로 다루는 경우가 많다.

적에게 피해를 줄 수 있는 대상을 기반 클래스로 만들 수 있다.

```cs
public abstract class Damageable : MonoBehaviour
{
    public abstract void TakeDamage(int damage);
}
```

Player와 BreakableBox는 서로 다른 방식으로 피해를 처리한다.

```cs
public class PlayerHealth : Damageable
{
    [SerializeField] private int health = 100;

    public override void TakeDamage(int damage)
    {
        health = Mathf.Max(0, health - damage);
    }
}
```

```cs
public class BreakableBox : Damageable
{
    public override void TakeDamage(int damage)
    {
        Destroy(gameObject);
    }
}
```

공격 코드는 충돌한 객체의 구체 타입을 구분하지 않는다.

```cs
private void OnTriggerEnter(Collider other)
{
    if (other.TryGetComponent(out Damageable target))
    {
        target.TakeDamage(damage);
    }
}
```

같은 `TakeDamage()` 요청을 보내지만 PlayerHealth는 체력을 줄이고 BreakableBox는 GameObject를 제거한다.

Unity Inspector에서도 기반 타입 필드에 파생 Component를 연결할 수 있다.

```cs
[SerializeField] private Damageable target;
```

다만 Unity의 직렬화는 일반 C# 다형성을 모두 자동으로 지원하지 않는다. `MonoBehaviour`나 `ScriptableObject` 참조는 파생 객체를 연결할 수 있지만 일반 직렬화 클래스의 다형적 데이터에는 `[SerializeReference]`가 필요할 수 있다.

```cs
[SerializeReference] private SkillEffect effect;
```

상속 구조가 깊어지는 문제는 이전 글과 같다. 공통 타입이 필요하더라도 구현 재사용까지 반드시 상속으로 해결할 필요는 없다. 인터페이스와 Component 조합으로도 다형적인 협력을 만들 수 있다.

---

## 실무에서 자주 하는 오해

### 타입 검사도 다형성이라는 오해

다음 코드는 여러 타입을 처리하지만 새로운 타입이 추가될 때마다 조건문을 수정해야 한다.

```cs
if (skill is Fireball) { }
else if (skill is Heal) { }
else if (skill is Stun) { }
```

다형성의 장점은 타입을 구분하는 데 있지 않다. 구체 타입을 구분하지 않고 공통 동작을 요청하는 데 있다.

### 기반 타입으로 저장하면 파생 정보가 사라진다는 오해

업캐스팅은 객체를 새로운 기반 객체로 복사하지 않는다. 참조를 통해 보이는 멤버 범위만 달라지며 실제 객체와 런타임 타입 정보는 유지된다.

### virtual 메서드는 항상 느리다는 오해

가상 호출에는 대상 메서드를 선택하는 과정이 있지만 실제 성능 영향은 호출 빈도, JIT 최적화와 실행 환경에 따라 달라진다.

구조를 복잡하게 만들면서까지 가상 호출을 제거하기보다 Profiler와 측정 결과를 기준으로 판단해야 한다.

### 다형성에는 반드시 상속이 필요하다는 오해

클래스 상속은 다형성을 구현하는 한 가지 방법이다. 인터페이스를 구현한 서로 다른 클래스도 공통 인터페이스 타입으로 다룰 수 있다.

Delegate를 통해 실행할 동작을 교체하는 구조도 넓은 의미에서 다형적인 설계를 제공한다.

---

## 마무리

다형성은 서로 다른 객체를 공통 타입으로 다루면서 실제 객체에 맞는 동작이 실행되도록 만드는 객체지향 특성이다.

호출하는 코드는 구체 타입에 따른 조건문을 작성하지 않고 공통된 동작만 요청한다. 새로운 구현이 추가되어도 사용하는 코드를 그대로 유지할 수 있어 변경 범위와 결합도가 줄어든다.

기반 타입 참조는 실제 객체의 타입을 없애지 않는다. 런타임은 객체가 가진 타입 정보를 이용해 재정의된 메서드를 선택한다.

좋은 다형성은 타입 검사를 늘리는 구조가 아니라 구체 타입을 몰라도 협력할 수 있는 공통 계약을 만드는 데서 시작한다.

---

## 핵심 정리

- 다형성은 같은 요청이 실제 객체에 따라 다른 동작으로 실행되는 특성이다.
- 파생 객체는 기반 타입 변수와 컬렉션에 저장할 수 있다.
- 컴파일러는 기반 타입의 멤버를 검사하고 런타임은 실제 객체의 재정의된 메서드를 선택한다.
- 오버로딩은 컴파일 시점에, 오버라이딩은 런타임 객체에 따라 호출 대상이 결정된다.
- 업캐스팅은 객체를 복사하거나 실제 타입을 변경하지 않는다.
- 반복적인 다운캐스팅과 타입 검사는 공통 계약이 부족하다는 신호일 수 있다.
- 가상 호출은 JIT에 의해 최적화될 수 있으며 성능은 측정 결과로 판단해야 한다.
- Unity에서는 기반 Component, 추상 클래스와 인터페이스를 통해 다형성을 활용할 수 있다.
- 다형성의 핵심은 구체 타입을 모르는 상태에서도 공통 동작을 요청할 수 있다는 점이다.
