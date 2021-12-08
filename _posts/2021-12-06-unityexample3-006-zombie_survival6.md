---
title:  "[레트로의 유니티] 좀비서바이벌6 - 총"
excerpt: "unity3d, retro, example, zombie, interface"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, interface]

toc: true
toc_sticky: true
 
date: 2021-12-06 
last_modified_at: 2021-12-06
---  

***  

### IDamageable 인터페이스  

이 게임에서 공격당할 수 있는 모든 대상은 IDamageable 인터페이스를 상속해야한다.  

Assets > Scripts > IDamageable  

```cs
using UnityEngine;

public interface IDamageable {
  void OnDamage(float damage, Vector3 hitPoint, Vector3 hitNormal);
}
```

IDamageable 인터페이스를 상속하는 클래스는 OnDamage() 메서드를 반드시 구현해야 한다.  

* damage : 데미지의 크기

* hitPoint : 공격당한 위치  

* hitNormal : 공격당한 표면의 방향

<br>

### 총  


플레이어가 사용할 총을 배치한다.  

**빈 오브젝트**  

우선 기준점이 될 게임 오브젝트를 Player Character 의 자식으로 추가한다.  

Player Character > Create Empty 빈 오브젝트를 추가해준다.  

이름 : Gun Pivot  
위치 : 0, 1, 0.5  

**총 오브젝트**  

Prefabs > Gun 오브젝트를 Gun Pivot으로 드래그앤드롭한다.  

위치 : -0.2, -0.04, 0.17

<br>

### 탄알의 궤적  

라인 렌더러를 사용하여 탄알의 궤적을 그린다.  

Gun > Add Component > Effect > Line Renderer 추가한 탄알의 궤적은 발사하는 순간에만 켜고 끌것이기 때문에 컴포넌트는 비활성화 해준다.  

* Cast Shadows : off  

  라인 렌더러의 그림자를 선택한다. 탄알의 궤적은 그림자가 필요없기 때문에 꺼준다. 

* Receive Shadows : 체크해제

  라인 렌더러에 그림자가 비칠지 선택한다.  

* Materials > Element 0 > Bullet 머티리얼 할당

  머티리얼을 설정한다.  

* Position > Size : 0

  필드에서 사용할 점의 개수로 스크립트로 설정해줄 것이다.  

* Width : 0.02

  두께를 정한다. 적당한 크기로 조절  

<br>

### 오디오 소스 추가  

총의 효과음을 위해 오디오 소스를 추가한다.  

Gun > Add Component > Audio > Audio Source  

Audio Source 컴포넌트의 Play On Awake 체크를 해제한다.  

<br>

### 파티클 효과 추가  

총구 화염과 탄피 배출 효과를 추가한다.  

Prefab > MuzzleFlashEffect, ShellEjectEffect 프리팹을 Gun으로 드래그앤드롭

MuzzleFlashEffect 위치 : 0, 0.08, 0.2  

ShellEjectEffect 위치 : 0.01, 0.09 -0.02  

<br>

### 스크립트  

Scripts > Gun 스크립트를 Gun 오브젝트에 추가해준다.  

