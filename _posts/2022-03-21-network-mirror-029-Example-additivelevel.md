---
title:  "Mirror Example - Additive"
excerpt: "Network, Mirror, Example, Additive"

categories:
  - Mirror
tags:
  - [Network, Mirror, Example, Additive]

toc: true
toc_sticky: true
 
date: 2022-03-22
last_modified_at: 2022-03-22
---  

***

<br>

## Additive Levels Example

Assets > Mirror > Examples > Scenes

SceneManager의 LoadSceneMode.Additive를 사용해서 네트워크 상에서 씬 전환을 동기화 한다.


<br>

### Scene

Offline, Online, SubLevel1, SubLevel2 총 4 개의 씬으로 이루어져있다.

Offlin 씬은 시작화면이다. 네트워크 연결, 즉 호스트나 클라이언트로 참가시 Online 씬으로 전환된다.

Online 씬은 SubLevel1, SubLevel2 씬과 Additive를 통해서 동시에 그려지게 되며 Player 오브젝트가 생성되는 씬의 위치에 따라 Level이 변경된다.

![online](/assets/images/20220322_Posting/onlinescene.png)

<br>

#### Offline

Network 게임 오브젝트는 AdditiveLevelsNetworkManager 스크립트를 가지고 있다.

![inspector](/assets/images/20220322_Posting/inspector.png)

<br>

**SceneManagement**

NetworkManager의 기본 기능으로 네트워크 연결전 씬과 네트워크 연결 후 씬이 따로 존재할 경우 연결해주는 역할을 한다.

Offline Scene 필드에는 Offline 씬, Online Scene 필드에는 Online 씬을 등록한다.

<br>

Player Object에는 플레이어의 프리팹을 등록한다.

<br>

**Additive Scene = FIrst is start scene**

AdditiveLevelsNetworkManager에서 구현된 것으로 사용할 각 Level 씬을 배열 형태로 참조한다.

가장 첫번째 즉 0번 인덱스의 씬이 온라인 접속시 로드되는 씬이다.

<br>

**Fade Control - See child FadeCanvas**

화면의 페이드 인, 아웃 효과를 주는 컴포넌트이다. 하이어라키의 Network 게임 오브젝트의 자식에는 FadeCanvas가 있으며 이 오브젝트가 들고 있는 FadeInOut 스크립트로 캔버스의 자식으로 있는 Panel의 색과 알파값을 조절하여 효과를 만들어 낸다.

씬 전환시 부드러운 화면 연출을 위해서 사용한다.

<br>

#### Online

Online 씬에는 조명과 플레이어 추락을 방지하는 콜라이더 뿐이다. 지형과 지물은 Additive를 통해서 로드되는 Level씬을 통해서 구현되므로 이 장면에서는 씬 전환 동안 잠시 머물 수 있도록만 구현되어있다.

>정보!  
>유니티는 Additive Scene에서 LightProbes의 병합/분리를 지원하지 않기 때문에 Online씬의 조명이  Level1, Level2로 씬 전환 후에도 조명이 영향을 준다.

<br>

#### SubLevel

각 Level 씬들은 씬 전환을 위한 Portal과 다른 씬임을 인식할 수 있는 오브젝트가 있다. 

<br>

### Scripts

#### AdditiveLevelsNetworkManager

Additive Scene를 사용하기 위해서 씬을 string 배열로 참조받는다. string인 이유는 씬 전환시 이름값을 사용하기 때문이다.

씬 전환시 연출을 위해서 FadeInOut에 대한 참조도 받는다.

그리고 서버상에서 씬의 로드가 끝났는지 확인할 플래그, 클라이언트 상에서 씬이 전환중인지 확인할 플래그를 선언한다.

```cs
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Mirror.Examples.AdditiveLevels
{
    [AddComponentMenu("")]
    public class AdditiveLevelsNetworkManager : NetworkManager
    {
        [Header("Additive Scenes - First is start scene")]

        [Scene, Tooltip("Add additive scenes here.\nFirst entry will be players' start scene")]
        public string[] additiveScenes;

        [Header("Fade Control - See child FadeCanvas")]

        [Tooltip("Reference to FadeInOut script on child FadeCanvas")]
        public FadeInOut fadeInOut;

        // This is set true after server loads all subscene instances
        bool subscenesLoaded;

        // This is managed in LoadAdditive, UnloadAdditive, and checked in OnClientSceneChanged
        bool isInTransition;
```
<br>

OnServerSceneChanged 메서드는 서버에서 씬전환이 끝난 후 호출된다. 이 예제에서는 offline 씬에서 online 씬으로 전환될 때 사용하는것이다.

