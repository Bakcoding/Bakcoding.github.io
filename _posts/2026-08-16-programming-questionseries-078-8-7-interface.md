---
title: "[궁금시리즈] 8-7. 인터페이스는 왜 필요할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-7-interface/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:06 +0900
last_modified_at: 2026-08-16 12:00:06 +0900
---

## 들어가며

Player와 Monster는 모두 피해를 받을 수 있다. 상자를 공격하면 파괴되고 문을 공격하면 잠금 장치가 손상될 수도 있다.

```text
Player
Monster
BreakableBox
Door
```

이 객체들은 서로 같은 종류라고 보기 어렵다.

Player와 Monster는 Character일 수 있지만 BreakableBox와 Door까지 Character를 상속하게 만들면 타입의 의미가 어색해진다.

```cs
public class BreakableBox : Character
{
}
```

공통 기반 클래스를 만들기 위해 이미 다른 상속 관계를 포기할 수도 없다. C# 클래스는 하나의 클래스만 직접 상속할 수 있기 때문이다.

필요한 것은 같은 부모 클래스가 아니라 피해를 받을 수 있다는 공통 역할이다.

인터페이스(Interface)는 객체가 제공해야 할 기능의 계약을 정의한다.

```cs
public interface IDamageable
{
    void TakeDamage(int damage);
}
```

어떤 클래스든 이 계약을 구현하면 구체 타입과 상속 계층이 달라도 `IDamageable`로 다룰 수 있다.

---

## 개념 설명

인터페이스는 타입이 제공해야 하는 멤버를 선언한다.

```cs
public interface IDamageable
{
    int Health { get; }
    void TakeDamage(int damage);
}
```

클래스는 `:` 뒤에 인터페이스를 작성해 계약을 구현한다.

```cs
public class Monster : IDamageable
{
    public int Health { get; private set; } = 100;

    public void TakeDamage(int damage)
    {
        Health = Math.Max(0, Health - damage);
    }
}
```

구현 클래스가 필요한 멤버를 제공하지 않으면 컴파일 오류가 발생한다.

```cs
public class Door : IDamageable // TakeDamage()가 없어 오류
{
    public int Health => 100;
}
```

인터페이스는 호출하는 코드와 구현하는 코드가 합의한 사용 방법을 나타낸다.

```cs
public void Hit(IDamageable target, int damage)
{
    target.TakeDamage(damage);
}
```

`Hit()`은 target이 Monster인지 Door인지 알 필요가 없다. `IDamageable` 계약을 지킨다는 사실만 사용한다.

### 역할을 표현한다

클래스 상속은 대상이 무엇인지에 가까운 관계를 표현한다.

```text
Slime is a Monster.
Warrior is a Character.
```

인터페이스는 대상이 무엇을 할 수 있는지에 가까운 역할을 표현한다.

```text
Monster is damageable.
Door is damageable.
NPC is interactable.
Item is selectable.
```

인터페이스 이름에 `I` 접두어를 붙이는 것은 C#에서 널리 사용하는 관례이다.

```cs
IDamageable
IInteractable
ISaveable
IComparable<T>
```

문법적으로 필수는 아니지만 클래스와 역할 계약을 구분하기 쉽다.

### 여러 인터페이스를 구현할 수 있다

C# 클래스는 여러 인터페이스를 동시에 구현할 수 있다.

```cs
public class NPC : Character,
    IDamageable,
    IInteractable,
    ISaveable
{
}
```

NPC는 Character라는 하나의 기반 클래스를 상속하면서 피해 처리, 상호작용과 저장이라는 여러 역할을 가질 수 있다.

```text
NPC
├─ Character 상속
├─ IDamageable 구현
├─ IInteractable 구현
└─ ISaveable 구현
```

인터페이스도 다른 인터페이스를 상속할 수 있다.

```cs
public interface IEntity
{
    int Id { get; }
}

public interface ISaveableEntity : IEntity, ISaveable
{
}
```

이 경우 구현 타입은 결합된 모든 계약을 제공해야 한다.

### 인터페이스는 상태를 소유할까?

