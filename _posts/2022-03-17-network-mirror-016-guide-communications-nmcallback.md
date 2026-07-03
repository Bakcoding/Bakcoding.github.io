---
title:  "Mirror Guide Communications - NetworkManager Callbacks"
excerpt: "Network, Mirror, Communications, NetworkManager"

categories:
  - Mirror
tags:
  - [Network, Mirror, Communications, NetworkManager]

toc: true
toc_sticky: true
 
date: 2022-03-17
last_modified_at: 2022-03-17
---  

***

<br>

### Network Manager

멀티플레이어 게임의 통상적인 운용 과정에서 호스트 기동, 플레이어 참가, 퇴장 등 다양한 이벤트가 발생할 수 있다. 이러한 이벤트에는 각각 관련 콜백이 있어 이벤트 발생시 독자적인 코드로 구현하여 동작을 취할 수 있다.

NetworkManager에서 이를 수행하려면 상속되는 자체 스크립트를 작성해야한다. 그 다음 특정 이벤트가 발생했을 때 작업을 가상 메서드에 오버라이드해서 구현한다.

게임은 호스트, 클라이언트 또는 서버 전용 3가지 모드 중 하나로 실행할 수 있다. 


<a href="https://mirror-networking.com/docs/api/Mirror.NetworkManager.html">NetworkManager Reference</a>

<br>

#### Host Mode

**Host가 시작될 때**  

* OnStartServer

* OnStartHost

* OnServerConnect

* OnStartClient

* OnClientConnect

* OnServerSceneChanged

* OnServerReady

* OnServerReady

* OnServerAddPlayer

* OnClientChangeScene

* OnClientSceneChanged

<br>

**Client 연결될 때**  

* OnServerConnect

* OnServerReady

* OnServerAddPlayer

<br>

**Client 연결 끊길 때**

* OnServerDisconnect

<br>

**Host 정지할 때**

* OnStopHost

* OnServerDisconnect

* OnStopClient

* OnStopServer

<br>

#### Client Mode

**Client 시작될 때**

* OnStartClient

* OnClientConnect

* OnClientChangeScene

* OnClientSceneChanged

<br>

**Client 정지할 때**

* OnStopClient

* OnClientDisconnect

<br>


#### Server Mode

**Server 시작될 때**

* OnStartServer

* OnServerSceneChanged

<br>

**Client 연결될 때**

* OnServerConnect

* OnServerReady

* OnServerAddPlayer

<br>

**Client 연결 끊길 때**

* OnServerDisconnect

<br>

**Server 정지할 때**

* OnStopServer

