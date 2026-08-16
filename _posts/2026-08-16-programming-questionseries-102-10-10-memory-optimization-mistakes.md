---
title: "[궁금시리즈] 10-10. Unity 메모리 최적화에서 자주 하는 실수 총정리"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/10-10-memory-optimization-mistakes/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:30 +0900
last_modified_at: 2026-08-16 12:00:30 +0900
---

## 들어가며

메모리 최적화는 작은 할당을 발견하는 작업부터 시작하지 않는다.

```text
게임이 끊김
↓
모든 new 제거

메모리가 큼
↓
모든 Texture 해상도 절반

GC Spike 발생
↓
매 Frame GC.Collect 호출
```

증상과 원인을 연결하지 않은 수정은 효과가 없거나 다른 비용을 만든다.

Frame이 끊기는 원인은 반복 Managed Allocation일 수 있지만 Asset Load, Shader Compile이나 CPU 병목일 수도 있다. 메모리가 큰 이유는 누수가 아니라 Loading된 고해상도 Texture나 Allocator가 유지하는 Reserved Memory일 수 있다.

```text
증상 확인
↓
Managed / Native / Graphics / Audio 영역 구분
↓
사용량 / 반복 할당 / 누수 / Peak 구분
↓
원인에 맞는 수정
↓
동일 조건 재측정
```

메모리 최적화에서 가장 흔한 실수는 특정 API를 사용한 것이 아니라 측정 기준과 객체의 소유권을 정하지 않은 것이다.

---

## 개념 설명

### 메모리 문제는 종류가 다르다

다음 문제는 모두 접근 방법이 다르다.

```text
전체 사용량 초과
└─ Asset, Cache와 상주 객체 크기 확인

GC Spike
└─ 반복 Managed Allocation과 Live Object 확인

시간이 지날수록 증가
└─ 미해제 참조와 반복 Load 확인

Scene 전환 순간 종료
└─ 동시에 존재하는 Asset과 Peak Memory 확인

간헐적 Instantiate Spike
└─ 생성 비용, Prewarm과 Pool 검토
```

메모리 사용량이 크다는 말만으로는 문제를 정의할 수 없다.

### 최적화에는 교환 비용이 있다

```text
Cache
CPU 계산 감소 ↔ 상주 메모리 증가

Object Pool
생성 Spike 감소 ↔ Inactive 객체 유지

Audio Compression
메모리 감소 ↔ Decode CPU 증가

Texture 해상도 감소
메모리 감소 ↔ 화면 품질 저하

Incremental GC
긴 Spike 분산 ↔ Write Barrier와 분산 작업
```

한 지표를 낮추는 변경이 전체 성능도 개선한다고 가정하면 안 된다.

### 수명과 소유권

메모리 문제는 누가 생성했는지보다 누가 해제할 책임을 가지는지가 불명확할 때 자주 생긴다.

```text
획득한 쪽
└─ Release 규칙도 함께 가짐

Pool에서 Get
└─ 사용 후 Release

Event 구독
└─ 수명 종료 전 구독 해제

Native Collection 생성
└─ Dispose 책임 지정
```

생성 API와 해제 API를 한 쌍으로 설계한다.

### 측정 단위

평균값 하나로 판단하지 않는다.

```text
GC Alloc / Frame
Collection 발생 주기
평균 Frame Time
최악 Frame Time
평균 Memory
Peak Memory
객체 수의 반복 증가량
```

사용자가 느끼는 끊김과 플랫폼의 강제 종료는 평균보다 최악 구간에서 발생할 수 있다.

---

## 코드 예제

### 매 Frame GC.Collect 호출

```cs
void Update()
{
    GC.Collect();
}
```

Garbage 생성을 줄이지 않고 Full Blocking Collection을 반복 요청한다.

원인은 반복 문자열 생성일 수 있다.

```cs
void Update()
{
    hpText.text = $"HP: {player.Hp}";
}
```

값이 바뀔 때만 갱신한다.

```cs
private int displayedHp = -1;

public void SetHp(int hp)
{
    if (displayedHp == hp)
    {
        return;
    }

    displayedHp = hp;
    hpText.text = $"HP: {hp}";
}
```

Collector를 강제로 실행하기 전에 Garbage 발생 경로를 줄인다.

