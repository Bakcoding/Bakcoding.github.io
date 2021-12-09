---
title:  "[레트로의 유니티] 좀비서바이벌21 - 네트워크 - 플레이어"
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

### 메인 씬

기존 프로젝트의 게임 오브젝트와 스크립트를 멀티플레이어로 포팅한다.  

포팅 과정에서 Zombie 프로젝트의 스크립트 대부분은 멀티플레이어용으로 다시 작성하게 된다.  

<br>

#### 네트워크 플레이어 캐릭터 준비

싱글 플레이어로 만들어 졌던 각종 게임 오브젝트를 재구성한다.  

* Main 씬 

  Project > Scenes > Main 씬을 연다.  

  Prefabs > Player Character 프리팹을 씬에 추가해준다.


**Player Character**  

추가된 컴포넌트를 확인한다.  

* Camera Setup

  시네머신 가상 카메라가 로컬 플레이어만 추적하도록 설정한다. 멀티플레이어가 되면 한 씬에 Player Character가 두 개 이상이 존재할 수 있기 때문에 Camera Setup을 통해서 로컬 게임 오브젝트인지 검사한다.  

* Photon View

  네트워크를 통해 동기화될 모든 게임 오브젝트는 Photon View 컴포넌트를 가져야 한다.  

  게임 오브젝트가 네트워크상에서 구별 가능하도록 식별자인 View ID를 부여한다. 또는 Observed Components 리스트에 등록된 컴포넌트들의 변화와 수치를 관측하고 네트워크를 넘어서 다른 클라이언트에 전달할 수 있다. 

  즉 로컬과 리모트 구분이 가능해져 다른 클라이언트의 분신에 관측된 수치를 전달하고 동기화할 수 있다. 

  Observed Components 필드에 관측할 컴포넌트를 할당할 수 있으며 이 때 컴포넌트는 IPunObservable 인터페이스를 상속한 컴포넌트만 관측할 수 있다.  

* Photon Transform View  

  자신의 게임 오브젝트에 추가된 트랜스폼 컴포넌트 값의 변화를 측정하고 Photon View 컴포넌트를 사용해 동기화한다.  

  * Synchronize Options

    동기화 옵션

    Position : 위치

    Rotation : 회전

    Scale : 크기

  관측을 통해서 동기화되기 때문에 Photon View 컴포넌트가 반드시 필요하다.  

* Photon Animator View 

  애니메이터 컴포넌트의 파라미터를 동기화하여 서로 같은 애니메이션을 재생하도록 한다.  

  로컬일 때는 자신의 애니메이터 컴포넌트의 파라미터를 관측하고 Photon View 컴포넌트를 사용해 다른 클라이언트에 있는 자신의 리모트에 전달한다.  

  리모트일 때는 네트워크를 통해 로컬이 건넨 수치들을 받아 자신의 애니메이터 컴포넌트의 파라미터를 덮어쓰기를 한다.

  동기화를 원하는 파라미터는 드롭다운 메뉴를 클릭해 옵션을 선택할  수 있다.  

  * Discreate : 불연속적인 확인, Continous에 비해 반영은 잘못하지만 대역폭을 아낄 수 있다.  

  * Continuous : 연속적인 확인, 지속적으로 반영하지만 그만큼 많이 소비된다.  

  현재 게임에서는 Move, Reload 파라미터를 동기화한다. Die는 로컬과 리모트 모두 직접 Die 트리거 파라미터를 사용하도록 할것이기 때문에 동기화 설정하지 않는다. 

<br>

### CameraSetup

#### Start()

```cs
void Start() {
    // 만약 자신이 로컬 플레이어라면
    if (photonView.IsMine)
    {
        // 씬에 있는 시네머신 가상 카메라를 찾고
        CinemachineVirtualCamera followCam = FindObjectOfType<CinemachineVirtualCamera>();
        // 가상 카메라의 추적 대상을 자신의 트랜스폼으로 변경
        followCam.Follow = transform;
        followCam.LookAt = transform;
    }
}
```

IsMine 프로퍼티는 게임 오브젝트의 주도권, 즉 로컬 클라이언트에 있는지 알려준다. 

<br>

### PlayerInput

MonoBehaviour 대신 MonoBehaviourPun 를 상속받는다. 

기존에 사용자 입력을 감지하는 기능에서 멀티플레이를 위해서 로컬 플레이어 캐릭터인 경우에만 사용자 입력을 감지하도록 변경한다.

#### Update()

```cs
// 매프레임 사용자 입력을 감지
private void Update() {
    // 로컬 플레이어가 아닌 경우 입력을 받지 않음
    if (!photonView.IsMine)
    {
        return;
    }

    // 게임오버 상태에서는 사용자 입력을 감지하지 않는다
    if (GameManager.instance != null
        && GameManager.instance.isGameover)
    {
        move = 0;
        rotate = 0;
        fire = false;
        reload = false;
        return;
    }

    // ~

}
```

<br>

### PlayerMovement

MonoBehaviour 대신 MonoBehaviourPun 를 상속받는다. 

