---
title: "[궁금시리즈] 8-11. 제어의 역전(IoC)이란 무엇일까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-11-inversion-of-control/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:10 +0900
last_modified_at: 2026-08-16 12:00:10 +0900
---

## 들어가며

일반적인 프로그램에서는 작성한 코드가 실행 순서를 직접 결정한다.

```cs
public void RunGame()
{
    Initialize();

    while (isRunning)
    {
        ReadInput();
        UpdateGame();
        Render();
    }

    Shutdown();
}
```

`RunGame()`이 언제 초기화하고, 어떤 순서로 업데이트하며, 언제 종료할지 모두 제어한다.

Unity에서는 개발자가 이 반복문을 직접 호출하지 않는다.

```cs
public class PlayerController : MonoBehaviour
{
    private void Awake()
    {
    }

    private void Update()
    {
    }
}
```

Unity Engine이 전체 실행 흐름을 소유하고 적절한 시점에 `Awake()`와 `Update()`를 호출한다.

```text
일반적인 호출
사용자 코드 → Library 호출

Unity 실행 흐름
Unity Engine → 사용자 코드 호출
```

프로그램의 전체 흐름을 누가 결정하는지가 바뀌었다.

제어의 역전(Inversion of Control)은 객체 생성, 실행 순서와 호출 시점 같은 제어권을 현재 객체가 직접 소유하지 않고 외부 구조에 맡기는 설계 개념이다.

IoC는 특정 Library나 Container의 이름이 아니다. Framework, Event, Callback, Template Method와 Dependency Injection 등 여러 구조에서 나타나는 넓은 개념이다.

---

## 개념 설명

제어(Control)는 프로그램에서 다음과 같은 결정을 의미할 수 있다.

- 객체를 언제 생성할지
- 어떤 구현을 사용할지
- 메서드를 언제 호출할지
- 실행 순서를 어떻게 구성할지
- 객체의 수명을 누가 관리할지

객체가 이 결정을 직접 처리하면 제어권이 객체 내부에 있다.

```cs
public class BattleService
{
    private readonly BattleLogger logger;

    public BattleService()
    {
        logger = new BattleLogger();
    }

    public void Run()
    {
        logger.Begin();
        Fight();
        logger.End();
    }
}
```

BattleService가 Logger의 생성과 실행 순서를 모두 결정한다.

외부 코드가 필요한 객체를 만들어 전달하면 객체 생성에 대한 제어권이 밖으로 이동한다.

```cs
public BattleService(IBattleLogger logger)
{
    this.logger = logger;
}
```

Framework가 전체 실행 순서를 관리하고 일부 단계만 사용자 코드에 맡길 수도 있다.

```cs
public abstract class BattleLoop
{
    public void Run()
    {
        Begin();
        Update();
        End();
    }

    protected abstract void Update();
}
```

파생 클래스는 `Run()`의 순서를 결정하지 않는다. Framework 역할의 기반 클래스가 정한 시점에 `Update()` 구현이 호출된다.

### Library와 Framework의 차이

Library를 사용할 때는 일반적으로 사용자 코드가 필요한 기능을 직접 호출한다.

```cs
string json = JsonSerializer.Serialize(player);
```

호출 시점과 실행 순서는 사용자 코드가 결정한다.

Framework는 전체 실행 구조를 제공하고 사용자 코드가 들어갈 확장 지점을 호출한다.

```text
Library
사용자 코드가 Library를 호출

Framework
Framework가 사용자 코드를 호출
```

이를 Hollywood Principle이라고 표현하기도 한다.

```text
Don't call us, we'll call you.
```

Framework가 항상 IoC를 사용하고 Library는 절대 사용하지 않는다는 엄격한 구분은 아니다. 핵심은 특정 기능에서 누가 실행 흐름을 소유하는가이다.

### IoC의 여러 형태

IoC는 하나의 구현 방식만 의미하지 않는다.

```text
IoC
├─ Framework Callback
├─ Template Method
├─ Event와 Delegate
├─ Strategy 전달
├─ Dependency Injection
└─ IoC Container
```

Event에서는 Publisher가 Subscriber의 구체 메서드를 직접 선택하지 않는다.

