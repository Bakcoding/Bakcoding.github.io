---
title: "[궁금시리즈] 8-12. 의존성 주입(DI)은 무엇일까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-12-dependency-injection/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:11 +0900
last_modified_at: 2026-08-16 12:00:11 +0900
---

## 들어가며

BattleService가 전투 기록을 직접 생성할 수 있다.

```cs
public class BattleService
{
    private readonly FileBattleLogger logger =
        new FileBattleLogger("battle.log");

    public void Attack()
    {
        logger.Write("Attack");
    }
}
```

BattleService는 기록 기능을 사용하는 동시에 어떤 Logger를 만들지, 파일 이름은 무엇인지, 객체를 언제 생성할지까지 결정한다.

Console 출력이나 서버 전송으로 바꾸려면 BattleService를 수정해야 한다. 테스트에서도 실제 파일이 생성될 수 있다.

의존성 주입(Dependency Injection)은 객체가 필요한 의존 대상을 내부에서 직접 생성하지 않고 외부에서 전달받는 방식이다.

```cs
public class BattleService
{
    private readonly IBattleLogger logger;

    public BattleService(IBattleLogger logger)
    {
        this.logger = logger;
    }
}
```

BattleService는 기록 기능을 사용하지만 실제 구현 선택과 생성은 외부에 맡긴다.

```cs
IBattleLogger logger = new FileBattleLogger("battle.log");
BattleService service = new BattleService(logger);
```

DI의 핵심은 Framework나 Container가 아니다. 객체가 사용할 협력 대상을 외부에서 받아 생성 책임과 사용 책임을 분리하는 데 있다.

---

## 개념 설명

의존성은 객체가 기능을 수행하기 위해 필요한 다른 객체나 타입이다.

```cs
public class QuestService
{
    private readonly IQuestRepository repository;
}
```

QuestService는 Quest를 저장하기 위해 `IQuestRepository` 구현 객체가 필요하다.

직접 생성 방식에서는 QuestService가 의존 대상을 결정한다.

```cs
private readonly IQuestRepository repository =
    new JsonQuestRepository();
```

주입 방식에서는 외부 조립 코드가 대상을 결정하고 전달한다.

```cs
public QuestService(IQuestRepository repository)
{
    this.repository = repository;
}
```

```text
직접 생성
QuestService
├─ 구현 선택
├─ 객체 생성
└─ 객체 사용

의존성 주입
조립 코드
├─ 구현 선택
└─ 객체 생성
       ↓ 전달
QuestService
└─ 객체 사용
```

### 생성자 주입

생성자 매개변수로 의존 객체를 전달한다.

```cs
public class QuestService
{
    private readonly IQuestRepository repository;
    private readonly IQuestNotifier notifier;

    public QuestService(
        IQuestRepository repository,
        IQuestNotifier notifier)
    {
        this.repository = repository
            ?? throw new ArgumentNullException(nameof(repository));

        this.notifier = notifier
            ?? throw new ArgumentNullException(nameof(notifier));
    }
}
```

객체가 생성되는 순간 모든 필수 의존성이 준비된다.

필드를 `readonly`로 유지할 수 있고 불완전한 객체가 만들어지는 것을 막을 수 있어 필수 의존성에 가장 일반적으로 사용한다.

### 메서드 주입

특정 메서드를 실행할 때만 필요한 의존성을 매개변수로 전달한다.

```cs
public void Export(IQuestExporter exporter)
{
    exporter.Export(quests);
}
```

QuestService의 전체 수명 동안 필요하지 않고 특정 작업에서만 필요한 협력 대상에 적합하다.

호출할 때마다 다른 구현을 전달할 수도 있다.

```cs
service.Export(new JsonQuestExporter());
service.Export(new CsvQuestExporter());
```

### 프로퍼티 주입

객체를 생성한 뒤 프로퍼티나 Setter를 통해 의존성을 전달한다.

```cs
public IQuestNotifier? Notifier { get; set; }
```

선택적인 기능이나 생성 이후에만 연결할 수 있는 환경에서 사용할 수 있다.

하지만 주입되기 전에 메서드가 호출되면 `null` 상태를 처리해야 한다.

```cs
Notifier?.Notify(quest);
```

필수 의존성을 프로퍼티로 받으면 객체가 완성되었는지 생성 시점에 보장하기 어렵다.

