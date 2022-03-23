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

* Offline Scene : 일반적으로 Lobby에 해당하는 씬이다. 호스트, 서버, 클라이언트 중 선택한다. 

* Room Scene : 게임 시작전 준비하기 위해 플레이어가 모이는 씬이다. 호스트, 서버가 생성될 때 방이 만들어지고 이후 클라이언트가 접속이 가능하다.

               예제에서는 GUI를 통해서 플레이어를 확인하기 때문에 비어있는 씬이다.

* Online Scene : 게임이 플레이되는 씬이다. StartPosition의 자식에는 플레이어의 생성 위치가 만들어져있고 각 오브젝트는 Network Start Position 컴포넌트를 가지고 있다.

                 이 컴포넌트를 설정하면 NetworkManager는 해당 위치에 플레이어를 Spawn하게 된다.
<br>

#### Offline Scene

NetworkRoomManager 오브젝트에 있는 NetworkRoomManagerExt 스크립트로 기본적으로 네트워크가 만들어진다.

![room](/assets/images/20220323_Posting/room.png)

<br>

* SceneManagement

  Offline Scene : OfflineScene

  Online Scene : RoomScene

  네트워크에 연결되면 RoomScene을 로드한다.

* Player Object

  플레이어로 사용할 프리팹을 등록한다.

* Room Settings

  Show Room GUI : 룸 정보를 표시할지 정한다.

  Min Players : 최소 필요한 플레이어 수

  Room Player Prefab  : Room에 참가한 플레이어의 프리팹, 게임에 들어갔을 때 생성되는 플레이어 프리팹과 별도로 필요하다.

  Room Scene : RoomScene, 룸으로 사용할 씬을 등록한다.

  Gameplay Scene : OnlineScene, 게임이 시작되는 씬을 등록한다.

<br>

####  Prefabs


* RoomPlayer

  룸 플레이어는 네트워크 식별을 위한 NetworkIdentity와 눈으로 확인할 수 있도록 GUI 기능만 있는 NetworkRoomPlayer 스크립트를 가지고 있다.

* GamePlayer

  NetworkIdentity 포함한 기본적으로 네트워크를 위한 컴포넌트 외에도 게임 로직에 사용되는 컴포넌트를 포함하고 있다. 

RoomPlayer, GamePlayer 각각이 Identity 컴포넌트를 가지고 있기 때문에 룸에서 게임, 게임에서 룸 전환시 Identity를 옮겨서 클라이언트를 일치시켜주는 작업이 필요하다.

<br>

**index**

RoomPlayer가 GUI를 그릴 때 입장한 순서대로 정보가 표시된다. 이 때 사용되는 값이 index로 룸에 플레이어가 입장할 때마다 값이 증가하고 이 값으로 GUI의 간격을 조절한다.

GamePlayer도 index를 가지고 있으며 이 값은 RoomPlayer의 index를 가져와서 사용하기 위해 선언되었다. 

이 값은 NetworkRoomManagerExt의 OnRoomServerSceneLoadedForPlayer가 호출될 때 인계된다.

<br>

#### NetworkRoomManagerExt

룸을 생성하는 네트워크 연결을 위한 스크립트이다.

NetworkRoomManager를 상속받았기 때문에 인스펙터 창에서 NetworkManager랑 다르게 추가로 룸 설정에 대한 필드가 보였다.

<br>

OnRoomServerSceneChanged 메서드는 네트워크 씬의 로드가 끝났을 때 호출된다. 즉 Room에서 게임이 시작되어 씬이 전환될 때 호출되어 게임 씬에서 점수 오브젝트의 생성이 초기화 된다.


```cs
using UnityEngine;

/*
	Documentation: https://mirror-networking.gitbook.io/docs/components/network-manager
	API Reference: https://mirror-networking.com/docs/api/Mirror.NetworkManager.html
*/

namespace Mirror.Examples.NetworkRoom
{
    [AddComponentMenu("")]
    public class NetworkRoomManagerExt : NetworkRoomManager
    {
        [Header("Spawner Setup")]
        [Tooltip("Reward Prefab for the Spawner")]
        public GameObject rewardPrefab;

        /// <summary>
        /// This is called on the server when a networked scene finishes loading.
        /// </summary>
        /// <param name="sceneName">Name of the new scene.</param>
        public override void OnRoomServerSceneChanged(string sceneName)
        {
            // spawn the initial batch of Rewards
            if (sceneName == GameplayScene)
                Spawner.InitialSpawn();
        }
```
<br>

OnRoomServerSceneLoadedForPlayer 메서드는 게임 플레이어 오브젝트가 인스턴스화 된 후 그리고 룸 플레이어 객체를 대체하기 전에 호출된다.

여기서 온라인 씬으로 들어가기 전에 게임 플레이어 오브젝트에게 이름, 권한, 토큰, 색 등의 정보를 전달하기 좋은 지점이다. 예제에서는 룸 플레이어와 게임 플레이어가 index 변수를 공유하고 동기화해서 점수를 표시한다.


```cs
        /// <summary>
        /// Called just after GamePlayer object is instantiated and just before it replaces RoomPlayer object.
        /// This is the ideal point to pass any data like player name, credentials, tokens, colors, etc.
        /// into the GamePlayer object as it is about to enter the Online scene.
        /// </summary>
        /// <param name="roomPlayer"></param>
        /// <param name="gamePlayer"></param>
        /// <returns>true unless some code in here decides it needs to abort the replacement</returns>
        public override bool OnRoomServerSceneLoadedForPlayer(NetworkConnectionToClient conn, GameObject roomPlayer, GameObject gamePlayer)
        {
            PlayerScore playerScore = gamePlayer.GetComponent<PlayerScore>();
            playerScore.index = roomPlayer.GetComponent<NetworkRoomPlayer>().index;
            return true;
        }
```

