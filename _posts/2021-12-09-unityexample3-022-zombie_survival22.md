---
title:  "[레트로의 유니티] 좀비서바이벌22 - 네트워크 - 총"
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

### 총  

추가된 컴포넌트  

* Photon View

부모 오브젝트에 추가된것과 별개로 자식 게임 오브젝트에서 독자적으로 실행할 네트워크 처리가 있다면 추가하고 View ID를 부여해야한다.  

<br>

### Gun

MonoBehaviour 대신 MonoBehaviourPun, IPunObservable 를 상속받는다.
 

사격 실행, 이펙트 재생, 재장전 실행, 탄알 관리의 기능을 하던 스크립트다. 이제 실제 사격 처리 부분을 호스트에서만 실행하고 상태를 동기화 시킨다.  

<br>

#### OnPhotonSerializeView()

Photon View 컴포넌트를 사용해 동기화를 구현할 모든 컴포넌트는 IPunObservable 인터페이스를 상속하고 OnPhotonSerializeView()메서드를 구현해야한다.  

IPunObservable 인터페이스를 상속한 컴포넌트는 Photon View 컴포넌트의 Observed Components에 등록되어 로컬과 리모트에서 동기화될 수 있다.  

OnPhotonSerializeView() 메서드는 Photon View 컴포넌트에 의해 자동으로 실행된다.  

```cs
// 주기적으로 자동 실행되는, 동기화 메서드
public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info) {
    // 로컬 오브젝트라면 쓰기 부분이 실행됨
    if (stream.IsWriting)
    {
        // 남은 탄약수를 네트워크를 통해 보내기
        stream.SendNext(ammoRemain);
        // 탄창의 탄약수를 네트워크를 통해 보내기
        stream.SendNext(magAmmo);
        // 현재 총의 상태를 네트워크를 통해 보내기
        stream.SendNext(state);
    }
    else
    {
        // 리모트 오브젝트라면 읽기 부분이 실행됨
        // 남은 탄약수를 네트워크를 통해 받기
        ammoRemain = (int) stream.ReceiveNext();
        // 탄창의 탄약수를 네트워크를 통해 받기
        magAmmo = (int) stream.ReceiveNext();
        // 현재 총의 상태를 네트워크를 통해 받기
        state = (State) stream.ReceiveNext();
    }
}
```

OnPhotonSerializeView() 메서드는 ammoRemain, magAmmo, state 값을 로컬에서 리모트 방향으로 동기화한다. 남은 전체 탄알, 탄창의 탄알, 총의 상태가 클라이언트 사이에서 동기화된다.  

OnPhotonSerializeView() 메서드의 입력으로 들어오는 stream은 현재 클라이언트에서 다른 클라이언트로 보낼 값을 쓰거나, 다른 클라이언트가 보내온 값을 읽을 때 사용할 스트림 형태의 데이터 컨테이너이다.  

stream.IsWriting은 현재 스트림 모드를 반환한다. 현재 게임 오브젝트가 로컬 게임 오브젝트면 쓰기 모드가 되어 true, 리모트 게임 오브젝트면 읽기 모드가 되어 false가 반환된다.  

즉, 클라이언트 A와 B가 있다고 가정했을 때 A에서 플레이어 캐릭터 a가 들고 있는 총의 Gun 스크립트에서 stream.IsWriting이 true읻다. 따라서 SendNext() 메서드로 스트림에 값을 삽입하여 네트워크를 통해 전송한다.  

클라이언트 B에서의 플레이어 캐릭터 a가 들고 있는 총의 Gun 스크립트에서는 stream.IsWriting이 false이다. 따라서 스트림으로 들어온 값을 ReceiveNext() 메서드로 가져온다. 이렇게 클라이언트 B의 a 총은 클라이언트 A의 a 총이 가지고 있는 값으로 동기화 된다.  

여기서 ReceiveNext() 메서드를 통해 값이 들어올 때는 범용적인 object 타입으로 들어오기 때문에 읽는 측에서 원본 타입으로 형변환된다. 또한 스트림에 삽입한 순서대로 값이 도착하기 때문에 SendNext() 와 ReceiveNext() 메서드를 사용해 주고받는 변수들의 나열 순서가 일치해야한다.  

<br>

#### AddAmmo() 

탄알을 추가하는 메서드로 호스트가 아이템을 사용하여 탄알을 추가했을 때 다른 클라이언트에서도 탄알이 추가되게 하는 RPC 메서드이다.  

