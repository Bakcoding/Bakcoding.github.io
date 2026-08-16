---
title: "[궁금시리즈] 8-13. 상속보다 Composition을 우선하라는 이유"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-13-composition/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:12 +0900
last_modified_at: 2026-08-16 12:00:12 +0900
---

## 들어가며

게임 캐릭터의 기능을 상속으로 확장할 수 있다.

```text
Character
└─ MovableCharacter
   └─ AttackableCharacter
      └─ SkillCharacter
         └─ Player
```

Player는 이동하고 공격하며 Skill을 사용한다. 처음에는 공통 코드를 차례로 물려받는 구조가 자연스러워 보인다.

하지만 이동할 수 없고 공격만 하는 Turret, 이동하고 대화하지만 공격하지 않는 NPC, 공격과 Skill은 있지만 이동하지 않는 Boss가 추가되면 상속 조합이 복잡해진다.

```text
Turret는 어떤 클래스를 상속해야 할까?
NPC가 AttackableCharacter의 공격 기능을 제외할 수 있을까?
Flying 기능은 상속 계층의 어느 위치에 들어가야 할까?
```

기능 조합마다 새로운 파생 클래스를 만들면 클래스 수가 늘고 하나의 기능을 바꾸기 위해 여러 상속 계층을 수정하게 된다.

Composition은 객체가 필요한 기능을 상속받는 대신 다른 객체를 포함하고 그 객체에 작업을 위임하는 설계 방식이다.

```text
Player
├─ IMovement
├─ IAttack
└─ ISkill
```

객체의 종류를 상속 단계로 고정하지 않고 작은 기능 객체를 조합하여 동작을 구성한다.

---

## 개념 설명

Composition은 한 객체가 다른 객체를 필드로 가지고 협력하는 has-a 관계이다.

```cs
public class Player
{
    private readonly Weapon weapon;
}
```

```text
Player has a Weapon.
```

Player는 Weapon이 아니므로 상속 관계는 자연스럽지 않다.

```cs
public class Player : Weapon // 의미가 맞지 않음
{
}
```

Player가 Weapon을 포함하고 공격을 위임하면 각 객체의 역할이 분리된다.

```cs
public class Player
{
    private readonly Weapon weapon;

    public Player(Weapon weapon)
    {
        this.weapon = weapon;
    }

    public void Attack(Character target)
    {
        weapon.Attack(target);
    }
}
```

Player는 공격 요청을 받고 Weapon은 실제 공격 방식을 처리한다.

### 위임

위임(Delegation)은 객체가 받은 작업을 내부의 다른 객체에 맡기는 것이다.

```text
외부 코드
↓ Player.Attack()
Player
↓ weapon.Attack()
Weapon
↓ target.TakeDamage()
Character
```

Player는 Weapon의 구현을 상속하지 않는다. Weapon을 협력 객체로 사용한다.

상속은 기반 클래스가 결정한 구현과 생명 주기를 파생 클래스가 이어받는다. Composition은 필요한 객체를 외부에서 선택해 연결할 수 있다.

```text
상속
Player is a Character.

Composition
Player has a Weapon.
Player uses an IMovement.
```

두 관계는 서로 대체되는 문법이 아니다. is-a 관계에는 상속을 사용하고, 역할과 기능 조합에는 Composition을 사용할 수 있다.

### 기능을 조합한다

이동 방식을 인터페이스로 표현한다.

```cs
public interface IMovement
{
    void Move(Vector3 direction);
}
```

서로 다른 구현을 만들 수 있다.

```cs
public class GroundMovement : IMovement
{
    public void Move(Vector3 direction)
    {
        Console.WriteLine("지상 이동");
    }
}
```

```cs
public class FlyingMovement : IMovement
{
    public void Move(Vector3 direction)
    {
        Console.WriteLine("비행 이동");
    }
}
```

Character는 구체 이동 방식이 아니라 역할을 포함한다.

```cs
public class Character
{
    private IMovement movement;

    public Character(IMovement movement)
    {
        this.movement = movement;
    }

    public void Move(Vector3 direction)
    {
        movement.Move(direction);
    }
}
```

생성할 때 기능을 선택할 수 있다.

```cs
Character warrior =
    new Character(new GroundMovement());

Character dragon =
    new Character(new FlyingMovement());
```

Character 상속 계층을 늘리지 않고 동작을 조합한다.

