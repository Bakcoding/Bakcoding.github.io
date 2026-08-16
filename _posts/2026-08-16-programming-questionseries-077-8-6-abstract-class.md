---
title: "[궁금시리즈] 8-6. 추상 클래스는 왜 필요할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-6-abstract-class/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:05 +0900
last_modified_at: 2026-08-16 12:00:05 +0900
---

## 들어가며

Skill에는 이름과 재사용 대기시간 같은 공통 정보가 있다. 하지만 모든 Skill이 같은 효과를 실행하지는 않는다.

```cs
public class Skill
{
    public string Name { get; }
    public float Cooldown { get; }

    public void Execute()
    {
        // 어떤 효과를 실행해야 할까?
    }
}
```

Fireball은 적에게 피해를 주고 Heal은 아군의 체력을 회복한다.

기반 클래스가 `Execute()`의 기본 동작을 정하기 어렵다고 빈 메서드로 두면 파생 클래스가 구현을 빼먹어도 컴파일된다.

```cs
public class Heal : Skill
{
    // Execute() 구현을 잊어도 오류가 발생하지 않는다.
}
```

또한 효과가 정해지지 않은 일반 Skill 객체가 생성될 수도 있다.

```cs
Skill skill = new Skill("Unknown", 1f);
```

이 객체는 타입으로는 Skill이지만 실제로 수행할 동작이 없다.

추상 클래스(Abstract Class)는 공통 상태와 동작을 제공하면서, 그 자체로는 완성되지 않은 기반 타입을 표현하기 위해 사용한다.

파생 클래스가 반드시 구현해야 할 동작을 선언하고 불완전한 기반 클래스의 직접 생성을 막을 수 있다.

---

## 개념 설명

클래스 선언에 `abstract`를 붙이면 추상 클래스가 된다.

```cs
public abstract class Skill
{
}
```

추상 클래스는 `new`로 직접 생성할 수 없다.

```cs
Skill skill = new Skill(); // 컴파일 오류
```

추상 클래스는 파생 클래스가 완성해야 하는 기반 개념이기 때문이다.

```cs
public class Fireball : Skill
{
}

Skill skill = new Fireball();
```

Fireball 객체는 Skill의 한 종류이므로 Skill 타입 변수에 저장할 수 있다.

### 추상 멤버

추상 메서드는 선언만 있고 구현 본문이 없다.

```cs
public abstract class Skill
{
    public abstract void Execute(Character target);
}
```

구현이 없는 대신 구체적인 파생 클래스가 반드시 `override`해야 한다.

```cs
public class Fireball : Skill
{
    public override void Execute(Character target)
    {
        target.TakeDamage(30);
    }
}
```

구체 클래스가 추상 멤버를 구현하지 않으면 컴파일 오류가 발생한다.

```cs
public class Heal : Skill // 컴파일 오류
{
}
```

Heal도 추상 클래스로 선언한다면 구현을 다음 파생 클래스에 미룰 수 있다.

```cs
public abstract class RecoverySkill : Skill
{
}
```

추상 메서드뿐 아니라 프로퍼티, 인덱서와 이벤트도 추상 멤버로 선언할 수 있다.

```cs
public abstract class Skill
{
    public abstract string Description { get; }
    public abstract event Action Executed;
}
```

추상 멤버는 파생 클래스에서 재정의되어야 하므로 암시적으로 가상 동작에 참여한다. `abstract virtual`처럼 두 키워드를 함께 작성하지 않는다.

### 추상 클래스도 구현을 가질 수 있다

추상 클래스의 모든 멤버가 추상일 필요는 없다.

```cs
public abstract class Skill
{
    public string Name { get; }
    public float Cooldown { get; }

    protected Skill(string name, float cooldown)
    {
        Name = name;
        Cooldown = cooldown;
    }

    public void PrintInfo()
    {
        Console.WriteLine($"{Name}: {Cooldown}초");
    }

    public abstract void Execute(Character target);
}
```