클라이언트 A와 B가 있을 때 A가 호스트라고 가정한다.  
클라이언트 B가 자신의 로컬 플레이어 캐릭터 b를 움직여 탄알 아이템을 먹었을 때 위치가 동기화되므로 클라이언트 A의 리모트 플레이어 캐릭터 b도 탄알 아이템을 먹게된다.  

하지만 아이템의 실제 사용은 호스트가 처리하기 때문에 클라이언트 B는 아이템을 사용할 수 없고 클라이언트 A의 리모트 플레이어 b에서 실행된다.  

따라서 호스트인 클라이언트 A는 모든 클라이언트 A와 B에서 b의 탄알이 증가하도록 RPC를 통해 AddAmmo()를 실행한다.  

```cs
// 남은 탄약을 추가하는 메서드
[PunRPC]
public void AddAmmo(int ammo) {
    ammoRemain += ammo;
}
```

<br>

#### ShotProcessOnServer()

클라이언트의 발사 처리를 호스트에 맡기는 구조로 변경되었다.  

데미지를 적용하던 Shot() 메서드는 이제 ShotProcessOnServer() 메서드를 호스트로 원격 실행한다. 그리고 ShotProcessOnServer()메서드에서 실제 데미지를 처리하는 기능을 하게된다.  

```cs
// 호스트에서 실행되는, 실제 발사 처리
[PunRPC]
private void ShotProcessOnServer() {
    // 레이캐스트에 의한 충돌 정보를 저장하는 컨테이너
    RaycastHit hit;
    // 총알이 맞은 곳을 저장할 변수
    Vector3 hitPosition = Vector3.zero;

    // 레이캐스트(시작지점, 방향, 충돌 정보 컨테이너, 사정거리)
    if (Physics.Raycast(fireTransform.position,
        fireTransform.forward, out hit, fireDistance))
    {
        // 레이가 어떤 물체와 충돌한 경우

        // 충돌한 상대방으로부터 IDamageable 오브젝트를 가져오기 시도
        IDamageable target =
            hit.collider.GetComponent<IDamageable>();

        // 상대방으로 부터 IDamageable 오브젝트를 가져오는데 성공했다면
        if (target != null)
        {
            // 상대방의 OnDamage 함수를 실행시켜서 상대방에게 데미지 주기
            target.OnDamage(damage, hit.point, hit.normal);
        }

        // 레이가 충돌한 위치 저장
        hitPosition = hit.point;
    }
    else
    {
        // 레이가 다른 물체와 충돌하지 않았다면
        // 총알이 최대 사정거리까지 날아갔을때의 위치를 충돌 위치로 사용
        hitPosition = fireTransform.position +
                      fireTransform.forward * fireDistance;
    }

    // 발사 이펙트 재생, 이펙트 재생은 모든 클라이언트들에서 실행
    photonView.RPC("ShotEffectProcessOnClients", RpcTarget.All, hitPosition);
}
```

발사 처리는 호스트에서만 실행하고 눈으로 보이는 시각 효과는 모든 클라이언트에서 실행되어야한다. 

#### ShotEffectProcessOnClients()

```cs
// 이펙트 재생 코루틴을 랩핑하는 메서드
[PunRPC]
private void ShotEffectProcessOnClients(Vector3 hitPosition) {
    StartCoroutine(ShotEffect(hitPosition));
}
```

ShotEffect() 코루틴 메서드를 PunRPC로 선언 가능한 메서드로 감싼 다음 코루틴일 실행하는 메서드를 작성한다.  


Shot() 메서드는 다음과 같이 실행된다. 

1. 클라이언트 B의 로컬 플레이어 b의 총에서 Shot() 실행 

2. Shot()에서 photonView.RPC("ShotProcessOnServer", RpcTarget.MasterClient); 실행

3. 실제 사격 처리를 하는 ShotProcessOnServer()는 호스트 클라이언트 A에서만 실행

4. ShotProcessOnServer()에서 photonView.RPC("ShotEffectProcessOnClients", RpcTarget.All, hitPosition); 실행

5. 사격 효과 재생인 ShotEffectProcessOnClients()는 모든 클라이언트 A, B, C에서 실행

<br>

플레이어는 프리팹으로 생성할것이기 때문에 씬에 남은 Player Character 게임 오브젝트는 삭제해준다.  