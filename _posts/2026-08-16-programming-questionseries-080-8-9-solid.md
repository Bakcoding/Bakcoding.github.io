---
title: "[궁금시리즈] 8-9. SOLID 원칙은 왜 필요할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-9-solid/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:08 +0900
last_modified_at: 2026-08-16 12:00:08 +0900
---

## 들어가며

작은 Player 클래스는 이동과 공격만 처리해도 충분하다.

```cs
public class Player
{
    public void Move() { }
    public void Attack() { }
}
```

프로젝트가 커지면 기능이 계속 추가된다.

```cs
public class Player
{
    public void Move() { }
    public void Attack() { }
    public void UpdateUI() { }
    public void PlaySound() { }
    public void Save() { }
    public void SendPacket() { }
}
```

처음에는 한곳에 모여 있어 편리해 보인다. 하지만 UI를 변경해도 Player를 수정하고, 저장 형식을 변경해도 Player를 수정하며, 네트워크 구조를 변경해도 Player를 수정하게 된다.

새로운 Weapon을 추가하려고 Player의 조건문을 바꾸고, 테스트를 실행하려면 UI와 사운드 시스템까지 준비해야 할 수도 있다.

객체지향 문법만 사용한다고 변경에 강한 코드가 자동으로 만들어지는 것은 아니다.

SOLID는 객체의 책임과 의존 관계를 설계할 때 반복해서 발생하는 문제를 다루는 다섯 가지 원칙이다.

```text
S ─ Single Responsibility Principle
O ─ Open/Closed Principle
L ─ Liskov Substitution Principle
I ─ Interface Segregation Principle
D ─ Dependency Inversion Principle
```

다섯 원칙의 공통 목적은 클래스를 많이 만드는 데 있지 않다. 변경이 필요한 이유를 분리하고, 새로운 기능을 추가할 때 기존 코드가 받는 영향을 줄이는 데 있다.

---

## 개념 설명

### SRP: 단일 책임 원칙

Single Responsibility Principle은 클래스가 하나의 변경 이유를 가져야 한다는 원칙이다.

```cs
public class Player
{
    public void TakeDamage(int damage) { }
    public void UpdateHealthUI() { }
    public void SaveToDatabase() { }
}
```

이 클래스는 게임 규칙, UI와 데이터 저장이라는 서로 다른 이유로 변경된다.

역할을 분리하면 각 클래스의 변경 이유가 명확해진다.

```text
PlayerHealth
└─ 체력 규칙 변경

HealthView
└─ UI 표현 변경

PlayerRepository
└─ 저장 방식 변경
```

책임은 메서드 개수와 같지 않다. 여러 메서드가 하나의 일관된 변경 이유를 위해 존재할 수 있다.

### OCP: 개방-폐쇄 원칙

Open/Closed Principle은 소프트웨어 요소가 확장에는 열려 있고 수정에는 닫혀 있어야 한다는 원칙이다.

새로운 타입을 추가할 때 기존 조건문을 계속 수정하는 구조를 예로 들 수 있다.

```cs
public void Attack(WeaponType type)
{
    if (type == WeaponType.Sword)
    {
        // 검 공격
    }
    else if (type == WeaponType.Bow)
    {
        // 활 공격
    }
}
```

새로운 Staff가 추가되면 기존 메서드를 수정해야 한다.

다형성을 사용하면 새로운 구현을 추가하여 기능을 확장할 수 있다.

```cs
public interface IWeapon
{
    void Attack();
}
```

```cs
public class Staff : IWeapon
{
    public void Attack()
    {
        // 마법 공격
    }
}
```

기존 Player는 `IWeapon.Attack()`만 호출하므로 새로운 Weapon 구현을 몰라도 된다.

수정에 닫혀 있다는 말은 코드를 절대 수정하지 않는다는 뜻이 아니다. 변화가 예상되는 지점을 추상화하여 기능 추가가 안정된 기존 코드에 반복적으로 영향을 주지 않게 한다는 의미이다.

### LSP: 리스코프 치환 원칙

Liskov Substitution Principle은 기반 타입을 사용하는 위치에 파생 타입을 넣어도 프로그램의 올바른 동작이 유지되어야 한다는 원칙이다.

```cs
public class Character
{
    public virtual void Move()
    {
    }
}
```

```cs
public class Statue : Character
{
    public override void Move()
    {
        throw new NotSupportedException();
    }
}
```

