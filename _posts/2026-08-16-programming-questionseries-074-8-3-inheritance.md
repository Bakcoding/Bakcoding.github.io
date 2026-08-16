---
title: "[궁금시리즈] 8-3. 상속은 왜 필요할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-3-inheritance/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:02 +0900
last_modified_at: 2026-08-16 12:00:02 +0900
---

## 들어가며

게임에는 비슷한 특징을 가진 객체가 자주 등장한다.

```cs
public class Warrior
{
    public string Name { get; set; }
    public int Health { get; set; }

    public void Move() { }
    public void TakeDamage(int damage) { }
}
```

```cs
public class Archer
{
    public string Name { get; set; }
    public int Health { get; set; }

    public void Move() { }
    public void TakeDamage(int damage) { }
}
```

Warrior와 Archer는 서로 다른 클래스지만 이름과 체력을 가지고 이동하며 피해를 받는다는 공통점이 있다.

클래스가 늘어날 때마다 같은 필드와 메서드를 반복해서 작성하면 수정도 반복된다. 체력 규칙을 변경할 때 모든 클래스를 찾아 고쳐야 하고 일부 클래스에만 변경이 빠질 수도 있다.

상속(Inheritance)은 기존 타입의 특성과 동작을 새로운 타입이 이어받도록 만들어 공통 개념을 표현하는 객체지향 기능이다.

하지만 상속은 중복 코드를 없애기 위한 문법만은 아니다.

어떤 타입을 더 구체적인 타입으로 확장하고, 여러 객체를 하나의 기반 타입으로 다룰 수 있게 만드는 데 더 중요한 의미가 있다.

---

## 개념 설명

C#에서는 클래스 이름 뒤에 `:`을 사용하여 상속 관계를 선언한다.

```cs
public class Character
{
    public string Name { get; }
    public int Health { get; protected set; }

    public Character(string name, int health)
    {
        Name = name;
        Health = health;
    }

    public void Move()
    {
        Console.WriteLine($"{Name} moves.");
    }
}
```

`Character`를 상속하는 `Warrior`는 Character가 가진 멤버를 사용할 수 있다.

```cs
public class Warrior : Character
{
    public Warrior(string name, int health)
        : base(name, health)
    {
    }

    public void UseShield()
    {
        Console.WriteLine($"{Name} uses a shield.");
    }
}
```

`Character`는 기반 클래스(Base Class) 또는 부모 클래스라고 부른다. `Warrior`는 파생 클래스(Derived Class) 또는 자식 클래스라고 부른다.

```text
Character
├─ Name
├─ Health
└─ Move()
    ▲
    │ 상속
Warrior
└─ UseShield()
```

Warrior 객체는 자신에게 선언된 `UseShield()`뿐 아니라 Character에서 물려받은 `Name`, `Health`, `Move()`도 가진다.

```cs
Warrior warrior = new Warrior("Alice", 150);

warrior.Move();
warrior.UseShield();
```

### is-a 관계

상속 관계는 보통 is-a 관계가 성립할 때 자연스럽다.

```text
Warrior is a Character.
Archer is a Character.
Monster is a Character.
```

Warrior가 Character의 한 종류라면 Character가 필요한 위치에서 Warrior를 사용할 수 있다.

```cs
Character character = new Warrior("Alice", 150);
```

반면 Player가 Weapon을 가지고 있다는 관계는 is-a가 아니라 has-a 관계이다.

```text
Player has a Weapon.
```

이 관계를 상속으로 표현하면 의미가 어색해진다.

```cs
public class Player : Weapon // 잘못된 관계
{
}
```

has-a 관계는 객체를 필드로 가지는 Composition이 더 적절하다.

```cs
public class Player
{
    private readonly Weapon weapon;
}
```

코드를 재사용할 수 있다는 이유만으로 상속을 선택하면 타입 관계가 실제 의미와 달라질 수 있다.

### C#은 클래스 다중 상속을 지원하지 않는다

C# 클래스는 하나의 클래스만 직접 상속할 수 있다.

```cs
public class Paladin : Warrior, Healer // 컴파일 오류
{
}
```

여러 부모 클래스가 같은 멤버를 제공하면 어떤 구현을 사용할지 모호해지고 객체 구조도 복잡해질 수 있다.

C#은 클래스의 단일 상속만 허용하고, 여러 역할이 필요할 때 인터페이스 구현이나 Composition을 사용하도록 설계되었다.

```cs
public class Paladin : Character, IAttacker, IHealer
{
}
```

모든 클래스는 명시하지 않아도 최종적으로 `System.Object`를 상속한다.

```text
System.Object
└─ Character
   └─ Warrior
```

그래서 모든 객체에서 `ToString()`, `Equals()`와 `GetHashCode()` 같은 메서드를 사용할 수 있다.

---

## 코드 예제

Character의 공통 체력 규칙을 상속 구조로 만들 수 있다.