### 런타임 교체

Composition은 포함한 객체를 바꾸어 실행 중에도 동작을 교체할 수 있다.

```cs
public void ChangeMovement(IMovement movement)
{
    this.movement = movement;
}
```

```cs
player.ChangeMovement(new FlyingMovement());
```

비행 버프가 끝나면 다시 GroundMovement로 바꿀 수 있다.

상속은 객체가 생성된 뒤 실제 타입을 바꿀 수 없지만 Composition은 협력 객체 참조를 교체하여 행동을 변경할 수 있다.

---

## 코드 예제

Enemy의 이동과 공격 기능을 상속 조합으로 만들면 파생 클래스가 빠르게 늘어날 수 있다.

```text
GroundMeleeEnemy
GroundRangedEnemy
FlyingMeleeEnemy
FlyingRangedEnemy
```

이동 방식 2개와 공격 방식 2개만 조합해도 4개 클래스가 필요하다. 기능이 추가될수록 조합 수가 증가한다.

각 기능을 별도 역할로 분리할 수 있다.

```cs
public interface IMovement
{
    void Move();
}

public interface IAttack
{
    void Attack(Character target);
}
```

이동 구현을 만든다.

```cs
public class GroundMovement : IMovement
{
    public void Move()
    {
        Console.WriteLine("지면을 따라 이동한다.");
    }
}
```

```cs
public class FlyingMovement : IMovement
{
    public void Move()
    {
        Console.WriteLine("공중으로 이동한다.");
    }
}
```

공격 구현도 분리한다.

```cs
public class MeleeAttack : IAttack
{
    private readonly int damage;

    public MeleeAttack(int damage)
    {
        this.damage = damage;
    }

    public void Attack(Character target)
    {
        target.TakeDamage(damage);
    }
}
```

```cs
public class RangedAttack : IAttack
{
    private readonly Projectile projectile;

    public RangedAttack(Projectile projectile)
    {
        this.projectile = projectile;
    }

    public void Attack(Character target)
    {
        projectile.Fire(target);
    }
}
```

Enemy는 두 역할에 작업을 위임한다.

```cs
public class Enemy
{
    private readonly IMovement movement;
    private readonly IAttack attack;

    public Enemy(IMovement movement, IAttack attack)
    {
        this.movement = movement;
        this.attack = attack;
    }

    public void Update(Character target)
    {
        movement.Move();
        attack.Attack(target);
    }
}
```

조립 코드에서 원하는 기능을 선택한다.

```cs
Enemy flyingArcher = new Enemy(
    new FlyingMovement(),
    new RangedAttack(arrowProjectile));

Enemy groundWarrior = new Enemy(
    new GroundMovement(),
    new MeleeAttack(20));
```

새로운 TeleportMovement를 추가해도 Enemy와 Attack 구현은 수정하지 않는다.

```cs
public class TeleportMovement : IMovement
{
    public void Move()
    {
        Console.WriteLine("순간 이동한다.");
    }
}
```

```text
Movement 3개 × Attack 2개
↓
파생 클래스 6개가 아니라
구현 객체를 조립하여 사용
```

### Decorator 형태의 조합

기존 공격 기능을 수정하지 않고 추가 동작으로 감쌀 수도 있다.

```cs
public class CriticalAttack : IAttack
{
    private readonly IAttack inner;
    private readonly float chance;

    public CriticalAttack(IAttack inner, float chance)
    {
        this.inner = inner;
        this.chance = chance;
    }

    public void Attack(Character target)
    {
        if (Random.Shared.NextSingle() < chance)
        {
            Console.WriteLine("Critical");
        }

        inner.Attack(target);
    }
}
```

```cs
IAttack attack = new CriticalAttack(
    new MeleeAttack(20),
    0.2f);
```

CriticalAttack은 다른 `IAttack`을 포함하고 호출을 위임한다. 조합을 통해 기능을 계층적으로 확장할 수 있다.

---

## 내부 동작

Composition은 특별한 CLR 기능이 아니다. 객체가 다른 객체의 참조를 필드에 저장하고 메서드를 호출하는 구조이다.

```cs
public class Enemy
{
    private readonly IMovement movement;
    private readonly IAttack attack;
}
```

런타임의 객체 그래프는 다음과 같다.

