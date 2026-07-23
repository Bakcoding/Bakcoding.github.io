---
title: "[궁금시리즈] 2-9. Object Pool은 왜 GC 최적화의 핵심 기법일까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - CSharp
permalink: /programming/2-9-object-pool-gc/
toc: true
toc_sticky: true
date: 2026-07-23
last_modified_at: 2026-07-23
---

게임을 만들다 보면 다음과 같은 코드를 자주 작성하게 된다.

```cs
void Fire()
{
    Bullet bullet = new Bullet();
}
```

총을 한 번 쏠 때마다 Bullet 객체를 생성한다.
평소에는 문제가 없어 보인다.

하지만 초당 100발, 1000발을 발사한다면 어떨까?

```
new

↓

new

↓

new

↓

GC

↓

new

↓

GC
```

객체 생성과 GC가 계속 반복된다.

이 과정은 CPU에 부담을 주고, 게임에서는 순간적인 프레임 드랍(GC Pause)의 원인이 될 수 있다.
그래서 게임 개발에서는 **필요할 때마다 객체를 생성하는 대신, 미리 만들어 둔 객체를 재사용하는 방식**을 많이 사용한다.

이것이 바로 **Object Pool**이다.

---

## Object Pool이란?

Object Pool은

> 객체를 미리 생성해 두고 필요할 때 꺼내 쓰고, 사용이 끝나면 다시 반환하여 재사용하는 기법이다.

즉, 새로운 객체를 계속 만드는 것이 아니라
기존 객체를 재활용하는 것이다.

---

## 일반적인 객체 생성 방식

예를 들어 총알을 발사한다고 하자.

```cs
void Fire()
{
    Bullet bullet = new Bullet();
}
```

발사할 때마다

```
new Bullet()

↓

Heap 할당

↓

사용

↓

GC
```

가 반복된다.

총알이 많아질수록 GC도 자주 발생한다.

---

## Object Pool 방식

처음 시작할 때

```
Bullet 100개 생성
```
을 해 둔다.

이후에는

```
Pool

↓

Bullet 하나 가져오기

↓

사용

↓

Pool에 반환
```
한다.

새로운 객체는 거의 생성되지 않는다.

---

## 메모리 구조

**일반 방식**

```
Fire

↓

new

↓

Heap 증가

↓

GC

↓

Heap 감소
```

Heap 크기가 계속 변한다.

**Object Pool**

```
처음 생성

↓

Heap 고정

↓

재사용

↓

재사용

↓

재사용
```

Heap이 안정적으로 유지된다.

---

## 간단한 구현

예를 들어

```cs
class BulletPool
{
    private Queue<Bullet> _pool = new();

    public Bullet Get()
    {
        if (_pool.Count > 0)
            return _pool.Dequeue();

        return new Bullet();
    }

    public void Return(Bullet bullet)
    {
        _pool.Enqueue(bullet);
    }
}
```

사용은

```cs
Bullet bullet = pool.Get();

// 사용

pool.Return(bullet);
```

처럼 이루어진다.

---

## Unity에서는?
Unity에서도 Object Pool은 매우 자주 사용된다.

예를 들어

```
Instantiate(prefab);
Destroy(gameObject);
```

를 반복하면

매번

- GameObject 생성
- Component 생성
- 메모리 할당
- GC 대상 생성

이 반복된다.

대신

```
SetActive(true)

↓

사용

↓

SetActive(false)
```

로 재사용하면

Instantiate와 Destroy 호출 횟수를 크게 줄일 수 있다.

---

## Unity 2021부터는?

Unity는 UnityEngine.Pool.ObjectPool<T>
클래스를 제공한다.

즉, 직접 Object Pool을 구현하지 않아도
기본 기능을 사용할 수 있다.

간단한 프로젝트라면 기본 구현만으로도 충분한 경우가 많다.

---

## 언제 사용해야 할까?

다음과 같은 객체는 Object Pool의 대표적인 대상이다.

- 총알(Bullet)
- 몬스터
- 파티클
- 데미지 텍스트
- 이펙트
- UI 팝업
- 네트워크 패킷 객체

즉, **짧은 시간 동안 반복적으로 생성되고 삭제되는 객체**에 적합하다.

---

## 모든 객체를 Pool에 넣어야 할까?

그렇지는 않다.

예를 들어

```cs
Player player = new Player();
```

플레이어는 게임 내내 하나만 존재한다.
Pool을 사용하는 의미가 거의 없다.

반대로

```
Bullet

Enemy

DamageText
```

처럼 매우 자주 생성되는 객체는
Pool 효과가 크다.

---

## Object Pool의 장점
**1. GC 발생 감소**
객체를 재사용하므로
Heap 할당이 줄어든다.

---

**2. 성능 향상**
new와 GC 비용이 감소한다.

---

**3. 프레임 안정성**
GC Pause가 줄어
프레임 드랍이 감소한다.

---

**4. 메모리 사용 예측 가능**
미리 생성한 개수만큼 메모리를 사용하므로
메모리 사용량이 안정적이다.

---

## Object Pool의 단점

장점만 있는 것은 아니다.
 
**메모리를 미리 사용한다.**
100개를 만들어 놓았는데
10개만 사용한다면
90개는 놀고 있다.

---

**관리가 필요하다.**
반환을 잊으면 Pool이 점점 비게 된다.
반대로 같은 객체를 두 번 반환하는 버그도 발생할 수 있다.

---

**초기화가 중요하다.**
객체를 재사용하기 때문에
이전 상태가 남아 있을 수 있다.

예를 들어

```cs
bullet.Damage = 100;
```

을 변경했다면
반환하기 전에

```cs
bullet.Reset();
```

같은 초기화가 필요하다.

---

## Object Pool이 항상 빠를까?

아니다.

Object Pool도 비용이 있다.

다음과 같은 경우에는 굳이 사용할 필요가 없다.

- 한 번만 생성되는 객체
- 생성 비용이 매우 작은 객체
- 생성 횟수가 거의 없는 객체

즉, **생성과 삭제가 반복되는 객체**에서 가장 큰 효과를 얻는다.

---

## 마무리

Object Pool은 객체를 반복해서 생성하고 삭제하는 대신 재사용하여 GC 부담을 줄이는 대표적인 최적화 기법이다.

특히 게임처럼 실시간 성능이 중요한 환경에서는 총알, 파티클, UI 요소 등 반복 생성되는 객체를 Pool로 관리하는 것이 일반적이다.

하지만 모든 객체에 적용하는 것이 정답은 아니다. **생성 빈도와 생성 비용을 고려해 필요한 곳에만 사용하는 것**이 가장 효과적인 최적화 방법이다.

다음 글에서는 **stackalloc과 Span<T>는 왜 등장했을까?**를 알아보며 Heap 할당 자체를 줄이는 최신 메모리 최적화 기법을 살펴보겠다.

---

## 핵심 정리

- Object Pool은 객체를 재사용하는 패턴이다.
- 반복적인 new와 GC를 줄일 수 있다.
- 총알, 파티클, 이펙트처럼 자주 생성되는 객체에 적합하다.
- Unity에서는 SetActive()를 활용한 재사용과 ObjectPool<T>를 지원한다.
- 반환 전 객체 상태를 반드시 초기화해야 한다.
- 모든 객체를 Pool로 관리하는 것은 오히려 비효율적일 수 있다.
