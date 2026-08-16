---
title: "[궁금시리즈] 8-8. 의존성이란 무엇일까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-8-dependency/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:07 +0900
last_modified_at: 2026-08-16 12:00:07 +0900
---

## 들어가며

Player가 공격할 때 효과음을 재생한다고 가정한다.

```cs
public class Player
{
    private AudioManager audioManager = new AudioManager();

    public void Attack()
    {
        audioManager.Play("Attack");
    }
}
```

Player는 `AudioManager`를 사용한다.

AudioManager의 메서드 이름이 바뀌거나 생성 방법이 달라지면 Player도 수정해야 한다. 테스트에서 소리를 재생하지 않으려 해도 Player가 실제 AudioManager를 직접 생성한다.

```text
Player 변경 이유
├─ 공격 규칙 변경
└─ AudioManager 변경
```

Player가 자신의 핵심 책임과 관계없는 변경에도 영향을 받기 시작한다.

한 코드가 다른 타입이나 객체의 존재와 동작을 필요로 하는 관계를 의존성(Dependency)이라고 한다.

의존성 자체가 잘못된 것은 아니다. 객체는 혼자 모든 기능을 수행할 수 없으므로 다른 객체와 협력해야 한다.

중요한 것은 어떤 대상에 어떤 방식으로 의존하며, 그 대상의 변경이 현재 코드에 얼마나 크게 전파되는가이다.

---

## 개념 설명

다음 코드에서 `Player`는 `Weapon`에 의존한다.

```cs
public class Player
{
    private Weapon weapon;

    public void Attack(Monster target)
    {
        weapon.Attack(target);
    }
}
```

Player가 정상적으로 공격하려면 Weapon 객체와 `Attack()` 메서드가 필요하기 때문이다.

코드에서 의존성이 나타나는 형태는 다양하다.

### 필드 의존성

다른 타입을 필드로 보관한다.

```cs
private Weapon weapon;
```

Player 객체가 살아 있는 동안 같은 Weapon을 계속 사용할 수 있다.

### 매개변수 의존성

메서드를 실행하는 동안 다른 타입이 필요하다.

```cs
public void Attack(Monster target)
{
}
```

Player는 `Attack()`을 실행하기 위해 Monster에 의존한다.

### 반환형 의존성

메서드가 다른 타입을 결과로 제공한다.

```cs
public Item FindItem(int id)
{
    return inventory.Find(id);
}
```

이 메서드를 사용하는 코드도 반환형인 Item을 알아야 한다.

### 지역 변수와 정적 호출 의존성

메서드 내부에서 객체를 직접 생성하거나 정적 기능을 호출해도 의존성이 생긴다.

```cs
public void Save()
{
    JsonSaveService service = new JsonSaveService();
    service.Save(this);
}
```

```cs
public void LogDamage(int damage)
{
    GameLogger.Write(damage);
}
```

필드에 보이지 않는다고 의존성이 없는 것은 아니다. 코드를 컴파일하고 실행하기 위해 다른 타입을 알아야 한다면 의존 관계가 존재한다.

### 직접 의존성과 간접 의존성

Player가 Inventory를 사용하고 Inventory가 Database를 사용한다면 Player는 Database를 직접 호출하지 않는다.

```text
Player
  ↓ 직접 의존
Inventory
  ↓ 직접 의존
Database

Player ── Database에 간접 의존
```

Database의 변경이 Inventory의 공개 동작까지 바꾸면 그 영향이 Player로 전파될 수 있다.

의존 관계가 여러 단계를 거칠수록 전체 구조를 파악하기 어려워질 수 있다.

### 결합도

결합도(Coupling)는 코드가 다른 코드의 구체적인 내용에 얼마나 강하게 연결되어 있는지를 나타낸다.

```cs
public class Quest
{
    private readonly MonsterRepository repository =
        new MySqlMonsterRepository(
            "Server=localhost;Database=Game");
}
```

Quest가 데이터베이스 제품, 연결 문자열과 객체 생성 방법까지 알고 있다.