```text
생성자 주입
└─ 객체 생성 시 필요한 의존성 보장

메서드 주입
└─ 특정 작업에서만 필요한 의존성 전달

프로퍼티 주입
└─ 선택적이거나 나중에 연결되는 의존성
```

### Composition Root

객체 생성과 연결을 한곳에 모으는 위치를 Composition Root라고 한다.

```cs
IQuestRepository repository =
    new JsonQuestRepository("quest.json");

IQuestNotifier notifier =
    new ConsoleQuestNotifier();

QuestService service =
    new QuestService(repository, notifier);
```

구체 구현에 대한 지식이 사라지는 것은 아니다. 프로그램의 진입점이나 조립 전용 코드에 모인다.

도메인 객체는 자신이 사용할 역할만 알고 Composition Root가 환경에 맞는 구현을 선택한다.

---

## 코드 예제

Player가 공격 효과와 피해 계산기를 직접 생성하는 구조를 생각할 수 있다.

```cs
public class PlayerAttack
{
    private readonly CriticalDamageCalculator calculator = new();
    private readonly ConsoleAttackEffect effect = new();

    public void Attack(Character target)
    {
        int damage = calculator.Calculate(20);
        target.TakeDamage(damage);
        effect.Play();
    }
}
```

PlayerAttack은 공격 순서뿐 아니라 치명타 공식과 출력 방식의 구체 클래스에 연결된다.

필요한 역할을 인터페이스로 정의한다.

```cs
public interface IDamageCalculator
{
    int Calculate(int baseDamage);
}

public interface IAttackEffect
{
    void Play();
}
```

PlayerAttack은 생성자로 두 역할을 전달받는다.

```cs
public class PlayerAttack
{
    private readonly IDamageCalculator calculator;
    private readonly IAttackEffect effect;

    public PlayerAttack(
        IDamageCalculator calculator,
        IAttackEffect effect)
    {
        this.calculator = calculator
            ?? throw new ArgumentNullException(nameof(calculator));

        this.effect = effect
            ?? throw new ArgumentNullException(nameof(effect));
    }

    public void Attack(Character target, int baseDamage)
    {
        int damage = calculator.Calculate(baseDamage);
        target.TakeDamage(damage);
        effect.Play();
    }
}
```

실제 게임에서는 치명타 계산과 사운드 효과를 연결할 수 있다.

```cs
IDamageCalculator calculator =
    new CriticalDamageCalculator(criticalChance: 0.2f);

IAttackEffect effect =
    new AudioAttackEffect(audioPlayer);

PlayerAttack attack =
    new PlayerAttack(calculator, effect);
```

테스트에서는 결과가 고정된 구현과 아무 동작도 하지 않는 구현을 전달한다.

```cs
public class FixedDamageCalculator : IDamageCalculator
{
    private readonly int damage;

    public FixedDamageCalculator(int damage)
    {
        this.damage = damage;
    }

    public int Calculate(int baseDamage) => damage;
}

public class NullAttackEffect : IAttackEffect
{
    public void Play()
    {
    }
}
```

```cs
PlayerAttack attack = new PlayerAttack(
    new FixedDamageCalculator(10),
    new NullAttackEffect());

attack.Attack(target, 20);
```

Random, Audio 장치와 Unity Scene 없이 공격 규칙을 검증할 수 있다.

### Factory를 주입하는 경우

객체가 실행 중에 새로운 Enemy를 만들어야 할 수 있다.

Enemy 객체 자체를 하나 전달하는 것으로는 부족하다. 생성 역할을 주입할 수 있다.

```cs
public interface IEnemyFactory
{
    Enemy Create(EnemyType type);
}
```

```cs
public class EnemySpawner
{
    private readonly IEnemyFactory factory;

    public EnemySpawner(IEnemyFactory factory)
    {
        this.factory = factory;
    }

    public Enemy Spawn(EnemyType type)
    {
        return factory.Create(type);
    }
}
```

EnemySpawner는 구체 Prefab, Object Pool과 생성 API를 몰라도 된다. 생성이 필요한 객체에서는 Factory 자체가 의존성이 된다.

---

## 내부 동작

DI는 CLR이 특별한 주입 명령을 실행하는 기능이 아니다.

직접 주입은 일반적인 생성자 호출과 참조 대입으로 동작한다.

```cs
PlayerAttack attack =
    new PlayerAttack(calculator, effect);
```

```text
IDamageCalculator 객체 생성
IAttackEffect 객체 생성
↓
PlayerAttack 생성자 호출
↓
매개변수 참조를 readonly 필드에 저장
```

