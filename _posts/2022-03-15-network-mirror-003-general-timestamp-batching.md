---
title:  "Timestamp batching"
excerpt: "Network, Mirror"

categories:
  - Mirror
tags:
  - [Network, Mirror]

toc: true
toc_sticky: true
 
date: 2022-03-15
last_modified_at: 2022-03-15
---  

***

<br>

### Timestamp Batching

Mirror만의 범용 월드 동기화 방식이다. 이 방식은 Mirror의 아키텍쳐에 잘 맞기 때문에 어떠한 종류의 프로젝트를 진행하든 대역폭을 줄이는데 도움이된다.

<br>

#### Batching

전송되는 모든 메시지는 대역폭과 전송 호출을 최소화하기 위해 프레임 끝까지 일괄 처리된다.

예를 들어 10바이트 메시지를 여러개 보내는 경우 일반적으로 약 1200바이트 크기의 MTU(Maximum Transmit Unit, 최대 전송 단위)로 하나의 배치에 최대 120바이트를 넣을 수 있다. transport의 경우 1200바이트 단위로 전송하는 것이 매우 편리하다. MTU보다 큰 메시지는 단일 배치로 전송된다. 

정확히는 Transport.GetBatchThreshold() 를 통해서 mirror가 지향하는 배치의 크기를 transport가 결정한다.

Mirror 배칭은 양방향이다. 클라이언트와 서버 모두 메시지를 일괄처리하여 프레임 끝에서 flush한다.

정리하면 Mirror는 Batching(일괄 처리)를 통해 대역폭이 크게 감소하고 성능이 향상된다.

<br>

#### Timestamp
일부 네트워킹 컴포넌트는 원격에서 메시지를 보낸 시간을 정확하게 알 수 있다.

ex) 
NetworkTransform은 서버의 위치를 수신한 다음 그 사이를 보간한다. 원활한 보간을 위해서는 서버에서 일어난 일을 정확하게 재구성해야한다. 

그러기 위해서는 오브젝트가 서버에서 특정 위치 어디에 있는지 알아야하는데 확실한 해결책은 계속해서 timestamp와 position을 전송하는 것이다.

```cs
[RPC]
public void RpcPositionUpdate(float timestamp, Vector3 position){~}
```

위의 코드는 매 프레임 timestamp와 position을 가져온다. 매번 4바이트 float을 포함해야 하기 때문에 상당한 대역폭 비용을 지불한다. 더 큰 스케일의 게임을 동기화하게 된다면 그 증가폭은 급격하게 늘어난다.

NetworkTransform은 많은 컴포넌트 중 하나이며 다른 여러 개의 타임스탬프가 필요할 수 있으므로 대역폭은 더 늘어날 수 있다. 따라서 Mirror는 모든 배치에 8바이트의 이중 정밀도 타임스탬프를 포함한다. 모든 메시지를 포함시키지 않는 대신에 대역폭에 있어서는 거의 눈에 띄지 않는 정도인 개당 약 1200바이트의 배치가 포함된다.

메시지 핸들러의 경우 NetworkConnection.remoteTimeStamp를 통해 도착한 배치에서 타임스탬프를 가져올 수 있다.

* 클라이언트에는 모든 오브젝트가 서버로 부터 메시지/배치 정보를 가지고 오기 때문에 언제든지 오브젝트가 Rpc/OnDeserialize/OnMessage 핸들러가 서버에서 NetworkClient.connection.remoteTimeStamp를 통해 전송된 시기를 확인할 수 있다.
 
* 클라이언트에서는 오브젝트를 소유한 플레이어만 서버에 연결되기 때문에 오브젝트의 ConnectionToServer를 사용하지 않는다. 대신에 클라이언트 NetworkClient 서버에 대한 연결을 사용하며 이 연결은 항상 유지된다.

* 서버에서는 플레이어 소유 객체만 플레이어 연결로부터 메시지를 받는다. 따라서 클라이언트가 connectionToClient.remoteTimeStamp를 통해 오브젝트의 Cmd/OnDeserialize/OnMessage 처리기를 전송했을 때를 언제든지  찾을 수 있다.