저장 방식이 파일이나 서버 API로 바뀌면 Quest도 수정해야 한다. 이런 관계는 구체적인 구현 세부 사항에 강하게 결합되어 있다.

결합도가 낮다는 것은 객체가 아무것에도 의존하지 않는다는 뜻이 아니다. 자신에게 필요한 역할만 알고 상대의 생성 방법과 내부 구현은 모르는 상태에 가깝다.

---

## 코드 예제

Monster가 사망할 때 보상을 지급하는 코드를 직접 의존 방식으로 작성할 수 있다.

```cs
public class Monster
{
    private readonly Inventory inventory = new Inventory();

    public void Die()
    {
        Item reward = new Item("Gold", 10);
        inventory.Add(reward);
    }
}
```

이 구조에는 여러 결정이 Monster 안에 들어 있다.

- 보상은 Inventory에 들어간다.
- 보상 타입은 Item이다.
- 보상 이름은 Gold이다.
- 수량은 10이다.
- Inventory는 Monster가 직접 생성한다.

Monster의 책임은 생명 상태와 사망 처리이지만 보상 생성과 보관 방법까지 알고 있다.

보상 지급 역할을 인터페이스로 표현할 수 있다.

```cs
public interface IRewardService
{
    void Grant();
}
```

Monster는 구체적인 Inventory가 아니라 필요한 역할에 의존한다.

```cs
public class Monster
{
    private readonly IRewardService rewardService;

    public Monster(IRewardService rewardService)
    {
        this.rewardService = rewardService;
    }

    public void Die()
    {
        rewardService.Grant();
    }
}
```

실제 보상 방식은 외부에서 연결한다.

```cs
public class ItemRewardService : IRewardService
{
    private readonly Inventory inventory;

    public ItemRewardService(Inventory inventory)
    {
        this.inventory = inventory;
    }

    public void Grant()
    {
        inventory.Add(new Item("Gold", 10));
    }
}
```

```cs
Inventory inventory = new Inventory();
IRewardService reward = new ItemRewardService(inventory);
Monster monster = new Monster(reward);
```

Monster는 여전히 보상 서비스에 의존한다. 의존성이 사라진 것이 아니다.

```text
변경 전
Monster → Inventory → Item

변경 후
Monster → IRewardService ← ItemRewardService
```

차이는 Monster가 구체적인 보상 구현보다 작은 역할 계약만 안다는 점이다.

테스트에서는 기록만 남기는 구현을 전달할 수 있다.

```cs
public class FakeRewardService : IRewardService
{
    public bool Granted { get; private set; }

    public void Grant()
    {
        Granted = true;
    }
}
```

```cs
FakeRewardService reward = new FakeRewardService();
Monster monster = new Monster(reward);

monster.Die();

Console.WriteLine(reward.Granted); // True
```

실제 Inventory, Item과 데이터 저장 환경 없이 Monster의 사망 동작만 검증할 수 있다.

### 의존성과 객체 생성의 분리

객체가 자신의 의존 대상을 직접 만들면 어떤 구현을 사용할지 스스로 결정한다.

```cs
private readonly IRewardService reward =
    new ItemRewardService(new Inventory());
```

필드 타입을 인터페이스로 바꿨어도 내부에서 구체 객체를 직접 생성하면 Monster는 여전히 구현과 생성 방법을 알고 있다.

객체 생성과 사용을 분리하면 조립하는 코드가 구현을 선택할 수 있다.

```cs
IRewardService reward =
    new ItemRewardService(inventory);

Monster monster = new Monster(reward);
```

Monster는 전달받은 역할을 사용하고 외부의 조립 코드는 실제 구현을 결정한다.

---

## 내부 동작

의존성은 CLR에 하나의 전용 객체로 저장되는 기능이 아니다. 타입 참조, 메서드 호출과 객체 참조를 통해 코드와 런타임에 나타나는 관계이다.

### 컴파일 시점 의존성

다음 코드를 컴파일하려면 컴파일러가 `IRewardService`의 정의를 찾을 수 있어야 한다.