인터페이스는 인스턴스 필드를 선언해 객체 상태를 저장하는 기반 클래스가 아니다.

```cs
public interface IDamageable
{
    int health; // 인스턴스 필드 선언 불가
}
```

프로퍼티를 선언할 수 있지만 값을 어디에 저장하고 어떻게 계산할지는 구현 타입이 결정한다.

```cs
public interface IDamageable
{
    int Health { get; }
}
```

Monster는 필드에 값을 저장할 수 있고, 보호막 객체는 다른 값에서 계산할 수도 있다.

```cs
public int Health => armor.Durability;
```

계약은 결과를 읽을 수 있다는 사실만 규정한다.

---

## 코드 예제

공격 시스템이 구체 타입 대신 `IDamageable`에 의존하도록 만들 수 있다.

```cs
public interface IDamageable
{
    bool IsDead { get; }
    void TakeDamage(int damage);
}
```

Monster는 체력을 줄이는 방식으로 계약을 구현한다.

```cs
public class Monster : IDamageable
{
    public int Health { get; private set; }
    public bool IsDead => Health == 0;

    public Monster(int health)
    {
        Health = health;
    }

    public void TakeDamage(int damage)
    {
        Health = Math.Max(0, Health - damage);
    }
}
```

BreakableBox는 내구도가 0이 되면 파괴 상태가 된다.

```cs
public class BreakableBox : IDamageable
{
    public int Durability { get; private set; } = 30;
    public bool IsDead => Durability == 0;

    public void TakeDamage(int damage)
    {
        Durability = Math.Max(0, Durability - damage);
    }
}
```

Weapon은 두 클래스의 내부 구조를 알지 못한다.

```cs
public class Weapon
{
    public int Damage { get; }

    public Weapon(int damage)
    {
        Damage = damage;
    }

    public void Attack(IDamageable target)
    {
        target.TakeDamage(Damage);
    }
}
```

```cs
Weapon sword = new Weapon(20);

IDamageable monster = new Monster(100);
IDamageable box = new BreakableBox();

sword.Attack(monster);
sword.Attack(box);
```

새로운 Door가 추가되어도 Weapon은 수정되지 않는다.

```cs
public class Door : IDamageable
{
    public bool IsDead { get; private set; }

    public void TakeDamage(int damage)
    {
        if (damage >= 50)
        {
            IsDead = true;
        }
    }
}
```

Weapon이 아는 것은 `IDamageable.TakeDamage()`뿐이다. 객체별 피해 처리 규칙은 각 구현 클래스 안에 유지된다.

### 명시적 인터페이스 구현

서로 다른 인터페이스에 같은 이름의 멤버가 있거나 특정 역할로 사용할 때만 멤버를 공개하고 싶을 수 있다.

```cs
public interface IPlayerController
{
    void Move();
}

public interface IAIController
{
    void Move();
}
```

명시적 인터페이스 구현은 멤버 이름 앞에 인터페이스 이름을 붙인다.

```cs
public class NPCController : IPlayerController, IAIController
{
    void IPlayerController.Move()
    {
        Console.WriteLine("입력으로 이동");
    }

    void IAIController.Move()
    {
        Console.WriteLine("AI로 이동");
    }
}
```

클래스 변수에서는 명시적 구현 멤버가 직접 보이지 않는다.

```cs
NPCController controller = new NPCController();
// controller.Move(); 사용 불가
```

해당 인터페이스 타입으로 변환해야 호출할 수 있다.

```cs
IPlayerController player = controller;
IAIController ai = controller;

player.Move(); // 입력으로 이동
ai.Move();     // AI로 이동
```

명시적 구현은 같은 이름의 역할을 구분하지만 지나치게 사용하면 객체의 사용 방법을 파악하기 어려울 수 있다.

---

## 내부 동작

인터페이스도 CLR 타입 시스템에 포함되는 타입이다.

컴파일된 타입 메타데이터에는 클래스가 어떤 인터페이스를 구현하는지와 각 인터페이스 멤버가 어떤 실제 메서드에 연결되는지가 기록된다.

