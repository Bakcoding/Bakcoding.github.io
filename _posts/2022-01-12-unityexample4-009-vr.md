---
title:  "[왕초보도 할 수 있는 VR] 타워디펜스 7 - 적 공격"
excerpt: "unity3d, vr, collision"

categories:
  - UnityExample
tags:
  - [unity3d, vr, collision]

toc: true
toc_sticky: true
 
date: 2022-01-12 
last_modified_at: 2023-06-05
---  

***  
<a href="https://www.gseek.kr/member/rl/studyRoom/studyRoomMain.do?courseSeq=2069&courseCsSeq=1&stuSeq=&subjSeq=5&pageNum=1">VR 강의</a>

Unity version 2018.1.1f1

### 충돌

적과의 충돌을 이용하여 공격을 구현한다.  

Tower > Main Camera 의 Gun 컴포넌트

Explosion 필드에 드론이 피격시 효과를 추가한다.  

Workshop > Effect > Explosion 오브젝트를 게임 씬에 생성한 다음 Explosion 필드에 추가한다.  

공격을 구현하기 위해서 충돌체로 만들어준다.  

#### 콜라이더 추가

충돌을 확인하기 위해서는 충돌체로 만들어야하며 이때 충돌 영역을 정하는 Collider 컴포넌트가 필요하다.  

Drone 오브젝트 > Sphere Coliider를 추가한다.  

<br>

### 스크립트

```cs
// 이름에 Drone이 포함된 오브젝트와 충돌 검사
                    if (hitInfo.transform.name.Contains("Drone"))
                    {
                        // 드론과 충돌시 폭발 이펙트가 있다면
                        if (explosion)
                        {   
                            // 이펙트 재생
                            explosion.position = hitInfo.transform.position;
                            explosionPs.Stop();
                            explosionPs.Play();
                            // 소리
                            explosion.GetComponent<AudioSource>().Stop();
                            explosion.GetComponent<AudioSource>().Play();

                        }
                        // 드론 오브젝트는 삭제
                        Destroy(hitInfo.transform.gameObject);
                    }
```

<br>
<img src="../assets/images/posting/20220112/play.gif" title="play" width="400px">
<br>