```cs
private readonly IRewardService rewardService;
```

컴파일된 Assembly의 메타데이터에는 필드 타입과 호출하는 멤버에 대한 참조 정보가 기록된다.

```text
Monster Assembly
├─ IRewardService 타입 참조
└─ IRewardService.Grant 멤버 참조
```

인터페이스가 다른 Assembly에 있다면 해당 Assembly에 대한 참조도 필요하다.

인터페이스 이름이나 메서드 시그니처가 바뀌면 Monster는 다시 컴파일되어야 한다. 추상화에 의존하더라도 컴파일 시점 의존성까지 완전히 사라지는 것은 아니다.

### 런타임 의존성

실행 시점에는 실제 구현 객체가 필요하다.

```cs
IRewardService rewardService =
    new ItemRewardService(inventory);
```

Monster 필드에는 인터페이스 자체가 저장되는 것이 아니라 `ItemRewardService` 객체를 가리키는 참조가 저장된다.

```text
Monster 객체
└─ rewardService 참조
       ↓
ItemRewardService 객체
└─ inventory 참조
       ↓
Inventory 객체
```

`rewardService.Grant()`를 호출하면 런타임은 실제 객체 타입의 인터페이스 구현을 찾아 실행한다.

의존 대상을 전달하지 않아 필드가 `null`이면 호출 시 `NullReferenceException`이 발생할 수 있다.

```cs
public Monster(IRewardService rewardService)
{
    this.rewardService = rewardService
        ?? throw new ArgumentNullException(nameof(rewardService));
}
```

생성 시점에 필수 의존성을 검사하면 불완전한 객체가 만들어지는 것을 막을 수 있다.

### 객체 수명 의존성

객체는 의존 대상의 존재 기간에도 영향을 받는다.

Monster가 살아 있는 동안 RewardService가 필요하다면 RewardService가 먼저 사라지거나 사용할 수 없는 상태가 되어서는 안 된다.

```text
Inventory 생성
↓
ItemRewardService 생성
↓
Monster 생성 및 사용
↓
Monster 사용 종료
↓
의존 객체 정리
```

파일, 네트워크 연결과 같은 자원을 가진 객체라면 누가 생성하고 누가 해제할지도 의존성 설계의 일부가 된다.

---

## 실제 Unity에서는?

Unity에서는 Inspector 참조, `GetComponent()`와 Singleton 접근에서 의존성이 자주 나타난다.

### Inspector로 연결하는 의존성

```cs
public class PlayerAttack : MonoBehaviour
{
    [SerializeField] private AudioSource audioSource;
    [SerializeField] private Animator animator;

    public void Attack()
    {
        animator.SetTrigger("Attack");
        audioSource.Play();
    }
}
```

PlayerAttack은 AudioSource와 Animator에 의존한다. 직접 생성하지 않고 Scene이나 Prefab의 Inspector에서 외부 객체가 연결된다.

의존성이 사라진 것은 아니지만 어떤 객체를 사용할지 Editor에서 교체할 수 있다.

필수 참조가 비어 있으면 런타임 오류가 발생하므로 Editor 단계에서 검증할 수 있다.

```cs
private void OnValidate()
{
    if (audioSource == null)
    {
        Debug.LogWarning("AudioSource가 필요하다.", this);
    }
}
```

### GetComponent로 찾는 의존성

```cs
private void Awake()
{
    animator = GetComponent<Animator>();
}
```

코드에서 `new`를 사용하지 않았지만 PlayerAttack이 Animator 타입과 같은 GameObject에 존재한다는 구조를 알고 있다.

`[RequireComponent]`로 Component 요구 사항을 표현할 수 있다.

```cs
[RequireComponent(typeof(Animator))]
public class PlayerAttack : MonoBehaviour
{
}
```

이는 필수 Component 누락을 줄여 주지만 구체 Animator Component에 대한 의존 자체를 제거하지는 않는다.

### 전역 접근 의존성

```cs
GameManager.Instance.AddScore(100);
AudioManager.Instance.Play("Win");
```