사용자 입력에 따라 이동, 회전, 애니메이터 파라미터를 지정했던걸 로컬 플레이어 캐릭터인 경우에만 동작하도록 한다. 

#### FixedUpdate()

```cs
// FixedUpdate는 물리 갱신 주기에 맞춰 실행됨
private void FixedUpdate() {
    // 로컬 플레이어만 직접 위치와 회전을 변경 가능
    if (!photonView.IsMine)
    {
        return;
    }

    // 회전 실행
    Rotate();
    // 움직임 실행
    Move();

    // 입력값에 따라 애니메이터의 Move 파라미터 값을 변경
    playerAnimator.SetFloat("Move", playerInput.move);
}
```

<br>

### PlayerShooter

MonoBehaviour 대신 MonoBehaviourPun 를 상속받는다. 

입력에따라 사격 실행 및 탄알 UI 갱신을 로컬 플레이어 한정으로 변경한다. 

#### Update()

```cs
private void Update() {
    // 로컬 플레이어만 총을 직접 사격, 탄약 UI 갱신 가능
    if (!photonView.IsMine)
    {
        return;
    }

    // 입력을 감지하고 총 발사하거나 재장전
    if (playerInput.fire)
    {
        // 발사 입력 감지시 총 발사
        gun.Fire();
    }
    else if (playerInput.reload)
    {
        // 재장전 입력 감지시 재장전
        if (gun.Reload())
        {
            // 재장전 성공시에만 재장전 애니메이션 재생
            playerAnimator.SetTrigger("Reload");
        }
    }

    // 남은 탄약 UI를 갱신
    UpdateUI();
}
```

<br>

### LivingEntity 

MonoBehaviour 대신 MonoBehaviourPun 를 상속받는다. 

체력과 사망 상태관리, 데미지 처리, 사망 처리를 위한 클래스이다. 이제 호스트에서만 체력 관리와 데미지 처리가 실행되도록 한다. 

게임의 승패에 관여되는 매우 민감한 처리이다. 따라서 무조건 호스트에서 처리하도록하며 그 결과를 클라이언트에서 받아들이도록 구현한다.

#### ApplyUpdatedHealth()

```cs
// 호스트->모든 클라이언트 방향으로 체력과 사망 상태를 동기화 하는 메서드
[PunRPC]
public void ApplyUpdatedHealth(float newHealth, bool newDead) {
    health = newHealth;
    dead = newDead;
}
```

* \[PunRPC\]

  RPC를 구현하는 속성이다. 선언된 메서드는 다른 클라이언트에서 원격 실행할 수 있다.

  RPC를 통해 어떤 메서드를 다른 클라이언트에서 원격 실행할 때는 Photon View 컴포넌트의 RPC() 메서드를 사용한다. 

* RPC() 메서드는 다음 값을 받는다.  

  * 원격 실행할 메서드 이름 (string)

  * 원격 실행할 대상 클라이언트 (RpcTarget)

  * 원격 실행할 메서드에 전달할 값 (필요한 경우)

ApplyUpdatedHealth() 메서드는 새로운 체력값과 새로운 사망 상태값을 받아 기존 변수값을 갱신하는 메서드이다. 이 메서드는 호스트 측 LivingEntity의 체력, 사망 상태값을 다른 클라이언트의 LivingEntity에 전닫하기 위해 사용된다.  

만약 오브젝트 a가 있을 때 호스트 클라이언트에서 a의 상태를 변경한다. 이 때 동시에 같은 코드로 변경된 상태값을 입력하여 다른 모든 클라이언트에서 원격 실행한다. 그러면 호스트에서 a의 상태가 다른 모든 클라이언트 a에 적용된다.  

<br>

#### OnDamage()

변경된 OnDamage() 메서드는 PunRPC 속성이 선언되어 다른 클라이언트가 원격으로 실행할 수 있다.   

```cs
// 데미지 처리
// 호스트에서 먼저 단독 실행되고, 호스트를 통해 다른 클라이언트들에서 일괄 실행됨
[PunRPC]
public virtual void OnDamage(float damage, Vector3 hitPoint, Vector3 hitNormal) {
    if (PhotonNetwork.IsMasterClient)
    {
        // 데미지만큼 체력 감소
        health -= damage;

        // 호스트에서 클라이언트로 동기화
        photonView.RPC("ApplyUpdatedHealth", RpcTarget.Others, health, dead);

        // 다른 클라이언트들도 OnDamage를 실행하도록 함
        photonView.RPC("OnDamage", RpcTarget.Others, damage, hitPoint, hitNormal);
    }

    // 체력이 0 이하 && 아직 죽지 않았다면 사망 처리 실행
    if (health <= 0 && !dead)
    {
        Die();
    }
}
```

IsMasterClient 일 때만 데미지 수치를 적용하고 그것을 호스트에서 다른 클라이언트로 전파하는 처리를 수행한다.  

<br>

#### RestoreHealth()

