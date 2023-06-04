---
title:  "[레트로의 유니티] 좀비서바이벌7 - 슈터"
excerpt: "unity3d, retro, example, zombie, ik"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, ik]

toc: true
toc_sticky: true
 
date: 2021-12-07 
last_modified_at: 2021-12-07
---  

***  

### 슈터  

실제로 총을 쏘는 역할을 한다.  

플레이어 입력에 따라 총을 쏘거나 재장전을 한다.  

플레이어 캐릭터의 손이 항상 총의 손잡이에 위치하도록 한다.  

<br>

### 애니메이션

* FK

  forward kinematics  

  부모 조인트에서 자식 조인트 순서로 움직임을 적용한다. 자식 조인트는 부모 조인트에 종속되어 있기 때문에 부모 조인트가 움직이면 자식 조인트도 함께 움직인다.  

  FK로 물건을 집는 애니메이션이 동작한다면  

  어깨를 움직인다. -> 어깨에 종속된 팔이 움직인다. - > 팔에 종속된 손이 움직인다.  

  큰 단위의 관절에서 세부적인 관절 순서로 움직임을 적용한다. 따라서 FK에서는 손의 최종 위치는 상위에서 하위 순서대로 누적된 움직임으로 결정된다.  

  즉 FK로 물건을 집는다면 물건의 위치에 맞춰 손의 위치를 변형할 수 없기 때문에 물건을 손의 위치로 순간이동 시켜게 된다.  

* IK

  inverse kinematics 

  역운동학  

  자식 조인트의 위치를 먼저 결정하고 부모 조인트가 거기에 맞춰 변형된다.  

  만약 물건을 집는 애니메이션이 재생된다고하면 

  손의 위치가 물건의 위치로 이동 -> 팔이 손의 위치에 맞춰 이동 -> 어깨가 팔의 위치에 맞춰 이동

  즉 IK를 사용하면 하위 조인트의 위치를 먼저 결정하고 그 위치에 따라서 상위의 조인트들의 위치가 결정되기 때문에 자연스러운 움직임을 만들 수 있다.  

따라서 플레이어가 총을 잡고 쏘는 동작을 자연스럽게 적용시키기 위해서는 IK를 사용하여야한다.  

Player Character의 Animator 창의 컨트롤러의 레이어에 IK Pass 설정을 킨다.  

애니메이터 컴포넌트가 IK 정보를 갱신할 때마다 OnAnimatorIK 메시지가 발생하게 되고 스크립트 상에서 메서드로 구현하면 IK를 어떻게 사용할지 정의할 수 있다.  

<br>

#### 적용하기  

Assets > Scripts > PlayerShooter 스크립트를 Player Character에 추가한다.  

```cs
using UnityEngine;

// 주어진 Gun 오브젝트를 쏘거나 재장전
// 알맞은 애니메이션을 재생하고 IK를 사용해 캐릭터 양손이 총에 위치하도록 조정
public class PlayerShooter : MonoBehaviour {
    public Gun gun; // 사용할 총
    public Transform gunPivot; // 총 배치의 기준점
    public Transform leftHandMount; // 총의 왼쪽 손잡이, 왼손이 위치할 지점
    public Transform rightHandMount; // 총의 오른쪽 손잡이, 오른손이 위치할 지점

    private PlayerInput playerInput; // 플레이어의 입력
    private Animator playerAnimator; // 애니메이터 컴포넌트

    private void Start() {
        // 사용할 컴포넌트들을 가져오기
        playerInput = GetComponent<PlayerInput>();
        playerAnimator = GetComponent<Animator>();
    }

    private void OnEnable() {
        // 슈터가 활성화될 때 총도 함께 활성화
        gun.gameObject.SetActive(true);
    }
    
    private void OnDisable() {
        // 슈터가 비활성화될 때 총도 함께 비활성화
        gun.gameObject.SetActive(false);
    }

    private void Update() {
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
        // 남은 탄알 UI 갱신
        UpdateUI();
    }

    // 탄약 UI 갱신
    private void UpdateUI() {
        if (gun != null && UIManager.instance != null)
        {
            // UI 매니저의 탄약 텍스트에 탄창의 탄약과 남은 전체 탄약을 표시
            UIManager.instance.UpdateAmmoText(gun.magAmmo, gun.ammoRemain);
        }
    }

    // 애니메이터의 IK 갱신
    private void OnAnimatorIK(int layerIndex) {
        // 총의 기준점 gunPivot을 3D 모델의 오른쪽 팔꿈치 위치로 이동
        gunPivot.position = playerAnimator.GetIKHintPosition(AvatarIKHint.RightElbow);

        // IK를 사용하여 왼손의 위치와 회전을 총의 왼쪽 손잡이에 맞춤
        playerAnimator.SetIKPositionWeight(AvatarIKGoal.LeftHand, 1.0f);
        playerAnimator.SetIKRotationWeight(AvatarIKGoal.LeftHand, 1.0f);

        playerAnimator.SetIKPosition(AvatarIKGoal.LeftHand, leftHandMount.position);
        playerAnimator.SetIKRotation(AvatarIKGoal.LeftHand, leftHandMount.rotation);

        // IK를 사용하여 오른손의 위치와 회전을 총의 오른쪽 손잡이에 맞춤
        playerAnimator.SetIKPositionWeight(AvatarIKGoal.RightHand, 1.0f);
        playerAnimator.SetIKRotationWeight(AvatarIKGoal.RightHand, 1.0f);

        playerAnimator.SetIKPosition(AvatarIKGoal.RightHand, rightHandMount.position);
        playerAnimator.SetIKRotation(AvatarIKGoal.RightHand, rightHandMount.rotation);
    }
}
```

PlayerShooter 컴포넌트 설정하기  

Gun 게임 오브젝트를 Gun 필드로  

Gun Pivot 게임 오브젝트를 Gun Pivot 필드로  

Left Handle 게임 오브젝트를 Left Hand Mount 필드로  

Right Handle 게임 오브젝트를 Right Hand Mount 필드로  

![play](/assets/images/posting/20211207/play_scene.gif)