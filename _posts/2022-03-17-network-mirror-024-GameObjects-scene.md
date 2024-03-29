---
title:  "Mirror Guide GameObjects - Scene"
excerpt: "Network, Mirror, GameObjects, Scene"

categories:
  - Mirror
tags:
  - [Network, Mirror, GameObjects, Scene]

toc: true
toc_sticky: true
 
date: 2022-03-17
last_modified_at: 2022-03-17
---  

***

<br>

### Scene Game Object

Mirror의 멀티플레이어 시스템에서 네트워크화된 게임 오브젝트는 두가지 타입이 있다.

* 런타임 중 동적으로 만들어진것

* 씬에 저장된것

런타임에 동적으로 생성되는 게임 오브젝트는 멀티플레이어 Spawning system을 사용하며 인스턴스화된 프리팹은 Network Manager의 네트워크화된 게임 오브젝트 리스트에 등록되어야 한다.

하지만 씬의 일부로 저장되는 네트워크화 게임 오브젝트는 다르게 처리된다. 이러한 게임 오브젝트는 클라이언트와 서버 모두에서 장면의 일부로 로드되며 멀티플레이어 시스템에 의해 spawn 메시지가 전송되기 전 런타임에 존재한다.

씬이 로드되면 씬의 모든 네트워크 게임 오브젝트가 클라이언트와 서버 모두에서 비활성화된다. 그런 다음 씬이 완전히 로드되면 Network Manager는 씬의 네트워크 게임 오브젝트를 자동으로 처리하여 모든 오브젝트를 등록하고(클라이언트 간에 동기화된다.), 런타임에 생성된 것처럼 활성화한다. 클라이언트가 플레이어 오브젝트를 요청할 때까지 네트워크 오브젝트를 사용할 수 없다.

씬이 로드된 후 동적으로 spawn 하지 않고 네트워크에 연결된 게임 오브젝트를 씬에 저장하면 다음과 같은 이점이 있다.

* 레벨로 로드되기 때문에 런타임 중 일시중지되지 않는다.

* 프리팹과 다른 특정 수정사항이 있을 수 있다.

* 씬의 다른 게임 오브젝트 인스턴스는 그것들을 참조할 수 있기 때문에 게임 오브젝트를 찾고 런타임에 그것들을 참조하기 위해 코드를 사용할 필요가 없어진다.

Network Manager가 네트워크화된 씬 게임 오브젝트를 생성하면 해당 게임 오브젝트는 동적으로 생성된 게임 오브젝트와 동일하게 동작한다. Mirror는 업데이트와 ClientRPC 호출을 전송한다.

클라이언트가 게임에 참여하기 전에 서버에서 씬 게임 오브젝트가 파괴된 경우 참여하는 새 클라이언트에서는 해당 오브젝트가 활성화되지 않는다.

클라이언트가 접속하면 서버에 존재하는 각 씬의 게임 오브젝트에 대해 ObjectSpawnScene spawn 메시지를 보내고 이 메시지는 클라이언트에 표시된다. 메시지는 게임 오브젝트를 활성화하고 서버로부터의 게임 오브젝트의 최신 상태를 나타낸다.

즉, 서버에서 파괴되지 않고 클라이언트에 표시되는 게임 오브젝트만 클라이언트에서 활성화된다. 일반적인 non-Scene 게임 오브젝트처럼 씬 게임 오브젝트는 클라이언트가 게임에 참가할 때 가장 최신 상태로 시작한다.