```text
Monster 타입
└─ IDamageable 구현
   ├─ get_IsDead → Monster.get_IsDead
   └─ TakeDamage → Monster.TakeDamage
```

인터페이스 참조로 메서드를 호출하면 런타임은 실제 객체 타입의 구현 정보를 찾아 대상 메서드를 실행한다.

```cs
IDamageable target = new Monster(100);
target.TakeDamage(20);
```

```text
IDamageable.TakeDamage 요청
↓
실제 객체 타입은 Monster
↓
Monster의 인터페이스 구현 탐색
↓
Monster.TakeDamage 실행
```

이 과정은 클래스 가상 메서드 호출과 목적은 비슷하지만 인터페이스 계약과 구현 타입 사이의 매핑을 사용한다.

JIT는 실제 타입을 확정할 수 있는 경우 인터페이스 호출도 직접 호출 형태로 최적화할 수 있다.

### 참조 타입 변환

클래스 객체를 인터페이스 변수에 대입해도 새로운 객체가 생성되거나 원본 객체가 복사되지 않는다.

```cs
Monster monster = new Monster(100);
IDamageable target = monster;
```

두 변수는 같은 Monster 객체를 참조한다.

```text
monster ──┐
          ├──▶ 하나의 Monster 객체
target ───┘
```

인터페이스 참조로 보이는 멤버는 해당 인터페이스가 선언한 계약으로 제한된다.

### 값 타입과 Boxing

구조체도 인터페이스를 구현할 수 있다.

```cs
public struct Damage : IComparable<Damage>
{
    public int Value { get; }

    public int CompareTo(Damage other)
    {
        return Value.CompareTo(other.Value);
    }
}
```

구조체 값을 인터페이스 타입 변수에 대입하면 Boxing이 발생할 수 있다.

```cs
Damage damage = new Damage();
IComparable<Damage> comparable = damage;
```

값을 인터페이스 참조로 다루기 위해 관리되는 Heap의 객체로 감싸야 하기 때문이다.

Generic 제약 조건을 통해 호출하면 JIT가 Boxing 없이 처리할 수 있는 경우가 있다.

```cs
static int Compare<T>(T left, T right)
    where T : IComparable<T>
{
    return left.CompareTo(right);
}
```

성능이 중요한 반복 경로에서 구조체를 인터페이스 타입으로 변환한다면 할당 여부를 측정해야 한다.

---

## 실제 Unity에서는?

Unity의 Component도 인터페이스를 구현할 수 있다.

```cs
public interface IInteractable
{
    void Interact();
}
```

```cs
public class NPC : MonoBehaviour, IInteractable
{
    public void Interact()
    {
        Debug.Log("대화를 시작한다.");
    }
}
```

```cs
public class TreasureChest : MonoBehaviour, IInteractable
{
    public void Interact()
    {
        Debug.Log("상자를 연다.");
    }
}
```

Player는 충돌한 대상의 구체 Component 타입을 알 필요가 없다.

```cs
private void TryInteract(Collider other)
{
    if (other.TryGetComponent(out IInteractable target))
    {
        target.Interact();
    }
}
```

NPC, TreasureChest와 이후 추가되는 다른 Component도 같은 코드에서 동작한다.

### Inspector 직렬화 제약

일반적인 Unity Inspector에서는 인터페이스 타입 필드를 직접 직렬화하기 어렵다.

```cs
[SerializeField] private IInteractable target;
```

이 필드는 기본 Object 참조 슬롯으로 정상 노출되지 않는다.

`MonoBehaviour` 참조를 Inspector에서 연결해야 한다면 `MonoBehaviour` 또는 `GameObject`로 직렬화한 뒤 인터페이스 구현 여부를 검증하는 방식을 사용할 수 있다.

```cs
[SerializeField] private MonoBehaviour targetObject;

private IInteractable Target =>
    targetObject as IInteractable;
```

```cs
private void OnValidate()
{
    if (targetObject is not null &&
        targetObject is not IInteractable)
    {
        Debug.LogError("IInteractable 구현이 필요하다.", this);
    }
}
```

일반 C# 객체의 다형적 직렬화에는 `[SerializeReference]`를 사용할 수 있지만 지원되는 타입과 Inspector 편집 방식에는 제약이 있다.