```cs
using System.Collections;
using UnityEngine;

// 총을 구현한다
public class Gun : MonoBehaviour {
    // 총의 상태를 표현하는데 사용할 타입을 선언한다
    public enum State {
        Ready, // 발사 준비됨
        Empty, // 탄창이 빔
        Reloading // 재장전 중
    }

    public State state { get; private set; } // 현재 총의 상태

    public Transform fireTransform; // 총알이 발사될 위치

    public ParticleSystem muzzleFlashEffect; // 총구 화염 효과
    public ParticleSystem shellEjectEffect; // 탄피 배출 효과

    private LineRenderer bulletLineRenderer; // 총알 궤적을 그리기 위한 렌더러

    private AudioSource gunAudioPlayer; // 총 소리 재생기
    public AudioClip shotClip; // 발사 소리
    public AudioClip reloadClip; // 재장전 소리

    public float damage = 25; // 공격력
    private float fireDistance = 50f; // 사정거리

    public int ammoRemain = 100; // 남은 전체 탄약
    public int magCapacity = 25; // 탄창 용량
    public int magAmmo; // 현재 탄창에 남아있는 탄약


    public float timeBetFire = 0.12f; // 총알 발사 간격
    public float reloadTime = 1.8f; // 재장전 소요 시간
    private float lastFireTime; // 총을 마지막으로 발사한 시점


    private void Awake() {
        // 사용할 컴포넌트들의 참조를 가져오기
        gunAudioPlayer = GetComponent<AudioSource>();
        bulletLineRenderer = GetComponent<LineRenderer>();
        // 사용할 점을 두 개로 변경
        bulletLineRenderer.positionCount = 2;
        // 라인 렌더러를 비활성화
        bulletLineRenderer.enabled = false;
    }

    private void OnEnable() {
        // 총 상태 초기화
        // 현재 탄창을 가득 채우기
        magAmmo = magCapacity;
        // 총의 현재 상트를 총을 쏠 준비가 된 상태로 변경  
        state = State.Ready;
        // 마지막으로 총을 쏜 시점을 초기화
        lastFireTime = 0;
    }

    // 발사 시도
    public void Fire() {
        // 현재 상태가 발사 가능한 상태
        // && 마지막 총 발사 시점에서 timeBetFire 이상의 시간이 지남
        if (state == State.Ready && Time.time >= lastFireTime + timeBetFire)
        {
            // 마지막 총 발사 시점 갱신
            lastFireTime = Time.time;
            // 실제 발사 처리 실행
            Shot();
        }
    }

    // 실제 발사 처리
    private void Shot() {
        // 레이캐스트에 의한 충돌 정보를 저장하는 컨테이너
        RaycastHit hit;
        // 탄알이 맞은 곳을 저장하는 변수
        Vector3 hitPosition = Vector3.zero;
        // 레이캐스트(시작 지점, 방향, 충돌 정보 컨테이너, 사정거리)
        if (Physics.Raycast(fireTransform.position, fireTransform.forward, out hit, fireDistance))
        {
            // 레이가 어떤 물체와 충돌한 경우 내부실행

            // 충돌한 상대방으로부터 IDamageable 오브젝트 가져오기 시도
            IDamageable target = hit.collider.GetComponent<IDamageable>();
            // 상대방으로부터 IDamageable 오브젝트를 가져오는데 성공했다면
            if (target != null)
            {
                // 상대방의 OnDamage 함수를 실행시켜 상대방에 데미지 주기
                target.OnDamage(damage, hit.point, hit.normal);
            }

            // 레이가 충돌한 위치 저장
            hitPosition = hit.point;
        }
        else
        {
            // 레이가 다른 물체와 충돌하지 않았다면
            // 탄알이 최대 사정거리까지 날아갔을 때의 위치를 충돌 위치로 사용
            hitPosition = fireTransform.position + fireTransform.forward * fireDistance;
        }

        // 발사 이펙트 재생 시작
        StartCoroutine(ShotEffect(hitPosition));
        // 남은 탄알 수를 -1
        magAmmo--;
        if (magAmmo <= 0)
        {
            // 탄창에 남은 탄알이 없다면 총의 현재 상태를 empty로 갱신
            state = State.Empty;
        }
    }

    // 발사 이펙트와 소리를 재생하고 총알 궤적을 그린다
    private IEnumerator ShotEffect(Vector3 hitPosition) {
        // 총구 화염 효과 재생
        muzzleFlashEffect.Play();
        // 탄피 배출 효과 재생
        shellEjectEffect.Play();
        // 총격 소리 재생 
        gunAudioPlayer.PlayOneShot(shotClip);
        // 선의 시작점은 총구 위치
        bulletLineRenderer.SetPosition(0, fireTransform.position);
        // 선의 끝점은 입력으로 들어온 충돌 위치
        bulletLineRenderer.SetPosition(1, hitPosition);
        // 라인 렌더러를 활성화하여 총알 궤적을 그린다
        bulletLineRenderer.enabled = true;

        // 0.03초 동안 잠시 처리를 대기
        yield return new WaitForSeconds(0.03f);

        // 라인 렌더러를 비활성화하여 총알 궤적을 지운다
        bulletLineRenderer.enabled = false;
    }

    // 재장전 시도
    public bool Reload() {
        if (state == State.Reloading || ammoRemain <= 0 || magAmmo >= magCapacity)
        {
            // 이미 재장전 중이거나 남은 탄알이 없거나
            // 탄창에 탄알이 이미 가득한 경우 재장전할 수 없음
            return false;
        }

        // 재장전 처리 시작
        StartCoroutine(ReloadRoutine());
        return true;
    }

    // 실제 재장전 처리를 진행
    private IEnumerator ReloadRoutine() {
        // 현재 상태를 재장전 중 상태로 전환
        state = State.Reloading;
        // 재장전 소리 재생
        gunAudioPlayer.PlayOneShot(reloadClip);
        
        // 재장전 소요 시간 만큼 처리를 쉬기
        yield return new WaitForSeconds(reloadTime);

        // 탄창에 채울 탄알을 계산
        int ammoToFill = magCapacity - magAmmo;
        
        // 탄창에 채워야 할 탄알이 남은 탄알보다 많으면
        // 채워야 할 탄알 수를 남은 탄알 수에 맞춰 줄임
        if (ammoRemain < ammoToFill)
        {
            ammoToFill = ammoRemain;
        }

        // 탄창을 채움
        magAmmo += ammoToFill;
        // 남은 탄알에서 탄창에 채운만큼 탄알을 뺌
        ammoRemain -= ammoToFill;
        // 총의 현재 상태를 발사 준비된 상태로 변경
        state = State.Ready;
    }
}
```

Gun 컴포넌트의 필드를 채워준다.  

* FirePosition -> Fire Transform 필드로

* MuzzleFLashEffect -> Muzzle Flash Effect 필드로

* ShellEjectEffect -> Shell Eject Effec 필드로

* Audios > Gun Shoot 오디오 클립을 Shot Clip 필드로  

* Audios > Gun Reload 오디오 클립을 Reload Clip 필드로