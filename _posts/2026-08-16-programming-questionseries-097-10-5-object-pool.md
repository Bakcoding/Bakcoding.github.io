---
title: "[궁금시리즈] 10-5. Object Pool은 언제 사용해야 할까?"
excerpt: "C#"
categories:
  - CSharp
series: question-series
tags:
  - CSharp
permalink: /programming/10-5-object-pool/
toc: true
toc_sticky: true
date: 2026-08-16 12:00:25 +0900
last_modified_at: 2026-08-16 12:00:25 +0900
---

## 들어가며

총알, Enemy와 Particle을 사용할 때마다 생성하고 파괴하는 코드는 단순하다.

```cs
GameObject projectile = Instantiate(
    projectilePrefab,
    position,
    rotation);

Destroy(projectile, 3f);
```

하지만 짧은 시간에 같은 종류의 객체를 반복해서 만들면 다음 작업도 반복된다.

```text
GameObject와 Component 생성
Transform과 내부 Native Object 준비
Awake / OnEnable 실행
관련 Managed Allocation
Destroy와 수명 정리
```

Object Pool은 사용이 끝난 객체를 파괴하지 않고 보관했다가 다시 꺼내 쓰는 구조다.

```text
생성 → 사용 → 파괴 → 생성

대신

Pool에서 꺼냄 → 사용 → 상태 초기화 → Pool에 반환
```

생성과 파괴 비용은 줄일 수 있지만 객체를 계속 보관하므로 상주 메모리가 늘고 상태 초기화 책임이 생긴다.

반복 생성되는 모든 객체에 Pool을 적용하는 것이 아니라 생성 비용, 사용 빈도, 동시 사용량과 상태 복잡도를 기준으로 선택해야 한다.

---

## 개념 설명

### Object Pool의 구성

Pool은 크게 두 상태의 객체를 관리한다.

```text
Active
└─ 현재 게임에서 사용 중인 객체

Inactive
└─ 사용이 끝나 Pool에서 대기 중인 객체
```

`Get()`은 대기 객체를 꺼내 활성 상태로 만든다. 대기 객체가 없으면 새 객체를 만들거나 요청을 거절한다.

`Release()`는 사용을 끝낸 객체를 초기화해 대기 상태로 돌려보낸다.

### Pool이 줄이는 비용

Pool은 다음과 같은 반복 비용을 줄이는 데 사용한다.

- `Instantiate()`와 `Destroy()` 호출
- Managed 객체와 Native Object 생성
- 반복적인 Component 초기화
- 짧게 사는 객체로 인한 GC Alloc
- 복잡한 Prefab 생성 시 발생하는 CPU Spike

이미 생성된 객체를 재사용하므로 플레이 중 비용을 Loading이나 초기화 구간으로 옮길 수 있다.

### Pool이 추가하는 비용

Pool 자체도 비용이 있다.

- 사용하지 않는 객체의 상주 메모리
- 반환 시 상태 초기화 코드
- 중복 반환과 미반환 추적
- Scene과 Asset 수명 관리
- 최대 크기와 확장 정책 관리

객체 생성이 드물거나 수명이 길다면 Pool 관리 비용이 더 클 수 있다.

### 적합한 대상

다음 조건이 여러 개 겹치면 Pool을 검토할 수 있다.

```text
같은 타입을 자주 생성하고 파괴함
동시에 사용하는 최대 개수를 예측할 수 있음
생성 비용이 Profiler에서 확인됨
객체 상태를 안전하게 초기화할 수 있음
사용 구간과 반환 시점이 명확함
```

Projectile, Damage Text, Particle Effect, 반복되는 UI Item과 일부 Enemy가 대표적인 대상이다.

---

## 코드 예제

Unity의 `UnityEngine.Pool.ObjectPool<T>`로 Projectile Pool을 구성한다.

```cs
using UnityEngine;
using UnityEngine.Pool;

public sealed class ProjectilePool : MonoBehaviour
{
    [SerializeField]
    private Projectile projectilePrefab = null!;

    [SerializeField]
    private int defaultCapacity = 32;

    [SerializeField]
    private int maxSize = 128;

    private IObjectPool<Projectile> pool = null!;

    private void Awake()
    {
        pool = new ObjectPool<Projectile>(
            CreateProjectile,
            OnGetProjectile,
            OnReleaseProjectile,
            OnDestroyProjectile,
            collectionCheck: true,
            defaultCapacity,
            maxSize);
    }
}
```