호출은 간단하지만 어떤 클래스가 전역 Manager에 의존하는지 생성자나 필드만 보고 파악하기 어렵다.

테스트와 Scene 전환에서 Singleton의 상태가 유지되면 서로 다른 테스트와 객체 생명 주기가 연결될 수도 있다.

전역 접근을 모두 금지할 필요는 없지만 사용 위치와 수명, 초기화 순서를 명확하게 관리해야 한다.

Unity에서 의존성은 Scene, Prefab과 Component 구성에도 존재한다. 코드만 확인할 것이 아니라 Inspector 참조와 Asset 연결까지 함께 봐야 전체 관계를 이해할 수 있다.

---

## 실무에서 자주 하는 오해

### 의존성이 있으면 설계가 나쁘다는 오해

객체의 협력에는 의존성이 필요하다. 문제는 의존성의 존재가 아니라 불필요하게 많은 대상과 구체적인 구현 세부 사항에 연결되는 것이다.

필요한 역할에 명확하게 의존하는 구조가 의존성을 숨긴 구조보다 관리하기 쉽다.

### 인터페이스를 사용하면 의존성이 사라진다는 오해

```cs
private readonly IRewardService rewardService;
```

Monster는 여전히 `IRewardService`에 의존한다. 구체 클래스 의존성을 더 안정적인 역할 계약에 대한 의존성으로 바꾼 것이다.

### new를 사용하면 안 된다는 오해

모든 객체 생성을 외부로 옮길 필요는 없다.

객체 내부에서만 사용하는 단순한 값 객체나 구현 세부 객체는 직접 생성하는 편이 자연스러울 수 있다. 교체 가능성, 생명 주기와 테스트 경계를 기준으로 분리할 대상을 결정해야 한다.

### 의존성을 숨기면 코드가 단순해진다는 오해

Singleton이나 Service Locator를 사용하면 생성자 매개변수는 줄어든다. 하지만 메서드 내부에서 전역 서비스를 찾으면 객체가 무엇을 필요로 하는지 외부에서 알기 어렵다.

의존성을 명시적으로 드러내는 것은 코드가 필요로 하는 조건을 타입과 생성 과정에 표현하는 방법이다.

---

## 마무리

의존성은 한 코드가 자신의 기능을 수행하기 위해 다른 타입이나 객체를 필요로 하는 관계이다.

필드, 매개변수와 반환형뿐 아니라 메서드 내부의 객체 생성, 정적 호출과 Unity Inspector 참조에도 의존성이 존재한다.

객체 간 협력에는 의존성이 필요하지만 구체 구현과 생성 방법까지 아는 관계는 변경을 넓게 전파한다. 필요한 역할만 알고 객체 생성과 사용을 분리하면 의존 관계를 더 명확하게 관리할 수 있다.

좋은 설계는 의존성을 모두 제거하는 것이 아니라 변화가 잦은 세부 구현보다 안정적인 계약에 의존하고, 필요한 관계를 코드와 객체 구성에 분명하게 드러내는 것이다.

---

## 핵심 정리

- 의존성은 코드가 다른 타입이나 객체를 필요로 하는 관계이다.
- 의존성은 필드, 매개변수, 반환형, 객체 생성과 정적 호출에 나타난다.
- 직접 호출하지 않아도 중간 객체를 통해 간접 의존성이 생길 수 있다.
- 결합도가 높으면 의존 대상의 변경이 사용하는 코드에 크게 전파된다.
- 인터페이스를 사용해도 의존성은 사라지지 않고 역할 계약에 대한 의존성으로 바뀐다.
- 객체 생성과 사용을 분리하면 외부에서 실제 구현을 선택할 수 있다.
- 컴파일 시점에는 타입 계약이, 런타임에는 실제 구현 객체가 필요하다.
- Unity에서는 Inspector, `GetComponent()`와 Singleton 접근도 의존 관계를 만든다.
- 의존성을 제거하는 것보다 필요한 관계를 명확하고 안정적으로 관리하는 것이 중요하다.