PlayerAttack 객체 안에는 인터페이스가 저장되는 것이 아니라 실제 구현 객체를 가리키는 참조가 저장된다.

```text
PlayerAttack 객체
├─ calculator ──▶ CriticalDamageCalculator 객체
└─ effect ──────▶ AudioAttackEffect 객체
```

메서드를 호출하면 CLR의 인터페이스 디스패치를 통해 실제 구현이 실행된다.

### DI Container의 객체 생성

Container를 사용하면 타입 등록 정보를 바탕으로 객체 그래프를 자동으로 구성할 수 있다.

```text
IDamageCalculator → CriticalDamageCalculator
IAttackEffect      → AudioAttackEffect
```

PlayerAttack이 요청되면 Container는 생성자를 확인하고 필요한 타입을 재귀적으로 생성한다.

```text
PlayerAttack 요청
↓
생성자 매개변수 확인
├─ IDamageCalculator 해결
└─ IAttackEffect 해결
↓
PlayerAttack 생성
```

Container 구현에 따라 Reflection을 사용하거나 컴파일 시점에 Factory 코드를 생성할 수 있다.

### 객체 수명

Container는 객체를 언제 만들고 재사용할지도 관리할 수 있다.

```text
Transient
└─ 요청할 때마다 새 객체 생성

Scoped
└─ 특정 Scope 안에서 같은 객체 재사용

Singleton
└─ Container 전체에서 하나의 객체 재사용
```

긴 수명의 객체가 짧은 수명의 객체를 계속 보관하면 의도한 Scope가 끝난 뒤에도 참조가 남을 수 있다.

파일이나 네트워크 연결처럼 `IDisposable` 자원을 가진 의존성은 누가 해제할지도 수명 정책에 포함된다.

### 순환 의존성

두 객체가 생성자에서 서로를 요구하면 객체 그래프를 만들 수 없다.

```text
QuestService
└─ PlayerService 필요
       └─ QuestService 필요
```

```cs
public QuestService(PlayerService player) { }
public PlayerService(QuestService quest) { }
```

어느 객체도 먼저 완성할 수 없기 때문에 Container도 일반적으로 해결하지 못한다.

순환 의존성은 두 객체의 책임이 강하게 얽혀 있거나 중간 역할이 빠져 있다는 신호일 수 있다. Event, 작은 인터페이스 또는 별도 조정 객체로 관계를 다시 나누어야 한다.

---

## 실제 Unity에서는?

Unity에서는 일반 C# 생성자를 사용하기 어려운 `MonoBehaviour`가 많다.

```cs
PlayerController controller = new PlayerController(); // 사용할 수 없음
```

Unity가 Scene, Prefab과 `AddComponent()`를 통해 Component를 생성하기 때문이다.

### Inspector 주입

Inspector 참조는 Unity에서 가장 기본적인 주입 방식이다.

```cs
public class PlayerAttackBehaviour : MonoBehaviour
{
    [SerializeField] private AudioSource audioSource;
    [SerializeField] private Animator animator;
}
```

Component가 의존 객체를 생성하지 않고 Scene이나 Prefab 구성에서 외부 참조를 연결한다.

필수 참조가 누락될 수 있으므로 검증이 필요하다.

```cs
private void Awake()
{
    if (audioSource == null)
    {
        throw new InvalidOperationException(
            "AudioSource가 연결되지 않았다.");
    }
}
```

### 초기화 메서드 주입

런타임에 생성한 Component에는 초기화 메서드로 의존성을 전달할 수 있다.

```cs
public class EnemyBehaviour : MonoBehaviour
{
    private ITargetProvider targetProvider;

    public void Initialize(ITargetProvider targetProvider)
    {
        this.targetProvider = targetProvider;
    }
}
```

```cs
EnemyBehaviour enemy = Instantiate(enemyPrefab);
enemy.Initialize(targetProvider);
```

`Awake()`는 `Instantiate()` 과정에서 `Initialize()`보다 먼저 호출될 수 있다. 주입 전 의존성을 `Awake()`에서 사용하면 오류가 발생한다.

초기화 순서를 고려해 의존성이 필요한 로직을 `Start()` 이후에 실행하거나 Factory가 생성과 초기화를 함께 보장하도록 만들 수 있다.

### 순수 C# 객체 조립

`MonoBehaviour`는 Unity 연결과 입력만 담당하고 게임 규칙은 생성자 주입이 가능한 일반 C# 객체로 분리할 수 있다.

