---
title:  "Mirror Example - Multiple Additive Scenes"
excerpt: "Network, Mirror, Example, Multiple-Additive-Scenes"

categories:
  - Mirror
tags:
  - [Network, Mirror, Example, Multiple-Additive-Scenes]

toc: true
toc_sticky: true
 
date: 2022-03-22
last_modified_at: 2022-03-22
---  

***

<br>

## Multiple Additive Scenes Example

맵에 있는 보상 오브젝트를 먹어서 점수를 얻는 게임이다.

이 예제에는 두 개의 씬이 있다. 접속을 시작하는 Main 씬과 접속하게 되는 Game씬이 존재한다.

Multiple Additive 예제는 하나의 Game씬을 서버에서 여러개 만들어내고 플레이어를 분배해서 Spawn하는 방법을 다룬다.

<br>

### MultiSceneNetManager

![multiple](/assets/images/20220322_Posting/multiple.png)

<br>

NetworkManager 오브젝트의 인스펙터 창에서 MultiSceneNetManager 컴포넌트를 보면 MultiScene Setup 필드에서 만들 씬의 참조와 개수를 입력할 수 있다. 여기서 입력한 개수대로 서버에서 씬을 생성한다.

#### Script

맵에 보상 오브젝트를 생성하기 위한 프리팹의 참조와 서버에 생성할 씬과 그 개수를 입력받을 변수를 만든다.

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

/*
	Documentation: https://mirror-networking.gitbook.io/docs/components/network-manager
	API Reference: https://mirror-networking.com/docs/api/Mirror.NetworkManager.html
*/

namespace Mirror.Examples.MultipleAdditiveScenes
{
    [AddComponentMenu("")]
    public class MultiSceneNetManager : NetworkManager
    {
        [Header("Spawner Setup")]
        [Tooltip("Reward Prefab for the Spawner")]
        public GameObject rewardPrefab;

        [Header("MultiScene Setup")]
        public int instances = 3;

        [Scene]
        public string gameScene;
```
<br>

서브씬이 로드되었는지 확인용 플래그를 선언한다.

참조된 서브씬은 읽기 전용으로 선언된 List에 추가된다.

생성된 게임 씬에 순차적으로 플레이어와 점수 판을 배치하기 위해서 클라이언트의 인덱스를 계산한다.

```cs
        // This is set true after server loads all subscene instances
        bool subscenesLoaded;

        // subscenes are added to this list as they're loaded
        readonly List<Scene> subScenes = new List<Scene>();

        // Sequential index used in round-robin deployment of players into instances and score positioning
        int clientIndex;
```
<br>

OnServerAddPlayer 는 NetworkClient.AddPlayer 로 클라이언트가 추가될 때 서버에서 호출된다.

이 때 OnServerAddPlayerDelayed 코루틴을 호출한다.

코루틴은 subscenesLoaded 를 검사해서 서버에 서브 씬 게임 인스턴스가 모두 로드가 될 때 까지 기다린다.

그 후 클라이언트에 Scene Message를 전송해서 씬을 로드한다.

프레임이 끝날 때까지 대기해서 플레이어가 추가되기 전에 메시지가 먼저 보내지도록 한다.

base.OnServerAddPlayer를 호출해서 해당 클라이언트를 준비 상태로 만든다.

현재 플레이어의 점수 판에 클라이언트 인덱스 값을 표시하고 점수를 계산한다.

마지막으로 서브 씬이 생성된 이후라면 지금 플레이어를 해당 서브 씬으로 이동 시킨다. 이 것은 오직 서버에서만 동작한다. 이를 통해 플레이어와 씬 오브젝트들의 NetworkSceneChecker가 서버상의 씬 인스턴스마다 일치하는 항목을 분리할 수 있다.

```cs
        #region Server System Callbacks

        /// <summary>
        /// Called on the server when a client adds a new player with NetworkClient.AddPlayer.
        /// <para>The default implementation for this function creates a new player object from the playerPrefab.</para>
        /// </summary>
        /// <param name="conn">Connection from client.</param>
        public override void OnServerAddPlayer(NetworkConnectionToClient conn)
        {
            StartCoroutine(OnServerAddPlayerDelayed(conn));
        }

