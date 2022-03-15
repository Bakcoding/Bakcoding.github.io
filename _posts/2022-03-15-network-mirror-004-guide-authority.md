---
title:  "Mirror Guide 권한"
excerpt: "Network, Mirror, Authority"

categories:
  - Mirror
tags:
  - [Network, Mirror, Authority]

toc: true
toc_sticky: true
 
date: 2022-03-15
last_modified_at: 2022-03-15
---  

***

<br>

## Authority

권한

### 네트워크 권한

  network authority

  누가 오브젝트를 소유하고 있으며 오브젝트를 제어할 어떻게 제어할 수 있는지를 결정하는 방법이다.

* Server Authority

  서버 권한

  서버가 오브젝트를 제어할 수 있음을 의미한다. 기본적으로 서버는 오브젝트에 대한 권한을 가진다.

  즉, 서버는 수집 가능한 아이템, 이동 플랫폼, NPC 및 플레이어가 아닌 다른 네트워크 오브젝트를 관리하고 제어한다.


* Client Authority

  클라이언트가 오브젝트를 제어할 수 있음을 의미한다.

  오브젝트에 대한 권한이 있는 경우 명령어를 호출할 수 있으며 클라이언트의 연결이 끊어지면 오브젝트가 자동으로 파괴된다.

  클라이언트가 오브젝트에 대한 권한이 있는 경우에도 서버는 SyncVar를 제어하고 다른 시리얼화 기능을 제어한다. 컴포넌트는 다른 클라이언트와 동기화 하기 위해 명령어를 사용하여 서버 상태를 갱신해야한다.

<br>

### 권한 부여 방법

기본적으로 서버는 모든 오브젝트에 대한 권한을 가진다. 서버는 플레이어 오브젝트와 같이 클라이언트가 제어해야 하는 오브젝트에 권한을 부여할 수 있다.

NetworkServer.AddPlayerForConnection를 사용하여 플레이어 오브젝트를 생성하는 경우 자동으로 권한이 부여된다.

* Using NetworkServer.Spawn

  오브젝트가 생성될 때 클라이언트에 권한을 부여할 수 있다. 이는 생성 메시지에 대한 연결을 전달함으로써 수행된다.

  ```cs
  GameObject go = Instantiate(prefab);
  NetworkServer.Spawn(go, connectionToClient);
  ```

  <br>

* Using identity.AssignClientAuthority

  AssignClientAuthority를 사용하면 언제든지 클라이언트에게 권한을 부여할 수 있다.

  권한을 부여하고자 하는 오브젝트의 AssignClientAuthority를 호출함으로서 수행할 수 있다.

  ```cs
  identity.AssignClientAuthority(conn);
  ```

  플레이어가 아이템을 집어 들었을 때 다음을 수행할 수 있다.

  ```cs
  // Command on player object
  void CmdPickupItem(NetworkIdentity item)
  {
    item.AssignClientAuthority(connectionToClient);
  }
  ```

  <br>

* 권한을 제거하는 방법

  identity.RemoveClienAuthority를 사용하여 오브젝트의 클라이언트 권한을 제거할 수 있다.

  ```cs
  identity.RemoveClientAuthority();
  ```
  
  플레이어 오브젝트의 권한은 제거할 수 없다.
  대신에 NetworkServer.ReplacePlayerForConnection을 사용해서 플레이어 오브젝트를 교환해야한다.

  <br>

* 권한 있음

  오브젝트에 권한이 주어지거나 제거될 때 클라이언트에게 알리기 위해 메시지가 전송된다.

  이로 인해서 OnStartAuthority 또는 OnStopAuthority 메서드를 호출하게 된다.

* 권한 확인

  **Client Side**  

  identity.hasAuthority 속성을 사용해서 로컬 플레이어가 오브젝트에 대한 권한을 가지고 있는지 확인할 수 있다.

  **Server Side**

  identity.connectionToClient 속성을 사용해서 클라이언트가 오브젝트에 대한 권한을 가지고 있는지 확인할 수 있다.  

  만약 null이라면 서버가 권한을 가진다.