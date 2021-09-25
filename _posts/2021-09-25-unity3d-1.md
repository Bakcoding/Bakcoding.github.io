---
title:  "유니티 라이프 사이클"
excerpt: "unity3d, engine, lifecycle"

categories:
  - Unity3D
tags:
  - [unity3d, engine, lifecycle]

toc: true
toc_sticky: true
 
date: 2021-09-25 
last_modified_at: 2021-09-25
---  

***

### 유니티
C#과 JavaScript를 스크립트 언어로 사용하며 2D와 3D 작업이 모두 가능한 게임 엔진이다. 무료이며 프로그램 언어의 이해에 대한 요구가 비교적 적기 때문에 접근성이 좋아 세계적으로 많이 사용되는 게임 엔진 중 하나로 다양한 기능들이 추가되면서 게임 엔진 뿐만 아니라 기타 아티스트를 위한 작업도 지원하기도 한다.  

**장점**  

* 멀티 플랫폼을 지원하기 때문에 한 번의 작업으로 빌드설정에 따라 여러 플랫폼에 대응할 수 있다.  

* 에디터를 제공하기 때문에 직관적인 작업을 할 수 있다.  

* 참고할 수 있는 자료들이 많이 있다. 대부분 기능들은 검색을 통해서 구현이 가능하다.  

* 에셋 스토어를 통해 소스를 구하기 편하다.  

**단점**  

* 사용자의 접근성에 제한적이다.  

* 최적화가 상대적으로 힘들다.  

* 버전간의 호환성이 떨어진다.  


기본적으로 제공하는 기능들 덕에 개발에 편의성을 제공하지만 동시에 사용자가 직접 손댈 수 있는 부분도 제한적이게 된다.  
메모리 관리 측면에서 C++이라면 할당과 해제를 통해 직접 관리할 수 있지만 유니티의 경우 garbage collection 방식으로 메모리를 관리하기 때문에 사용자가 관여할 수 없게 된다.  

* 쓰레기 수집(garbage collection)  
  메모리 누수를 방지하기 위한 방법으로 주기적으로 전체 메모리를 순회하며 시스템에서 더 이상 사용하지 않는 메모리를 찾아 지우는 방식이다.  

  사용자가 메모리 관리에 신경쓰지 않아도 되는 편함이 있지만 해제 시점을 알 수 없고 메모리를 순회하는데도 비용이 발생하는 단점도 있다.  

<br/>

### Behaviour Script  
유니티는 하나의 스크립트가 그 자체로 하나의 클래스를 의미하게 된다. C#은 다른 파일에 있는 클래스를 참조하는 경우 파일이 프로젝트에 포함되어 있고 동일한 네임스페이스라면 include 없이도 호출하여 사용이 가능하다.  

유니티의 모든 스크립트는 MonoBehaviour를 상속받으며 이 클래스는 사용자가 엔진의 작동 방식을 이해하지 못해도 유니티의 기본적인 기능들을 사용하기 위한 코드를 작성할 수 있도록 만든 스크립트 명령어들의 집합이다.  

스크립트를 생성하면 기본적인 포맷을 가지고 있으며 클래스 내에서 스크립트 명령어들을 호출하여 사용하면 된다.    

```c#
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UnityScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
```

접근 제한자는 생략이 가능하며 기본적으로 private 상태이다. 다른 클래스에서 호출하기 위해서는 public 상태여야한다.  

<br/>

### 라이프 사이클 (life cycle)
유니티에서 호출되는 함수들은 우선 순위를 가지게 되는데 이 부분에서 문제가 생기면 의도한대로 동작하지 않거나 오류가 발생하기도 한다.  

기능들을 제대로 활용하기 위해서 반드시 숙지해야할 부분이다.  


![lifecycle](/assets/images/20210925_Posting/1.png)  


### 1.Editor  
  에디터 모드에서 값이 변경될 때 바로 반영된다.  
  스크립트에서 변수를 할당하고 다시 에디터로 돌아오면 로딩이 발생하고 public으로 선언했다면 인스펙터 창에서 별도의 실행과정 없이 확인이 가능하다.  

  ```c#
  using System.Collections;
  using System.Collections.Generic;
  using UnityEngine;

  public class UnityScript : MonoBehaviour
  {
      public int number = 0;
  }
  ```
