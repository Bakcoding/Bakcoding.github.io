---
title:  "[왕초보도 할 수 있는 VR] 타워디펜스 3 - 공격"
excerpt: "unity3d, vr"

categories:
  - UnityExample
tags:
  - [unity3d, vr]

toc: true
toc_sticky: true
 
date: 2021-12-24 
last_modified_at: 2021-12-24
---  

***  
<a href="https://www.gseek.kr/member/rl/studyRoom/studyRoomMain.do?courseSeq=2069&courseCsSeq=1&subjSeq=4">VR 강의</a>

Unity version 2018.1.1f1

### 공격

보통의 FPS처럼 카메라의 정중앙에 조준점을 만들어 사용한다.  

Workshop > Scripts > Gun 스크립트를 카메라에 추가한다.

<br>

#### Gun 스크립트 추가

에디터창에서 Gun스크립트의 필드를 채워준다.  

Workshop > Crosshair > 원하는 크로스헤어를 선택하고 하이어라키창으로 드래그앤드롭, 오브젝트로 만들어진 크로스헤어의 크기 0.01, 0.01, 0.01로 변경한다.

* 2D UI를 사용하지 않는 이유는 VR에서는 UI를 반드시 3D로 구현해야하기 때문이다.

크로스헤어 오브젝트를 Cross Hair 필드로 드래그앤드롭한다.  

<br>

#### Effect 추가

Effect는 플레이어로 하여금 제대로 동작하는지 알 수 있는 시각적인 정보를 제공한다.

Workshop > Effects > Stone_BulletImpact 프리팹을 씬에 추가한다.  

생성된 이펙트 오브젝트를 카메라의 Bullet Impact 필드에 드래그앤드롭한다.

<br>

#### Gun.cs

```cs
using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

public class Gun : MonoBehaviour {
	public Transform bulletImpact;
	public Transform explosion;
	ParticleSystem bulletps;
	ParticleSystem explosionPs;

    public Transform crossHair;

    Vector3 originSize;
	void Start()
	{
        // 크로스헤어 기본크기 저장
        originSize = crossHair.localScale * 3.2f;
        if (bulletImpact)
			bulletps = bulletImpact.GetComponent<ParticleSystem>();
		if(explosion)
			explosionPs = explosion.GetComponent<ParticleSystem>();
	}
	void Update () {
		{
            // 충돌 체크를 위한 레이, 카메라의 중심에서 정면으로 나가도록한다.
			Ray ray = new Ray(Camera.main.transform.position, Camera.main.transform.forward);
			RaycastHit hitInfo;

            // 레이가 충돌할 때
			if(Physics.Raycast(ray, out hitInfo))
			{
                // 충돌한 지점의 위치에 크로스헤어가 위치하도록한다.
                // 따라서 맵밖으로 시야를 돌리면 크로스헤어가 잡히지 않는다.
                crossHair.position = hitInfo.point;
                // 크로스헤어의 정면 방향은 카메라를 바라보도록 한다.
                crossHair.forward = -1 * ray.direction;
                // 크로스헤어의 크기를 거리에 변함없이 일정하도록 보정한다.
                crossHair.localScale = originSize * hitInfo.distance;
                // 유니티 InputManager로 마우스 클릭 입력 받는다.
                if (Input.GetButtonDown("Fire1"))
                {
                    // 에디터에서 스크립트의 필드를 채워놓은 경우라면
                    if (bulletImpact)
                    {
                        // 탄흔 이펙트의 up 방향을 충돌한 방향의 노멀벡터로 해준다. 
                        // 이렇게 해야 이펙트가 총알의 입사각에 대응하여 재생된다.
                        bulletImpact.up = hitInfo.normal;
                        // 탄흔 이펙트의 위치는 레이의 충돌지점에서 살짝 띄어주어 오브젝트에 뭍히지 않도록한다.
                        bulletImpact.position = hitInfo.point + hitInfo.normal * 0.2f;
                        // 이펙트 정지 후 재생, 만약 발사를 연속해서 입력한경우 매끄럽게 이펙트가 재생되도록 다시 처음부터 재생되게 한다.
                        bulletps.Stop();
                        bulletps.Play();
                    }
                }
			}
		}
	}
}
```