다음 요소를 모두 포함할 수 있다.

- 인스턴스 필드와 정적 필드
- 생성자
- 구현된 메서드
- `virtual` 메서드
- 추상 멤버
- 접근 제한자

공통으로 확정할 수 있는 규칙은 기반 클래스가 구현하고, 구체 타입마다 달라져야 하는 동작만 추상 멤버로 남길 수 있다.

### abstract와 virtual의 차이

`virtual` 메서드는 기본 구현이 있으며 파생 클래스가 필요할 때 재정의한다.

```cs
public virtual void Cancel()
{
    Console.WriteLine("Skill 취소");
}
```

`abstract` 메서드는 기본 구현이 없으며 구체 파생 클래스가 반드시 재정의한다.

```cs
public abstract void Execute(Character target);
```

```text
virtual
├─ 기본 구현 있음
└─ 재정의 선택

abstract
├─ 기본 구현 없음
└─ 구체 클래스에서 재정의 필수
```

기반 클래스가 합리적인 기본 동작을 제공할 수 있는지 여부가 중요한 기준이다.

---

## 코드 예제

공통 실행 흐름은 유지하고 실제 효과만 파생 클래스에 맡기는 Skill 구조를 만들 수 있다.

```cs
public abstract class Skill
{
    public string Name { get; }
    public float Cooldown { get; }

    protected Skill(string name, float cooldown)
    {
        Name = name;
        Cooldown = cooldown;
    }

    public void Use(Character target)
    {
        if (!CanUse(target))
        {
            return;
        }

        Execute(target);
        StartCooldown();
    }

    protected virtual bool CanUse(Character target)
    {
        return target is not null;
    }

    protected abstract void Execute(Character target);

    private void StartCooldown()
    {
        Console.WriteLine($"{Cooldown}초 재사용 대기");
    }
}
```

`Use()`는 검증, 효과 실행과 재사용 대기 시작이라는 전체 순서를 관리한다.

파생 클래스는 달라져야 하는 `Execute()`만 구현한다.

```cs
public class Fireball : Skill
{
    private readonly int damage;

    public Fireball(int damage)
        : base("Fireball", 3f)
    {
        this.damage = damage;
    }

    protected override void Execute(Character target)
    {
        target.TakeDamage(damage);
    }
}
```

```cs
public class Heal : Skill
{
    private readonly int amount;

    public Heal(int amount)
        : base("Heal", 5f)
    {
        this.amount = amount;
    }

    protected override void Execute(Character target)
    {
        target.RestoreHealth(amount);
    }
}
```

사용하는 코드는 구체적인 효과를 구분하지 않는다.

```cs
List<Skill> skills =
[
    new Fireball(30),
    new Heal(20)
];

foreach (Skill skill in skills)
{
    skill.Use(target);
}
```

### 실행 순서를 기반 클래스가 관리하는 이유

파생 클래스가 `Use()` 전체를 재정의하도록 만들면 공통 규칙이 빠질 수 있다.

```cs
public override void Use(Character target)
{
    Execute(target);
    // 재사용 대기 시작을 누락
}
```

대신 변경되면 안 되는 실행 흐름은 비가상 메서드로 두고 일부 단계만 추상 또는 가상 메서드로 제공할 수 있다.

```text
Skill.Use()
├─ CanUse()       → 기본 구현, 필요하면 override
├─ Execute()      → 구현 없음, 반드시 override
└─ StartCooldown() → 기반 클래스만 관리
```

이 구조는 알고리즘의 전체 순서를 기반 클래스가 정의하고 일부 단계를 파생 클래스가 구현하는 Template Method 형태이다.

상속을 사용하면서도 파생 클래스가 변경할 수 있는 범위를 제한해 공통 규칙을 유지할 수 있다.

---

## 내부 동작

추상 클래스도 일반 클래스와 마찬가지로 컴파일된 Assembly에 타입 정보가 기록된다.