Character를 전달받은 코드는 `Move()`를 정상적으로 호출할 수 있다고 기대한다. Statue로 교체했을 때 예외가 발생한다면 상속 관계의 계약이 깨진다.

문법적으로 상속할 수 있다는 사실과 의미상 안전하게 대체할 수 있다는 사실은 다르다.

### ISP: 인터페이스 분리 원칙

Interface Segregation Principle은 사용하는 코드가 필요하지 않은 멤버에 의존하도록 강요해서는 안 된다는 원칙이다.

```cs
public interface IEntity
{
    void Move();
    void Attack();
    void Talk();
    void Save();
}
```

Door는 저장될 수 있지만 이동하거나 대화하지 않는다. 큰 인터페이스를 구현하면 빈 메서드나 예외가 생긴다.

```cs
public void Talk()
{
    throw new NotSupportedException();
}
```

역할별로 작은 인터페이스를 만들면 필요한 계약만 구현할 수 있다.

```cs
public interface IMovable { void Move(); }
public interface IAttackable { void Attack(); }
public interface ISaveable { void Save(); }
```

### DIP: 의존 역전 원칙

Dependency Inversion Principle은 상위 수준 정책이 하위 수준 세부 구현에 직접 의존하지 않고 둘 다 추상화에 의존해야 한다는 원칙이다.

```cs
public class Quest
{
    private readonly MySqlQuestRepository repository = new();
}
```

Quest 규칙이 MySQL이라는 저장 세부 사항에 직접 연결되어 있다.

```cs
public interface IQuestRepository
{
    void Save(QuestData data);
}
```

```cs
public class Quest
{
    private readonly IQuestRepository repository;

    public Quest(IQuestRepository repository)
    {
        this.repository = repository;
    }
}
```

Quest는 필요한 저장 계약을 정의하고 실제 파일, 데이터베이스와 서버 저장 구현이 그 계약을 따른다.

의존성의 방향이 구체적인 세부 사항이 아니라 정책이 요구하는 추상화를 향하게 된다.

---

## 코드 예제

SOLID를 고려하지 않은 전투 코드는 여러 책임과 구체 의존성을 한 클래스에 모을 수 있다.

```cs
public class BattleManager
{
    public void Attack(Player player, Monster monster)
    {
        int damage = player.Damage - monster.Defense;
        monster.Health -= Math.Max(0, damage);

        Console.WriteLine($"Damage: {damage}");

        if (monster.Health <= 0)
        {
            File.WriteAllText("save.txt", "Monster Dead");
        }
    }
}
```

BattleManager는 다음 책임을 가진다.

- 피해 계산
- Monster 상태 변경
- 출력
- 사망 판단
- 파일 저장

피해 공식이나 출력 형식, 저장 위치가 바뀔 때마다 같은 클래스가 수정된다.

먼저 피해 계산을 분리할 수 있다.

```cs
public interface IDamageCalculator
{
    int Calculate(AttackData attack, DefenseData defense);
}
```

```cs
public class DamageCalculator : IDamageCalculator
{
    public int Calculate(
        AttackData attack,
        DefenseData defense)
    {
        return Math.Max(0, attack.Damage - defense.Defense);
    }
}
```

전투 결과 출력도 별도 역할로 표현한다.

```cs
public interface IBattleLogger
{
    void LogDamage(int damage);
}
```

저장 기능 역시 계약으로 분리한다.

```cs
public interface IBattleRepository
{
    void Save(BattleResult result);
}
```

BattleService는 전투 흐름만 조정한다.

```cs
public class BattleService
{
    private readonly IDamageCalculator calculator;
    private readonly IBattleLogger logger;
    private readonly IBattleRepository repository;

    public BattleService(
        IDamageCalculator calculator,
        IBattleLogger logger,
        IBattleRepository repository)
    {
        this.calculator = calculator;
        this.logger = logger;
        this.repository = repository;
    }

    public void Attack(Player player, Monster monster)
    {
        int damage = calculator.Calculate(
            player.AttackData,
            monster.DefenseData);

        monster.TakeDamage(damage);
        logger.LogDamage(damage);

        if (monster.IsDead)
        {
            repository.Save(new BattleResult(monster.Id));
        }
    }
}
```

각 역할은 서로 다른 이유로 변경된다.

```text
BattleService
└─ 전투 진행 순서

IDamageCalculator 구현
└─ 피해 공식

IBattleLogger 구현
└─ 출력 방식

IBattleRepository 구현
└─ 저장 방식
```

