---
title: "[궁금시리즈] 8-1. 객체지향은 왜 등장했을까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-1-object-oriented-programming/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:00 +0900
last_modified_at: 2026-08-16 12:00:00 +0900
---

## 들어가며

게임에는 서로 다른 데이터와 동작을 가진 대상이 계속 등장한다.

- Player
- Monster
- NPC
- Item
- Skill
- Quest

절차 중심으로 작성한 작은 프로그램에서는 필요한 변수와 함수를 나열하는 것만으로 충분하다.

```cs
string playerName = "Alice";
int playerHealth = 100;
int playerDamage = 20;

void AttackMonster()
{
    monsterHealth -= playerDamage;
}
```

하지만 Monster가 늘어나고 장비, 버프, 상태 이상과 전투 규칙이 추가되면 어떤 데이터가 누구의 것이고 어떤 함수가 그 데이터를 변경하는지 파악하기 어려워진다.

객체지향 프로그래밍(Object-Oriented Programming)은 복잡해지는 프로그램을 현실의 대상과 역할에 가까운 단위로 나누기 위해 등장했다.

객체지향의 핵심은 모든 코드를 클래스로 만드는 데 있지 않다.

서로 관련된 상태와 동작을 하나의 객체로 묶고, 객체가 책임을 나누어 협력하도록 설계하는 데 있다.

---

## 개념 설명

객체는 상태(State)와 동작(Behavior)을 함께 가진다.

Player를 객체로 표현하면 이름과 체력은 상태가 되고, 공격하거나 피해를 받는 기능은 동작이 된다.

```cs
public class Player
{
    public string Name;
    public int Health;

    public void TakeDamage(int damage)
    {
        Health -= damage;
    }
}
```

이 코드에서 `Player`는 클래스이고, 클래스를 기반으로 생성된 실제 값은 객체 또는 인스턴스이다.

```cs
Player warrior = new Player();
Player archer = new Player();
```

`warrior`와 `archer`는 같은 `Player` 클래스를 기반으로 하지만 서로 다른 상태를 가진 별개의 객체이다.

```text
Player 클래스
├─ warrior 객체
│  ├─ Name: Warrior
│  └─ Health: 150
│
└─ archer 객체
   ├─ Name: Archer
   └─ Health: 80
```

클래스는 객체가 가져야 할 데이터와 동작을 정의한다. 객체는 그 정의를 바탕으로 메모리에 생성되어 실제 상태를 가진다.

객체지향에서 중요한 기준은 클래스의 개수가 아니라 각 객체가 어떤 상태와 규칙을 책임지는지에 있다. 객체는 다른 객체의 내부 데이터를 직접 조작하기보다 공개된 동작을 통해 협력한다.

---

## 코드 예제

간단한 전투 코드를 객체 단위로 나누면 다음과 같이 작성할 수 있다.

```cs
public class Player
{
    private readonly Weapon weapon;

    public Player(Weapon weapon)
    {
        this.weapon = weapon;
    }

    public void Attack(Monster target)
    {
        weapon.Attack(target);
    }
}
```

Player는 공격을 시작하지만 실제 공격 수치와 공격 처리는 Weapon에 맡긴다.

```cs
public class Weapon
{
    public int Damage { get; }

    public Weapon(int damage)
    {
        Damage = damage;
    }

    public void Attack(Monster target)
    {
        target.TakeDamage(Damage);
    }
}
```

Monster는 자신의 체력과 사망 규칙을 관리한다.

```cs
public class Monster
{
    public int Health { get; private set; }
    public bool IsDead => Health <= 0;

    public Monster(int health)
    {
        Health = health;
    }

    public void TakeDamage(int damage)
    {
        if (IsDead)
        {
            return;
        }

        Health = Math.Max(0, Health - damage);
    }
}
```

사용하는 코드는 각 객체를 생성하고 협력 관계를 연결한다.

```cs
Weapon sword = new Weapon(30);
Player player = new Player(sword);
Monster slime = new Monster(50);

player.Attack(slime);
player.Attack(slime);

Console.WriteLine(slime.Health); // 0
Console.WriteLine(slime.IsDead); // True
```

