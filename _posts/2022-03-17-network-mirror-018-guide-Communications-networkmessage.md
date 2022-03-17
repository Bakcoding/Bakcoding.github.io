---
title:  "Mirror Guide Communications - Network Message"
excerpt: "Network, Mirror, Communications, Network-Message"

categories:
  - Mirror
tags:
  - [Network, Mirror, Communications, Network-Message]

toc: true
toc_sticky: true
 
date: 2022-03-17
last_modified_at: 2022-03-17
---  

***

<br>

### Network Message

대부분의 경우 높은 수준인 Commands, RPC 호출과 SyncVar을 권장한다. 하지만 또한 낮은 수준의 네트워크 메시지를 송신할 수 도 있다. 이 방법은 로그, 분석, 프로파일링 정보 등 게임 오브젝트에 얽매이지 않는 메시지를 클라이언트가 송신할 때 유용하다.

NetworkMessage라는 public interface를 확장하면 직렬화 가능한 네트워크 메시지 struct를 만들 수 있다. 이 인터페이스에는 Wirter 및 Reader 오브젝트를 가져오는 직렬화와 역직렬화 기능이 있다. 이러한 기능은 사용자가 직접 구현할 수 있지만 Mirror에서 생성하는것이 좋다.

자동 생성된 직렬화/역직렬화는 Mirror에서 지원 되는 타입을 효율적으로 처리할 수 있다. 멤버들은 public으로 만들고 Class 또는 List나 Dictionary 같은 복잡한 컨테이너의 경우 직접 직렬화/역직렬화 메서드를 구현해야한다.

메시지를 전송하려면 NetworkClient, NetworkServer, NetworkConnection 클래스에 있는 Send() 메서드를 사용한다. 모두 NetworkMessage에서 파생된 메시지 struct를 사용하여 모두 동일하게 동작한다. 

```cs
using UnityEngine;
using Mirror;

public class Scores : MonoBehaviour
{
  public struct ScoreMessage : NetworkMessage
  {
    public int scroe;
    public Vector3 scorePos;
    public int lives;
  }

  public void SendScore(int score, Vector3 score, int lives)
  {
    ScoreMessage msg = new ScoreMessage()
    {
      score = score;
      scorePos = scorePos;
      lives = lives;
    };

    NetworkServer.SendToAll(msg);
  }

  public void SetupClient()
  {
    NetworkClient.RegisterHandler<ScoreMessage>(OnScore);
    NetworkClient.Connect("localhost");
  }

  public void OnScore(ScoreMessage msg)
  {
    Debug.Log("OnScoreMessage " + msg.score);
  }
}
```