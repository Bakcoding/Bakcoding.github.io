---
title:  "[레트로의 유니티] 좀비서바이벌11 - 플레이어 체력"
excerpt: "unity3d, retro, example, zombie, slider"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, slider]

toc: true
toc_sticky: true
 
date: 2021-12-08 
last_modified_at: 2021-12-08
---  

***  

### 플레이어 체력 UI

#### UI 오브젝트 생성 

슬라이더를 사옹해서 플레이어 체력을 표시할 UI를 만든다.  

* Create > UI > Slider

    새 슬라이더 오브젝트 생성  

* Canvas 오브젝트 설정

    * Canvas 컴포넌트  

        Render Mode -> World Space  

        UI는 기본적으로 게임 화면 기준으로 배치된다. 플레이어를 따라다녀야 하므로 렌더링 위치를 World Space로 변경해준다.  

    * Canvas Scaler 컴포넌트

        Reference Pixels per Unit : 1

        단위당 레퍼런스 픽셀은 UI 스프라이트의 픽셀 크기와 게임 월드의 유닛 크기가 대응되는 비율을 결정한다. 스프라이트 화질에 영향을 주기 때문에 값이 작을수록 픽셀 집적도가 높아지게 된다.  

<br>

#### UI 위치와 크기  

* Canvas 오브젝트를 Player Character 오브젝트의 자식으로 만든다.  

* Canvas 오브젝트 설정  

    * Rect Transform 위치 (0, 0.3, 0)
        
        Width, Height : 1

        Rotation : (90, 0, 0);


* 크기 변경 

    * Canvas 오브젝트를 alt + 클릭으로 펼쳐준다.  

        Handle Slide Area 오브젝트 삭제

    * Slider, Background, Fill Area, Fill 모두 선택

        앵커 프리셋을 alt + stretch 클릭


<br>

#### 슬라이더 이미지  

* Slider 컴포넌트 설정  

    * Slider > 이름 Health Slider 변경  

    * Interactable 체크 해제

        UI는 기본적으로 상호작용이 가능하지만 체력을 표시하는 경우 필요없기 때문에 상호작용은 꺼준다.  

    * Transition : none 

        상호작용시 일어나는 시각적인 효과를 설정한다. 필요없기 때문에 none 설정

    * Max Value : 100

* Background 오브젝트  

    Source Image : Health Circle 할당 

    Color : 알파값을 30으로 변경

* Fill 오브젝트  

    Source Image : Health Circle 할당 

    Color : (255, 0, 0, 150)

    Image Type : Filled


<br>

### 스크립트  

PlayerHealth 구조

* LivingEntity의 생명체 기본 기능

* 체력이 변경되면 체력 슬라이더에 반영

* 공격받으면 피격 효과음 재생

* 사망시 플레이어의 다른 컴포넌트를 비활성화

* 사망시 사망 효과음과 사망 애니메이션 재생

* 아이템을 감지하고 사용  

**OnEnable()**  

```cs
protected override void OnEnable() {
        // LivingEntity의 OnEnable() 실행 (상태 초기화)
        base.OnEnable();

        // 체력 슬라이더 활성화
        healthSlider.gameObject.SetActive(true);
        // 체력 슬라이더의 최대값을 기본 체력값으로 변경
        healthSlider.maxValue = startingHealth;
        // 체력 슬라이더의 값을 현재 체력값으로 변경
        healthSlider.value = health;

        // 플레이어 조작을 받는 컴포넌트 활성화
        playerMovement.enabled = true;
        playerShooter.enabled = true;
    }
```

OnEnable 메서드를 사용해서 초기화를 하게되면 나중에 확장 기능에 대비할 수 있게 된다.  

만약 부활의 기능을 추가한다고 OnEnable로 값을 초기화 한다면 부활시 초기화를 따로 고려하지 않아도 된다.  

<br>

**RestoreHealth()**  

```cs
public override void RestoreHealth(float newHealth) {
        // LivingEntity의 RestoreHealth() 실행 (체력 증가)
        base.RestoreHealth(newHealth);
        // 갱신된 체력으로 체력 슬라이더 갱신
        healthSlider.value = health;
    }
```

생명체의 체력회복의 처리는 이미 상위 클래스에서 구현되어 있기 때문에 그대로 가져와서 사용한다.  

슬라이더에 회복된 체력을 반영해준다.

**OnDamage**  

```cs
// 데미지 처리
public override void OnDamage(float damage, Vector3 hitPoint, Vector3 hitDirection) {
    if (!dead)
    {
        // 사망하지 않은 경우에만 효과음 재생
        playerAudioPlayer.PlayOneShot(hitClip);
    }

    // LivingEntity의 OnDamage() 실행(데미지 적용)
    base.OnDamage(damage, hitPoint, hitDirection);
    // 갱신된 체력을 체력 슬라이더에 반영
    healthSlider.value = health;
}
```

맞았을 때 우선 피격 사운드를 재생한다. 단, 플레이어가 이미 사망한 상태에서 공격을 받았을 때는 효과음이 재생되는 것을 막기 위해 if 문으로 사망하지 않은 경우에만 효과음을 재생한다.  

<br>

**Die()**  

```cs
// 사망 처리
public override void Die() {
    // LivingEntity의 Die() 실행(사망 적용)
    base.Die();

    // 체력 슬라이더 비활성화
    healthSlider.gameObject.SetActive(false);
    // 사망음 재생
    playerAudioPlayer.PlayOneShot(deathClip);
    // 애니메이터의 Die 트리거를 발동시켜 사망 애니메이션 재생
    playerAnimator.SetTrigger("Die");
    // 플레이어 조작을 받는 컴포넌트 비활성화
    playerMovement.enabled = false;
    playerShooter.enabled = false;
}
```

먼저 base.Die()를 실행하여 LivingEntity의 사망 처리를 실행한 다음 체력 슬라이더의 오브젝트를 비활성화한다.  

오디오 소스로 사망효과음을 재생하고 애니메이터의 Die 트리거를 발동시켜 사망 애니메이션을 재생한다.  

마지막으로 Player Character 오브젝트에 추가된 Player Shooter와 PlayerMovement 컴포넌트를 비활성화해서 더이상 플레이어 조작이 불가능하게 만든다.

<br>

**OnTriggerEnter()**  

```cs
private void OnTriggerEnter(Collider other) {
        // 아이템과 충돌한 경우 해당 아이템을 사용하는 처리
        // 사망하지 않은 경우에만 아이템 사용 가능
        if (!dead)
        {
            // 충돌한 상대방으로부터 IItem 컴포넌트 가져오기 시도
            IItem item = other.GetComponent<IItem>();

            // 충돌한 상대방으로부터 IItem 컴포넌트를 가져오는데 성공했다면
            if (item != null)
            {
                // Use 메서드를 실행하여 아이템 사용
                item.Use(gameObject);
                // 아이템 습득 소리 재생
                playerAudioPlayer.PlayOneShot(itemPickupClip);
            }
        }
    }
```  

우선 사망하지 않은 경우에만 동작하도록 한다.  

사망하지 않았다면 충돌한 오브젝트의 IItem 컴포넌트를 가져와서 만약 컴포넌트를 가지고 있는 오브젝트라면 기능을 수행한다.  

<br>

PlayerHealth 컴포넌트에 필드를 설정해준다.  

* Player Health 컴포넌트  

    Health Slider 필드에 Health Slider 오브젝트 할당

    Death Clip 필드에 Woman Die 오디오 클립 할당
    
    Hit Clip 필드에 Woman Damage 오디오 클립 할당

    Item Pickup Clip 필드에 Pick Up 오디오 클립 할당