```cs
public event Action Died;
```

외부에서 등록된 Callback이 이벤트 발생 시 호출된다.

```cs
monster.Died += quest.OnMonsterDied;
```

Monster는 Quest의 구체적인 진행 로직을 직접 호출하지 않는다. 어떤 반응이 연결될지는 외부 구성에 맡긴다.

### IoC와 DIP의 차이

DIP는 소스 코드의 의존 방향에 관한 원칙이다.

IoC는 객체 생성과 호출 흐름 같은 제어권을 외부로 옮기는 개념이다.

```text
DIP
└─ 어떤 방향으로 의존하는가

IoC
└─ 누가 생성과 호출을 제어하는가
```

두 개념은 함께 사용되는 경우가 많지만 같은 의미는 아니다.

---

## 코드 예제

QuestManager가 Monster 생성과 사망 확인을 모두 직접 제어하는 코드를 생각할 수 있다.

```cs
public class QuestManager
{
    public void RunQuest()
    {
        Monster monster = new Monster();

        while (!monster.IsDead)
        {
            monster.Update();
        }

        CompleteQuest();
    }

    private void CompleteQuest()
    {
    }
}
```

QuestManager가 Monster 생성, 반복 실행과 완료 시점을 모두 알고 있다.

게임의 Main Loop가 이미 존재한다면 Quest가 별도의 반복문을 소유할 필요가 없다. Event를 통해 완료 시점의 제어를 바꿀 수 있다.

```cs
public class Monster
{
    public event Action Died;

    public int Health { get; private set; } = 100;

    public void TakeDamage(int damage)
    {
        if (Health == 0)
        {
            return;
        }

        Health = Math.Max(0, Health - damage);

        if (Health == 0)
        {
            Died?.Invoke();
        }
    }
}
```

Quest는 이벤트에 반응할 동작만 제공한다.

```cs
public class DefeatMonsterQuest
{
    public bool IsCompleted { get; private set; }

    public void Bind(Monster monster)
    {
        monster.Died += OnMonsterDied;
    }

    private void OnMonsterDied()
    {
        IsCompleted = true;
    }
}
```

객체를 조립하는 코드가 두 객체의 관계를 연결한다.

```cs
Monster monster = new Monster();
DefeatMonsterQuest quest = new DefeatMonsterQuest();

quest.Bind(monster);
```

Quest는 Monster의 반복 실행을 제어하지 않는다. Monster가 사망한 시점에 등록된 Callback이 호출된다.

```text
Game Loop
↓
Monster가 피해를 받음
↓
Monster.Died Event 발생
↓
등록된 Quest Callback 호출
```

### Template Method를 이용한 제어 역전

전체 순서를 기반 클래스가 관리하고 일부 단계만 파생 클래스에 맡길 수 있다.

```cs
public abstract class Skill
{
    public void Use(Character target)
    {
        Validate(target);
        Execute(target);
        StartCooldown();
    }

    private void Validate(Character target)
    {
        if (target is null)
        {
            throw new ArgumentNullException(nameof(target));
        }
    }

    protected abstract void Execute(Character target);

    private void StartCooldown()
    {
    }
}
```

Fireball은 전체 실행 순서를 호출하지 않고 효과만 구현한다.

```cs
public class Fireball : Skill
{
    protected override void Execute(Character target)
    {
        target.TakeDamage(30);
    }
}
```

```text
Skill 기반 클래스
├─ 검증 시점 결정
├─ Execute() 호출 시점 결정
└─ Cooldown 시작 시점 결정

Fireball
└─ Execute() 내용만 제공
```

파생 클래스가 Framework의 확장 지점에 코드를 제공하고 기반 클래스가 적절한 시점에 호출한다.

### 객체 생성 제어의 역전

GameService가 자신의 저장소를 직접 생성할 수 있다.

```cs
public class GameService
{
    private readonly SaveRepository repository = new();
}
```

외부 조립 코드가 생성하면 구현 선택과 수명 관리의 제어권이 밖으로 이동한다.

```cs
ISaveRepository repository = new JsonSaveRepository();
GameService service = new GameService(repository);
```