따라서 씬이름이 onlineScene이면 서버에 sublevels 씬들도 같이 로드한다.

```cs
        #region Scene Management

        /// <summary>
        /// Called on the server when a scene is completed loaded, when the scene load was initiated by the server with ServerChangeScene().
        /// </summary>
        /// <param name="sceneName">The name of the new scene.</param>
        public override void OnServerSceneChanged(string sceneName)
        {
            // This fires after server fully changes scenes, e.g. offline to online
            // If server has just loaded the Container (online) scene, load the subscenes on server
            if (sceneName == onlineScene)
                StartCoroutine(ServerLoadSubScenes());
        }
```
<br>

ServerLoadSubScenes 메서드는 코루틴을 통해서 호출한다.

참조한 additiveScenes 배열을 순회하면서 SceneManager가 비동기화로 백그라운드에서 모든 서브 씬의 로드가 끝날 때 까지 대기한 후 서버에 씬의 로드가 끝났음을 플래그로 체크한다. 

```cs
        IEnumerator ServerLoadSubScenes()
        {
            foreach (string additiveScene in additiveScenes)
                yield return SceneManager.LoadSceneAsync(additiveScene, new LoadSceneParameters
                {
                    loadSceneMode = LoadSceneMode.Additive,
                    localPhysicsMode = LocalPhysicsMode.Physics3D // change this to .Physics2D for a 2D game
                });

            subscenesLoaded = true;
        }
```

<br>

OnClientChangeScene 메서드는 SceneManager.LoadSceneAsync가 실행되기 전에 ClientChageScene에서 즉시 호출된다.

이것을 통해서 클라이언트가 씬을 전환하기 전에 작업, 정리, 준비 등을 수행한다.

sceneOperation은 Mirror의 씬 상태를 나타내는 byte enum 값이다. Load와 Unload를 구분해서 각 각을 실행시킨다.

```cs
        /// <summary>
        /// Called from ClientChangeScene immediately before SceneManager.LoadSceneAsync is executed
        /// <para>This allows client to do work / cleanup / prep before the scene changes.</para>
        /// </summary>
        /// <param name="sceneName">Name of the scene that's about to be loaded</param>
        /// <param name="sceneOperation">Scene operation that's about to happen</param>
        /// <param name="customHandling">true to indicate that scene loading will be handled through overrides</param>
        public override void OnClientChangeScene(string sceneName, SceneOperation sceneOperation, bool customHandling)
        {
            //Debug.Log($"{System.DateTime.Now:HH:mm:ss:fff} OnClientChangeScene {sceneName} {sceneOperation}");

            if (sceneOperation == SceneOperation.UnloadAdditive)
                StartCoroutine(UnloadAdditive(sceneName));

            if (sceneOperation == SceneOperation.LoadAdditive)
                StartCoroutine(LoadAdditive(sceneName));
        }
```
<br>

LoadAdditive는 코루틴으로 호출한다. 

우선 씬의 전환 중임을 체크하고 화면을 로딩에 들어가기 전 화면을 암전 시킨다.

그리고 호스가 있을 경우 additive scene을 다시 로드하는것을 방지하기 위해서 ClientOnly로 걸러낸다.

loadingSceneAsync는 NetworkManager의 정적 변수로 비동기 씬 전환 작업을 저장하면 NetworkManager에서 씬 작업을 처리한다.

이 작업이 null이 아니고 완료되었을 때 대기를 종료하고 NetworkClient.isLoadingScene을 false로 바꾸어 다음 진행으로 넘어갈 준비가 됐음을 알린다.

씬이 더이상 로딩 중이 아니므로 isInTransition을 false로 변경한다.

OnClientSceneChanged를 호출해서 클라이언트를 ready 상태로 바꾸고 로드된 씬을 FadeOut을 시작으로 화면이 보이게 한다.

```cs
        IEnumerator LoadAdditive(string sceneName)
        {
            isInTransition = true;

            // This will return immediately if already faded in
            // e.g. by UnloadAdditive above or by default startup state
            yield return fadeInOut.FadeIn();

            // host client is on server...don't load the additive scene again
            if (mode == NetworkManagerMode.ClientOnly)
            {
                // Start loading the additive subscene
                loadingSceneAsync = SceneManager.LoadSceneAsync(sceneName, LoadSceneMode.Additive);

                while (loadingSceneAsync != null && !loadingSceneAsync.isDone)
                    yield return null;
            }

            // Reset these to false when ready to proceed
            NetworkClient.isLoadingScene = false;
            isInTransition = false;

            OnClientSceneChanged();

            yield return fadeInOut.FadeOut();
        }
```
<br>

