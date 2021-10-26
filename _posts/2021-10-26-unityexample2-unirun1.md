---
title:  "[레트로의 유니티] 유니런1"
excerpt: "unity3d, retro, example, unirun"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, unirun]

toc: true
toc_sticky: true
 
date: 2021-10-26 
last_modified_at: 2021-10-26
---  

***

### 1. 프로젝트 열기  

[프로젝트 예제](https://github.com/IJEMIN/Unity-Programming-Essence)

유니티 허브에서 폴더 11을 연다.  

ctrl+s를 눌러서 main이라는 이름의 새로운 씬을 생성한다.  

<br/>

### 2. 시작과 끝
유니런은 횡스크롤로 지나가는 발판을 옮기면서 떨어지지않고 오래동안 살아남는 게임이다.  

플레이어가 처음 등장할 위치와 게임오버를 판정할 위치를 생성한다.  

**시작 지점**  
플레이어가 서 있을 발판을 만든다.  

* 프로젝트 창에서 Sprite > Platform_Long 스프라이트를 하이어라키 창으로 드래그앤드롭한다.  

* 생성된 Platform_Long 게임 오브젝트의 이름을 Start Platform, 위치 (0, -1, 0) 변경

* 플레이어가 서있기 위해서 콜라이더를 추가해준다. 스프라이트이기 때문에 2D Collider를 선택한다.  

  ![platform](/assets/images/20211026_Posting/1.png)

**데드존**

* 빈 게임오브젝트 생성하고 이름 Deadzone, 위치 (0, -8, 0), 크기 (50, 2) 변경  

* Dead 태그를 지정해준다.

* 콜라이더를 추가해주고 Is Trigger 체크

<br/>

### 3. 플레이어 스프라이트 

플레이어는 Toko_Die, Toko_Jump, Toko_Run 스프라이트를 사용한다.  

플레이어가 움직이는 것처럼 보여주기 위해서 동작을 여러개의 스프라이트로 구분하고 하나씩 보여준다.  

* 스프라이트 인스펙터의 Sprite Mode를 Multiple로 바꾸고 apply를 눌러서 변경사항 적용한다.  
  
* Sprite Editor를 켜서 스프라이트를 잘라준다.  

  Slice > Type 을 Grid By Cell Size로 변경( X : 64, Y : 64 ) Slice를 해준다음 Apply를 누르면 스프라이트가 동작별로 구분되어 잘라진다.  

  ![run](/assets/images/20211026_Posting/2.png)

**플레이어 오브젝트**  

Toko_Run 스프라이트를 펼치고 Toko_Run_0 스프라이트를 하이어라키 창으로 드래그앤드롭하여 게임 오브젝트를 생성한다.  

이름은 Player, 태그는 Player, 위치 (-6, 2, 0) 변경한다.  

발판 위에 서 있기 위해서, 중력의 영향을 받기 위해서 Rigidbody 2D와 Circle Collider 2D를 추가해준다.  

* Rigidbody  

  컴포넌트를 추가하고 Collision Detection을 Continous로 변경

  Constraints 옵션을 펼쳐서 Z를 체크한다.  

* Collider  

  Offset에서 X: 0, Y: -0.57, Radius는 0.2로 변경한다.  

**오디오 추가**  

점프시 소리가 나도록 오디오 소스를 추가한다.  

Add Component > Audio Source 컴포넌트의 옵션을 수정한다.  

Audio Clip에서 jump를 추가해준다.  

Play On Awake : 실행시 소리가 발생하는 옵션으로 체크를 해제한다.  


**애니메이션 편집**  

Window > Animation > Animation

Create를 눌러서 애니메이션 클립을 만들어준다.  

클립은 Run이름으로 Assets > Animation 폴더에 저장한다.  

Toko_Run 스프라이트를 펼치고 모두 선택한 다음 애니메이션 창으로 드래그앤드롭을 하면 편집할 수 있는 상태가 된다.  

samples의 60을 16으로 변경해서 프레임 재생 속도를 조절한다.  

![60](/assets/images/20211026_Posting/1.gif)

![16](/assets/images/20211026_Posting/2.gif)

같은 방법으로 Jump와 Die도 수정한다. (Samples : 6)

Die의 경우 애니메이션이 반복해서 재생될 필요가 없기 때문에 프로젝트에서 Assets > Animation 에서 Die 파일의 Loop Time 옵션을 해제한다.  

**애니메이터 설정**  

Window > Animation > Animator  

![animator](/assets/images/20211026_Posting/3.png)

사진처럼 전이를 이어준 다음 Parameter를 통해서 애니메이션이 넘어갈 조건을 설정한다.  

Bool 파라미터를 추가하고 이름은 Grounded로 한다. 이 파라미터는 플레이어가 바닥에 붙어있는지 떨어져 있는지를 구분해서 점프할 수 있는 조건으로 사용한다.  

Trigger를 사용하고 이름은 Die, 플레이어가 데드존에 닿는 순간 동작시켜 애니메이션 재생을 넘긴다.  

* 점프  

  Run에서 Jump로 넘어가는 전이의 옵션을 수정한다.  

  **Setting**  

  Has Exit Time 해제, 종료 시점을 활성화 시켜서 재생 중인 애니메이션을 즉시 종료하고 다음 애니메이션으로 넘어가게 한다.  

  Transition Duration 0, 현재 애니메이션과 다음 애니메이션을 블렌딩해서 부드럽게 이어주는 역할을 한다.  

  **Conditions**  

  Grounded 파라미터를 추가해주고 조건값 false로 변경

  이와같은 방식으로 세팅을 동일하게 해주고 Jump에서 Run으로 넘어갈 때는 Grounded가 true일 때, 

  Any State에서 Die로 향하는 전이로 무슨 애니메이션이 재생 중이던지 즉시 전환하게 만든다.  

<br/>

### 플레이어 컨트롤러  

플레이어를 제어하기 위한 스크립트를 추가한다.  

프로젝트에 미리 생성된 PlayerController.cs를 플레이어 오브젝트에 추가한다.  

```javascript
// PlayerController.cs
using UnityEngine;

// PlayerController는 플레이어 캐릭터로서 Player 게임 오브젝트를 제어한다.
public class PlayerController : MonoBehaviour {
   public AudioClip deathClip; // 사망시 재생할 오디오 클립
   public float jumpForce = 700f; // 점프 힘

   private int jumpCount = 0; // 누적 점프 횟수
   private bool isGrounded = false; // 바닥에 닿았는지 나타냄
   private bool isDead = false; // 사망 상태

   private Rigidbody2D playerRigidbody; // 사용할 리지드바디 컴포넌트
   private Animator animator; // 사용할 애니메이터 컴포넌트
   private AudioSource playerAudio; // 사용할 오디오 소스 컴포넌트

   private void Start() {
       // 초기화
   }

   private void Update() {
       // 사용자 입력을 감지하고 점프하는 처리
   }

   private void Die() {
       // 사망 처리
   }

   private void OnTriggerEnter2D(Collider2D other) {
       // 트리거 콜라이더를 가진 장애물과의 충돌을 감지
   }

   private void OnCollisionEnter2D(Collision2D collision) {
       // 바닥에 닿았음을 감지하는 처리
   }

   private void OnCollisionExit2D(Collision2D collision) {
       // 바닥에서 벗어났음을 감지하는 처리
   }
}
```

구체적인 동작을 작성한다.  

초기화  

```javascript
// PlayerController.cs
private void Start() {
    // 초기화
    playerRigidbody = GetComponent<Rigidbody2D>();
    animator = GetComponent<Animator>();
    playerAudio = GetComponent<AudioSource>();
}
```  

플레이어 점프 동작, Update 함수에 추가

```javascript
// 사용자 입력을 감지하고 점프하는 처리
if (isDead)
{
    // 사망시 업데이트 진행안되게
    return;
}

// 마우스 왼쪽 버튼을 눌렀을 때, 최대 점프 횟수 2에 도달하지 않으면
if (Input.GetMouseButtonDown(0) && jumpCount < 2)
{
    // 점프 횟수 증가
    jumpCount++;
    // 점프 직전에 속도를 순간적으로 (0, 0)로 변경
    playerRigidbody.velocity = Vector2.zero;
    // 리지드바디의 위쪽으로 힘 주기
    playerRigidbody.AddForce(new Vector2(2, jumpForce));
    // 오디오 소스 재생 
    playerAudio.Play();
}
else if (Input.GetMouseButtonUp(0) && playerRigidbody.velocity.y > 0)
{
    // 마우스 왼쪽 버튼에서 손을 때면, 속도의 y값이 양수일 때(점프 중)
    // 현재 속도를 절반으로 변경  
    playerRigidbody.velocity = playerRigidbody.velocity * 0.5f;
}

// 파라미터 Grounded의 값을 isGroundded 값으로 갱신  
animator.SetBool("Grounded", isGrounded);
```

플레이어 사망, OnTriggerEnter2D 함수에 추가

```javascript
// PlayerController.cs
// 애니메이터 Die 트리거 파라미터를 작동시킨다.  
animator.SetTrigger("Die");
// 오디오 소스에 할당된 오디오 클립을 deathClip으로 변경
playerAudio.clip = deathClip;
// 사망 효과음 재생
playerAudio.Play();
// 속도를 제로(0, 0)로 변경
playerRigidbody.velocity = Vector2.zero;
// 사망 상태를 true로 변경
isDead = true;
```

바닥에 착지했을 때 감지, OnCollisionEnter2D 함수에 추가

```javascript
// 바닥에 닿았음을 감지하는 처리
// 어떤 콜라이더와 닿았으며, 충돌 표면이 위쪽을 보고 있을 때  
if (collision.contacts[0].normal.y > 0.7f)
{
    // isGrounded를 true로 변경하고, 누적 점프 횟수를 0으로 리셋
    isGrounded = true;
    jumpCount = 0;
}
```

바닥을 벗어났을 때 감지, OnCollisionExit2D 함수에 추가  

```javascript
// 바닥에서 벗어났음을 감지하는 처리
// 어떤 콜라이더에서 떼어진 경우 isGrounded를 false로 변경
isGrounded = false;
```

컴포넌트를 설정한다.  

Player 오브젝트에서 PlayerController 컴포넌트의 DeathClip에 Die 추가

![play](/assets/images/20211026_Posting/3.gif)