```cs
public class Character
{
    public string Name { get; }
    public int MaxHealth { get; }
    public int Health { get; protected set; }
    public bool IsDead => Health == 0;

    public Character(string name, int maxHealth)
    {
        Name = name;
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
}
```

Warrior와 Monster는 공통 규칙을 이어받고 각자의 기능만 추가한다.

```cs
public class Warrior : Character
{
    public int Armor { get; }

    public Warrior(string name, int health, int armor)
        : base(name, health)
    {
        Armor = armor;
    }
}
```

```cs
public class Monster : Character
{
    public int RewardGold { get; }

    public Monster(string name, int health, int rewardGold)
        : base(name, health)
    {
        RewardGold = rewardGold;
    }
}
```

서로 다른 파생 객체를 `Character` 컬렉션에 함께 저장할 수 있다.

```cs
List<Character> characters =
[
    new Warrior("Alice", 150, 20),
    new Monster("Slime", 50, 10)
];

foreach (Character character in characters)
{
    character.TakeDamage(10);
}
```

호출하는 코드는 실제 객체가 Warrior인지 Monster인지 확인하지 않아도 공통 기능을 사용할 수 있다.

이것이 상속이 제공하는 중요한 효과이다. 파생 타입을 기반 타입으로 다룰 수 있기 때문에 사용하는 쪽이 구체 타입에 덜 의존한다.

### base 키워드

`base`는 기반 클래스의 생성자나 멤버에 접근할 때 사용한다.

```cs
public Warrior(string name, int health, int armor)
    : base(name, health)
{
    Armor = armor;
}
```

Character에는 매개변수가 없는 생성자가 없으므로 Warrior 생성자는 어떤 기반 생성자를 호출할지 명시해야 한다.

파생 클래스에서 기반 클래스의 구현을 호출할 때도 `base`를 사용할 수 있다.

```cs
public void Restore()
{
    Health = MaxHealth;
}
```

다만 파생 클래스가 기반 클래스의 내부 구현에 지나치게 의존하면 부모의 작은 변경이 자식에 영향을 줄 수 있다. `protected` 멤버를 필요한 범위보다 넓게 공개하지 않는 것이 좋다.

---

## 내부 동작

파생 클래스 객체에는 기반 클래스가 정의한 인스턴스 필드도 함께 포함된다.

```cs
Warrior warrior = new Warrior("Alice", 150, 20);
```

개념적인 객체 구성은 다음과 같다.

```text
Warrior 객체
├─ Object 영역
├─ Character 영역
│  ├─ Name
│  ├─ MaxHealth
│  └─ Health
└─ Warrior 영역
   └─ Armor
```

Character 객체와 Warrior 객체가 따로 생성되어 연결되는 구조가 아니다. 하나의 Warrior 객체 안에 기반 클래스가 정의한 상태가 함께 배치된다.

### 생성자 호출 순서

파생 객체를 생성하면 기반 클래스 생성자가 먼저 실행되고 그다음 파생 클래스 생성자가 실행된다.

```cs
public class Character
{
    public Character()
    {
        Console.WriteLine("Character");
    }
}

public class Warrior : Character
{
    public Warrior()
    {
        Console.WriteLine("Warrior");
    }
}
```

```cs
new Warrior();
```

실행 결과는 다음과 같다.

```text
Character
Warrior
```

객체의 기반 영역이 먼저 초기화되어야 파생 클래스가 상속받은 상태를 안전하게 사용할 수 있기 때문이다.

객체 생성 흐름을 단순화하면 다음과 같다.

```text
Warrior 메모리 확보
↓
Character 필드 초기화
↓
Character 생성자 실행
↓
Warrior 필드 초기화
↓
Warrior 생성자 실행
```

### 기반 타입 참조

다음 대입에는 새로운 Character 객체 생성이나 Warrior 객체 복사가 발생하지 않는다.

```cs
Warrior warrior = new Warrior();
Character character = warrior;
```

두 변수는 같은 Warrior 객체를 가리킨다. 다만 `character` 변수로 접근할 수 있는 멤버는 컴파일 시점 타입인 Character가 공개하는 범위로 제한된다.

```text
warrior ────┐
            ├──▶ 하나의 Warrior 객체
character ──┘
```

실제 객체의 타입 정보는 런타임에도 유지된다. 이 정보는 형식 검사, 캐스팅과 가상 메서드 호출에 사용된다.

상속받은 메서드가 실제 객체 타입에 따라 달라지는 과정은 다음 글의 다형성과 `virtual`, `override`에서 구체적으로 연결된다.

---

## 실제 Unity에서는?

Unity의 Component도 상속 구조를 사용한다.

```text
System.Object
└─ UnityEngine.Object
   └─ Component
      └─ Behaviour
         └─ MonoBehaviour
            └─ PlayerController
```

사용자 스크립트가 `MonoBehaviour`를 상속하면 Unity가 제공하는 Component 기능과 생명 주기에 참여할 수 있다.