LoadAdditive와 마찬가지로 UnLoadAdditive를 구현한다.

```cs
        IEnumerator UnloadAdditive(string sceneName)
        {
            isInTransition = true;

            // This will return immediately if already faded in
            // e.g. by LoadAdditive above or by default startup state
            yield return fadeInOut.FadeIn();

            if (mode == NetworkManagerMode.ClientOnly)
            {
                yield return SceneManager.UnloadSceneAsync(sceneName);
                yield return Resources.UnloadUnusedAssets();
            }

            // Reset these to false when ready to proceed
            NetworkClient.isLoadingScene = false;
            isInTransition = false;

            OnClientSceneChanged();

            // There is no call to FadeOut here on purpose.
            // Expectation is that a LoadAdditive will follow
            // that will call FadeOut after that scene loads.
        }
```
<br>


OnClientSceneChanged 는 씬의 로드가 서버에 의해서 시작되고, 씬이 완전히 로드되었을 때 클라이언트에서 호출된다.
씬의 전환은 플레이어 오브젝트를 파괴시킨다. NetworkManager의 OnClientSceneChanged 메서드의 기본 구현은 플레이어 오브젝트가 존재하지 않는다면 연결을 위한 플레이어 오브젝트를 추가한다.

메서드 내에서 isInTransition으로 확인한 다음에만 base 메서드가 진행되도록하여 Mirror가 처음 씬의 로딩을 끝내고 호출되는 경우를 방지한다.

```cs
        /// <summary>
        /// Called on clients when a scene has completed loaded, when the scene load was initiated by the server.
        /// <para>Scene changes can cause player objects to be destroyed. The default implementation of OnClientSceneChanged in the NetworkManager is to add a player object for the connection if no player object exists.</para>
        /// </summary>
        /// <param name="conn">The network connection that the scene change message arrived on.</param>
        public override void OnClientSceneChanged()
        {
            //Debug.Log($"{System.DateTime.Now:HH:mm:ss:fff} OnClientSceneChanged {isInTransition}");

            // Only call the base method if not in a transition.
            // This will be called from DoTransition after setting doingTransition to false
            // but will also be called first by Mirror when the scene loading finishes.
            if (!isInTransition)
                base.OnClientSceneChanged();
        }
        #endregion
```

<br>


OnServerReady메서드는 클라이언트가 ready가 되었을 때 서버에서 호출된다. NetworkServer.SetClientReady의 기본 구현은 네트워크 시작의 처리과정을 지속하기 위함이다.

Online 씬이 로딩된 후 클라이언트에서 서버로 메시지를 보낸다.

연결된 NetIdentity가 식별되지 않는다면 코루틴 함수를 호출한다.

```cs
        #region Server System Callbacks

        /// <summary>
        /// Called on the server when a client is ready.
        /// <para>The default implementation of this function calls NetworkServer.SetClientReady() to continue the network setup process.</para>
        /// </summary>
        /// <param name="conn">Connection from client.</param>
        public override void OnServerReady(NetworkConnectionToClient conn)
        {
            //Debug.Log($"OnServerReady {conn} {conn.identity}");

            // This fires from a Ready message client sends to server after loading the online scene
            base.OnServerReady(conn);

            if (conn.identity == null)
                StartCoroutine(AddPlayerDelayed(conn));
        }
```

<br>

AddPlayerDelayed 메서드는 서버가 OnServerSceneChaged 로부터 SubScene을 비동기화해서 로드하는 것보다 호스트 플레이어가 더 빨리 로드될 때를 대비한다.

서버에 모든 SubScenes 게임 인스턴스가 비동기 로드 될 때 까지 대기한다.

그리고 서버에 클라이언트에 첫 번째 Additive 씬을 로드할 것이라고 SceneMessage를 보내고 플레이어의 생성 위치는 각 SubScene의 StartPosition으로 한다.

플레이어를 StartPositin에 플레이어 프리팹을 통해서 생성하고 플레이어 게임오브젝트의 부모를 null로 해주어야 StartPosition의 자식에서 해제된다.

프레임이 끝날 때 까지 대기해서 SceneMessage가 먼저 보내지도록 한다.

마지막으로 플레이어 오브젝트를 연결상에 Spawn한다.

