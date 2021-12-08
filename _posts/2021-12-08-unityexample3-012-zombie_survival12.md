---
title:  "[레트로의 유니티] 좀비서바이벌12 - 에너미"
excerpt: "unity3d, retro, example, zombie, nav"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, nav]

toc: true
toc_sticky: true
 
date: 2021-12-08 
last_modified_at: 2021-12-08
---  

***  

### 네비게이션

한 위치에서 다른 위치로서의 경로를 계산하고 실시간으로 장애물을 피하여 이동하는 인공지능을 만들 수 있도록 유니티에서 제공하는 기능이다.  

이 기능에서 사용되는 오브젝트는 크게 4가지이다. 

* NavMesh  
    
    에이전트가 걸어 다닐 수 있는 표면  

* NavMesh Agent 

    네비메시 위에서 경로를 계산하고 이동하는 캐릭터 또는 컴포넌트

* NavMesh Obstacle 

    에이전트의 경로를 막는 장애물  

* Off Mesh Link 

    끊어진 네비메시 영역 사이를 잇는 연결 지점

    (뛰어넘을 수 있는 울타리나 타고 올라갈 수 있는 담벼락을 구현하는데 사용)

<br>

#### 빌드  

네비메시는 게임 월드에서 에이전트가 돌아다닐 수 있는 표면이다. 에이전트가 경로를 계싼하고 이동하는 AI를 만들기 위해서는 기본적으로 네비메시가 구성되어있어야한다.  

이 네비메시는 정적 오브젝트를 대상으로 생성된다. 실시간으로 플레이 도중에 생성할 수 없기 때문에 미리 구워주는 과정이 필요하다.  

* 네비메시 굽기  

    Window > AI > Navigation  

    Bake 탭을 선택한다.  

    Agent Radius : 0.4

    Agent Height : 1.8

    Bake 클릭해서 굽기 시작한다.  


<br>

### 좀비 오브젝트

준비된 네비메시 위를 돌아다닐 AI 좀비를 만든다.  

#### 오브젝트 추가 

* Models > Zombie Hierarchy 창으로 드래그앤드롭  

* Zombie 오브젝트 위치 -2, 0, 0

* 좀비 오브젝트의 

    Animator > Controller > Zombie Animator 할당

    Animator 옵션에서 Apply Root Motion 체크 해제

<br>

#### 콜라이더 추가  

* Capsule Collider

    Zombie > Add Component > Physics > Capsule Collider

    Center : 0, 0.75, 0

    Radius : 0.2

    Height : 1.5

* Box Collider 

    Zombie > Add Component > Physics > Box Collider

    Is Trigger 체크

    Center : 0, 1, 0.25

    Size : 0.5, 0.5, 0.5
    
<br>

캡슐 콜라이더는 좀비의 물리적인 표면 역할을 하고 박스 콜라이더는 좀비의 공격 범위로 사용한다.  

#### 오디오 소스 추가  

* Add Component > Audio > Audio Source  

    Play On Awake 체크 해제 

<br>

#### 인공지능 추가하기  

* Nav Mesh Agent 추가  

    Add Component > Navigation > Nav Mesh Agent

* Enemy 스크립트 추가  

    Assets > Scripts > Enemy 좀비 오브젝트에 드래그앤드롭


<br>

#### 피탄 효과 추가하기

Prefabs > BloodSprayPrefab 을 좀비 오브젝트에 추가해준다.  

<br>

### 스크립트  

#### Awake() 

```cs
private void Awake() {
        // 초기화
        // 게임 오브젝트로부터 사용할 컴포넌트 가져오기
        pathFinder = GetComponent<NavMeshAgent>();
        enemyAnimator = GetComponent<Animator>();
        enemyAudioPlayer = GetComponent<AudioSource>();

        // 렌더러 컴포넌트는 자식 게임 오브젝트에 있으므로
        // GetComponentInChildren() 메서드 사용
        enemyRenderer = GetComponentInChildren<Renderer>();
    }
```

