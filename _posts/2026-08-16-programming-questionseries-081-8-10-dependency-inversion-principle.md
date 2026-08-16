---
title: "[궁금시리즈] 8-10. 의존 역전 원칙(DIP)은 무엇일까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/8-10-dependency-inversion-principle/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:09 +0900
last_modified_at: 2026-08-16 12:00:09 +0900
---

## 들어가며

Quest가 완료되면 진행 상태를 파일에 저장한다고 가정한다.

```cs
public class QuestService
{
    private readonly JsonQuestFileWriter writer = new();

    public void Complete(Quest quest)
    {
        quest.Complete();
        writer.Write(quest);
    }
}
```

`QuestService`는 게임의 Quest 완료 규칙을 담당한다. `JsonQuestFileWriter`는 JSON 형식과 파일 시스템을 다루는 저장 세부 구현이다.

현재 구조에서는 상위 수준의 게임 규칙이 하위 수준의 파일 저장 방식에 직접 의존한다.

```text
Quest 완료 정책
QuestService
     ↓
JSON 파일 저장 세부 구현
JsonQuestFileWriter
```

서버 저장으로 전환하거나 테스트에서 메모리 저장소를 사용하려면 QuestService를 수정해야 한다.

게임 규칙은 그대로인데 저장 기술의 변경이 상위 정책까지 전파된다.

의존 역전 원칙(Dependency Inversion Principle)은 중요한 정책이 구체적인 기술 세부 사항에 끌려다니지 않도록 의존 방향을 설계하는 원칙이다.

상위 수준 모듈과 하위 수준 모듈이 모두 안정적인 추상화에 의존하도록 관계를 뒤집는다.

---

## 개념 설명

DIP는 두 가지 문장으로 정리할 수 있다.

```text
상위 수준 모듈은 하위 수준 모듈에 의존해서는 안 된다.
둘 모두 추상화에 의존해야 한다.

추상화는 세부 사항에 의존해서는 안 된다.
세부 사항이 추상화에 의존해야 한다.
```

### 상위 수준과 하위 수준

상위 수준 모듈은 프로그램이 무엇을 해야 하는지에 해당하는 정책과 업무 규칙을 다룬다.

```text
Quest 완료 처리
전투 결과 계산
아이템 구매 규칙
플레이어 인증 흐름
```

하위 수준 모듈은 그 정책을 실행하는 구체적인 기술과 방법을 다룬다.

```text
JSON 파일 저장
MySQL 데이터베이스
Unity AudioSource
HTTP 요청
Debug.Log 출력
```

상위와 하위는 중요도의 우열이 아니다. 추상적인 정책과 구체적인 구현 세부 사항의 수준을 구분하는 표현이다.

### 일반적인 의존 방향

추상화가 없으면 상위 정책이 구체 구현을 직접 생성하고 호출한다.

```cs
public class QuestService
{
    private readonly JsonQuestFileWriter writer = new();
}
```

소스 코드의 의존 방향은 다음과 같다.

```text
QuestService
     ↓ 의존
JsonQuestFileWriter
```

JsonQuestFileWriter의 생성자, 메서드와 데이터 형식이 바뀌면 QuestService도 영향을 받는다.

### 역전된 의존 방향

Quest 정책이 필요로 하는 저장 기능을 인터페이스로 정의한다.

```cs
public interface IQuestRepository
{
    void Save(QuestData data);
}
```

QuestService는 이 계약에 의존한다.

```cs
public class QuestService
{
    private readonly IQuestRepository repository;

    public QuestService(IQuestRepository repository)
    {
        this.repository = repository;
    }
}
```

구체 저장 클래스도 같은 계약을 구현한다.

```cs
public class JsonQuestRepository : IQuestRepository
{
    public void Save(QuestData data)
    {
        // JSON 파일 저장
    }
}
```

```text
QuestService ──────▶ IQuestRepository
                           ▲
                           │ 구현
JsonQuestRepository ───────┘
```

기존에는 QuestService가 JsonQuestRepository를 향했다. 이제 구체 저장 구현이 상위 정책이 요구한 계약을 향한다.

세부 구현을 향하던 소스 코드 의존 방향이 정책이 정의한 추상화를 향하도록 바뀌었기 때문에 의존 역전이라고 부른다.

### 추상화는 누가 소유할까?

인터페이스의 위치도 중요하다.