이 형태는 IoC를 구현하는 대표적인 방법인 Dependency Injection이다.

---

## 내부 동작

IoC는 CLR에 존재하는 하나의 전용 기능이 아니다. 일반적인 메서드 호출, 가상 디스패치, Delegate, Event와 객체 참조를 조합하여 제어 구조를 바꾼다.

### Callback 호출

Event에 메서드를 등록하면 Delegate가 대상 객체와 메서드 정보를 저장한다.

```cs
monster.Died += quest.OnMonsterDied;
```

개념적인 관계는 다음과 같다.

```text
Monster.Died Delegate
└─ Target: quest 객체
   Method: OnMonsterDied
```

Monster가 이벤트를 호출하면 등록 목록을 순서대로 실행한다.

```cs
Died?.Invoke();
```

제어 흐름이 외부 Callback으로 이동하지만 런타임에서는 Delegate 호출로 동작한다.

### 가상 메서드 Callback

Template Method 구조에서는 기반 클래스가 추상 또는 가상 메서드를 호출한다.

```cs
public void Use(Character target)
{
    Execute(target);
}
```

`Execute()`는 가상 슬롯을 통해 실제 파생 객체의 구현으로 디스패치된다.

```text
Skill.Use()
↓
가상 Execute 슬롯 확인
↓
Fireball.Execute() 호출
```

기반 클래스가 실행 순서를 소유하고 파생 클래스가 호출되는 구조는 일반 C#의 가상 메서드 메커니즘 위에서 구현된다.

### IoC Container의 역할

IoC Container는 등록된 규칙을 보고 객체를 생성하고 의존 관계를 연결할 수 있다.

```text
IQuestRepository → JsonQuestRepository 등록
↓
QuestService 요청
↓
생성자 분석
↓
JsonQuestRepository 생성
↓
QuestService에 전달
```

Reflection이나 미리 생성된 Factory 코드를 이용해 생성자와 타입 정보를 확인할 수 있다.

Container를 사용하지 않아도 직접 객체를 만들고 전달하면 IoC와 DI를 구현할 수 있다.

```cs
new QuestService(new JsonQuestRepository());
```

IoC의 본질은 Container 사용 여부가 아니라 제어권이 적절한 외부 구성으로 이동했는가이다.

---

## 실제 Unity에서는?

Unity 자체가 IoC 구조를 가진 Framework이다.

개발자는 Main Loop를 직접 호출하지 않고 Unity가 Component의 메시지를 호출한다.

```text
Unity Player Loop
├─ Scene 로드
├─ Awake 호출
├─ Start 호출
├─ 매 프레임 Update 호출
├─ 물리 단계에서 FixedUpdate 호출
└─ Object 제거 시 OnDestroy 호출
```

```cs
public class PlayerController : MonoBehaviour
{
    private void Update()
    {
        Move();
    }
}
```

PlayerController는 `Update()`를 언제 몇 번 호출할지 결정하지 않는다. Unity가 실행 시점을 제어하고 사용자 코드는 정해진 확장 지점에 동작을 제공한다.

### Unity Event와 Callback

UI Button도 클릭 시점을 Unity UI System이 감지하고 등록된 Listener를 호출한다.

```cs
button.onClick.AddListener(StartGame);
```

사용자 코드는 입력 Polling과 Button 판정을 직접 반복하지 않고 클릭 이후 실행할 Callback만 등록한다.

Coroutine도 Unity가 실행 시점을 관리한다.

```cs
private IEnumerator SpawnAfterDelay()
{
    yield return new WaitForSeconds(1f);
    Spawn();
}
```

`yield return` 이후 언제 다시 진행할지는 Unity Coroutine Scheduler가 결정한다.

### Scene과 Prefab의 객체 조립

Unity는 Scene과 Prefab을 역직렬화하여 Component를 생성하고 `[SerializeField]` 참조를 연결한다.

```cs
[SerializeField] private AudioSource audioSource;
```

Component가 `new AudioSource()`로 의존 객체를 직접 만들지 않는다. Unity Editor와 Scene 구성이 객체 생성과 연결의 일부를 제어한다.