```cs
        // This delay is mostly for the host player that loads too fast for the
        // server to have subscenes async loaded from OnServerSceneChanged ahead of it.
        IEnumerator AddPlayerDelayed(NetworkConnectionToClient conn)
        {
            // Wait for server to async load all subscenes for game instances
            while (!subscenesLoaded)
                yield return null;

            // Send Scene msg to client telling it to load the first additive scene
            conn.Send(new SceneMessage { sceneName = additiveScenes[0], sceneOperation = SceneOperation.LoadAdditive, customHandling = true });

            // We have Network Start Positions in first additive scene...pick one
            Transform start = GetStartPosition();

            // Instantiate player as child of start position - this will place it in the additive scene
            // This also lets player object "inherit" pos and rot from start position transform
            GameObject player = Instantiate(playerPrefab, start);
            // now set parent null to get it out from under the Start Position object
            player.transform.SetParent(null);

            // Wait for end of frame before adding the player to ensure Scene Message goes first
            yield return new WaitForEndOfFrame();

            // Finally spawn the player object for this connection
            NetworkServer.AddPlayerForConnection(conn, player);
        }

        #endregion
    }
}
```


<br>

#### PhysicsSimulatior

씬에 물리적 효과들이 적용되도록 한다.

AdditiveLevelsNetworkManager.cs 에서 서버에 씬을 로드할 때 설정한 LocalPhysicsMode를 분기로 설정한다.

3D와 2D 각 PhysicsScene을 저장할 변수와 확인할 플래그를 선언한다.

```cs
using UnityEngine;

namespace Mirror.Examples.AdditiveLevels
{
    public class PhysicsSimulator : MonoBehaviour
    {
        PhysicsScene physicsScene;
        PhysicsScene2D physicsScene2D;

        bool simulatePhysicsScene;
        bool simulatePhysicsScene2D;
```
<br>

NetworkServer가 활성화되었을 때 현재 씬의 PhysicsScene 값을 저장하고 이 값이 유효하며 기본 PhysicsScene이 아닌가를 체크한다.


```cs
        void Awake()
        {
            if (NetworkServer.active)
            {
                physicsScene = gameObject.scene.GetPhysicsScene();
                simulatePhysicsScene = physicsScene.IsValid() && physicsScene != Physics.defaultPhysicsScene;

                physicsScene2D = gameObject.scene.GetPhysicsScene2D();
                simulatePhysicsScene2D = physicsScene2D.IsValid() && physicsScene2D != Physics2D.defaultPhysicsScene;
            }
            else
            {
                enabled = false;
            }
        }
```

<br>

FixedUpdate를 통해서 NetworkServer가 활성화 상태일 때 각 physicsScene의 상태를 체크해서 씬에 물리를 Simulate 한다.

```cs
        void FixedUpdate()
        {
            if (!NetworkServer.active) return;

            if (simulatePhysicsScene)
                physicsScene.Simulate(Time.fixedDeltaTime);

            if (simulatePhysicsScene2D)
                physicsScene2D.Simulate(Time.fixedDeltaTime);
        }
    }
}
```

<br>

#### Portal

SubLevelScene간의 전환 역할을 한다.

<br>

전환할 씬의 이름은 인스펙터 창에서 씬을 참조하여 얻게된다.

전환시 플레이어가 Spawn될 위치 저장 변수, 그리고 Portal 오브젝트의 정보를 표시하는 이름표로 자식에 TextMeshPro 오브젝트를 만들어서 사용한다.

포탈은 씬전환마다 이름이 변경되도록 SyncVar로 동기화한다.



```cs
using System.Collections;
using System.IO;
using System.Text.RegularExpressions;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Mirror.Examples.AdditiveLevels
{
    public class Portal : NetworkBehaviour
    {
        [Scene, Tooltip("Which scene to send player from here")]
        public string destinationScene;

        [Tooltip("Where to spawn player in Destination Scene")]
        public Vector3 startPosition;

        [Tooltip("Reference to child TMP label")]
        public TMPro.TextMeshPro label;

        [SyncVar(hook = nameof(OnLabelTextChanged))]
        public string labelText;
        
        // This is approximately the fade time
        WaitForSeconds waitForFade = new WaitForSeconds(2f);
```
<br>

OnLabelTextChaned 메서드는 Hook을 통해서 동기화 된다. labelText의 값이 변경될 경우 OnLabelTextChanged 메서드가 실행된다.


```cs
        public void OnLabelTextChanged(string _, string newValue)
        {
            label.text = labelText;
        }
```
<br>

OnStartServer는 서버가 시작될 때 호출된다. 

destinationScene에는 씬이 참조되어있어 string 값으로 씬의 경로까지 모두 나와있다.

System.IO.Path의 GetFileNameWithoutExtention 메서드를 이용해서 씬 파일 이름만 가져온다.

Regex.Replace는 입력한 문자열을 입력한 패턴과 문자로 변경시켜준다. 