좀비의 외형을 그리는 렌더러 컴포넌트는 Zombie 오브젝트 자식인 Zombie_Cylinder 오브젝트에 추가 되어있기 때문에 렌더러 컴포넌트는 GetComponentInChildren() 메서드를 사용해 찾아온다.  

<br>

#### Setup()

```cs
// 적 AI의 초기 스펙을 결정하는 셋업 메서드
public void Setup(float newHealth, float newDamage, float newSpeed, Color skinColor) {
    // 체력 설정
    startingHealth = newHealth;
    health = newHealth;
    // 공격력 설정
    damage = newDamage;

    // 네비메시 에이전트의 이동 속도 설정
    pathFinder.speed = newSpeed;
    // 렌더러가 사용 중인 머티리얼의 컬러를 변경, 외형 색이 변함
    enemyRenderer.material.color = skinColor;
}
```

입력받은 체력과 공격력을 사용해 적의 체력과 공격력으로 사용한다.  

네비메시 컴포넌트에 접근해서 속도를 조절한다.

모델의 외형을 그릴 때 사용하는 머티리얼은 material 필드를 사용해 접근할 수 있다. 색상을 바꾸려면 material.color로 접근한다. 

<br>

#### Start()

```cs
private void Start() {
        // 게임 오브젝트 활성화와 동시에 AI의 추적 루틴 시작
        StartCoroutine(UpdatePath());
    }
```

경로를 갱신하기 위해 코루틴을 사용한다.

<br>

#### Update()

```cs
private void Update() {
        // 추적 대상의 존재 여부에 따라 다른 애니메이션을 재생
        enemyAnimator.SetBool("HasTarget", hasTarget);
    }
```

애니메이터의 HasTarget 파라미터에 hasTarget 프로퍼티의 값을 할당하여 추적 대상의 존재 여부에 따라 알맞은 애니메이션이 재생되도록한다.

<br>

#### UpdatePath()

```cs
private IEnumerator UpdatePath() {
        // 살아있는 동안 무한 루프
        while (!dead)
        {
            if (hasTarget)
            {
                // 추적 대상 존재 : 경로를 갱신하고 AI 이동을 계속 진행
                pathFinder.isStopped = false;
                pathFinder.SetDestination(targetEntity.transform.position);
            }
            else
            {
                // 추적 대상 없음 : AI 이동 중지
                pathFinder.isStopped = true;

                // 20유닛의 반지름을 가진 가상의 구를 그렸을 때 구와 겹치는 모든 콜라이더를 가져옴
                // 단, whatIsTarget 레이어를 가진 콜라이더만 가져오도록 필터링
                Collider[] collider = Physics.OverlapSphere(transform.position, 20f, whatIsTarget);

                // 모든 콜라이더를 순회하면서 살아 있는 LivingEntity 찾기
                for (int i = 0; i < collider.Length; i++)
                {
                    // 콜라이더로부터 LivingEntity 컴포넌트 가져오기
                    LivingEntity livingEntity = collider[i].GetComponent<LivingEntity>();
                    
                    // LivingEntity 컴포넌트가 존재하며, 해당 LivingEntity가 살아 있다면
                    if (livingEntity != null && !livingEntity.dead)
                    {
                        // 추적 대상을 해당 LivingEntity로 설정
                        targetEntity = livingEntity;

                        // for 문 루프 즉시 정지
                        break;
                    }
                }
            }
            // 0.25초 주기로 처리 반복
            yield return new WaitForSeconds(0.25f);
        }
    }
```

추적할 대상의 갱신된 위치를 일정 주기로 파악하고 인공지능의 목적지를 재설정하는 코루틴 메서드이다.  

지속적인 경로 갱신을 위해 UpdatePath()는 AI가 살아있고, 추적할 대상이 존재하는 동안 영원히 실행되는 무한 루프로 만든다.  

일반적으로 무한 루프는 프로그램을 망가뜨리는 요인이지만 코루틴을 사용하면 루프 회차 사이에 적절한 휴식 시간을 삽입하여 에러 없는 무한 루프를 구현할 수 있다.

<br>

#### OnDamage()

