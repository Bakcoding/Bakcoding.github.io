---
title:  "Mirror Guide Communications"
excerpt: "Network, Mirror, Communications"

categories:
  - Mirror
tags:
  - [Network, Mirror, Communications]

toc: true
toc_sticky: true
 
date: 2022-03-16
last_modified_at: 2022-03-16
---  

***

<br>

### Communications

멀티플레이어 게임을 만들 때 게임 오브젝트의 속성의 동기화 뿐만 아니라 다른 정보들도 주고받고 반응 해야한다.  

예를 들어 매치 시작, 매치 참가 또는 퇴장시 또는 사용자의 게임 유형마다 고유한 기타 정보를 모든 플레이어에게 전달해야한다.

Mirror Networking HLAPI에서는 이러한 유형의 정보를 전달하는 세 가지 주요 방법이 잇다.

#### Remote Actions

네트워크를 개입시켜 스크립트의 메서드를 호출할 수 있다. 

* 서버 콜 방식은 모든 클라이언트 또는 개개의 클라이언트에 대해서 구체적으로 설정할 수 있다.

* 클라이언트에 서버 상의 메서드를 호출할 수 있다.

* 로컬 프로젝트(멀티플레이어 게임이 아닌)에서 메서드를 호출하는 방법과 매우 유사한 방법으로 데이터를 메서드에 매개 변수로 전달할 수  있다.

<br>

#### Networking Callbacks

네트워킹 콜백을 사용하면 플레이어가 참여 또는 퇴장할 때, 게임 오브젝트가 생성 또는 파괴될 때, 새 장면이 로드될 때 등 게임 진행 중에 발생하는 내장 미러 이벤트에 연결할 수 있다.

구현할 수 있는 네트워킹 콜백에는 2 종류가 있다.

* Network Manager Callback

  NetworkManager 자체에 관한 콜백이다. 클라이언트 접속, 퇴장 등

* Network Behaviour Callbacks

  개별 네트워크 게임 오브젝트와 관련된 콜백이다.  

  Start 함수가 호출되었을 때 또는 새로운 플레이어가 게임에 참여했을 때 이 특정 게임 오브젝트가 수행해야할 작업이다.


<br>

#### Network Messages

네트워크 메시지는 메시지 전송에 대한 low level 접근 방식이다. 하지만 여전히 네트워킹 high level API의 일부로 분류된다.  

스크립트를 사용하여 클라이언트와 서버 간에 직접 데이터를 전송할 수 있다. 기본적인 데이터 타입과 일반적인 Unity의 타입을 송신할 수 있다. 

사용자가 직접 구현하기 때문에 이러한 메시지는 특정 게임 오브젝트나 유니티 이벤트와 직접 관련되지 않는다. 목적을 결정하고 구현하는 것은 개발자에게 달려있다.

