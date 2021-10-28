---
title:  "[레트로의 유니티] 유니런2"
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

### 1. 배경  

게임을 꾸며주는 배경이미지를 추가한다.  

Sprite > Sky 스프라이트를 하이어라키로 드래그앤드롭, 위치 (0, 0, 0)  

* 카메라 배경색 변경  

  배경 스프라이트 색에 맞춰서 카메라의 배경색을 변경한다.  

  Main Camera 오브젝트의 Camera 컴포넌트, Clear Flag를 Solid Color, Background 컬러 (163, 185, 194)로 변경


스프라이트의 개수가 많아졌으니 정렬을 해주어야 원하는대로 화면에 출력된다.  

* 정렬 레이어 추가  

  Sky 스프라이트의 Sprite Renderer  

  Sorting Layer > Default > Add Sorting Layer...  

  Sorting Layers를 추가한다.  

  Background, Middleground, Foreground 이름의 레이어를 추가한다.  


생성한 정렬 레이어를 스프라이트에 할당한다.  

Sky - Background, Player - Foreground, Start Platform - Foreground  

<br/>

### 2. 움직이는 배경  

Sky, Start Platform 게임 오브젝트에 ScrollingObject 스크립트를 추가한다.  

```c#
using UnityEngine;

// 게임 오브젝트를 계속 왼쪽으로 움직이는 스크립트
public class ScrollingObject : MonoBehaviour {
    public float speed = 10f; // 이동 속도

    private void Update() {
        // 게임 오브젝트를 왼쪽으로 일정 속도로 평행 이동하는 처리
        // 초당 speed의 속도로 왼쪽으로 평행이동  
        transform.Translate(Vector3.left * speed * Time.deltaTime);
    }
}
```

**반복되는 배경**  

스프라이트를 이어붙여서 스크롤 시킨다. 앞의 스프라이트가 화면을 벗어날 때 위치를 뒤에 이어붙여서 끊임없이 반복되는 배경을 만든다.  

* Sky  

  스프라이트의 사이즈를 가져와 사용하기 위해서 Sky 게임 오브젝트에 콜라이더를 추가시킨다.  

  Add Component > Box Collider 2D, Is Trigger 옵션을 켠다.  

  BackgroundLoop 스크립트를 추가한다.  

  ```c#
  using UnityEngine;

  // 왼쪽 끝으로 이동한 배경을 오른쪽 끝으로 재배치하는 스크립트
  public class BackgroundLoop : MonoBehaviour {
  private float width; // 배경의 가로 길이

  private void Awake() {
      // 가로 길이를 측정하는 처리
      // BoxCollider2D 컴포넌트의 Size 필드의 X 값을 가로 길이로 사용
      BoxCollider2D backgroundCollider = GetComponent<BoxCollider2D>();
      width = backgroundCollider.size.x;
  }

  private void Update() {
      // 현재 위치가 원점에서 왼쪽으로 width 이상 이동했을때 위치를 리셋
      if (transform.position.x <= -width)
      {
          Reposition();
      }
  }

  // 위치를 리셋하는 메서드
  private void Reposition() {
      // 현재 위치에서 오른쪽으로 가로 길이 * 2 만큼 이동
      Vector2 offset = new Vector2(width * 2f, 0);
      transform.position = (Vector2)transform.position + offset;
        
    }
  }
  ```

  Sky 오브젝트를 복제하고 위치 (20.48, 0, 0) 변경  

  배경을 두개 이어붙여서 무한히 반복되게 한다.  

  ![scroll](/assets/images/20211026_Posting/4.gif)


**오브젝트 정리**  

Background 이름의 빈 오프젝트를 만들고 Sky, Sky (1)을 자식으로 만든다.  