테스트에서는 파일 저장과 실제 출력 없이 단순한 구현을 전달할 수 있다.

```cs
BattleService service = new BattleService(
    new FixedDamageCalculator(10),
    new FakeBattleLogger(),
    new InMemoryBattleRepository());
```

이 예제에는 여러 SOLID 원칙이 함께 적용된다.

- 책임을 역할별로 나눈다.
- 새로운 계산과 저장 구현을 추가할 수 있다.
- 구현은 각 인터페이스의 계약을 지켜야 한다.
- 사용하는 기능에 맞는 작은 인터페이스를 제공한다.
- 전투 정책은 구체적인 파일 저장보다 추상 계약에 의존한다.

SOLID 원칙은 서로 분리된 체크리스트가 아니라 같은 설계에서 함께 작용한다.

---

## 내부 동작

SOLID는 C# 컴파일러나 CLR이 강제하는 언어 기능이 아니다.

```cs
public class GameManager
{
    // 수백 개의 책임을 넣어도 컴파일된다.
}
```

컴파일러는 클래스의 책임이 몇 개인지, 인터페이스가 지나치게 큰지, 파생 클래스가 의미상 계약을 위반하는지 판단하지 않는다.

SOLID는 코드 변경과 의존 관계를 관리하기 위한 설계 원칙이다.

### 런타임에는 일반 객체로 동작한다

인터페이스와 다형성을 사용한 SOLID 구조도 런타임에서는 앞에서 다룬 일반 C# 기능으로 실행된다.

```text
BattleService 객체
├─ IDamageCalculator 참조
├─ IBattleLogger 참조
└─ IBattleRepository 참조
```

각 필드에는 실제 구현 객체를 가리키는 참조가 저장된다. 인터페이스 메서드를 호출하면 런타임이 실제 객체의 구현을 찾아 실행한다.

SOLID를 적용한다고 별도의 실행 엔진이나 자동 최적화가 생기는 것은 아니다.

### 비용도 존재한다

책임과 인터페이스를 분리하면 클래스와 객체 수가 늘어날 수 있다.

```text
단순 구조
BattleManager 1개

분리된 구조
BattleService
DamageCalculator
BattleLogger
BattleRepository
여러 인터페이스
```

호출 단계가 늘고 코드를 여러 파일에서 확인해야 할 수도 있다. 작은 기능에 과도하게 적용하면 이해 비용이 실제 변경 비용보다 커질 수 있다.

SOLID의 효과는 실행 속도를 높이는 데 있지 않다. 변경이 발생했을 때 수정 위치를 제한하고 테스트와 교체가 가능한 경계를 만드는 데 있다.

원칙은 미래에 일어날 모든 변화를 예측하는 도구가 아니다. 실제로 함께 바뀌는 코드와 자주 변경되는 지점을 관찰하면서 적용해야 한다.

---

## 실제 Unity에서는?

Unity에서 하나의 `MonoBehaviour`에 모든 기능을 넣으면 Scene과 Component 의존성까지 함께 커질 수 있다.

```cs
public class PlayerController : MonoBehaviour
{
    private void Update()
    {
        // 입력
        // 이동
        // 공격
        // 애니메이션
        // 사운드
        // UI
        // 저장
    }
}
```

기능을 Component로 분리하면 변경 이유를 나눌 수 있다.

```text
Player GameObject
├─ PlayerInput
├─ PlayerMovement
├─ PlayerAttack
├─ PlayerAnimator
└─ PlayerHealth
```

하지만 Component를 나누는 것만으로 SOLID가 완성되지는 않는다.

PlayerAttack이 모든 Component를 직접 찾고 구체 타입을 제어하면 의존 관계가 다시 한곳에 모인다.

```cs
private void Awake()
{
    animator = GetComponent<PlayerAnimator>();
    audio = FindFirstObjectByType<AudioManager>();
    inventory = FindFirstObjectByType<PlayerInventory>();
}
```

필요한 역할을 명확히 하고 Scene 또는 조립 코드에서 연결할 수 있다.

```cs
public interface IAttackEffect
{
    void Play();
}
```

Unity에서는 Inspector, Prefab과 `GetComponent()`도 객체를 조립하는 도구가 된다.

```cs
[SerializeField] private AttackEffect attackEffect;
```

ScriptableObject를 전략 데이터와 구현의 확장 지점으로 활용할 수도 있다.