<br>

OnRoomStopClient 는 클라이언트가 룸을 떠날 때 OnRoomStopServer 는 서버가 룸을 떠날 때 호출된다.

```cs
        public override void OnRoomStopClient()
        {
            base.OnRoomStopClient();
        }

        public override void OnRoomStopServer()
        {
            base.OnRoomStopServer();
        }
```

<br>

아래 코드는 호스트 플레이어 또는 서버에게만 게임 시작 버튼이 나타나게 한다. UNITY_SERVER 로 정의된 영역은 유니티 서버로 빌드할 때만 읽게되는 서버 전용 코드가 된다.

OnRoomServerPlayersReady는 방에 있는 모든 플레이어가 준비되었을 때만 호출된다. 따라서 여기서 bool값을 변경하고 게임 시작 버튼을 이 bool 값을 사용하면 모든 플레이어가 준비 되었을 때 게임 시작 버튼이 서버에서만 활성화되도록한다.


```cs
        /*
            This code below is to demonstrate how to do a Start button that only appears for the Host player
            showStartButton is a local bool that's needed because OnRoomServerPlayersReady is only fired when
            all players are ready, but if a player cancels their ready state there's no callback to set it back to false
            Therefore, allPlayersReady is used in combination with showStartButton to show/hide the Start button correctly.
            Setting showStartButton false when the button is pressed hides it in the game scene since NetworkRoomManager
            is set as DontDestroyOnLoad = true.
        */

        bool showStartButton;

        public override void OnRoomServerPlayersReady()
        {
            // calling the base method calls ServerChangeScene as soon as all players are in Ready state.
#if UNITY_SERVER
            base.OnRoomServerPlayersReady();
#else
            showStartButton = true;
#endif
        }
```

<br>

allPlayersReady와 showStartButton을 검사하여 버튼을 그리고 클릭시 버튼이 안보이게 한 후 ServerChangeScene를 호출해서 씬을 전환한다.  

```cs
        public override void OnGUI()
        {
            base.OnGUI();

            if (allPlayersReady && showStartButton && GUI.Button(new Rect(150, 300, 120, 20), "START GAME"))
            {
                // set to false to hide it in the game scene
                showStartButton = false;

                ServerChangeScene(GameplayScene);
            }
        }
    }
}
```

<br>

#### ServerChangeScene

NetworkRoomManager.SeverChangeScene 메서드는 룸에서 게임, 게임에서 룸으로 이동할 때 호출된다. 

```cs
public override void ServerChangeScene(string newSceneName)
        {
            if (newSceneName == RoomScene)
            {
                foreach (NetworkRoomPlayer roomPlayer in roomSlots)
                {
                    if (roomPlayer == null)
                        continue;

                    // find the game-player object for this connection, and destroy it
                    NetworkIdentity identity = roomPlayer.GetComponent<NetworkIdentity>();

                    if (NetworkServer.active)
                    {
                        // re-add the room object
                        roomPlayer.GetComponent<NetworkRoomPlayer>().readyToBegin = false;
                        NetworkServer.ReplacePlayerForConnection(identity.connectionToClient, roomPlayer.gameObject);
                    }
                }

                allPlayersReady = false;
            }

            base.ServerChangeScene(newSceneName);
        }
```

<br>

**Game -> Room**  

게임에서 룸으로 돌아가는 경우 메서드 내 if 안으로 들어가서 동작하게 된다. 이 때 생성된 게임 오브젝트의 identity를 룸 플레이어로 전환시키고 게임 플레이어 오브젝트를 파괴하는 작업이 진행된다.

<br>

**Room -> Game**  

룸에서 게임으로 들어갈 때는 NetworkRoomManager.ServerChangeScene 호출 이후 SceneLoadedForPlayer 메서드의 호출로 게임 플레이어의 Instantiate가 진행된다. 이 메서드 안에서 룸으로 이동인지 검사해서 룸이 아닌 씬으로 이동할 때만 플레이어 게임 오브젝트가 생성되도록한다. 이 때 OnlineScene에서 만들어 놓은 StartPosition의 위치를 참조하게 된다.

플레이어 게임 오브젝트를 생성한 후 ReplacePlayerForConnection을 통해서 룸 플레이어의 identity를 게임 씬의 플레이어 오브젝트로 변환하는 작업이 진행된다.

<br>


#### NetworkRoomPlayer

이 스크립트는 NetworkRoomPlayer를 상속받았지만

그 중에서 GUI 기능만 필요하기 OnGUI 메서드만 오버라이드 후 base에서 호출한다.

```cs
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Mirror.Examples.NetworkRoom
{
    [AddComponentMenu("")]
    public class NetworkRoomPlayerExt : NetworkRoomPlayer
    {
        public override void OnStartClient()
        {
            //Debug.Log($"OnStartClient {gameObject}");
        }

        public override void OnClientEnterRoom()
        {
            //Debug.Log($"OnClientEnterRoom {SceneManager.GetActiveScene().path}");
        }

        public override void OnClientExitRoom()
        {
            //Debug.Log($"OnClientExitRoom {SceneManager.GetActiveScene().path}");
        }

        public override void IndexChanged(int oldIndex, int newIndex)
        {
            //Debug.Log($"IndexChanged {newIndex}");
        }

        public override void ReadyStateChanged(bool oldReadyState, bool newReadyState)
        {
            //Debug.Log($"ReadyStateChanged {newReadyState}");
        }

        public override void OnGUI()
        {
            base.OnGUI();
        }
    }
}
```