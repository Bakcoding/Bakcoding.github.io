---
title:  "[레트로의 유니티] 좀비서바이벌3 - 플레이어"
excerpt: "unity3d, retro, example, zombie"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie]

toc: true
toc_sticky: true
 
date: 2021-12-06 
last_modified_at: 2021-12-06
---  

***

### 플레이어 생성  

프로젝트 창의 Models > Woman 오브젝트를 Hierarchy 창에 드래그앤드롭한다.  

**오브젝트 설정**  

이름 Player Character  
태그 Player  
위치 (0, 0, 0)  

<br>

**컴포넌트 추가**  

* Rigidbody  
 
  Angular Drag : 값 20  

  Constraints > Freeze Rotation : x와 z 체크

* Capsule Collider  

  Center : 0, 0.75, 0  

  Radius : 0.2  

  Height : 1.5  

* Audio Source  

  Play On Awake : 체크 해제


<br>

**애니메이터 설정**  

* Player Character > Animatior > Controller > ShooterAnimator 할당  

* upper body 레이어에 아바타 마스크 적용  

  Upper Body > 설정 > Mask > Upper Body Mask 선택  

  상체에만 적용되는 애니메이션을 설정한다. 

<br>

### 이동 구현  

스크립트를 추가한다.  

Assets > Scripts 의 PlayerInput, PlayerMovement 스크립트를 Player Character 오브젝트에 추가한다.  

PlayerInput : 입력을 감지하고 다른 컴포넌트에 정보 전달  

PlayerMovement : 직접적으로 움직임을 제어하는 스크립트

<br>

**PlayerInput.cs**  

```cs
using UnityEngine;

// 플레이어 캐릭터를 조작하기 위한 사용자 입력을 감지
// 감지된 입력값을 다른 컴포넌트들이 사용할 수 있도록 제공
public class PlayerInput : MonoBehaviour {
    public string moveAxisName = "Vertical"; // 앞뒤 움직임을 위한 입력축 이름
    public string rotateAxisName = "Horizontal"; // 좌우 회전을 위한 입력축 이름
    public string fireButtonName = "Fire1"; // 발사를 위한 입력 버튼 이름
    public string reloadButtonName = "Reload"; // 재장전을 위한 입력 버튼 이름

    // 값 할당은 내부에서만 가능
    public float move { get; private set; } // 감지된 움직임 입력값
    public float rotate { get; private set; } // 감지된 회전 입력값
    public bool fire { get; private set; } // 감지된 발사 입력값
    public bool reload { get; private set; } // 감지된 재장전 입력값

    // 매프레임 사용자 입력을 감지
    private void Update() {
        // 게임오버 상태에서는 사용자 입력을 감지하지 않는다
        if (GameManager.instance != null && GameManager.instance.isGameover)
        {
            move = 0;
            rotate = 0;
            fire = false;
            reload = false;
            return;
        }

        // move에 관한 입력 감지
        move = Input.GetAxis(moveAxisName);
        // rotate에 관한 입력 감지
        rotate = Input.GetAxis(rotateAxisName);
        // fire에 관한 입력 감지
        fire = Input.GetButton(fireButtonName);
        // reload에 관한 입력 감지
        reload = Input.GetButtonDown(reloadButtonName);
    }
}
```

* 프로퍼티  

  입력값은 외부 클래스에서 사용할 수 있도록 만든다.  

  get을 통해 값을 사용할 수 있지만 set은 pritvate로 지정해 외부 클래스에서 값이 변경되지 않도록한다.  


**PlayerMovement**  

```cs
using UnityEngine;

// 플레이어 캐릭터를 사용자 입력에 따라 움직이는 스크립트
public class PlayerMovement : MonoBehaviour {
    public float moveSpeed = 5f; // 앞뒤 움직임의 속도
    public float rotateSpeed = 180f; // 좌우 회전 속도


    private PlayerInput playerInput; // 플레이어 입력을 알려주는 컴포넌트
    private Rigidbody playerRigidbody; // 플레이어 캐릭터의 리지드바디
    private Animator playerAnimator; // 플레이어 캐릭터의 애니메이터

    private void Start() {
        // 사용할 컴포넌트들의 참조를 가져오기
        playerInput = GetComponent<PlayerInput>();
        playerRigidbody = GetComponent<Rigidbody>();
        playerAnimator = GetComponent<Animator>();
    }

    // FixedUpdate는 물리 갱신 주기에 맞춰 실행됨
    private void FixedUpdate() {
        // 물리 갱신 주기마다 움직임, 회전, 애니메이션 처리 실행
        // 회전 실행
        Rotate();
        // 움직임 실행
        Move();
        // 입력값에 따라 애니메이터의 Move 파라미터값 변경
        playerAnimator.SetFloat("Move", playerInput.move);
    }

    // 입력값에 따라 캐릭터를 앞뒤로 움직임
    private void Move() {
        // 상대적으로 이동할 거리 계산
        Vector3 moveDistance =
            playerInput.move * transform.forward * moveSpeed * Time.deltaTime;
        // 리지드바디를 이용해 게임 오브젝트 위치 변경  
        playerRigidbody.MovePosition(playerRigidbody.position + moveDistance);
    }

    // 입력값에 따라 캐릭터를 좌우로 회전
    private void Rotate() {
        // 상대적으로 회전할 수치 계산
        float turn = playerInput.rotate * rotateSpeed * Time.deltaTime;
        // 리지드바디를 이용해 게임 오브젝트 회전 변경
        playerRigidbody.rotation =
            playerRigidbody.rotation * Quaternion.Euler(0, turn, 0f);
    }
}
```