각 Callback은 객체 수명 단계의 책임을 가진다.

```cs
private Projectile CreateProjectile()
{
    Projectile projectile = Instantiate(
        projectilePrefab,
        transform);

    projectile.SetPool(pool);
    projectile.gameObject.SetActive(false);

    return projectile;
}
```

```cs
private static void OnGetProjectile(Projectile projectile)
{
    projectile.gameObject.SetActive(true);
}

private static void OnReleaseProjectile(Projectile projectile)
{
    projectile.ResetState();
    projectile.gameObject.SetActive(false);
}

private static void OnDestroyProjectile(Projectile projectile)
{
    Destroy(projectile.gameObject);
}
```

Pool이 비어 있을 때 `Get()`을 호출하면 `CreateProjectile()`로 새 객체를 만든다. `maxSize`를 넘은 상태에서 객체가 반환되면 Pool에 보관하지 않고 Destroy Callback을 호출한다.

### 발사와 반환

```cs
public Projectile Spawn(
    Vector3 position,
    Vector3 direction,
    float damage)
{
    Projectile projectile = pool.Get();
    projectile.Launch(position, direction, damage);

    return projectile;
}
```

```cs
public sealed class Projectile : MonoBehaviour
{
    private IObjectPool<Projectile> pool = null!;
    private Vector3 direction;
    private float damage;
    private float remainingLife;
    private bool isReleased;

    public void SetPool(IObjectPool<Projectile> value)
    {
        pool = value;
    }

    public void Launch(
        Vector3 position,
        Vector3 newDirection,
        float newDamage)
    {
        transform.position = position;
        direction = newDirection.normalized;
        damage = newDamage;
        remainingLife = 3f;
        isReleased = false;
    }
}
```

```cs
private void Update()
{
    transform.position +=
        direction * (speed * Time.deltaTime);

    remainingLife -= Time.deltaTime;

    if (remainingLife <= 0f)
    {
        Release();
    }
}

private void OnTriggerEnter(Collider other)
{
    ApplyDamage(other, damage);
    Release();
}
```

수명 만료와 충돌이 같은 Frame에 발생하면 두 경로가 모두 반환을 요청할 수 있다. 중복 반환을 막는다.

```cs
private void Release()
{
    if (isReleased)
    {
        return;
    }

    isReleased = true;
    pool.Release(this);
}
```

### 상태 초기화

```cs
public void ResetState()
{
    direction = Vector3.zero;
    damage = 0f;
    remainingLife = 0f;

    trailRenderer.Clear();
    rigidbody.linearVelocity = Vector3.zero;
    rigidbody.angularVelocity = Vector3.zero;
}
```

위치만 바꾸고 다시 사용하면 이전 Trail, Velocity, Timer와 충돌 상태가 다음 사용자에게 이어질 수 있다.

Event를 등록하는 객체라면 반환 시 구독도 정리한다.

```cs
public void ResetState()
{
    onHit = null;
    hitTargets.Clear();
    cancellationTokenSource?.Cancel();
    cancellationTokenSource?.Dispose();
    cancellationTokenSource = null;
}
```

### Pool 정리

Pool 소유자의 수명이 끝날 때 대기 객체를 제거할 수 있다.

```cs
private void OnDestroy()
{
    pool?.Clear();
}
```

`Clear()`는 Pool에 반환되어 대기 중인 객체에 Destroy Callback을 실행한다. 아직 사용 중인 Active 객체의 반환과 수명은 별도로 관리해야 한다.

---

## 내부 동작

### ObjectPool의 저장 방식

Unity의 `ObjectPool<T>`는 Stack 기반 `IObjectPool<T>` 구현이다.

```text
Release A → Push
Release B → Push

Stack
┌───┐
│ B │ ← 다음 Get
├───┤
│ A │
└───┘
```

최근 반환된 객체를 먼저 다시 사용하므로 해당 객체의 데이터가 CPU Cache에 남아 있을 가능성이 있지만 실제 효과는 객체 구조와 플랫폼에 따라 측정해야 한다.

### defaultCapacity와 Prewarm은 다르다

```cs
new ObjectPool<Projectile>(
    createFunc,
    actionOnGet,
    actionOnRelease,
    actionOnDestroy,
    collectionCheck: true,
    defaultCapacity: 32,
    maxSize: 128);
```

`defaultCapacity`는 Pool의 내부 Stack이 준비하는 초기 저장 Capacity다. Projectile 32개를 미리 생성한다는 뜻이 아니다.