각 객체의 책임은 분리되어 있다.

- Player는 어떤 Weapon을 사용할지 안다.
- Weapon은 공격 피해량을 안다.
- Monster는 피해를 받은 뒤 체력을 어떻게 변경할지 안다.

새로운 Weapon을 추가하거나 Monster의 방어 규칙을 바꾸더라도 관련 객체를 중심으로 수정할 수 있다.

## 내부 동작

C#에서 클래스는 참조 타입이다.

```cs
Monster slime = new Monster(100);
```

`new Monster(100)`이 실행되면 런타임은 관리되는 Heap에 Monster 객체가 사용할 메모리를 확보하고 생성자를 호출한다.

변수 `slime`에는 객체 자체가 아니라 객체를 가리키는 참조가 저장된다.

```text
Stack                         Managed Heap

slime ──────────────────────▶ Monster 객체
                              ├─ Health: 100
                              └─ 객체 헤더
```

같은 객체의 참조를 다른 변수에 대입하면 객체가 복사되는 것이 아니다.

```cs
Monster target = slime;

target.TakeDamage(30);

Console.WriteLine(slime.Health); // 70
```

`slime`과 `target`이 동일한 Monster 객체를 참조하므로 한쪽을 통해 변경한 상태가 다른 쪽에서도 보인다.

객체를 여러 개 생성해도 메서드 코드가 객체마다 복사되지는 않는다. 각 객체는 서로 다른 필드 값을 가지며 메서드 실행 코드는 타입 단위로 공유한다. 인스턴스 메서드가 호출되면 현재 객체의 참조가 숨겨진 인수로 전달되고, C#의 `this`는 이 참조를 나타낸다.

CLR은 타입 정보를 이용해 객체 크기, 필드 배치, 메서드 실행, 형식 검사와 Garbage Collector의 참조 추적을 처리한다.

---

## 실제 Unity에서는?

Unity의 게임 오브젝트 구조도 객체의 협력으로 이루어진다.

```text
GameObject
├─ Transform
├─ PlayerMovement
├─ PlayerHealth
├─ PlayerAttack
└─ Animator
```

Unity는 하나의 거대한 Player 클래스에 모든 기능을 넣기보다 작은 Component를 조합하는 방식을 사용한다.

```cs
public class PlayerHealth : MonoBehaviour
{
    [SerializeField] private int maxHealth = 100;

    public int CurrentHealth { get; private set; }

    private void Awake()
    {
        CurrentHealth = maxHealth;
    }

    public void TakeDamage(int damage)
    {
        CurrentHealth = Mathf.Max(0, CurrentHealth - damage);
    }
}
```

`PlayerHealth`는 체력 관리에 집중한다. 이동 입력이나 공격 애니메이션까지 처리하지 않는다.

공격 Component는 대상의 체력 Component에 피해 처리를 요청한다.

```cs
public class PlayerAttack : MonoBehaviour
{
    [SerializeField] private int damage = 20;

    public void Attack(PlayerHealth target)
    {
        target.TakeDamage(damage);
    }
}
```

Unity에서 `MonoBehaviour`를 상속한 객체의 생성은 일반 C# 객체와 다르게 관리된다.

```cs
PlayerHealth health = new PlayerHealth(); // 사용하면 안 된다
```

`MonoBehaviour`는 `GameObject.AddComponent<T>()`나 Scene·Prefab 로딩을 통해 Unity Engine이 생성하고 수명 주기를 연결한다.

반면 게임 규칙만 담당하며 Unity 생명 주기가 필요 없는 클래스는 일반 C# 객체로 분리할 수 있다.

```cs
public class Health
{
    public int Current { get; private set; }

    public Health(int current)
    {
        Current = current;
    }

    public void TakeDamage(int damage)
    {
        Current = Math.Max(0, Current - damage);
    }
}
```

이런 객체는 `new`로 생성할 수 있고 Unity Scene 없이도 테스트하기 쉽다.