차이는 타입 메타데이터에 추상 타입이라는 정보가 포함되고, 추상 멤버에는 구현 본문이 없다는 점이다.

```text
Skill 타입
├─ abstract 타입
├─ Name 필드와 Getter
├─ Use() 구현
└─ Execute() 추상 슬롯
```

CLR은 추상 클래스의 직접 인스턴스 생성을 허용하지 않는다. C# 컴파일러도 `new Skill()` 코드를 먼저 차단한다.

### 추상 클래스의 생성자

추상 클래스는 직접 생성할 수 없지만 생성자를 가질 수 있다.

```cs
protected Skill(string name, float cooldown)
{
    Name = name;
    Cooldown = cooldown;
}
```

이 생성자는 파생 객체를 만들 때 기반 영역을 초기화하기 위해 실행된다.

```cs
Skill skill = new Fireball(30);
```

```text
Fireball 객체 메모리 확보
↓
Skill 필드 초기화
↓
Skill 생성자 실행
↓
Fireball 필드 초기화
↓
Fireball 생성자 실행
```

외부에서 호출할 이유가 없으므로 추상 클래스 생성자는 일반적으로 `protected`로 선언한다.

### 추상 메서드와 가상 슬롯

추상 메서드도 가상 메서드 슬롯을 가진다. 기반 타입에서는 호출 계약만 존재하고 구체 구현은 파생 클래스가 연결한다.

```text
Skill.Execute 슬롯
├─ Skill       → 구현 없음
├─ Fireball    → Fireball.Execute
└─ Heal        → Heal.Execute
```

```cs
Skill skill = new Fireball(30);
skill.Use(target);
```

`Use()` 내부에서 `Execute()`를 호출하면 런타임은 실제 객체가 Fireball이라는 사실을 기준으로 `Fireball.Execute()`를 선택한다.

추상 클래스 변수는 선언할 수 있다. 금지되는 것은 추상 타입의 직접 생성이다.

```cs
Skill skill;                 // 가능
Skill fireball = new Fireball(30); // 가능
```

변수와 매개변수의 타입으로 사용할 수 있기 때문에 추상 클래스도 다형성의 공통 타입 역할을 한다.

---

## 실제 Unity에서는?

Unity에서도 추상 `MonoBehaviour` 기반 클래스를 만들 수 있다.

```cs
public abstract class Enemy : MonoBehaviour
{
    [SerializeField] private int health = 100;

    public void TakeTurn()
    {
        Move();
        Attack();
    }

    protected abstract void Move();
    protected abstract void Attack();
}
```

구체 Enemy Component가 실제 동작을 구현한다.

```cs
public class Slime : Enemy
{
    protected override void Move()
    {
        transform.Translate(Vector3.forward);
    }

    protected override void Attack()
    {
        Debug.Log("Slime Attack");
    }
}
```

추상 Component는 완성된 Component가 아니므로 GameObject에 직접 추가할 수 없다. Slime처럼 모든 추상 멤버를 구현한 구체 Component를 추가해야 한다.

```cs
Slime slime = gameObject.AddComponent<Slime>();
```

다음 코드는 사용할 수 없다.

```cs
Enemy enemy = gameObject.AddComponent<Enemy>();
```

Inspector에서 기반 타입 참조 필드에 파생 Component를 연결하는 것은 가능하다.

```cs
[SerializeField] private Enemy enemy;
```

### ScriptableObject와 추상 클래스

공통 데이터와 실행 계약을 가진 추상 `ScriptableObject`도 만들 수 있다.

```cs
public abstract class SkillData : ScriptableObject
{
    [SerializeField] private string skillName;

    public string SkillName => skillName;

    public abstract void Execute(GameObject target);
}
```

파생 Asset 타입은 고유 효과를 구현한다.

```cs
[CreateAssetMenu(menuName = "Skill/Fireball")]
public class FireballData : SkillData
{
    public override void Execute(GameObject target)
    {
        Debug.Log("Fireball");
    }
}
```