미리 객체를 만들려면 직접 `Get()`과 `Release()` 흐름을 실행하는 Prewarm 단계가 필요하다.

```cs
public void Prewarm(int count)
{
    List<Projectile> temporary = new(count);

    for (int i = 0; i < count; i++)
    {
        temporary.Add(pool.Get());
    }

    foreach (Projectile projectile in temporary)
    {
        pool.Release(projectile);
    }
}
```

한 객체를 꺼낸 즉시 반환하는 방식은 같은 객체만 반복해서 꺼내므로 원하는 개수만큼 생성되지 않는다.

### maxSize의 의미

`maxSize`는 Pool이 보관하는 Inactive 객체 수의 상한을 정한다.

```text
Inactive Count < maxSize
└─ 반환 객체 보관

Inactive Count == maxSize
└─ 추가 반환 객체에 Destroy Callback 실행
```

동시에 Active 상태로 빌려 간 객체 수를 강제로 제한하는 값은 아니다. 요청이 계속되면 Pool은 `maxSize`보다 많은 객체를 생성할 수 있고, 나중에 반환될 때 초과분을 파괴한다.

### collectionCheck

`collectionCheck`를 활성화하면 이미 Pool에 들어 있는 객체를 다시 반환할 때 예외를 발생시켜 중복 반환을 찾는다.

Unity의 Collection Check는 Editor에서만 수행된다. Player에서도 안전을 보장하려면 객체 상태나 별도 소유권 검사로 중복 반환 경로를 막아야 한다.

### Get과 Release Callback 순서

Pool은 수명 Hook을 통해 상태 전환을 한 위치에 모은다.

```text
Get
대기 객체 Pop 또는 새 객체 Create
↓
actionOnGet
↓
사용자에게 반환

Release
actionOnRelease
↓
Pool 저장 또는 maxSize 초과 시 actionOnDestroy
```

Reset 책임이 여러 호출부에 흩어지지 않도록 Release Callback을 공통 경계로 사용한다.

---

## 실제 Unity에서는?

### 적용 전에 Instantiate 비용을 측정한다

Prefab에 Component가 많고 초기화가 복잡할수록 Instantiate Spike가 커질 수 있다. 반대로 단순한 C# 데이터 객체를 드물게 만드는 경우에는 Pool 효과가 작다.

Profiler에서 다음 항목을 확인한다.

```text
Instantiate / Destroy 호출 횟수
호출당 CPU 시간
관련 GC Alloc
동시 Active 객체 수
Memory Peak
```

### 동시 사용량을 기록한다

Pool 크기는 평균보다 Peak Concurrent Count를 기준으로 정한다.

```text
평균 Projectile 12개
Boss Pattern Peak 76개
```

평균만 보고 16개를 Prewarm하면 Boss 전투 중 새 생성이 몰릴 수 있다. 최대값만 보고 수백 개를 항상 보관하면 일반 구간의 상주 메모리가 커진다.

`CountActive`, `CountInactive`와 `CountAll`을 개발 빌드에서 기록해 실제 분포를 확인할 수 있다.

### Prewarm 위치를 선택한다

Prewarm은 생성 비용을 없애지 않고 앞당긴다.

```text
전투 중 Instantiate Spike
↓
Loading Screen에서 Prewarm
↓
전투 중 재사용
```

한 Frame에 모두 만들면 Loading 화면도 끊길 수 있다. 큰 Pool은 여러 Frame에 나누어 준비하거나 실제 Asset 로드 흐름과 함께 처리한다.

### Scene과 Pool의 소유권을 맞춘다

Scene 전용 Prefab을 Global Pool이 계속 보관하면 Scene을 나간 뒤에도 관련 Asset 참조가 남을 수 있다.

```text
Scene Pool
└─ Scene 종료 시 함께 Clear

Global Pool
└─ 여러 Scene에서 공통으로 사용하는 객체만 보관
```

Pool의 수명은 빌린 객체와 Prefab Asset의 수명보다 명확해야 한다.

### Particle과 Coroutine을 정리한다

GameObject를 비활성화하면 일부 Unity 동작은 멈추지만 모든 외부 작업이 자동으로 취소되는 것은 아니다.

반환 시 다음 상태를 확인한다.

```text
Particle과 Trail
Rigidbody 속도
Animator 상태
Coroutine과 Async 작업
Event 구독
Navigation 상태
충돌한 대상 목록
```

