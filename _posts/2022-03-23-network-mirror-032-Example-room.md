---
title:  "Mirror Example - Room"
excerpt: "Network, Mirror, Example, Room"

categories:
  - Mirror
tags:
  - [Network, Mirror, Example, Room]

toc: true
toc_sticky: true
 
date: 2022-03-23
last_modified_at: 2022-03-23
---  

***

<br>

## Room Example

이번 예제는 서버나 호스트가 방을 만들고 클라이언트가 참가하는 방식이다.  

방을 생성한 곳에서 참가한 플레이어의 퇴장이 가능하고 모든 플레이어가 준비시 게임을 시작할 수 있다.

또한 호스트나 서버가 게임에서 방으로 돌아가게되면 모든 클라이언트들이 방으로 이동한다.

게임 중 나간 클라이언트는 호스트나 서버가 방으로 갈 때까지 다시 참가하지 못한다.

<br>

### Scene

세 개의 씬으로 구성되어있다. 

* Offline Scene : 호스트, 서버, 클라이언트 중 선택한다. 

* Room Scene : 호스트, 서버가 생성될 때 방이 만들어진다.

* Online Scene : 게임이 플레이되는 씬이다.

<br>

#### Offline Scene

NetworkRoomManager 오브젝트에 있는 NetworkRoomManagerExt 스크립트로 기본적으로 네트워크가 만들어진다.

![room](/assets/images/20220323_Posting/room.png)
<br>

*   SceneManagement

    Offline Scene : OfflineScene

    Online Scene : RoomScene

    네트워크에 연결되면 RoomScene을 로드한다.

*   Player Object

    플레이어로 사용할 프리팹