>C#에서 문자열 앞 '@'는 그 안의 이스케이프 문자를 무시하고 문자열로 읽겠다는 뜻이다.
>\B : 백스페이스 이스케이프 문자가 아닌 정규 표현식, 문자와 공백사이가 아닌 값을 찾는다. (\b : 문자와 공백사이의 문자를 찾는다.)
>[A-Z0-9] : 알파벳 A부터 Z, 숫자 0부터 9 중에서 문자를 찾는다.
> \+ : 선행문자 패턴이 1개 이상 반복된다.
>$0 : 찾은 문자 중 첫번째를 의미한다.
>즉 문자열에서 대문자로 이어지거나 숫자가 나오면 띄어쓰기가 들어간다.


```cs
        public override void OnStartServer()
        {
            labelText = Path.GetFileNameWithoutExtension(destinationScene);

            // Simple Regex to insert spaces before capitals, numbers
            labelText = Regex.Replace(labelText, @"\B[A-Z0-9]+", " $0");
        }
```
<br>

플레이어가 포탈에 닿으면 씬이 전환된다. 

OnTriggerEnter를 사용해서 충돌을 감지한다. Tag 를 비교해서 Player일 때 확인한다.

Player 오브젝트에서 PlayerController 컴포넌트를 비활성화 하고 서버일 경우 플레이어를 이동시킬 씬으로 보낸다.

```cs
        // Note that I have created layers called Player(8) and Portal(9) and set them
        // up in the Physics collision matrix so only Player collides with Portal.
        void OnTriggerEnter(Collider other)
        {
            // tag check in case you didn't set up the layers and matrix as noted above
            if (!other.CompareTag("Player")) return;

            //Debug.Log($"{System.DateTime.Now:HH:mm:ss:fff} Portal::OnTriggerEnter {gameObject.name} in {gameObject.scene.name}");

            // applies to host client on server and remote clients
            if (other.TryGetComponent<PlayerController>(out PlayerController playerController))
                playerController.enabled = false;

            if (isServer)
                StartCoroutine(SendPlayerToNewScene(other.gameObject));
        }
```

<br>

서버에서 메서드를 호출시킨다.

SendPlayerToNewScene은 해당 플레이어의 NetworkIdentity를 저장한다. 

클라이언트에게 현재 씬을 unload 하도록 메시지를 보내고 씬이 사라질 때 까지 대기한다.

씬이 전환되는 동안 플레이어 게임오브젝트가 파괴되지 않도록 RemovePlayerConnection의 두번째 인자를 false로 보낸다.

해당 플레이어의 클라이언트와 서버상의 위치를 수정한다.

그리고 MoveGameObjectToScene을 사용해서 플레이어를 대상 씬으로 이동시킨다.

클라이언트에게 OnClientChangeScene을 통해서 subScene을 로드하도록 시킨다.

플레이어를 연결 시킨다.

```cs
        [ServerCallback]
        IEnumerator SendPlayerToNewScene(GameObject player)
        {
            if (player.TryGetComponent<NetworkIdentity>(out NetworkIdentity identity))
            {
                NetworkConnectionToClient conn = identity.connectionToClient;
                if (conn == null) yield break;

                // Tell client to unload previous subscene. No custom handling for this.
                conn.Send(new SceneMessage { sceneName = gameObject.scene.path, sceneOperation = SceneOperation.UnloadAdditive, customHandling = true });

                yield return waitForFade;

                //Debug.Log($"SendPlayerToNewScene RemovePlayerForConnection {conn} netId:{conn.identity.netId}");
                NetworkServer.RemovePlayerForConnection(conn, false);

                // reposition player on server and client
                player.transform.position = startPosition;
                player.transform.LookAt(Vector3.up);

                // Move player to new subscene.
                SceneManager.MoveGameObjectToScene(player, SceneManager.GetSceneByPath(destinationScene));

                // Tell client to load the new subscene with custom handling (see NetworkManager::OnClientChangeScene).
                conn.Send(new SceneMessage { sceneName = destinationScene, sceneOperation = SceneOperation.LoadAdditive, customHandling = true });

                //Debug.Log($"SendPlayerToNewScene AddPlayerForConnection {conn} netId:{conn.identity.netId}");
                NetworkServer.AddPlayerForConnection(conn, player);

                // host client would have been disabled by OnTriggerEnter above
                if (NetworkClient.localPlayer != null && NetworkClient.localPlayer.TryGetComponent<PlayerController>(out PlayerController playerController))
                    playerController.enabled = true;
            }
        }
    }
}
```