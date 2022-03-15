---
title:  "Mirror Guide IDs"
excerpt: "Network, Mirror, IDs"

categories:
  - Mirror
tags:
  - [Network, Mirror, IDs]

toc: true
toc_sticky: true
 
date: 2022-03-15
last_modified_at: 2022-03-15
---  

***

<br>

## IDs

### Asset Id

Mirror는 Asset Id를 위해 GUID를 사용한다. 

모든 NetworkIdentity 컴포넌트가 있는 프리팹은 Asset Id를 가진다. 

이것은 단순히 유니티의 AssetDatabase.AssetPathToGUID에 16바이트로 변환된다. 

Mirror는 어떤 프리팹이 생성되는지 알필요가 있기 때문에 그것이 필요하다. 

<br>

### Scene Id

Mirror는 Scene Ids에 uint(32-bit unsigned integer)를 사용한다.

Scene(hierachy)에 있는 NetworkIdentity를 가지는 모든 게임 오브젝트는 OnPostProcessScene의 Scene id가 할당된다.

<br>

### Network Instance Id(akaNetId) 

Mirror는 NetId에 uint를 사용한다. 

모든 NetworkIdentity는 NetworkIdentity.OnStartServer 안에서 또는 생성된 후 NetId가 할당된다.

Mirror는 클라이언트와 서버 간에 메시지를 전달할 때 ID를 사용하여 메시지의 수신받는 오브젝트를 식별한다.

<br>

### Connection Id

모든 네트워크 연결에는 낮은 수준의 전송 계층에 의해 할당되는 연결 ID가 있다. 서버가 클라이언트(호스트)이기도 한 경우 연결 ID는 0으로 로컬 연결용이 예약된다.