```text
Enemy 객체
├─ movement ──▶ FlyingMovement 객체
└─ attack ────▶ RangedAttack 객체
                       └─ projectile ──▶ Projectile 객체
```

Enemy 안에 다른 객체의 데이터가 통째로 복사되는 것이 아니다. 클래스 필드에는 관리되는 Heap의 협력 객체를 가리키는 참조가 저장된다.

### 호출 과정

```cs
enemy.Update(target);
```

실행 흐름은 여러 객체를 거친다.

```text
Enemy.Update()
├─ IMovement.Move()
│  └─ FlyingMovement.Move()
└─ IAttack.Attack()
   └─ RangedAttack.Attack()
      └─ Projectile.Fire()
```

인터페이스 필드를 통해 호출하면 CLR은 실제 구현 타입을 찾아 메서드를 실행한다.

Composition을 적용하면 객체와 간접 호출이 늘 수 있다. JIT가 일부 호출을 최적화할 수 있지만 모든 위임이 자동으로 사라지는 것은 아니다.

### 객체 수명과 소유권

한 객체가 다른 객체를 포함한다고 해서 반드시 그 객체의 생성과 제거까지 책임지는 것은 아니다.

```cs
IMovement movement = new FlyingMovement();
Enemy enemy = new Enemy(movement, attack);
```

외부에서 생성해 전달한 객체는 여러 Enemy가 공유할 수도 있다.

```cs
IMovement sharedMovement = new GroundMovement();

Enemy first = new Enemy(sharedMovement, firstAttack);
Enemy second = new Enemy(sharedMovement, secondAttack);
```

상태를 가진 객체를 공유하면 한 객체의 변경이 다른 사용처에도 보일 수 있다.

파일이나 네트워크 연결처럼 해제가 필요한 의존성을 포함한다면 누가 `Dispose()`를 호출할지 명확해야 한다.

```text
포함 관계
≠ 항상 소유 관계
```

Composition을 설계할 때 생성 주체, 공유 여부와 수명 종료 책임을 함께 결정해야 한다.

### 상속 객체와의 메모리 차이

상속에서는 기반 클래스 필드와 파생 클래스 필드가 하나의 객체 안에 함께 배치된다.

```text
상속
Player 객체
├─ Character 영역
└─ Player 영역
```

Composition에서는 별도 객체가 참조로 연결된다.

```text
Composition
Player 객체 ──▶ Movement 객체
              └▶ Attack 객체
```

Composition은 객체 수와 참조가 늘 수 있지만 각 기능의 수명과 구현을 독립적으로 교체할 수 있다.

---

## 실제 Unity에서는?

Unity의 GameObject와 Component 구조는 Composition을 중심으로 설계되어 있다.

```text
Player GameObject
├─ Transform
├─ Rigidbody
├─ PlayerMovement
├─ PlayerAttack
├─ PlayerHealth
└─ Animator
```

Player가 이동, 공격, 체력과 애니메이션 구현을 모두 상속받지 않는다. 여러 Component가 하나의 GameObject에 연결되어 기능을 구성한다.

```cs
[RequireComponent(typeof(Rigidbody))]
public class PlayerMovement : MonoBehaviour
{
    private Rigidbody body;

    private void Awake()
    {
        body = GetComponent<Rigidbody>();
    }

    public void Move(Vector3 direction)
    {
        body.MovePosition(
            body.position + direction * Time.fixedDeltaTime);
    }
}
```

PlayerMovement는 Rigidbody를 포함한 협력 관계로 사용한다.

공격 효과도 별도 Component로 조합할 수 있다.

```cs
public abstract class AttackEffect : MonoBehaviour
{
    public abstract void Play();
}
```

```cs
public class PlayerAttack : MonoBehaviour
{
    [SerializeField] private AttackEffect effect;

    public void Attack()
    {
        effect.Play();
    }
}
```

Prefab마다 다른 AttackEffect Component를 연결하면 PlayerAttack 코드를 변경하지 않고 효과를 교체할 수 있다.

### Component를 나누는 것만으로 충분할까?

Component가 지나치게 작게 나뉘면 하나의 동작을 이해하기 위해 많은 파일과 참조를 따라가야 한다.

매 프레임 여러 Component가 `GetComponent()`와 메시지 전달을 반복하면 호출과 탐색 비용도 늘 수 있다.