하위 저장 모듈이 자신이 가진 모든 기능을 그대로 노출한 인터페이스를 만들면 상위 정책이 하위 구현의 관점에 맞춰질 수 있다.

```cs
public interface IJsonFileWriter
{
    void WriteJson(string path, string json);
}
```

QuestService가 이 인터페이스에 의존하면 파일 경로와 JSON 문자열을 알아야 한다.

```cs
writer.WriteJson("quest.json", json);
```

이름은 인터페이스지만 추상화가 여전히 파일 저장 세부 사항을 표현한다.

상위 정책이 실제로 필요한 역할을 기준으로 계약을 만들 수 있다.

```cs
public interface IQuestRepository
{
    void Save(QuestData data);
}
```

QuestService는 Quest 저장만 요청하고 파일 경로, JSON 변환과 서버 요청은 구현이 책임진다.

좋은 추상화는 구현 클래스에서 메서드를 추출하는 데 그치지 않고 사용하는 정책이 필요로 하는 의미를 표현한다.

---

## 코드 예제

게임 설정을 불러오는 서비스가 PlayerPrefs에 직접 의존하는 코드를 생각할 수 있다.

```cs
public class GameSettingsService
{
    public float LoadVolume()
    {
        return PlayerPrefs.GetFloat("Volume", 1f);
    }

    public void SaveVolume(float volume)
    {
        PlayerPrefs.SetFloat("Volume", volume);
        PlayerPrefs.Save();
    }
}
```

볼륨 범위와 설정 정책을 담당하는 클래스가 Unity의 `PlayerPrefs` API와 Key 문자열까지 알고 있다.

저장 계약을 정책의 관점에서 정의한다.

```cs
public interface ISettingsRepository
{
    GameSettings Load();
    void Save(GameSettings settings);
}
```

설정 값은 저장 기술을 모르는 데이터로 표현한다.

```cs
public sealed class GameSettings
{
    public float Volume { get; }

    public GameSettings(float volume)
    {
        Volume = Math.Clamp(volume, 0f, 1f);
    }
}
```

상위 정책은 인터페이스에만 의존한다.

```cs
public class GameSettingsService
{
    private readonly ISettingsRepository repository;

    public GameSettingsService(ISettingsRepository repository)
    {
        this.repository = repository;
    }

    public GameSettings ChangeVolume(float volume)
    {
        GameSettings settings = new GameSettings(volume);
        repository.Save(settings);
        return settings;
    }

    public GameSettings Load()
    {
        return repository.Load();
    }
}
```

PlayerPrefs 구현은 Unity API를 감싼다.

```cs
public class PlayerPrefsSettingsRepository
    : ISettingsRepository
{
    private const string VolumeKey = "Volume";

    public GameSettings Load()
    {
        float volume = PlayerPrefs.GetFloat(VolumeKey, 1f);
        return new GameSettings(volume);
    }

    public void Save(GameSettings settings)
    {
        PlayerPrefs.SetFloat(VolumeKey, settings.Volume);
        PlayerPrefs.Save();
    }
}
```

파일 저장 구현도 같은 계약을 따를 수 있다.

```cs
public class JsonSettingsRepository
    : ISettingsRepository
{
    public GameSettings Load()
    {
        // JSON 파일 읽기
        return new GameSettings(1f);
    }

    public void Save(GameSettings settings)
    {
        // JSON 파일 저장
    }
}
```

조립하는 코드가 실제 구현을 선택한다.

```cs
ISettingsRepository repository =
    new PlayerPrefsSettingsRepository();

GameSettingsService service =
    new GameSettingsService(repository);
```

테스트에서는 메모리 구현을 사용할 수 있다.

```cs
public class MemorySettingsRepository
    : ISettingsRepository
{
    private GameSettings settings = new GameSettings(1f);

    public GameSettings Load() => settings;

    public void Save(GameSettings settings)
    {
        this.settings = settings;
    }
}
```

GameSettingsService의 코드는 저장 방식과 관계없이 동일하다.

```text
GameSettingsService
        ↓
ISettingsRepository
   ▲        ▲        ▲
   │        │        │
PlayerPrefs JSON   Memory
```

### DIP와 DI는 같은 것일까?

DIP는 의존 방향에 관한 설계 원칙이다.

DI(Dependency Injection)는 객체가 사용할 의존 대상을 외부에서 전달하는 구성 방식이다.