```cs
public abstract class DamageFormula : ScriptableObject
{
    public abstract int Calculate(
        int attack,
        int defense);
}
```

새로운 계산 Asset을 추가하면 PlayerAttack의 코드를 바꾸지 않고 피해 공식을 교체할 수 있다.

Unity에서 중요한 것은 원칙을 위해 Component를 최대한 많이 만드는 것이 아니다. 함께 변경되는 기능은 가까이 두고 독립적으로 교체되는 기능만 명확한 경계로 나누어야 한다.

---

## 실무에서 자주 하는 오해

### 클래스는 메서드 하나만 가져야 한다는 오해

단일 책임 원칙의 책임은 메서드 수가 아니다.

Inventory의 추가, 제거, 검색 메서드는 모두 아이템 보관 규칙이라는 하나의 책임에 속할 수 있다. 서로 다른 변경 이유가 한 타입에 섞였는지가 중요하다.

### 수정이 발생하면 OCP를 위반한다는 오해

요구 사항이 바뀌면 코드는 수정된다.

OCP는 모든 수정을 금지하는 원칙이 아니라 반복적으로 추가되는 변형 때문에 안정된 기존 로직을 계속 수정하지 않도록 확장 지점을 설계하는 원칙이다.

### 인터페이스를 많이 만들면 SOLID라는 오해

구현이 하나이고 교체할 이유도 없는 코드에 인터페이스를 추가하면 파일과 탐색 비용만 늘어날 수 있다.

인터페이스는 실제 경계와 역할을 표현해야 한다. 클래스마다 같은 이름의 인터페이스를 기계적으로 만드는 것이 목적은 아니다.

### SOLID를 모두 적용해야 좋은 코드라는 오해

원칙은 서로 다른 설계 문제를 판단하는 기준이다. 작은 데이터 객체나 단순 계산에 모든 원칙을 적용하려 하면 구조가 실제 문제보다 복잡해질 수 있다.

현재 변경 가능성과 테스트 요구, 팀이 이해할 수 있는 비용을 기준으로 필요한 만큼 적용해야 한다.

### SOLID는 성능을 높이는 원칙이라는 오해

SOLID는 유지보수성과 변경 대응을 위한 원칙이다.

객체와 호출 계층이 늘면 오히려 작은 실행 비용이 추가될 수 있다. 성능이 중요한 Unity 반복 경로에서는 설계 유연성과 데이터 접근 비용을 함께 측정해야 한다.

---

## 마무리

SOLID는 객체지향 문법을 사용하면서 발생하는 책임 집중, 조건문 확장, 잘못된 상속과 구체 구현 결합 문제를 다루는 다섯 가지 설계 원칙이다.

각 원칙은 서로 다른 이름을 가지지만 변경의 영향을 줄이고 안정적인 계약을 중심으로 객체가 협력하게 만든다는 공통 목적을 가진다.

원칙을 적용하면 클래스와 인터페이스 수가 늘고 구조를 따라가는 비용도 생긴다. 모든 코드에 같은 수준의 추상화를 적용하는 것이 아니라 실제 변경 이유와 확장 가능성이 있는 경계에 사용해야 한다.

좋은 SOLID 설계는 원칙의 개수를 세는 코드가 아니라 기능이 바뀌었을 때 수정할 위치가 분명하고 새로운 구현이 기존 코드에 불필요한 영향을 주지 않는 코드이다.

---

## 핵심 정리

- SOLID는 객체의 책임과 의존 관계를 관리하는 다섯 가지 설계 원칙이다.
- SRP는 클래스가 하나의 변경 이유를 가지도록 책임을 나눈다.
- OCP는 안정된 코드를 반복 수정하지 않고 새로운 구현으로 확장할 수 있게 한다.
- LSP는 파생 타입이 기반 타입의 계약을 깨지 않고 대체될 수 있어야 한다.
- ISP는 사용하는 코드가 필요하지 않은 멤버에 의존하지 않도록 계약을 나눈다.
- DIP는 상위 정책과 하위 세부 구현이 안정적인 추상화에 의존하게 한다.
- SOLID는 컴파일러나 CLR이 자동으로 강제하는 기능이 아니다.
- 원칙 적용에는 클래스와 호출 계층이 늘어나는 비용도 존재한다.
- 실제 변경 가능성과 복잡성을 기준으로 필요한 경계에 적용해야 한다.