```cs
// 체력을 회복하는 기능
[PunRPC]
public virtual void RestoreHealth(float newHealth) {
    if (dead)
    {
        // 이미 사망한 경우 체력을 회복할 수 없음
        return;
    }

    // 호스트만 체력을 직접 갱신 가능
    if (PhotonNetwork.IsMasterClient)
    {
        // 체력 추가
        health += newHealth;
        // 서버에서 클라이언트로 동기화
        photonView.RPC("ApplyUpdatedHealth", RpcTarget.Others, health, dead);

        // 다른 클라이언트들도 RestoreHealth를 실행하도록 함
        photonView.RPC("RestoreHealth", RpcTarget.Others, newHealth);
    }
}
```

체력이 실제로 변경되는 기본 부분은 OnDamage와 마찬가지로 호스트에서만 처리하도록 한다.

<br>

### PlayerHealth

플레이어 캐릭터의 체력 관리 및 체력 UI 갱신을 했다.  
이제는 리스폰 기능을 추가하고 아이템을 호스트에서만 사용되도록한다.  

#### RestoreHealth() 

```cs
// 체력 회복
[PunRPC]
public override void RestoreHealth(float newHealth) {
    // LivingEntity의 RestoreHealth() 실행 (체력 증가)
    base.RestoreHealth(newHealth);
    // 체력 갱신
    healthSlider.value = health;
}
```

LivingEntity를 상속받아 사용한다. 부모에서 PunRPC로 선언되었기 때문에 오버라이드하는 측에서도 원본 메서드와 동일하게 PunRPC 선언이 필요하다.  

클라이언트에서 PlayerHealth 스크립트의 OnDamage()가 실행될 때 호스트가 아니여도 효과음을 재생하고 체력 슬라이더를 갱신하는 부분은 모두 제대로 실행된다. 하지만 체력을 변경하는 부분만 호스트에서 실행된다.  

즉 호스트가 아닌 클라이언트에서도 공격을 받았을 때 겉으로 보이는 데미지 효과는 동일하게 보여지게된다.  

<br>

#### Die()  

```cs
public override void Die() {
    // LivingEntity의 Die() 실행(사망 적용)
    base.Die();

    // 체력 슬라이더 비활성화
    healthSlider.gameObject.SetActive(false);

    // 사망음 재생
    playerAudioPlayer.PlayOneShot(deathClip);

    // 애니메이터의 Die 트리거를 발동시켜 사망 애니메이션 재생
    playerAnimator.SetTrigger("Die");

    // 플레이어 조작을 받는 컴포넌트들 비활성화
    playerMovement.enabled = false;
    playerShooter.enabled = false;

    // 5초 뒤에 리스폰
    Invoke("Respawn", 5f);
}
```

Invoke 메서드를 사용해서 5초 뒤에 부활이 동작하도록 한다.  

<br>

#### Respawn()

```cs
// 부활 처리
public void Respawn() {
    // 로컬 플레이어만 직접 위치를 변경 가능
    if (photonView.IsMine)
    {
        // 원점에서 반경 5유닛 내부의 랜덤한 위치 지정
        Vector3 randomSpawnPos = Random.insideUnitSphere * 5f;
        // 랜덤 위치의 y값을 0으로 변경
        randomSpawnPos.y = 0f;

        // 지정된 랜덤 위치로 이동
        transform.position = randomSpawnPos;
    }

    // 컴포넌트들을 리셋하기 위해 게임 오브젝트를 잠시 껐다가 다시 켜기
    // 컴포넌트들의 OnDisable(), OnEnable() 메서드가 실행됨
    gameObject.SetActive(false);
    gameObject.SetActive(true);
}
```

새로 추가된 메서드이다. 사망한 플레이어 캐릭터를 부활시켜 재배치하는 메서드이다.  

부활 처리는 단순히 게임 오브젝트를 끄고 다시 켜는 간단한 방식으로 구현된다. 

초기화를 모두 OnEnable에서 작성했기 때문에 오브젝트를 끄고 켜는 것으로 초기화를 진행시킬 수 있게된다. 

<br>

#### OnTriggerEnter()

```cs
private void OnTriggerEnter(Collider other) {
    // 아이템과 충돌한 경우 해당 아이템을 사용하는 처리
    // 사망하지 않은 경우에만 아이템 사용가능
    if (!dead)
    {
        // 충돌한 상대방으로 부터 Item 컴포넌트를 가져오기 시도
        IItem item = other.GetComponent<IItem>();

        // 충돌한 상대방으로부터 Item 컴포넌트가 가져오는데 성공했다면
        if (item != null)
        {
            // 호스트만 아이템 직접 사용 가능
            // 호스트에서는 아이템을 사용 후, 사용된 아이템의 효과를 모든 클라이언트들에게 동기화시킴
            if (PhotonNetwork.IsMasterClient)
            {
                // Use 메서드를 실행하여 아이템 사용
                item.Use(gameObject);
            }

            // 아이템 습득 소리 재생
            playerAudioPlayer.PlayOneShot(itemPickupClip);
        }
    }
}
```

충돌한 아이템을 감지하고 사용하는 처리가 구현되어있다. 기존 방식에서 조건문을 통해 호스트에서만 처리되도록 한다.

데미지와 마찬가지로 모든 클라이언트에서 겉보기로는 아이템을 직접 사용하는것처럼 보이지만 실제 사용만 호스트에서 진행된다.  