```cs
// 데미지를 입었을때 실행할 처리
public override void OnDamage(float damage, Vector3 hitPoint, Vector3 hitNormal) {
    // 아직 사망하지 않은 경우에만 피격 효과 재생
    if (!dead)
    {
        // 공격받은 지점과 방향으로 파티클 효과 재생
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

사망을 먼저 판단한 다음 살아있는 경우에만 코드를 진행한다. 

파티클 효과와 피격 효과음을 재생시킨다. 파티클 효과의 경우 공격이 날아온 방향을 바라보는 방향으로 회전시킨 다음 재생시킨다.  

효과의 재생이 끝난 다음에 데미지를 실제로 적용하는 메서드를 실행시킨다.  

<br>

#### Die()

```cs
// 사망 처리
public override void Die() {
    // LivingEntity의 Die()를 실행하여 기본 사망 처리 실행
    base.Die();

    // 다른 AI를 방해하지 않도록 자신의 모든 콜라이더를 비활성화
    Collider[] enemyColliders = GetComponents<Collider>();
    for (int i = 0; i < enemyColliders.Length; i++)
    {
        enemyColliders[i].enabled = false;
    }

    // AI 추적을 중지하고 네비메시 컴포넌트 비활성화
    pathFinder.isStopped = true;
    pathFinder.enabled = false;

    // 사망 애니메이션 재생
    enemyAnimator.SetTrigger("Die");
    // 사망 효과음 재생
    enemyAudioPlayer.PlayOneShot(deathSound);
}
```

사망 메서드이다. 실행되자마자 우선 사망처리를 실행시킨다.  

그다음 자신의 오브젝트에 추가된 모든 콜라이더 컴포넌트를 찾아 비활성화하여 사망한 적 AI의 시체에 남은 콜라이더가 다른 AI와 플레이어 캐릭터의 이동을 방해할 경우를 방지한다.  

GetComponents() 메서드를 사용한 이유는 좀비 오브젝트가 두 개의 콜라이더를 사용했기 때문이다.

pathFinder를 완전히 비활성화 시킨 이유는 사망한 이후 다른 에이전트의 경로 계산에 포함되어 시체를 넘어가지 못하고 피해가는 문제를 예방하기 위해서이다.

<br>

#### OnTriggerStay()

```cs
private void OnTriggerStay(Collider other) {
        // 자신이 사망하지 않았으며,
        // 최근 공격 시점에서 timeBetAttack 이상 시간이 지났다면 공격 가능
        if (!dead && Time.time >= lastAttackTime + timeBetAttack)
        {
            // 상대방의 LivingEntity 타입 가져오기 시도
            LivingEntity attackTarget = other.GetComponent<LivingEntity>();

            // 상대방의 LivingEntity가 자신의 추적 대상이라면 공격 실행
            if (attackTarget != null && attackTarget == targetEntity)
            {
                // 최근 공격 시간 갱신
                lastAttackTime = Time.time;

                // 상대방의 피격 위치와 피격 방향을 근사값으로 계산
                Vector3 hitPoint = other.ClosestPoint(transform.position);
                Vector3 hitNormal = transform.position - other.transform.position;

                // 공격 실행
                attackTarget.OnDamage(damage, hitPoint, hitNormal);
            }
        }        
        // 트리거 충돌한 상대방 게임 오브젝트가 추적 대상이라면 공격 실행   
    }
```

<br>

### 컴포넌트 설정

* Player Character 의 레이어를 Player로 변경

    No, this object only 선택

* Enemy  

    * What Is Target 레이어 마스크에 Player 등록

    * Hit Effect 필드에 좀비 오브젝트의 자식인 BloodSprayEffect 할당

    * Death Sound 필드에 Zombie Die 오디오 클립 할당

    * Hit Sound 필드에 Zombie Damage 오디오 클립 할당


<br>

### 좀비 프리팹

지금 까지 설정한 좀비 오브젝트를 Prefabs 폴더로 드래그앤드롭해서 프리팹으로 만들어주고 Hierarchy 창에 있는 오브젝트는 지워준다.  

