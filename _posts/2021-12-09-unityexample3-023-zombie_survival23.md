---
title:  "[레트로의 유니티] 좀비서바이벌23 - 네트워크 - 좀비"
excerpt: "unity3d, retro, example, zombie, multiplayer, photon"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, multiplayer, photon]

toc: true
toc_sticky: true
 
date: 2021-12-09 
last_modified_at: 2021-12-09
---  

***  

### Enemy 

네비메시 경로 계산과 목표 추적 및 공격하던 기능을 호스트에서만 실행되도록 변경한다.  

<br>

#### Setup

생성되는 적의 능력치를 설정한다. 모든 클라이언트에서 동일한 능력치를 가지게 하려면 모든 클라이언트에서 적의 Setup() 메서드가 실행되어야한다.  

```cs
// 적 AI의 초기 스펙을 결정하는 셋업 메서드
[PunRPC]
public void Setup(float newHealth, float newDamage, float newSpeed, Color skinColor) {
    // 체력 설정
    startingHealth = newHealth;
    health = newHealth;
    // 공격력 설정
    damage = newDamage;
    // 내비메쉬 에이전트의 이동 속도 설정
    pathFinder.speed = newSpeed;
    // 렌더러가 사용중인 머테리얼의 컬러를 변경, 외형 색이 변함
    enemyRenderer.material.color = skinColor;
}
```

Setup() 메서드를 PunRPC로 선언하여 RPC로 메서드를 호출할 수 있도록 한다.  

<br>

#### OnDamage()

```cs
// 데미지를 입었을때 실행할 처리
[PunRPC]
public override void OnDamage(float damage, Vector3 hitPoint, Vector3 hitNormal) {
    // 아직 사망하지 않은 경우에만 피격 효과 재생
    if (!dead)
    {
        // 공격 받은 지점과 방향으로 파티클 효과를 재생
        hitEffect.transform.position = hitPoint;
        hitEffect.transform.rotation = Quaternion.LookRotation(hitNormal);
        hitEffect.Play();

        // 피격 효과음 재생
        enemyAudioPlayer.PlayOneShot(hitSound);
    }

    // LivingEntity의 OnDamage()를 실행하여 데미지 적용
    base.OnDamage(damage, hitPoint, hitNormal);
}
```

LivingEntity 스크립트에서 OnDamage() 메서드는 PunRPC로 선언되었다. Enemy 스크립트에서도 오버라이드해서 사용하는 것이기 때문에 마찬가지로 PunRPC 선언을 해주어야 제대로 사용할 수 있다.  

#### Start()

Start() 메서드에서는 Zombie 게임 오브젝트에 추가된 네비메시 에이전트가 대상을 찾아 경로를 계산하여 이동하게 하는 UpdatePath() 코루틴을 실행한다.

모든 클라이언트에서 독자적으로 네비메시 에이전트가 동작한다면 계산한 경로가 조금씩 차이가 날 수 있어 AI가 서로 다른 경로로 이동할 수 있다.  

따라서 모두 동일한 경로로 움직이게 만들기 위해서 경로의 계산과 이동은 호스트에서만 실행하고 이를 각 클라이언트로 정보를 공유하도록한다. 

```cs
private void Start() {
    // 호스트가 아니라면 AI의 추적 루틴을 실행하지 않음
    if (!PhotonNetwork.IsMasterClient)
    {
        return;
    }

    // 게임 오브젝트 활성화와 동시에 AI의 추적 루틴 시작
    StartCoroutine(UpdatePath());
}
```
호스트가 아니면 경로계산을 못하게 한다.  

Zombie 오브젝트는 호스트에서 먼저 생성된 다음 다른 클라이언트에서 복제 생성되기 때문에 호스트의 Zombie 게임 오브젝트는 로컬, 다른 클라이언트의 Zombie 게임 오브젝트는 리모트가 된다.  

따라서 호스트의 Zombie 게임 오브젝트의 위치를 다른 클라이언트의 Zombie 게임 오브젝트가 받아서 적용하는 과정은 Photon View 컴포넌트에 의해 자동으로 이루어진다.  

<br>

#### Update()

Zombie 게임 오브젝트의 애니메이션의 처리는 호스트에서만 처리되도록한다.

```cs
private void Update() {
    // 호스트가 아니라면 애니메이션의 파라미터를 직접 갱신하지 않음
    // 호스트가 파라미터를 갱신하면 클라이언트들에게 자동으로 전달되기 때문.
    if (!PhotonNetwork.IsMasterClient)
    {
        return;
    }

    // 추적 대상의 존재 여부에 따라 다른 애니메이션을 재생
    enemyAnimator.SetBool("HasTarget", hasTarget);
}
```
Photon Animator View 컴포넌트에 의해 동기화되어 클라이언트에서도 같은 애니메이션이 재생되어 문제가 없다. 

<br>

#### OnTriggerStay()  

Enemy 스크립트의 OnTriggerStay() 메서드는 트리거 콜라이더를 사용해 감지된 상대방 게임 오브젝트가 추적 대상인 경우 해당 게임 오브젝트를 공격하는 처리를 한다. 

OnDamage는 RPC로 모든 클라이언트에게 전파되기 때문에 Enemy의 공격은 호스트인 경우에만 실행되도록 한다.  

```cs
private void OnTriggerStay(Collider other) {
    // 호스트가 아니라면 공격 실행 불가
    if (!PhotonNetwork.IsMasterClient)
    {
        return;
    }

    // 자신이 사망하지 않았으며,
    // 최근 공격 시점에서 timeBetAttack 이상 시간이 지났다면 공격 가능
    if (!dead && Time.time >= lastAttackTime + timeBetAttack)
    {
        // 상대방으로부터 LivingEntity 타입을 가져오기 시도
        LivingEntity attackTarget
            = other.GetComponent<LivingEntity>();

        // 상대방의 LivingEntity가 자신의 추적 대상이라면 공격 실행
        if (attackTarget != null && attackTarget == targetEntity)
        {
            // 최근 공격 시간을 갱신
            lastAttackTime = Time.time;

            // 상대방의 피격 위치와 피격 방향을 근삿값으로 계산
            Vector3 hitPoint = other.ClosestPoint(transform.position);
            Vector3 hitNormal = transform.position - other.transform.position;

            // 공격 실행
            attackTarget.OnDamage(damage, hitPoint, hitNormal);
        }
    }
}
```