재사용 버그는 객체 생성 버그보다 이전 사용자의 상태가 남아 간헐적으로 나타나는 경우가 많다.

---

## 실무에서 자주 하는 오해

### Pool을 사용하면 메모리가 줄어든다

반복 할당과 생성 비용은 줄지만 대기 객체를 계속 보관하므로 상주 메모리는 늘 수 있다. Pool은 메모리를 없애는 구조가 아니라 재사용하는 구조다.

### defaultCapacity만 지정하면 객체가 미리 생성된다

`defaultCapacity`는 내부 저장 Collection의 초기 Capacity다. 실제 객체 Prewarm은 별도로 수행해야 한다.

### maxSize는 동시에 생성 가능한 객체 수다

`maxSize`는 반환된 Inactive 객체를 보관하는 상한이다. Pool이 비어 있는 동안 Get 요청이 계속되면 그보다 많은 Active 객체가 생성될 수 있다.

### SetActive(false)만 호출하면 초기화가 끝난다

필드, Collection, Trail, Rigidbody, Event와 비동기 작업 상태는 남을 수 있다. 반환 계약에 모든 재사용 상태를 포함해야 한다.

### Pool에 반환했으니 다른 참조를 계속 사용해도 된다

반환 순간 소유권은 Pool로 이동한다. 이전 사용자가 참조를 보관하고 수정하면 이미 다른 요청에 재사용된 객체를 건드릴 수 있다.

### collectionCheck가 Player의 중복 반환도 막는다

Unity의 Collection Check는 Editor에서만 검사한다. Player의 수명 안전성은 별도 상태와 호출 구조로 보장해야 한다.

### 모든 객체를 최대 개수만큼 미리 만들면 안전하다

초기 Loading 시간과 Peak Memory가 커진다. 자주 사용하는 기준 개수만 준비하고 초과 시 확장할지, 거절할지, 오래된 객체를 재사용할지 정책을 정해야 한다.

### Pool은 빨라 보이므로 측정할 필요가 없다

복잡한 Reset, 대규모 Prewarm과 비활성 객체의 Update 구조가 새로운 비용을 만들 수 있다. 적용 전후의 Frame Time과 Memory를 비교해야 한다.

---

## 마무리

Object Pool은 같은 객체의 생성과 파괴가 자주 반복될 때 그 비용을 초기화와 재사용으로 바꾸는 구조다.

```text
반복 생성 비용 확인
↓
동시 사용량 측정
↓
Get / Release 계약 정의
↓
상태 초기화 목록 작성
↓
Prewarm과 maxSize 결정
↓
Scene 수명과 정리 연결
↓
적용 전후 재측정
```

Pool의 핵심은 Stack이나 Queue 구현이 아니라 소유권이다. `Get()` 이후에는 호출자가 객체를 소유하고, `Release()` 이후에는 Pool이 소유한다. 이 경계가 명확해야 중복 반환과 반환 후 접근을 막을 수 있다.

생성 비용이 작고 호출이 드문 객체에는 단순한 생성과 파괴가 더 적합하다. Pool을 적용할 때는 CPU Spike 감소와 상주 메모리 증가 사이의 균형을 프로젝트의 실제 사용량으로 결정해야 한다.

---

## 핵심 정리

- Object Pool은 사용이 끝난 객체를 보관했다가 다시 꺼내 생성과 파괴 반복을 줄인다.
- 생성 비용이 크고 같은 타입을 자주 사용하며 반환 시점이 명확한 객체에 적합하다.
- Pool은 반복 할당을 줄이는 대신 Inactive 객체의 상주 메모리를 사용한다.
- `actionOnGet`, `actionOnRelease`와 `actionOnDestroy`에 상태 전환 책임을 모을 수 있다.
- `defaultCapacity`는 내부 Stack의 초기 Capacity이며 객체 Prewarm 개수가 아니다.
- `maxSize`는 Inactive 객체 보관 상한이며 동시에 생성 가능한 Active 객체 수 제한이 아니다.
- Unity의 `collectionCheck`는 Editor에서 중복 반환을 찾지만 Player 안전성은 별도로 구성해야 한다.
- 반환 시 Physics, Particle, Event, Coroutine과 이전 사용 데이터까지 초기화해야 한다.
- Pool의 Scene 수명과 Prefab Asset의 수명을 맞춰 불필요한 참조가 남지 않게 해야 한다.
- 적용 전후의 Instantiate 시간, GC Alloc, Peak 동시 사용량과 전체 Memory를 비교해야 한다.