Unity가 제공하는 IoC와 프로젝트 내부의 의존성 설계는 구분해야 한다. Unity가 Component를 생성해 준다는 사실만으로 게임 코드의 구체 의존성이 자동으로 분리되지는 않는다.

`FindFirstObjectByType()`와 Singleton을 모든 곳에서 호출하면 객체 생성은 외부에 있어도 의존 관계가 숨겨질 수 있다.

---

## 실무에서 자주 하는 오해

### IoC는 Container라는 오해

IoC Container는 객체 생성과 연결의 제어를 외부화하는 도구이다. IoC 자체는 더 넓은 설계 개념이다.

Unity 생명 주기, Event, Callback과 Template Method에도 제어의 역전이 존재한다.

### IoC와 DI가 같은 개념이라는 오해

DI는 의존 객체를 외부에서 전달하여 생성 제어를 역전하는 방법이다.

IoC는 객체 생성뿐 아니라 메서드 호출 시점과 실행 흐름을 외부 Framework에 맡기는 구조까지 포함한다. DI는 IoC의 대표적인 구현 방식 중 하나이다.

### Framework를 사용하면 설계가 자동으로 좋아진다는 오해

Framework가 실행 흐름을 관리해도 사용자 코드 내부에서 구체 타입을 직접 생성하고 전역 상태에 강하게 결합할 수 있다.

IoC 구조를 사용한다는 사실과 책임 및 의존성을 올바르게 나누었다는 사실은 별개이다.

### 제어권은 모두 외부로 넘겨야 한다는 오해

객체가 자신의 상태와 불변식을 관리하는 제어권까지 외부로 넘기면 캡슐화가 깨질 수 있다.

```cs
player.Health = -100;
```

객체 내부 규칙은 객체가 책임지고 객체의 생성, 구현 선택과 전체 실행 시점처럼 외부 구성이 관리해야 할 제어만 분리해야 한다.

### IoC를 사용하면 흐름을 이해하기 쉽다는 오해

Callback과 Container가 많아지면 누가 언제 코드를 호출하는지 직접적인 호출문만으로 파악하기 어려울 수 있다.

등록 위치, 실행 순서와 객체 수명 규칙을 명확하게 관리하지 않으면 제어의 역전이 오히려 추적 비용을 높인다.

---

## 마무리

제어의 역전은 객체 생성, 구현 선택과 메서드 호출 시점 같은 제어권을 현재 코드가 직접 소유하지 않고 외부 Framework나 조립 구조에 맡기는 개념이다.

Unity가 `Update()`를 호출하고 Event가 등록된 Callback을 실행하며 기반 클래스가 파생 구현의 호출 시점을 결정하는 구조에 IoC가 나타난다.

Dependency Injection과 IoC Container는 객체 생성과 연결의 제어를 외부화하는 방법이지만 IoC 전체와 같은 의미는 아니다.

제어를 외부로 옮기면 확장 지점과 구현 교체가 명확해질 수 있다. 동시에 호출 흐름이 간접적으로 바뀌므로 등록 위치, 실행 순서와 객체 수명을 이해할 수 있게 설계해야 한다.

---

## 핵심 정리

- IoC는 객체 생성과 호출 흐름의 제어권을 외부 구조에 맡기는 개념이다.
- Library는 보통 사용자 코드가 호출하고 Framework는 사용자 코드의 확장 지점을 호출한다.
- Event, Callback, Template Method와 DI에서 IoC 구조가 나타난다.
- DIP는 의존 방향의 원칙이고 IoC는 제어권의 위치에 관한 개념이다.
- DI는 객체 생성과 연결의 제어를 역전하는 IoC 구현 방식 중 하나이다.
- IoC Container가 없어도 직접 객체를 조립하여 IoC와 DI를 적용할 수 있다.
- Unity의 생명 주기, UI Event, Coroutine과 Scene 조립에도 IoC가 사용된다.
- IoC가 객체 내부의 상태 규칙까지 외부로 넘긴다는 의미는 아니다.
- 간접 호출이 늘어나므로 등록 위치, 실행 순서와 객체 수명을 명확히 관리해야 한다.