![inspector1](/assets/images/20210925_Posting/2.png) 

변수가 처음 할당될 때 초기화가 한 번 진행되면서 인스펙터 창에 바로 반영이 된다. 하지만 이후에 초기화 값을 변경하더라도 인스펙터 창의 값은 변하지 않는데 스크립트의 reset으로 다시 초기화를 시킬 수 있다.  
  
  * Reset  
    오브젝트를 생성하고 인스펙터 창에서 리셋을 할 때 실행된다. 객체의 값을 초기값으로 설정할 때 사용된다.  

```c#
public int number = 10;
```

![inspector2](/assets/images/20210925_Posting/3.png) 


number의 값을 바꾸고 스크립트를 Reset 해주면 값이 다시 초기화 되면서 반영된다.  


### 2. Initialization
초기화 함수들이 여러가지 존재하며 순서에 따라서 적절한 배치가 필요하다.  

  * Awake()  
    플레이 모드에서 씬이 시작되고 프리팹의 인스턴스화 직후에 호출되는 콜백함수이다. 시작시 한 번만 호출되며 오브젝트의 활성화 여부와 상관없이 실행된다.    

  * OnEnable()  
    Awake 다음의 우선순위를 가지며 한 번만 호출되는 Awake나 다음에 오는 Start와 달리 라이프 사이클 동안 여러번 호출이 될 수 있다.  

    오브젝트가 활성화 될 때 마다 호출된다.   
    
  * Start()
    다른 초기화 함수들 이후 그리고 모든 업데이트 함수들 이전에 호출된다. Awake와 달리 오브젝트가 활성화 되어있어야만 호출이 된다.  

    ```c#
    public int number = 10;

    private void Awake()
    {
        number = 20;
    }

    private void OnEnable()
    {
        number = 30;
    }

    private void Start()
    {
        number = 40;
    }
    ```

    위 코드가 실행되면 가장 마지막에 동작하는 number = 40의 값으로 초기화 된다.  

    플레이 중에 오브젝트를 비활성화 후 다시 활성화하면 OnEnable()이 호출되어 30으로 바뀌는걸 확인할 수 있다.  

    위 초기화는 순서가 명확히 정해저 있기 때문에 Start에서 생성되는 오브젝트를 Awake에서 접근하려고 하면 에러가 발생한다.  

    같은 함수 내에서는 순차적으로 진행되기 때문에 작성 순서도 중요하다.  


### 3. Physics  
게임 내에서 이루어지는 물리적 작용은 물리 주기 내에서 이루어 진다.  

  * FixedUpdate()  
    Update는 매 프레임 호출되는 함수이다.  
    기본 update는 매 프레임 작업이 진행되면서 시간내에 작업이 끝나지 않으면 딜레이 되기도 하지만 FixedUpdate는 수행 시간내에 작업이 끝나지 않더라도 시간이되면 다음 단계로 넘어가기 때문에 문제가 발생하기도 하지만 일정한 주기로 동작할 수 있게 한다.  

    FixedUpdate의 고정된 시간은 Edit -> Project Settings -> Time -> Fixed Timestep 에서 설정이 가능하다. (기본 값 0.02)

  * OnTrigger/Collision - Enter / Stay / Exit  
    충돌체의 충돌을 판정하는 기능의 함수로 Enter는 충돌 순간 Stay는 충돌 중 Exit은 충돌이 끝날 때를 판정할 수 있다.  

    Stay의 경우 프레임 단위로 충돌되는 동안 계속 호출이 된다.  

### 4. Input events  
마우스 입력 판정이 진행되는 주기이다.  

  * OnMouse Over/Enter/Down/Up/Exit/Drag

    Over : 객체 위에 있는 동안 프레임마다 호출  
    Enter : 객체에 들어가는 순간 호출  
    Down : 왼쪽 버튼을 누르는 순간 호출  
    Up : 왼쪽 버튼을 떼는 순간 호출  
    Exit : 객체에서 나오는 순간 호출  
    Drag : 객체를 드래그하는 동안 호출  
    