런타임에 Component를 찾는 경우에는 `GetComponent<IInteractable>()` 또는 `TryGetComponent()`로 인터페이스 구현을 조회할 수 있다.

인터페이스는 Unity Component의 상속 계층을 깊게 만들지 않고 필요한 역할만 연결하는 데 유용하다.

---

## 실무에서 자주 하는 오해

### 인터페이스는 메서드 목록일 뿐이라는 오해

문법상으로는 멤버 선언이지만 설계에서는 호출자와 구현자 사이의 계약이다.

`TakeDamage()`가 음수 값을 허용하는지, 사망한 대상에서 어떻게 동작하는지 같은 의미도 계약의 일부이다. 이름과 시그니처만 같고 의미가 다르면 안전한 다형성을 만들 수 없다.

### 모든 클래스에 인터페이스를 만들어야 한다는 오해

구현이 하나뿐이고 교체하거나 공통 타입으로 사용할 이유가 없다면 인터페이스가 추가 계층만 만들 수 있다.

경계 분리, 여러 구현, 테스트 대역 또는 의존 방향을 바꿀 필요가 있을 때 가치가 생긴다.

### 큰 인터페이스 하나가 편리하다는 오해

```cs
public interface IEntity
{
    void Move();
    void Attack();
    void Interact();
    void Save();
}
```

모든 구현이 모든 기능을 필요로 하지 않으면 빈 메서드나 예외를 반환하는 구현이 생긴다.

```cs
public void Attack()
{
    throw new NotSupportedException();
}
```

`IMovable`, `IAttacker`, `IInteractable`처럼 사용하는 역할을 기준으로 작은 계약을 만드는 편이 좋다.

### 인터페이스 호출은 항상 느리다는 오해

인터페이스 호출에는 구현을 찾는 과정이 있지만 JIT가 실제 타입을 파악하면 최적화할 수 있다.

성능 차이를 가정해 설계를 복잡하게 만들기보다 실제 실행 환경에서 Profiler와 Benchmark로 확인해야 한다. 구조체를 인터페이스로 다룰 때의 Boxing은 별도로 주의해야 한다.

---

## 마무리

인터페이스는 객체가 무엇인지가 아니라 무엇을 할 수 있는지를 표현하는 역할 계약이다.

서로 다른 상속 계층의 클래스도 같은 인터페이스를 구현하면 공통 타입으로 협력할 수 있다. 호출하는 코드는 구체적인 구현 대신 필요한 역할에 의존하므로 새로운 구현이 추가되어도 변경 범위가 줄어든다.

인터페이스는 상태와 공통 생명 주기를 공유하는 기반 클래스가 아니다. 공통 상태와 구현이 핵심이면 추상 클래스가 자연스러울 수 있고, 서로 다른 객체에 같은 역할을 부여하는 것이 핵심이면 인터페이스가 적합하다.

좋은 인터페이스는 가능한 많은 기능을 모으는 계약이 아니라 사용하는 코드가 실제로 필요로 하는 작고 분명한 역할을 표현한다.

---

## 핵심 정리

- 인터페이스는 타입이 제공해야 할 기능의 계약을 정의한다.
- 클래스는 하나의 기반 클래스와 여러 인터페이스를 함께 사용할 수 있다.
- 인터페이스는 객체가 무엇인지보다 무엇을 할 수 있는지를 표현한다.
- 인터페이스는 인스턴스 상태를 저장하는 기반 클래스가 아니다.
- 인터페이스 참조는 실제 구현 객체를 복사하지 않고 같은 객체를 가리킨다.
- 명시적 인터페이스 구현으로 같은 이름의 역할을 구분할 수 있다.
- 구조체를 인터페이스 타입으로 변환하면 Boxing이 발생할 수 있다.
- Unity에서는 Component가 인터페이스를 구현할 수 있지만 인터페이스 필드의 기본 직렬화에는 제약이 있다.
- 인터페이스는 사용하는 코드가 필요로 하는 작고 명확한 역할을 기준으로 설계해야 한다.