```cs
public GameSettingsService(
    ISettingsRepository repository)
{
    this.repository = repository;
}
```

이 생성자 전달은 DI이다. 동시에 GameSettingsService가 구체 저장소 대신 정책 인터페이스에 의존하므로 DIP도 적용되어 있다.

하지만 인터페이스 없이 구체 객체를 전달해도 DI는 성립할 수 있다.

```cs
public GameSettingsService(
    PlayerPrefsSettingsRepository repository)
{
}
```

외부에서 의존 객체를 전달했지만 상위 정책은 여전히 구체 저장 기술에 의존한다. 따라서 DI를 사용했다는 사실만으로 DIP가 자동 적용되는 것은 아니다.

---

## 내부 동작

DIP는 CLR이 의존 방향을 자동으로 바꾸는 기능이 아니다. 소스 코드와 Assembly가 어떤 타입을 참조하는지 결정하는 설계 원칙이다.

### Assembly 참조 방향

정책과 구현이 별도 Assembly에 있다고 가정한다.

직접 의존 구조에서는 Core Assembly가 Infrastructure Assembly의 클래스를 참조한다.

```text
Game.Core
└─ QuestService
       ↓ Assembly 참조
Game.Infrastructure
└─ JsonQuestRepository
```

Core를 컴파일하려면 Infrastructure가 필요하다.

추상화를 Core가 소유하면 방향이 달라진다.

```text
Game.Core
├─ QuestService
└─ IQuestRepository
       ▲
       │ Assembly 참조와 구현
Game.Infrastructure
└─ JsonQuestRepository
```

Infrastructure가 Core의 계약을 참조한다. Core는 Infrastructure 없이도 컴파일하고 테스트할 수 있다.

이것이 코드 수준에서 나타나는 실제 의존 방향의 역전이다.

### 런타임 객체 방향은 사라지지 않는다

소스 코드 의존 방향이 역전되어도 실행 시점에는 QuestService가 실제 Repository 객체를 사용한다.

```text
QuestService 객체
└─ IQuestRepository 참조
          ↓
JsonQuestRepository 객체
```

메서드 호출의 제어 흐름은 상위 정책에서 하위 구현으로 내려간다.

```text
QuestService.Complete()
↓
repository.Save()
↓
JsonQuestRepository.Save()
```

역전되는 것은 실행 순서가 아니라 소스 코드와 모듈이 바라보는 의존 방향이다.

### 인터페이스 호출

인터페이스 필드에는 실제 구현 객체를 가리키는 참조가 저장된다.

```cs
private readonly IQuestRepository repository;
```

`repository.Save()`가 호출되면 CLR은 실제 객체 타입의 인터페이스 구현을 찾아 실행한다.

DIP가 새로운 런타임 메커니즘을 만드는 것은 아니다. 인터페이스, 다형성과 객체 조립을 이용해 기존 메커니즘의 의존 관계를 설계한다.

---

## 실제 Unity에서는?

Unity 프로젝트에서는 Assembly Definition을 통해 의존 방향을 코드 구조로 제한할 수 있다.

```text
Game.Domain
├─ QuestService
└─ IQuestRepository

Game.Unity
├─ MonoBehaviour 조립 코드
└─ PlayerPrefsQuestRepository
       ↓
Game.Domain 참조
```

Domain Assembly가 `UnityEngine`과 구체 저장 구현을 참조하지 않게 만들면 순수 C# 테스트가 쉬워지고 저장 기술 변경도 Domain 규칙에 덜 영향을 준다.

Unity Component는 Inspector에서 구체 구현을 연결하는 방식으로 조립할 수 있다.

```cs
public abstract class QuestRepositoryBehaviour
    : MonoBehaviour, IQuestRepository
{
    public abstract void Save(QuestData data);
}
```

```cs
public class QuestController : MonoBehaviour
{
    [SerializeField]
    private QuestRepositoryBehaviour repository;

    private QuestService service;

    private void Awake()
    {
        service = new QuestService(repository);
    }
}
```

Unity Inspector가 인터페이스 필드를 기본 Object 참조로 직접 직렬화하기 어렵기 때문에 직렬화 가능한 추상 `MonoBehaviour` 기반 타입을 연결 지점으로 사용할 수 있다.

다른 방법으로 구체 `MonoBehaviour`를 직렬화한 뒤 인터페이스 구현 여부를 검증할 수도 있다.

