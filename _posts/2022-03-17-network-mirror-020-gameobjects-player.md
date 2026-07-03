---
title:  "Mirror Guide GameObjects - Player"
excerpt: "Network, Mirror, GameObjects, Player"

categories:
  - Mirror
tags:
  - [Network, Mirror, GameObjects, Player]

toc: true
toc_sticky: true
 
date: 2022-03-17
last_modified_at: 2022-03-17
---  

***

<br>

### Player Game Objects

Mirror는 플레이어 게임 오브젝트와 NPC의 처리 방식이 다르다. 새로운 플레이어가 게임에 참가했을 때(새 클라이언트가 서버에 연결될 때) 그 플레이어의 게임 오브젝트는 해당 클라이언트의 로컬 플레이어 게임 오브젝트가 되며 Unity는 플레이어의 연결을 플레이어의 게임 오브젝트와 연관 시킨다.

Unity는 게임을 플레이하는 사람마다 하나의 플레이어 게임 오브젝트를 연관시켜 네트워크 명령어를 각각의 게임 오브젝트에 라우팅한다. 플레이어는 다른 플레이어의 게임 오브젝트에서는 명령어를 호출할 수 없으며 자신의 게임 오브젝트에서만 명령어를 호출할 수 있다.

<br>

#### Local Player

NetworkBehaviour 클래스(Network 스크립트를 작성하기 위해 파생된 클래스)에는 isLocalPlayer라는 속성이 있다. 각 클라이언트의 플레이어 게임 오브젝트에서 Mirror는 NetworkBehaviour 스크립트의 해당 속성을 true로 설정하고 OnStartLocalPlayer() 콜백을 호출한다.

즉, 각 클라이언트에는 다른 게임 오브젝트가 설정되어 있다. 이는 isLocalPlayer 플래그의 설정으로 구분되며 각 플레이어마다 플래그가 체크된건 자신의 플레이어 게임 오브젝트 뿐이다. 따라서 클라이언트마다 로컬 플레이어를 나타내는 게임 오브젝트가 서로 다르게 된다.

보통 이 플래그를 스크립트로 설정하여 어떤 작업을 수행할 것인지 결정한다.

* 입력의 처리 여부

* 카메라가 게임 오브젝트를 추적여부

* 이벤트 발생 여부

<br>

#### Client-to-Server

플레이어 게임 오브젝트는 서버상의 플레이어를 나타내며 플레이어의 클라이언트에서 명령을 실행할 수 있다. 이 명령어는 안전한 Client-to-Server RPC이다. 이 서버 권한 시스템에서는 다른 none-player 서버 측 게임 오브젝트는 클라이언트 측 게임 오브젝트로부터 직접 명령어를 수신할 수 없다. 이는 보안과 게임 구축의 복잡성을 줄이기 위한 것으로 플레이어 게임 오브젝트를 통해 사용자로부터의 모든 수신 명령어를 라우팅함으로 이러한 메시지가 올바른 장소, 클라이언트에서 전송되어 중앙 위치에서 처리되도록 할 수 있다.


<br>

#### Create Player

Network Manager는 클라이언트가 서버에 접속할 때마다 플레이어를 추가한다. 다만 유저가 컨트롤러의 시작 버튼을 누르는 등 입력 이벤트가 발생할 때까지 플레이어를 추가하지 않는것이 바람직하다. 플레이어를 자동 생성하는것을 비활성화하려면 Network Manager 컴포넌트의 인스펙터 창에서 Auto Create Player의 체크박스를 해제한다.