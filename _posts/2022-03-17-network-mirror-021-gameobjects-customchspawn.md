---
title:  "Mirror Guide GameObjects - Custom Character Spawning"
excerpt: "Network, Mirror, GameObjects, Custom-Character"

categories:
  - Mirror
tags:
  - [Network, Mirror, GameObjects, Custom-Character]

toc: true
toc_sticky: true
 
date: 2022-03-17
last_modified_at: 2022-03-17
---  

***

<br>

### Custom Character Spawning

캐릭터의 머리, 눈, 피부, 키, 인종 등을 선택하는 커스터마이즈가 필요한 게임들이 있다.

기본적으로 Mirror가 플레이어를 인스턴스화한다. 이는 편리하지만 커스터마이즈에 있어서는 방해가 될 수 있다. Mirror는 플레이어 생성을 재정의하고 사용자가 지정할 수 있도록 옵션을 제공한다.

<br>

1. NetworkManager를 확장한 클래스를 만든다.

  ```cs
  public class MMONetworkManager : NetworkManager
  {
    ...
  }
  ```

  <br>

2. 생성한 NetworkManager 사용

  * NetworkManager의 인스펙터 창에서 Auto Create Player의 체크박스를 해제한다.

  * 스크립트에 플레이어 커스터마이즈에 대한 내용을 메시지 스트럭트를 생성해 작성한다.

    ```cs
    public struct CreateMMOCharacterMessage : NetworkMessage
    {
      public Race race;
      public string name;
      public Color hairColor;
      public Color eyeColor;
    }

    public enum Race
    {
      None,
      Elvish,
      Dwarvish,
      Human
    }
    ```  

  <br>

3. 플레이어를 등록

  * 플레이어 프리팹을 필요한 만큼 만들고 Network Manager에 있는 Register Spawnable Prefabs에 추가한다. 하나라면 인스펙터 창의 Player Prefab 필드에 넣는다.

  * 메시지를 보내고 플레이어를 등록한다.

    ```cs
    public class MMONetworkManager : NetworkManager
    {
        public override void OnStartServer()
        {
            base.OnStartServer();

            NetworkServer.RegisterHandler<CreateMMOCharacterMessage>(OnCreateCharacter);
        }

        public override void OnClientConnect()
        {
            base.OnClientConnect();

            // you can send the message here, or wherever else you want
            CreateMMOCharacterMessage characterMessage = new CreateMMOCharacterMessage
            {
                race = Race.Elvish,
                name = "Joe Gaba Gaba",
                hairColor = Color.red,
                eyeColor = Color.green
            };

            NetworkClient.Send(characterMessage);
        }

        void OnCreateCharacter(NetworkConnection conn, CreateMMOCharacterMessage message)
        {
            // playerPrefab is the one assigned in the inspector in Network
            // Manager but you can use different prefabs per race for example
            GameObject gameobject = Instantiate(playerPrefab);

            // Apply data from the message however appropriate for your game
            // Typically Player would be a component you write with syncvars or properties
            Player player = gameobject.GetComponent();
            player.hairColor = message.hairColor;
            player.eyeColor = message.eyeColor;
            player.name = message.name;
            player.race = message.race;

            // call this to use this gameobject as the primary controller
            NetworkServer.AddPlayerForConnection(conn, gameobject);
        }
    }
    ```

<br>

### Ready State

플레이어와 더불어 클라이언트의 연결도 ready state가 있다. 호스트는 생성된 게임 오브젝트와 상태 동기화 업데이트에 대한 준비된 정보를 클라이언트에 보낸다. 준비되지 않은 클라이언트는 이러한 업데이트를 보내지 않는다. 

클라이언트가 서버에 처음 접속할 때 준비가 되지 않는다. 준비되지 않은 상태에서는 씬을 로드하거나 플레이어가 아바타를 선택하는 등 클라이언트가 서버상의 게임 상태와의 실시간 상호작용을 필요로 하지 않는 작업을 수행할 수 있다. 

클라이언트는 게임의 전초 작업을 완료하고 모든 에셋을 로드한 후 NetworkClient.Ready를 호출하여 ready state가 될 수 있다.

클라이언트는 준비 없이도 네트워크 메시지를 송수신할 수 있다. 이는 활성화된 플레이어 게임 오브젝트를 사용하지 않고도 가능하다. 따라서 클라이언트의 메뉴나 선택 화면에서 플레이어 게임 오브젝트가 없어도 게임에 접속하여 상호 작용 할 수 있게 된다.  

<br>

### Switching Players

연결하기 위한 플레이어 게임 오브젝트를 바꾸려면 NetworkServer.ReplacePlayerForConnection을 사용한다. 이는 게임 전 룸 장면처럼 플레이어가 특정 시간에 실행할 수 있는 Commands를 제한할 때 유용하다. 이 함수는 AddPlayerForConnection과 동일한 인자를 사용하지만 해당 연결에 대한 플레이어가 이미 있을 수 있는 상황을 대비한다.

구 플레이어 게임 오브젝트를 파괴할 필요는 없다. NetworkRoomManager는 방안의 모든 플레이어들이 준비가 될 때 NetworkRoomPlayer의 기술을 사용하여 게임 오브젝트에서 플레이어 게임 오브젝트로 전환한다.

또한 ReplacePlayerForConnection을 사용하여 플레이어를 재활성화하거나 플레이어를 나타내는 오브젝트를 변경할 수도 있다. 경우에 따라서 게임 오브젝트를 무효로 하고 재활성화시 게임 속성을 리셋하도록 하는데 사용하는 것도 좋다.

예)  

게임 오브젝트를 교체하는 방법

```cs
public class MyNetworkManager : NetworkManager
{
    public void ReplacePlayer(NetworkConnection conn, GameObject newPrefab)
    {
        // Cache a reference to the current player object
        GameObject oldPlayer = conn.identity.gameObject;

        // Instantiate the new player object and broadcast to clients
        // Include true for keepAuthority paramater to prevent ownership change
        NetworkServer.ReplacePlayerForConnection(conn, Instantiate(newPrefab), true);

        // Remove the previous player object that's now been replaced
        NetworkServer.Destroy(oldPlayer);
    }
}
```

접속한 플레이어 게임 오브젝트가 파괴되면 클라이언트는 명령어를 실행할 수 없지만 네트워크 메시지를 송수신할 수는 있다.

ReplacePlayerForConnection을 사용하려면 플레이어의 클라이언트가 게임 오브젝트-클라이언트 간의 관계를 설정하기 위해 NetworkConnection 게임 오브젝트가 있어야한다. 보통 NetworkBehaviour 클래스의 connectionToClient 속성이지만 구 플레이어가 이미 파괴되어 있는 경우는 곧바로 사용할 수 없는 경우도 있다.

연결을 찾기 위해 사용할 수 있는 리스트가 있다. 

* NetworkRoomManager

  roomSlots

* NetworkServer

  connections lists