Unity에서 객체지향을 적용한다는 것은 모든 기능을 `MonoBehaviour`로 만드는 것이 아니다. Engine과 연결되는 부분과 순수한 게임 규칙을 구분하고, 각 객체가 맡을 책임을 명확히 만드는 것이 중요하다.

---

## 실무에서 자주 하는 오해

### 클래스만 사용하면 객체지향이라는 오해

코드를 클래스로 감쌌다고 해서 자동으로 객체지향 설계가 되는 것은 아니다.

```cs
public class GameManager
{
    public void MovePlayer() { }
    public void AttackMonster() { }
    public void UpdateQuest() { }
    public void SaveGame() { }
    public void PlaySound() { }
}
```

하나의 클래스가 모든 기능을 처리하면 전역 함수 모음을 클래스로 옮긴 것과 크게 다르지 않다.

객체지향의 핵심은 클래스의 개수가 아니라 책임을 어떤 기준으로 나누고 객체가 어떻게 협력하는지에 있다.

### 현실의 대상을 그대로 복사해야 한다는 오해

객체는 현실 세계의 사물을 그대로 표현해야 하는 것이 아니다.

`DamageCalculator`, `ObjectPool`, `InputHandler`처럼 물리적인 형태가 없는 개념도 명확한 상태와 책임을 가진 객체가 될 수 있다.

설계에서 중요한 기준은 현실과 얼마나 비슷한지가 아니라 프로그램의 변경과 협력을 얼마나 명확하게 표현하는가이다.

### 상속이 객체지향의 핵심이라는 오해

상속은 객체지향의 여러 도구 중 하나이다.

공통 코드를 재사용한다는 이유만으로 상속 관계를 만들면 부모 클래스의 변경이 모든 자식 클래스에 영향을 줄 수 있다.

Unity가 Component 조합을 중심으로 설계된 것처럼 실무에서는 상속보다 Composition이 더 유연한 경우가 많다.

### 모든 코드를 객체로 만들어야 한다는 오해

간단한 수학 계산, 값 변환과 상태를 가지지 않는 유틸리티까지 무조건 객체로 만들 필요는 없다.

객체지향은 목적이 아니라 복잡성을 관리하는 방법이다. 함수, 구조체, 데이터 중심 설계와 함께 상황에 맞게 사용해야 한다.

---

## 마무리

객체지향은 프로그램을 현실 세계처럼 꾸미기 위해 등장한 방식이 아니다.

프로그램이 커지면서 서로 관련된 데이터와 함수가 흩어지고, 하나의 변경이 여러 코드에 영향을 주는 문제를 줄이기 위해 등장했다.

객체는 상태와 동작을 함께 가지며 자신이 맡은 책임을 관리한다. 여러 객체는 공개된 동작을 통해 협력하고 서로의 내부 구현에 대한 의존을 줄인다.

C#의 클래스와 객체 문법은 이러한 설계를 표현하는 도구이다. 좋은 객체지향 코드는 클래스를 많이 사용하는 코드가 아니라 변경 이유가 다른 책임을 분리하고, 필요한 관계만 드러내는 코드이다.

---

## 핵심 정리

- 객체지향은 커지는 프로그램의 복잡성과 변경 범위를 관리하기 위해 등장했다.
- 객체는 상태와 동작을 하나의 단위로 묶는다.
- 클래스는 객체의 필드, 메서드와 타입 정보를 정의한다.
- 같은 클래스에서 생성된 객체도 서로 독립적인 상태를 가진다.
- C# 클래스 객체는 관리되는 Heap에 생성되며 변수에는 객체의 참조가 저장된다.
- 인스턴스 메서드는 현재 객체를 나타내는 `this`를 통해 상태에 접근한다.
- 객체지향의 핵심은 클래스의 개수가 아니라 책임 분리와 객체 간 협력이다.
- Unity에서는 `MonoBehaviour` 상속뿐 아니라 Component 조합도 객체지향 설계의 중요한 형태이다.
- 모든 문제에 객체지향을 적용할 필요는 없으며 상황에 맞는 설계 방식을 선택해야 한다.
