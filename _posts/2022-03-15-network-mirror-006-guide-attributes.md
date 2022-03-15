---
title:  "Mirror Guide Attributes"
excerpt: "Network, Mirror, Attributes"

categories:
  - Mirror
tags:
  - [Network, Mirror, Attributes]

toc: true
toc_sticky: true
 
date: 2022-03-15
last_modified_at: 2022-03-15
---  

***

<br>

### Attributes

Networking 속성은 네트워크 Behaviour 스크립트의 멤버 변수에 추가되어 클라이언트 또는 서버에서 실행할 수 있도록 한다.

이 속성은 유니티 게임 루프 메서드인 Start 또는 Update 같은 기타 구현된 다른 메서드들처럼 사용될 수 있다. 

**주의**  

추상 메서드 또는 가상 메서드를 사용할 경우 속성을 오버라이드 메서드에도 적용해야 한다.

* \[Server\]

  오직 서버에서만 호출할 수 있는 메서드이다. 

  클라이언트에서 호출 시 경고를 발생시킨다.

* \[ServerCallback\]

  Server와 유사하지만 클라이언트에서 호출해도 경고를 발생시키지 않는다.

* \[Client\]

  오직 클라이언트에서만 호출할 수 있는 메서드이다. 

  서버에서 호출 시 경고를 발생시킨다.

* \[ClientCallback\]

  Client와 유사하지만 서버에서 호출해도 경고를 발생시키지 않는다.

* \[Command\]

  클라이언트에서 호출하여 이 기능을 서버에서 실행시킨다.

  입력 등의 유효성을 확인한다. 서버에서 호출할 수 없다.

  서버에서 호출하려면 이 기능을 다른 함수에 대한 wrapper로 사용해야한다. 


* \[TargetRpc\]

  이것은 Network Behavior 클래스의 메서드에 배치하여 서버에서 클라이언트로 호출할 수 있는 속성이다.

  ClientRpc 속성과 달리 이러한 함수는 모든 준비된 클라이언트들이 아닌 하나의 개별 타겟 클라이언트에서 호출된다. 

* \[SyncVar\]

  SyncVars는 서버에서 모든 클라이언트로 변수를 자동으로 동기화하기 위해 사용된다.

  클라이언트에게 할당하는것은 무의미하며 null로 만들면 에러를 발생시킨다.

  int, long, float, string, Vector3 등 모든 간단한 유형과 Network Identity 및 게임 오브젝트에 Network Identity가 연결되어 있는 경우 사용할 수 있다. 

  SyncVar Hooks를 사용하여 클라이언트에서 업데이트를 받을 때 코드를 실행할 수 있다.