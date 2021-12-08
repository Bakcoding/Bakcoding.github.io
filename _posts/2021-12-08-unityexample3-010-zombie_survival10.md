---
title:  "[레트로의 유니티] 좀비서바이벌10 - LivingEntity"
excerpt: "unity3d, retro, example, zombie, event"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, event]

toc: true
toc_sticky: true
 
date: 2021-12-08 
last_modified_at: 2021-12-08
---  

***  

### LivingEntity  

#### OnEnable

```cs
protected virtual void OnEnable() {
    // 사망하지 않은 상태로 시작
    dead = false;
    // 체력을 시작 체력으로 초기화
    health = startingHealth;
}
```

virtual로 선언해서 가상 메서드로 만들어 자식 클래스에서 확장할 수 있도록한다. 그리고 자식만 접근이 허용되도록 접근자를 protected로 사용한다.  

<br>

#### OnDamage()

공격의 기능을 담당한다.  

```cs
public virtual void OnDamage(float damage. Vector3 hitPoint, Vector3 hitNormal) {
    // 데미지만큼 체력 감소
    health -= damage;
    // 체력이 0 이하 && 죽지 않은 상태면 사망 처리
    if (health <= 0 && !dead) {
        Die();
    }
}
```

입력받은 데미지 만큼 현재 체력을 감소시킨다. 그리고 현재 체력이 0보다 작거나 같고 아직 죽은 상태가 아니라면 사망  처리를 실행시킨다.  

<br>

#### RestoreHealth() 

체력을 회복하는 메서드이다.  

```cs
public virtual void RestoreHealth(float newHealth) {
    if (dead) {
        // 이미 사망한 경우 체력회복 불가능
        return;
    }

    // 체력 추가  
    health += newHealth;
}
```

죽은 상태라면 함수를 더 진행시키지 않고 종료시키고 그렇지 않은 경우에만 체력이 추가된다.  

<br>

#### Die()  

죽음을 구현한다.  

```cs
public virtual void Die() {
    // onDeath 이벤트에 등록된 메서드가 있다면 실행  
    if (onDeath != null) {
        onDeath();
    }

    // 사망 상태를 참으로 변경
    dead = true;
}
```

onDeath에 메서드가 하나라도 등록되어 있을 때만 onDeath()가 실행된다. 등록되어 있다면 deat 상태를 참으로 바꾼다.  