```cs
private void Update()
{
    GetComponent<PlayerHealth>().Regenerate();
}
```

자주 사용하는 참조는 초기화 시 캐시하고 함께 변경되는 데이터와 동작은 하나의 Component에 유지하는 편이 좋다.

```cs
private PlayerHealth health;

private void Awake()
{
    health = GetComponent<PlayerHealth>();
}
```

Unity의 Component 구조는 Composition을 쉽게 만들지만 책임 경계와 객체 수명을 자동으로 결정해 주지는 않는다.

---

## 실무에서 자주 하는 오해

### 상속은 사용하면 안 된다는 오해

Composition을 우선하라는 말은 상속을 금지한다는 뜻이 아니다.

타입의 is-a 관계가 분명하고 기반 계약을 안전하게 지킬 수 있으며 공통 상태와 생명 주기를 공유해야 한다면 상속이 자연스럽다.

기능 재사용과 조합만을 위해 깊은 상속 구조를 만드는 상황에서 Composition을 먼저 검토한다는 의미이다.

### Component가 많을수록 좋은 설계라는 오해

하나의 책임을 지나치게 작은 Component로 나누면 객체 간 통신과 초기화 순서가 복잡해진다.

함께 변경되고 항상 함께 사용되는 상태와 동작은 같은 Component에 두는 편이 응집도가 높다.

### Composition은 결합도가 없다는 오해

Enemy는 `IMovement`와 `IAttack` 계약에 의존한다. 구체 구현 결합은 줄었지만 역할 계약과 호출 순서에 대한 의존성은 남아 있다.

Composition의 목적은 의존성을 없애는 것이 아니라 교체 가능한 경계로 관리하는 데 있다.

### 위임 메서드는 불필요하다는 오해

```cs
public void Attack(Character target)
{
    weapon.Attack(target);
}
```

단순히 전달하는 것처럼 보여도 Player가 제공하는 API와 내부 Weapon 구현 사이에 경계를 만든다.

외부 코드가 Weapon을 직접 가져가 사용하게 하면 Player가 장비 교체, 공격 가능 상태와 자원 소비 규칙을 통제하기 어려워질 수 있다.

### 런타임 교체가 항상 필요하다는 오해

모든 기능을 인터페이스 필드로 만들고 Setter를 공개하면 객체의 유효한 구성이 쉽게 깨질 수 있다.

변하지 않는 협력 관계는 생성자에서 받아 `readonly`로 유지하고 실제로 교체가 필요한 기능에만 변경 API를 제공해야 한다.

---

## 마무리

Composition은 객체가 필요한 기능을 다른 객체로 포함하고 작업을 위임하여 동작을 구성하는 방식이다.

상속 계층에 기능 조합을 고정하지 않기 때문에 이동, 공격과 효과 구현을 독립적으로 추가하고 교체할 수 있다. 객체 생성과 연결을 외부로 분리하면 DI와도 자연스럽게 이어진다.

상속과 Composition은 경쟁하는 문법이 아니다. 타입의 정체성을 표현하는 is-a 관계에는 상속이, 역할과 기능을 결합하는 has-a 관계에는 Composition이 더 적합할 수 있다.

좋은 Composition은 객체를 최대한 잘게 나누는 구조가 아니다. 함께 변경되는 책임은 응집시키고 독립적으로 바뀌는 기능만 명확한 객체 경계로 분리하는 구조이다.

---

## 핵심 정리

- Composition은 객체가 다른 객체를 포함하고 작업을 위임하는 설계 방식이다.
- 상속은 is-a 관계를, Composition은 주로 has-a와 역할 사용 관계를 표현한다.
- 기능 객체를 조합하면 상속 조합마다 파생 클래스를 만들 필요가 없다.
- 협력 객체 참조를 교체하여 런타임에 행동을 변경할 수 있다.
- Composition은 별도 객체와 참조로 구성되므로 객체 수명과 소유권을 결정해야 한다.
- 상속 객체의 기반 필드는 하나의 객체에 포함되고 Composition 객체는 참조로 연결된다.
- Unity의 GameObject와 Component 구조는 Composition을 중심으로 동작한다.
- Component를 지나치게 작게 나누면 탐색, 초기화와 통신 비용이 커질 수 있다.
- 상속을 금지하는 것이 아니라 기능 재사용과 조합에서는 Composition을 먼저 검토해야 한다.