### Destroy만 호출하고 참조 유지

```cs
private readonly List<Enemy> enemies = new();

public void Despawn(Enemy enemy)
{
    Destroy(enemy.gameObject);
}
```

Native GameObject는 파괴를 요청했지만 List는 Managed Wrapper를 계속 참조한다.

```cs
public void Despawn(Enemy enemy)
{
    enemies.Remove(enemy);
    Destroy(enemy.gameObject);
}
```

Event와 Dictionary에도 같은 객체가 등록되어 있다면 모든 소유 관계를 정리해야 한다.

### Event 구독 누락

```cs
public sealed class InventoryPanel : MonoBehaviour
{
    private void OnEnable()
    {
        inventory.Changed += Refresh;
    }
}
```

구독 해제가 없으면 Publisher가 Panel을 계속 참조할 수 있고, 다시 활성화될 때 중복 구독도 생긴다.

```cs
private void OnDisable()
{
    inventory.Changed -= Refresh;
}
```

구독과 해제 시점은 Publisher와 Subscriber의 실제 수명 관계에 맞춘다. 모든 구독을 무조건 `OnEnable`과 `OnDisable`에 배치하는 규칙은 아니다.

### Asset Load와 Release 불일치

```cs
public async UniTask<GameObject> LoadAsync(string key)
{
    AsyncOperationHandle<GameObject> handle =
        Addressables.LoadAssetAsync<GameObject>(key);

    return await handle.ToUniTask();
}
```

반환값만 저장하고 Handle과 Release 책임을 잃어버리면 Asset 수명을 관리하기 어렵다.

```cs
public sealed class LoadedAsset<T>
{
    public T Asset { get; }
    public AsyncOperationHandle<T> Handle { get; }

    public LoadedAsset(
        T asset,
        AsyncOperationHandle<T> handle)
    {
        Asset = asset;
        Handle = handle;
    }
}
```

실제 프로젝트에서는 Load 성공, 실패, 중복 Load, Instance 생성 여부에 맞는 Release API와 호출 횟수를 함께 관리한다.

### Pool에서 상태 초기화 누락

```cs
public void Release(Projectile projectile)
{
    projectile.gameObject.SetActive(false);
    pool.Push(projectile);
}
```

비활성화만 하면 이전 사용자의 상태가 남을 수 있다.

```cs
public void ResetState()
{
    rigidbody.linearVelocity = Vector3.zero;
    rigidbody.angularVelocity = Vector3.zero;
    trailRenderer.Clear();
    hitTargets.Clear();
    onHit = null;
}
```

Pool은 생성 비용을 줄이지만 Reset 계약을 추가한다.

### 과도한 Capacity 유지

```cs
results.Clear();
```

Count는 0이지만 일시적인 Peak에서 커진 Capacity는 남을 수 있다.

반복 재사용하는 Buffer라면 정상이다. 해당 단계가 끝나고 다시 큰 크기를 사용하지 않는다면 상한을 기준으로 축소한다.

```cs
results.Clear();

if (results.Capacity > maxRetainedCapacity)
{
    results.Capacity = normalCapacity;
}
```

매 Frame 축소하면 다음 Frame에 다시 확장될 수 있으므로 수명 경계에서만 적용한다.

---

## 내부 동작

### Managed와 Native는 해제 경로가 다르다

```text
일반 C# 객체
참조 제거 → GC 회수

UnityEngine.Object
Destroy로 Native Object 파괴 + Managed 참조 정리

NativeArray
Dispose로 Native Allocation 반환

Addressables Asset
Load 방식과 Handle에 맞는 Release
```

`null`, `Destroy()`, `Dispose()`와 `Release()`는 서로 대체할 수 있는 하나의 해제 명령이 아니다.

### Reference Chain

객체가 남는 이유는 객체 자신보다 Root에서 이어지는 참조에 있다.

```text
Static Singleton
↓
Event Delegate
↓
Scene Controller
↓
GameObject Component
↓
Material과 Texture
```

마지막 Texture만 해제하려 하면 다른 참조가 있는 동안 다시 유지되거나 잘못된 상태가 된다. 소유권의 시작점에서 참조를 끊어야 한다.

### Reserved Memory

Allocator와 Managed Heap은 이후 할당에 재사용하기 위해 확보한 공간을 유지할 수 있다.