```cs
[SerializeField] private MonoBehaviour repositoryObject;

private void Awake()
{
    IQuestRepository repository =
        repositoryObject as IQuestRepository
        ?? throw new InvalidOperationException();

    service = new QuestService(repository);
}
```

중요한 점은 QuestService가 `MonoBehaviour`, `PlayerPrefs`와 Scene 탐색을 몰라도 된다는 것이다.

Scene과 Prefab은 구체 객체를 조립하고 Domain 코드는 안정된 계약을 사용한다.

Unity의 모든 클래스에 인터페이스와 Assembly를 추가할 필요는 없다. 변경이 잦은 외부 기술과 오래 유지할 게임 규칙 사이에 경계가 필요할 때 DIP의 효과가 커진다.

---

## 실무에서 자주 하는 오해

### 인터페이스를 사용하면 DIP라는 오해

```cs
public interface IJsonFileWriter
{
    void WriteJson(string path, string json);
}
```

인터페이스가 하위 기술의 세부 API를 그대로 표현하고 상위 정책이 JSON과 경로를 알아야 한다면 의존 방향의 문제는 남아 있다.

추상화는 상위 정책이 필요로 하는 역할과 의미를 기준으로 설계해야 한다.

### 의존 흐름 자체가 반대로 실행된다는 오해

QuestService가 Repository를 호출하는 실행 흐름은 그대로이다.

DIP에서 역전되는 것은 런타임 호출 순서가 아니라 소스 코드와 모듈이 구체 구현 대신 정책 추상화를 향하는 의존 방향이다.

### DIP와 DI가 같은 것이라는 오해

DIP는 설계 원칙이고 DI는 의존 객체를 외부에서 전달하는 방법이다.

DI는 DIP 구조를 조립할 때 자주 사용하지만 구체 타입을 주입할 수도 있으므로 두 개념은 동일하지 않다.

### 모든 의존성에 인터페이스가 필요하다는 오해

변경되지 않는 단순 값 객체와 내부 구현 세부 사항까지 인터페이스로 분리하면 코드 탐색 비용만 늘어날 수 있다.

외부 기술, 교체 가능한 구현, 테스트 경계와 여러 구현이 존재하는 지점을 중심으로 추상화해야 한다.

### DIP를 적용하면 구현을 몰라도 된다는 오해

상위 정책은 구현을 모르지만 프로그램을 조립하는 Composition Root는 실제 구현을 알아야 한다.

```cs
new QuestService(new JsonQuestRepository());
```

구체 타입에 대한 지식이 사라지는 것이 아니라 한곳의 조립 코드로 이동한다.

---

## 마무리

의존 역전 원칙은 상위 수준의 정책이 파일, 데이터베이스, 네트워크와 Unity API 같은 하위 세부 구현에 직접 끌려가지 않도록 의존 방향을 설계하는 원칙이다.

상위 정책이 필요한 역할을 추상화로 정의하고 구체 구현이 그 계약을 따르게 만들면 세부 기술이 정책의 구조에 맞춰진다.

실행 시점에는 여전히 상위 객체가 하위 구현을 호출한다. 역전되는 것은 실행 흐름이 아니라 소스 코드와 Assembly가 바라보는 방향이다.

DIP는 모든 클래스에 인터페이스를 추가하는 규칙이 아니다. 오래 유지할 정책과 자주 교체되는 기술 세부 사항 사이의 경계를 안정적으로 만드는 데 사용해야 한다.

---

## 핵심 정리

- DIP는 상위 정책이 하위 세부 구현에 직접 의존하지 않게 만드는 원칙이다.
- 상위와 하위 모듈은 모두 안정적인 추상화에 의존해야 한다.
- 추상화는 구현 기술보다 상위 정책이 필요로 하는 역할을 표현해야 한다.
- 의존 역전은 런타임 호출 순서가 아니라 소스 코드와 모듈 참조 방향의 변화이다.
- 구체 구현이 상위 정책이 소유한 인터페이스를 구현하면 의존 방향이 역전된다.
- DI는 의존 객체를 외부에서 전달하는 방법이며 DIP와 같은 개념은 아니다.
- DI를 사용해도 구체 타입에 의존하면 DIP가 적용되지 않을 수 있다.
- Unity Assembly Definition으로 Domain과 Unity 세부 구현의 참조 방향을 제한할 수 있다.
- 구체 구현에 대한 지식은 사라지는 것이 아니라 조립 코드로 모인다.