```cs
public class PlayerController : MonoBehaviour
{
    private void Update()
    {
        // 매 프레임 Unity가 호출
    }
}
```

`MonoBehaviour`를 상속했다는 이유만으로 `Update()`가 C#의 가상 메서드 Override로 동작하는 것은 아니다. Unity는 정해진 이름과 시그니처를 가진 메시지 메서드를 찾아 호출한다.

프로젝트 공통 Component 기능을 기반 클래스로 만들 수도 있다.

```cs
public class CharacterHealth : MonoBehaviour
{
    [SerializeField] private int maxHealth = 100;

    public int Health { get; private set; }

    protected virtual void Awake()
    {
        Health = maxHealth;
    }

    public void TakeDamage(int damage)
    {
        Health = Mathf.Max(0, Health - damage);
    }
}
```

```cs
public class PlayerHealth : CharacterHealth
{
}
```

하지만 Unity는 Component 조합을 중심으로 설계된 Engine이다.

`CharacterBase → LivingCharacter → ControllableCharacter → Player`처럼 상속 단계가 깊어지면 어느 클래스가 상태를 변경하는지 찾기 어려워지고 Unity Inspector의 의존 관계도 복잡해진다.

이동, 체력, 공격과 입력처럼 독립적으로 바뀌는 기능은 별도의 Component로 나누는 편이 유연할 수 있다.

```text
Player GameObject
├─ PlayerMovement
├─ PlayerHealth
├─ PlayerAttack
└─ PlayerInput
```

Unity에서 상속은 공통 타입 관계가 분명할 때 사용하고, 기능 재사용만 필요하다면 Component 조합을 먼저 검토하는 것이 좋다.

---

## 실무에서 자주 하는 오해

### 중복 코드가 있으면 상속해야 한다는 오해

코드가 비슷하다는 사실만으로 두 타입이 같은 종류가 되는 것은 아니다.

Player와 BreakableBox가 모두 체력을 가진다고 해서 반드시 같은 Character를 상속해야 하는 것은 아니다. 피해 처리 기능을 별도 객체나 Component로 분리할 수도 있다.

상속은 코드 모양이 아니라 타입 의미를 기준으로 결정해야 한다.

### 부모의 private 멤버는 상속되지 않는다는 오해

파생 객체에는 기반 클래스의 `private` 필드도 포함된다. 다만 파생 클래스 코드에서 직접 접근할 수 없을 뿐이다.

기반 클래스가 제공하는 `protected` 또는 `public` 메서드를 통해 해당 상태가 사용된다.

### 상속 단계가 많을수록 재사용성이 높다는 오해

깊은 상속 구조는 공통 코드를 많이 공유하지만 변경 영향도 함께 공유한다.

기반 클래스의 수정이 여러 파생 클래스에 예상하지 못한 동작을 만들 수 있고 특정 기능만 교체하기도 어려워진다.

### is-a 관계면 항상 상속해야 한다는 오해

개념적으로 is-a 관계가 성립하더라도 변경 방향이 다르거나 결합 비용이 크다면 인터페이스와 Composition이 더 적합할 수 있다.

상속은 강한 관계이므로 타입 대체가 실제로 필요하고 기반 클래스의 계약을 파생 클래스가 지킬 수 있을 때 선택해야 한다.

---

## 마무리

상속은 기존 클래스의 필드와 동작을 이어받아 더 구체적인 타입을 표현하는 기능이다.

파생 타입을 기반 타입으로 다룰 수 있게 만들기 때문에 여러 구체 객체를 공통된 방식으로 사용하는 기반이 된다.

그러나 상속은 기반 클래스와 파생 클래스를 강하게 결합한다. 단순한 코드 재사용이나 has-a 관계를 표현하기 위해 사용하면 변경에 취약한 구조가 될 수 있다.

좋은 상속 관계는 코드가 비슷해서 만들어지는 것이 아니라 파생 타입이 기반 타입의 의미와 규칙을 자연스럽게 이어받을 때 만들어진다.

---

## 핵심 정리

- 상속은 기존 타입을 바탕으로 더 구체적인 타입을 표현하는 기능이다.
- 기반 클래스는 공통 상태와 동작을 정의하고 파생 클래스는 고유 기능을 추가한다.
- 상속은 일반적으로 is-a 관계가 성립할 때 사용한다.
- has-a 관계와 기능 조합에는 Composition이 더 적합할 수 있다.
- C# 클래스는 하나의 클래스만 직접 상속할 수 있다.
- 파생 객체에는 기반 클래스가 선언한 인스턴스 상태도 함께 포함된다.
- 기반 클래스 생성자는 파생 클래스 생성자보다 먼저 실행된다.
- 기반 타입 변수와 파생 타입 변수는 같은 객체를 참조할 수 있다.
- Unity에서는 깊은 상속 구조보다 작은 Component 조합이 유연한 경우가 많다.