```text
Peak 전에 Used 300MB / Reserved 400MB
Peak 중 Used 700MB / Reserved 800MB
정리 후 Used 320MB / Reserved 800MB
```

Used가 원래 수준으로 돌아오고 객체 수도 안정적이라면 Reserved가 남아 있다는 사실만으로 누수라고 할 수 없다.

하지만 운영체제 관점의 Process Memory가 플랫폼 한도를 넘는다면 Reserved 정책도 실제 위험에 포함된다. 대상 기기에서 Peak와 종료 조건을 확인해야 한다.

### Pool과 Cache의 Retained Graph

Pool과 Cache는 의도적으로 객체를 Root에서 도달 가능한 상태로 유지한다.

```text
Global Pool
↓
Inactive GameObject
↓
Renderer
↓
Material
↓
Texture
```

Inactive GameObject 하나의 자체 크기는 작아도 Asset Graph 전체 수명을 연장할 수 있다. Pool Size만 세지 않고 참조하는 리소스까지 확인한다.

### 반복 할당과 Live Set

GC 비용에는 새 Garbage와 살아 있는 객체 그래프가 함께 영향을 준다.

```text
반복 Allocation 감소
└─ Collection 주기와 Garbage 양 감소

불필요한 장기 Reference 감소
└─ Mark해야 할 Live Set 감소
```

GC Alloc 0B만 목표로 삼으면 큰 Cache와 Event Reference 문제를 놓칠 수 있다.

---

## 실제 Unity에서는?

### Editor 수치로 Budget을 정하지 않는다

Editor에는 Inspector, Scene View, Console, Asset Database와 Profiler 자체 비용이 섞인다.

```text
Editor에서 원인 후보 탐색
↓
Development Player에서 재현
↓
Release 조건에 가까운 Build에서 최종 확인
```

Target Device의 운영체제와 Graphics Memory 공유 구조도 고려한다.

### 평균보다 Peak를 기록한다

Scene 전환에서는 이전 Scene과 다음 Scene의 Asset이 동시에 존재할 수 있다.

```text
이전 Scene Asset
+
다음 Scene Asset
+
Load 중 임시 Buffer
+
Snapshot과 Profiler Overhead
= Peak Memory
```

전환 완료 후 메모리가 정상이어도 Peak에서 앱이 종료될 수 있다.

### Snapshot 조건을 맞춘다

```text
같은 Build
같은 Device
같은 Scene과 Camera
같은 반복 횟수
같은 Load 완료 상태
```

조건이 다른 Snapshot의 차이를 최적화 결과로 해석하지 않는다.

### 가장 큰 범주부터 처리한다

```text
Texture 800MB
Mesh 200MB
Managed Heap 90MB
Frame GC Alloc 120B
```

메모리 제한이 문제라면 120B 할당보다 Texture 설정을 먼저 확인하는 편이 영향이 크다.

반대로 Memory Budget은 충분하지만 120B가 수천 개 객체에서 매 Frame 발생해 GC Spike를 만든다면 반복 할당이 우선이다.

### Resources.UnloadUnusedAssets를 만능 해제로 사용하지 않는다

사용되지 않는 Asset을 찾고 Unload하는 작업 자체가 큰 비용을 만들 수 있다. 매 Frame 호출할 API가 아니며 남아 있는 참조가 있다면 해당 Asset은 Unused가 아니다.

Scene 전환이나 Loading 화면처럼 수명 경계에서 사용을 검토하고, 먼저 Asset Reference와 Addressables Release를 올바르게 관리한다.

### 품질과 성능을 함께 검증한다

Texture Max Size를 줄이고 Audio를 Streaming으로 바꾼 뒤 메모리 수치만 확인하지 않는다.

```text
Texture 선명도와 Artifact
Audio Decode와 Streaming CPU
Asset Load 시간
Frame Spike
전체 Memory와 Peak
```

최적화가 다른 시스템의 Budget을 넘기지 않았는지 확인한다.

---

## 실무에서 자주 하는 오해

### 메모리가 크면 모두 누수다

현재 Scene에 필요한 Asset, Cache와 Allocator Reserved Space일 수 있다. 반복 시 계속 증가하는 객체와 Reference를 찾아야 누수를 판단할 수 있다.