        // This delay is mostly for the host player that loads too fast for the
        // server to have subscenes async loaded from OnStartServer ahead of it.
        IEnumerator OnServerAddPlayerDelayed(NetworkConnectionToClient conn)
        {
            // wait for server to async load all subscenes for game instances
            while (!subscenesLoaded)
                yield return null;

            // Send Scene message to client to additively load the game scene
            conn.Send(new SceneMessage { sceneName = gameScene, sceneOperation = SceneOperation.LoadAdditive });

            // Wait for end of frame before adding the player to ensure Scene Message goes first
            yield return new WaitForEndOfFrame();

            base.OnServerAddPlayer(conn);

            PlayerScore playerScore = conn.identity.GetComponent<PlayerScore>();
            playerScore.playerNumber = clientIndex;
            playerScore.scoreIndex = clientIndex / subScenes.Count;
            playerScore.matchIndex = clientIndex % subScenes.Count;

            // Do this only on server, not on clients
            // This is what allows the NetworkSceneChecker on player and scene objects
            // to isolate matches per scene instance on server.
            if (subScenes.Count > 0)
                SceneManager.MoveGameObjectToScene(conn.identity.gameObject, subScenes[clientIndex % subScenes.Count]);

            clientIndex++;
        }

        #endregion
```
<br>


OnStartServer 는 behaviour가 서버에서 생성될 때 호출된다. 이 때 ServerLoadSubScenes 코루틴 함수를 호출한다.  

```cs
        #region Start & Stop Callbacks

        /// <summary>
        /// This is invoked when a server is started - including when a host is started.
        /// <para>StartServer has multiple signatures, but they all cause this hook to be called.</para>
        /// </summary>
        public override void OnStartServer()
        {
            StartCoroutine(ServerLoadSubScenes());
        }
```

<br>

씬을 추가로 로드하고 있기 때문에 GetSceneAt(0)는 Main 씬을 반환한다. instance는 참조된 생성할 씬의 수이다. 

따라서 인덱스를 1부터 시작해서 instance까지 포함해서 반복해야 원하는 수만큼의 씬이 추가된다.


```cs
        // We're additively loading scenes, so GetSceneAt(0) will return the main "container" scene,
        // therefore we start the index at one and loop through instances value inclusively.
        // If instances is zero, the loop is bypassed entirely.
        IEnumerator ServerLoadSubScenes()
        {
            for (int index = 1; index <= instances; index++)
            {
                yield return SceneManager.LoadSceneAsync(gameScene, new LoadSceneParameters { loadSceneMode = LoadSceneMode.Additive, localPhysicsMode = LocalPhysicsMode.Physics3D });

                Scene newScene = SceneManager.GetSceneAt(index);
                subScenes.Add(newScene);
                Spawner.InitialSpawn(newScene);
            }

            subscenesLoaded = true;
        }
```
<br>

OnStopServer는 호스트를 포함해서 서버가 정지될 때 호출된다.

서버에서 모두에게 Unload 씬 메시지를 전송하고 ServerUnLoadSubScenes 코루틴을 실행한다.

모든 추가된 서브 씬들이 언로드 되기 때문에 clientIndex도 0으로 초기화해준다.

```cs
        /// <summary>
        /// This is called when a server is stopped - including when a host is stopped.
        /// </summary>
        public override void OnStopServer()
        {
            NetworkServer.SendToAll(new SceneMessage { sceneName = gameScene, sceneOperation = SceneOperation.UnloadAdditive });
            StartCoroutine(ServerUnloadSubScenes());
            clientIndex = 0;
        }
```
<br>

subScene들을 unload하고 안쓰는 에셋들과 subScenes 리스트를 정리한다.

subScenes 리스트의 전체를 순회하면서 정리할것이기 때문에 0부터 리스트의 크기만큼 반복한다.

리스트 안의 subScene들을 모두 unload하고 리스트를 비운다.

그리고 subscenesLoaded 상태를 false로 변경한다.

```cs
        // Unload the subScenes and unused assets and clear the subScenes list.
        IEnumerator ServerUnloadSubScenes()
        {
            for (int index = 0; index < subScenes.Count; index++)
                yield return SceneManager.UnloadSceneAsync(subScenes[index]);

            subScenes.Clear();
            subscenesLoaded = false;

            yield return Resources.UnloadUnusedAssets();
        }
```

<br>

OnStopClient는 클라이언트가 정지될 때 호출된다.

현재 호스트가 아닌것을 검사한 뒤에 Client의 Unload를 진행한다.

Button "Stop Client"(NetworkManagerHUD) -> StopClient -> OnStopClient 실행시 override한 OnStopClient 실행됨

```cs
        /// <summary>
        /// This is called when a client is stopped.
        /// </summary>
        public override void OnStopClient()
        {
            // make sure we're not in host mode
            if (mode == NetworkManagerMode.ClientOnly)
                StartCoroutine(ClientUnloadSubScenes());
        }
```
<br>

Main 씬을 제외한 나머지 씬들을 Unload한다.


```cs
        // Unload all but the active scene, which is the "container" scene
        IEnumerator ClientUnloadSubScenes()
        {
            for (int index = 0; index < SceneManager.sceneCount; index++)
            {
                if (SceneManager.GetSceneAt(index) != SceneManager.GetActiveScene())
                    yield return SceneManager.UnloadSceneAsync(SceneManager.GetSceneAt(index));
            }
        }

        #endregion
    }
}
```