```cs
public class PlayerAttackBehaviour : MonoBehaviour
{
    [SerializeField] private AudioAttackEffectBehaviour effect;

    private PlayerAttack attack;

    private void Awake()
    {
        attack = new PlayerAttack(
            new CriticalDamageCalculator(0.2f),
            effect);
    }
}
```

Scene의 `MonoBehaviour`가 Composition Root 역할을 하고 순수 C# 객체의 의존성을 조립한다.

Unity용 DI Container를 사용할 수도 있지만 작은 프로젝트에서는 Scene과 Factory, 명시적인 생성 코드만으로 충분할 수 있다.

---

## 실무에서 자주 하는 오해

### DI는 Container를 사용해야 한다는 오해

```cs
new BattleService(new FileBattleLogger());
```

직접 생성해서 생성자로 전달하는 코드도 DI이다.

Container는 큰 객체 그래프의 반복적인 조립을 자동화하는 도구이며 DI의 필수 조건은 아니다.

### 인터페이스를 전달해야만 DI라는 오해

구체 클래스도 외부에서 전달하면 의존성 주입이다.

```cs
public BattleService(FileBattleLogger logger)
{
}
```

다만 구현 교체와 의존 방향 분리가 목적이라면 인터페이스나 추상 타입을 함께 사용하는 경우가 많다.

### 모든 객체를 주입해야 한다는 오해

객체 내부에서만 사용하는 단순한 값과 구현 세부 객체까지 모두 외부에서 전달하면 생성 코드가 불필요하게 커질 수 있다.

교체 가능성, 생명 주기, 외부 자원과 테스트 경계를 기준으로 주입할 의존성을 결정해야 한다.

### Service Locator도 DI라는 오해

```cs
public void Attack()
{
    IBattleLogger logger =
        Services.Get<IBattleLogger>();
}
```

BattleService가 외부 객체를 사용하지만 필요한 의존성이 생성자나 API에 드러나지 않는다. 객체가 실행 중에 전역 Locator에서 직접 찾기 때문에 의존성 해결의 제어를 다시 내부에서 수행한다.

Service Locator는 호출 위치에서 요구 사항을 숨기며 테스트와 실행 순서를 추적하기 어렵게 만들 수 있다.

### 생성자 매개변수가 많으면 DI의 문제라는 오해

생성자 매개변수가 지나치게 많다는 것은 클래스가 너무 많은 책임을 가진다는 신호일 수 있다.

Container로 매개변수를 숨기기보다 객체의 책임과 협력 경계를 먼저 검토해야 한다.

---

## 마무리

의존성 주입은 객체가 필요한 협력 대상을 직접 생성하지 않고 외부에서 전달받는 구성 방식이다.

객체는 의존 대상을 사용하는 책임에 집중하고 Composition Root가 실제 구현 선택, 생성과 수명 관리를 담당한다.

생성자 주입은 필수 의존성을 객체 생성 시점에 보장하고, 메서드 주입은 특정 작업에만 필요한 대상을 전달하며, 프로퍼티 주입은 선택적이거나 나중에 연결되는 관계에 사용할 수 있다.

DI Container는 객체 그래프 조립을 자동화하지만 DI 자체와 같은 의미는 아니다. 프로젝트 규모와 객체 수명 복잡도에 따라 직접 조립, Factory, Unity Inspector 또는 Container를 선택해야 한다.

---

## 핵심 정리

- DI는 객체가 필요한 의존 대상을 외부에서 전달받는 방식이다.
- 생성자 주입은 필수 의존성을 객체 생성 시점에 보장한다.
- 메서드 주입은 특정 작업에서만 필요한 의존성에 적합하다.
- 프로퍼티 주입은 선택적 의존성에 사용할 수 있지만 불완전한 상태를 만들 수 있다.
- Composition Root는 구체 객체의 생성과 연결을 한곳에 모은다.
- DI Container는 타입 등록, 객체 그래프 생성과 수명 관리를 자동화할 수 있다.
- 순환 의존성은 객체의 책임과 관계를 다시 나눠야 한다는 신호일 수 있다.
- Unity에서는 Inspector, 초기화 메서드, Factory와 순수 C# 객체 조립으로 DI를 적용할 수 있다.
- DI는 Container나 인터페이스 사용 여부가 아니라 생성 책임과 사용 책임의 분리에 핵심이 있다.
