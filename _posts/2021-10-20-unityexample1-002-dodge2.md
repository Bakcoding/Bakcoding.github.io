---
title:  "[레트로의 유니티] 닷지2"
excerpt: "unity3d, retro, example, dodge"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, dodge]

toc: true
toc_sticky: true
 
date: 2021-10-20 
last_modified_at: 2023-06-04
---  

***

### 1. 탄알 오브젝트 만들기

총알 오브젝트는 생성 후 앞쪽 방향으로 이동한다. 벽과 충돌시 총알은 제거되며 플레이어와 충돌 시 게임이 종료된다.  

* Bullet 게임 오브젝트 생성  

  Sphere 오브젝트 생성  

  Create > 3D Object > Sphere  

  이름을 Bullet으로, 위치 (0, 5, 0), 스케일 (0.5, 0.5, 0.5)로 변경한다.  

* Bullet 머티리얼 생성  

  머티리얼을 BulletColor이름으로 생성한다. 컬러는 (255, 0, 0), 드래그앤드롭으로 Bullet에 적용시켜준다.  

* 리지드바디 추가  
  탄알의 움직임과 충돌을 판정하기 위해서 컴포넌트를 추가해주고 중력 영향은 필요없기 때문에 Use Gravity를 체크해제한다.

* 콜라이더 설정  

  콜라이더의 기본 상태에서는 충돌된 물체끼리 물리적 작용까지 하게된다.  

  총알의 경우 충돌 여부만 확인하면 되기 때문에 콜라이더 컴포넌트 설정 중에 Is Trigger에 체크를 해준다.  

  ![set_collider](/assets/images/posting/20211020/set_collider.png)

* Bullet 프리팹 만들기  

  기본적으로 사용하게될 오브젝트는 프리팹으로 만들어야 관리와 수정이 용이하다.  

  Hierarchy 창의 Bullet 오브젝트를 드래그해서 Project로 드롭한다.  

* 탄알 스크립트 준비  

  탄알이 실제로 동작할 수 있도록 Bullet 스크립트를 생성한다.  

  ```c#
  // Bullet.cs
  using System.Collections;
  using System.Collections.Generic;
  using UnityEngine;

  public class Bullet : MonoBehaviour
  {
      // 총알의 속도 변수
      public float speed = 8f;
      private Rigidbody bulletRigidbody;

      private void Start()
      {
          bulletRigidbody = GetComponent<Rigidbody>();
          // 총알의 앞 방향 * 속도
          bulletRigidbody.velocity = transform.forward * speed;
          // 3초 뒤 오브젝트 파괴
          Destroy(gameObject, 3f);
      }

      private void OnTriggerEnter(Collider other)
      {
          // Player 태그를 통해 충돌 확인
          if (other.tag == "Player")
          {
              // 충돌한 Player 컴포넌트 가져온다.  
              PlayerController playerController = other.GetComponent<PlayerController>();
              // 컴포넌트를 가져왔다면  
              if (playerController != null)
              {
                  // 플레이어의 Die 메서드 실행
                  playerController.Die();
              }
          }
      }
  }
  ```

<br/>

### 2. 탄알 생성기 준비  

랜덤한 시간 간격으로 플레이어 방향으로 총알을 생성하는 오브젝트를 만든다.  

* Bullet Spawner 오브젝트 생성  

  Create > 3D Object > Cylinder

  이름을 BulletSpawner, 위치 (8, 1, 0)로 변경하고 머티리얼은 BulletColor를 재사용한다.  

* 스크립트 추가

  ```c#
  // BulletSpawner.cs
  using System.Collections;
  using System.Collections.Generic;
  using UnityEngine;

  public class BulletSpawner : MonoBehaviour
  {
      // 생성할 탄알의 원본 프리팹
      public GameObject bulletPrefab;
      // 최소 생성 주기
      public float spawnRateMin = 0.5f;
      // 최대 생성 주기  
      public float spawnRateMax = 3f;

      // 발사할 대상
      private Transform target;
      // 생성 주기
      private float spawnRate;
      // 최근 생성 시점에서 지난 시간
      private float timeAfterSpawn;

      private void Start()
      {
          // 최근 생성 이후의 누적 시간을 0으로 초기화
          timeAfterSpawn = 0f;
          // 탄알 생성 간격을 spawnRateMin과 spawnRateMax 사이에서 랜덤 지정
          spawnRate = Random.Range(spawnRateMin, spawnRateMax);
          // PlayerController 컴포넌트를 가진 게임 오브젝트를 찾아 조준 대상으로 설정
          target = FindObjectOfType<PlayerController>().transform;
      }

      private void Update()
      {
          // timeAfterSpawn 갱신
          timeAfterSpawn += Time.deltaTime;
          // 최근 생성 시점에서부터 누적된 시간이 생성 주기보다 크거나 같다면
          if (timeAfterSpawn >= spawnRate)
          {
              // 누적된 시간을 리셋
              timeAfterSpawn = 0f;
              // bulletPrefab의 복제본을 회전
              GameObject bullet = Instantiate(bulletPrefab, transform.position, transform.rotation);
              // 생성된 bullet을 정면 방향이 target을 향하도록 회전
              bullet.transform.LookAt(target);
              // 다음번 생성 간격을 재조정
              spawnRate = Random.Range(spawnRateMin, spawnRateMax);
          }
      }
  }
  ```  

  스크립트의 Bullet Prefab에 Bullet 오브젝트를 등록해준다.  

  완성된 탄알 생성기는 프리팹으로 만들어주고 씬에 여러개 배치해준다.  

  Hierarchy 창을 정리하기 위해 탄알 생성기 프리팹은 Level 오브젝트의 자식으로 추가해준다.  

  BulletSpawner (1) 위치 (-8, 1, 0)
  BulletSpawner (2) 위치 (0, 1, 8)
  BulletSpawner (3) 위치 (0, 1, -8)

  ![bullet_test](/assets/images/posting/20211020/bullet_test.gif)  
  