### GC Alloc 0B가 모든 코드의 목표다

Gameplay Hot Path에는 유용하지만 Loading과 초기화의 작은 할당까지 복잡하게 제거하면 유지보수 비용만 커질 수 있다.

### 모든 반복 생성 객체는 Pool에 넣어야 한다

생성이 드물거나 상태 초기화가 복잡한 객체는 Pool 관리 비용이 더 클 수 있다. Pool은 상주 메모리도 늘린다.

### Destroy를 호출하면 참조도 모두 사라진다

Native Object 파괴와 List, Dictionary, Event가 가진 Managed Reference 정리는 별개다.

### null을 대입하면 Asset이 해제된다

변수 하나의 참조만 제거한다. 다른 Component, Static Cache와 Asset Load System의 Reference가 남아 있을 수 있다.

### GC.Collect는 메모리 최적화 API다

Full Blocking Collection을 요청할 뿐 Garbage 생성과 불필요한 Reference 원인을 해결하지 않는다. 호출 시점에 Spike를 만들 수 있다.

### Reserved Memory는 반드시 즉시 반환해야 한다

재사용을 위한 Allocator 전략일 수 있다. Used, Reserved, System Memory와 플랫폼 제한을 함께 판단한다.

### Texture 파일 크기만 줄이면 Runtime Memory도 같은 비율로 준다

Source 압축 크기와 GPU Runtime Format은 다르다. 해상도, 플랫폼 Format, Mipmap과 Read/Write를 확인해야 한다.

### Editor에서 개선됐으면 최적화가 끝났다

Player의 Runtime, Scripting Backend, Asset Format과 메모리 제한은 다를 수 있다. 실제 Target Device에서 검증해야 한다.

### 한 번 측정해 개선됐으면 충분하다

첫 실행 Cache, 무작위 Gameplay와 비동기 Release가 결과를 바꿀 수 있다. 같은 재현 시나리오를 여러 번 실행해 변화가 안정적인지 확인한다.

---

## 마무리

메모리 최적화의 시작은 코드를 바꾸는 것이 아니라 문제를 정확히 분류하는 것이다.

```text
전체 Memory 제한 문제인가?
GC로 인한 Frame Spike인가?
반복할 때 계속 증가하는가?
전환 순간의 Peak 문제인가?
생성과 파괴의 CPU Spike인가?
```

문제를 분류한 뒤 메모리 영역, 객체 수명과 Reference Chain을 확인한다.

```text
재현 시나리오 정의
↓
Profiler에서 증가 시점과 영역 확인
↓
Snapshot 전후 비교
↓
소유자와 해제 책임 확인
↓
가장 영향이 큰 원인 수정
↓
Memory / CPU / 품질 함께 재측정
```

좋은 메모리 최적화는 숫자를 가장 작게 만드는 것이 아니다. Target Device의 Budget 안에서 Peak를 견디고, Gameplay Frame을 안정적으로 유지하며, Asset과 객체가 설계한 시점에 해제되는 상태를 만드는 것이다.

---

## 핵심 정리

- 메모리 사용량 초과, GC Spike, 누수, Peak Memory와 생성 Spike는 서로 다른 문제다.
- 수정 전에 Managed, Native, Graphics와 Audio 중 어떤 영역이 증가했는지 확인한다.
- GC Alloc 0B보다 호출 빈도, Collection 주기와 실제 Frame 영향을 기준으로 우선순위를 정한다.
- `null`, `Destroy()`, `Dispose()`와 Asset `Release()`는 서로 다른 수명 영역을 처리한다.
- Object Pool과 Cache는 CPU 비용을 줄이지만 상주 메모리와 참조 그래프를 늘릴 수 있다.
- Reserved Memory가 남아 있다는 이유만으로 누수라고 단정하지 않는다.
- 평균 메모리뿐 아니라 Scene 전환과 Asset Load가 겹치는 Peak Memory를 측정한다.
- 같은 Build, Device와 재현 시나리오의 전후 Snapshot을 비교해야 한다.
- Editor는 원인 후보를 찾는 데 사용하고 최종 판단은 Target Player에서 수행한다.
- 최적화 후 Memory뿐 아니라 Frame Time, Load CPU와 화면·음질까지 함께 검증해야 한다.