추상 기반 타입 자체의 Asset을 생성하는 것이 아니라 구체적인 파생 타입의 Asset을 생성한다.

Unity에서도 상속 단계가 깊어질수록 기반 생명 주기와 `protected` 상태에 대한 의존이 커진다. 공통 타입과 상태를 반드시 공유해야 하는지, 독립 Component 조합으로 나누는 편이 나은지 함께 판단해야 한다.

---

## 실무에서 자주 하는 오해

### 추상 클래스는 메서드 구현을 가질 수 없다는 오해

구현을 가질 수 없는 것은 추상 멤버이다. 추상 클래스는 필드, 생성자와 구현된 메서드를 모두 가질 수 있다.

공통으로 확정할 수 있는 동작과 파생 타입이 완성할 동작을 한 타입 안에 함께 표현하는 것이 추상 클래스의 특징이다.

### 추상 클래스는 객체가 아니라는 오해

추상 타입 자체를 직접 생성할 수 없다는 의미이다. 추상 클래스를 상속한 구체 객체 안에는 추상 클래스가 정의한 필드와 구현이 포함된다.

추상 클래스 타입의 변수와 컬렉션도 정상적으로 사용할 수 있다.

### 공통 코드가 있으면 추상 클래스를 사용해야 한다는 오해

공통 코드가 있다는 이유만으로 상속 관계가 자연스러운 것은 아니다.

파생 타입이 기반 타입을 대체할 수 있는지, 같은 상태와 생명 주기를 공유해야 하는지 확인해야 한다. 기능 재사용만 필요하다면 별도 객체와 Composition이 더 적절할 수 있다.

### 추상 메서드가 많을수록 확장성이 높다는 오해

추상 멤버가 많으면 모든 파생 클래스가 많은 구현을 강제로 가져야 한다.

일부 파생 타입에서 필요하지 않은 메서드를 빈 구현으로 채우기 시작하면 기반 추상화가 너무 넓다는 신호이다. 책임을 더 작은 타입으로 나누는 편이 좋다.

---

## 마무리

추상 클래스는 공통 상태와 구현을 공유하면서 그 자체로는 완성되지 않은 기반 타입을 표현한다.

직접 인스턴스를 생성할 수 없고 추상 멤버를 통해 구체 클래스가 반드시 제공해야 할 동작을 컴파일 시점에 강제한다.

모든 동작을 파생 클래스에 맡기는 것이 목적은 아니다. 변하지 않는 실행 흐름은 기반 클래스가 관리하고 달라져야 하는 일부 단계만 확장 지점으로 제공할 수 있다.

추상 클래스는 강한 상속 관계를 만든다. 공통 코드의 양보다 타입의 의미, 공유해야 할 상태와 생명 주기가 실제로 같은지를 기준으로 선택해야 한다.

---

## 핵심 정리

- 추상 클래스는 직접 생성할 수 없는 미완성 기반 타입이다.
- 추상 멤버는 구현 본문이 없으며 구체 파생 클래스가 반드시 재정의해야 한다.
- 추상 클래스는 필드, 생성자와 구현된 메서드를 가질 수 있다.
- `virtual`은 재정의가 선택이고 `abstract`는 구체 클래스에서 재정의가 필수이다.
- 추상 클래스 생성자는 파생 객체의 기반 영역을 초기화할 때 실행된다.
- 추상 메서드도 가상 슬롯을 통해 실제 파생 객체의 구현과 연결된다.
- 추상 클래스 타입은 변수, 매개변수와 컬렉션 타입으로 사용할 수 있다.
- Unity에서는 추상 `MonoBehaviour`를 직접 추가할 수 없으며 구체 파생 Component를 사용해야 한다.
- 공통 코드만을 이유로 상속하지 말고 타입 관계와 공유할 상태를 기준으로 판단해야 한다.
