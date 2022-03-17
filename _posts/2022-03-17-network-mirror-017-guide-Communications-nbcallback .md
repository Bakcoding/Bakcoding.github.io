---
title:  "Mirror Guide Communications - NetworkBehaviour Callbacks"
excerpt: "Network, Mirror, Communications, NetworkBehaviour"

categories:
  - Mirror
tags:
  - [Network, Mirror, Communications, NetworkBehaviour]

toc: true
toc_sticky: true
 
date: 2022-03-17
last_modified_at: 2022-03-17
---  

***

<br>

### Network Behaviour

일반적인 멀티플레이어 게임 과정에서 발생할 수 있는 네트워크 동작과 관련된 여러 이벤트들이 있다.
호스트 시작, 플레이어 참가, 퇴장 등 이러한 이벤트에는 각각 관련 콜백이 있으며 이벤트 발생 시 독자적인 코드로 구현하여 동작을 취할 수 있다.

NetworkBehaviour에서 상속받은 스크립트의 가상 메서드에 오버라이드해서 지정된 이벤트가 발생했을 때 동작을 구현할 수 있다.

<a href="https://mirror-networking.com/docs/api/Mirror.NetworkBehaviour.html">NetworkBehaviour Reference</a>

<br>

#### Server Only

* OnStartServer

  behaviour가 서버에서 생성될 때 호출된다.

* OnStopServer

  behaviour가 서버에서 파괴되거나 사라질 때 호출된다. 

* OnSerialize

  behaviour가 클라이언트에 전송되기 전 base.OnSerialize를 오버라이드를 해서 직렬화될 때, 

<br>

#### Client Only

* OnStartClient

  behaviour가 클라이언트에 생성될 때 호출된다.

* OnStartAuthoriy

  로컬 플레이어처럼 behaviour가 생성되어서 권한을 얻을 때 호출된다.

  behaviour가 서버에 의해서 권한이 부여될 때 호출된다.

* OnStopAuthority

  로컬 플레이어가 교체되었지만 파괴되진 않았을 때 처럼 오브젝트에서 권한을 빼앗을 때 호출된다.

* OnStopClient

  ObjectDestroyMessage 또는 ObjectHideMessage로 클라이언트의 오브젝트가 파괴될 때 호출된다.

<br>

### Example Flows

호출의 순서

시작은 첫 번째 프레임 전에 Unity에 의해 호출되지만 일반적으로 Mirror의 콜백 후에 발생한다. 하지만 NetworkServer.Spawn을 호출하지 않으면 instantiate와 동일한 프레임을 생성한 후 Start를 먼저 호출할 수 있다.

<br>

#### Server Mode

NetworkServer.Spawn이 호출될 때 

* OnStartServer -> OnRebuildObservers -> Start

<br>

#### Client Mode

로컬 플레이어가 클라이언트에 생성될 때

OnStartAuthority -> OnStartClient -> OnStartLocalPlayer -> Start

<br>

#### Host Mode

Player Game Objects가 클라이언트에 연결 될 때만 호출된다.

* OnStartServer -> OnRebuildObservers -> OnStartAuthority -> OnStartClient -> OnSetHostVisibility -> OnStartLocalPlayer -> Start