### 5. Game logic
게임의 전반적인 동작들의 스크립트가 호출되는 주기이다.  

  * Update()  
    매 프레임 호출되는 함수이다. 하드웨어 성능에 따라 시간당 프레임에 차이가 있으며 물리적 작용이 없는 단순 키 입력 등을 받을 때 사용한다.  

  * yield - null/WaitForSeconds/WaitForFixedUpdate/WWW/StartCoroutine  

    코루틴 사용시 지연 시킬 시간들의 유형이다.   

    null : 프레임에 대한 모든 Update 함수가 호출된 후 동작하게 된다.  

    WaitForseconds : 프레임에 대한 모든 Update 함수가 호출된 후 지정된 시간 지연 후 동작한다.  

    WaitForFixedUpdate : 프로젝트내 모든 FixedUpdate 호출 후에 동작한다.  

    WWW : WWW 다운로드 후 동작한다.  

    StartCoroutine : 다른 코루틴이 완료될 때 까지 대기 후 동작한다.  

  * Internal Animation Update  
    애니메이션의 업데이트가 호출되는 구간이다. 
   

  * LateUpdate()  
    모든 업데이트가 호출된 후 마지막에 호출된다.  
    주로 캐릭터들의 동작들이 Update로 진행되기 때문에 LateUpdate에서는 그 캐릭터를 따라다니는 카메라를 배치시킨다.  


### 6. Scene rendering  
실제로 화면에 보여지는 렌더링되는 구간이다.  

  * On -   
    WillRenderObject : 오브젝트가 표시되면 각 카메라에 한 번 호출된다.  

    PreCull : 카메라가 씬을 추려내기 전 호출, Culling으로 카메라에 어떤 오브젝트를 표시할지 결정한다. 즉 컬링 직전에 호출된다.  

    BecameVisible : 오브젝트가 카메라에 표시될 때 호출  

    -InVisible : 카메라에 표시되지 않게 될 때 호출

    PreRender : 카메라가 씬의 렌더링을 시작하기 전에 호출  

    RenderObject : 모든 씬의 렌더링이 종료된 후 호출, 이 시점에서 GL클래스 또는 Graphics.DrawMeshNow를 사용하여 사용자 지정 지오메트리를 그릴 수 있다.  

    PostRender : 카메라가 씬의 렌더링을 종료한 후 호출  

    RenderImage : 화면 렌더링이 완료되고 이미지 처리가 가능하게 된 후 호출  

### 7. Gizmo rendering
기즈모가 그려지는 지점이다. 기즈모는 기본적으로 에디터 모드에서만 볼 수 있지만 GL 클래스를 사용해서 빌드 화면상에도 표시할 수 있는데  

[build-gizmo](https://itch.io/t/162915/drawing-unity-gizmos-in-builds)

이 때 그려지는 시점을 라이프 사이클에 맞춰 OnPostRender로 해주어야 정상적으로 그려지게 된다.  

### 8. GUI rendering  
GUI 이벤트에 따라 프레임마다 여러 차례 호출된다.  
레이아웃, 리페인트 -> 레이아웃, 키보드/마우스 이벤트가 각 입력 이벤트에 대해 처리된다.  

### 9. End of frame
프레임이 끝날 때 마다 호출  

### 10. Pausing  
어플리케이션이 정지될 때 호출

### 11. OnDisable
이 함수를 호출하는 스크립트를 가진 오브젝트가 비활성화 될 때 마다 호출된다.  

### 12. Decommissioning  
라이프 사이클의 끝에 해당한다. 어플리케이션의 종료나 오브젝트가 삭제 될 때의 주기에 해당한다.  

  * OnApplicationQuit() : 어플리케이션이 종료되기 전 모든 게임 오브젝트에서 호출된다. 에디터에서는 사용자가 플레이를 종료할 때, 웹 플레이어라면 웹 뷰가 닫힐 때 호출된다. 

  * OnDisable()

  * OnDestroy() : 오브젝트가 삭제 될 때 마지막 프레임의 업데이트 후 호출된다. 오브젝트는 이 함수가 호출 된 이후 또는 씬 종료시에 삭제된다.  