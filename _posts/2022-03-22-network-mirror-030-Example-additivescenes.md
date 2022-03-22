---
title:  "Mirror Example - Additive Scenes"
excerpt: "Network, Mirror, Example, Additive-Scenes"

categories:
  - Mirror
tags:
  - [Network, Mirror, Example, Additive-Scenes]

toc: true
toc_sticky: true
 
date: 2022-03-22
last_modified_at: 2022-03-22
---  

***

<br>

## Additive Scenes Example

Assets > Mirror > Examples > Additives > Scenes

MainScene과 SubScene 두 개를 Additive 해서 네트워크에 연결한다.

<br>

### AdditiveNetworkManager 

Zone 오브젝트의 참조를 가져온다.

SubScene 의 이름도 문자열로 가져온다. 

\[Scene] 을 통해서 문자열을 씬으로 변환한다.

```cs
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

/*
	Documentation: https://mirror-networking.gitbook.io/docs/components/network-manager
	API Reference: https://mirror-networking.com/docs/api/Mirror.NetworkManager.html
*/

namespace Mirror.Examples.AdditiveScenes
{
    [AddComponentMenu("")]
    public class AdditiveNetworkManager : NetworkManager
    {
        [Tooltip("Trigger Zone Prefab")]
        public GameObject Zone;

        [Scene]
        [Tooltip("Add all sub-scenes to this list")]
        public string[] subScenes;
```
<br>

OnStartServer Behaivour 객체가 서버에 생성되면 호출된다. 

base.OnStartServer를 호출하고 서버상에만 모든 서브 신들을 로드한다.

Zone을 서버에서 인스턴스화한다.

```cs
        public override void OnStartServer()
        {
            base.OnStartServer();

            // load all subscenes on the server only
            StartCoroutine(LoadSubScenes());

            // Instantiate Zone Handler on server only
            Instantiate(Zone);
        }
```
<br>

OnStopServer는 서버에서 Behaivour가 파괴되거나 사라질 때 호출된다. 

이 때 UnLoadScene을 호출해서 모든 서브씬을 unload한다.

```cs
        public override void OnStopServer()
        {
            StartCoroutine(UnloadScenes());
        }
```
<br>

OnStopClient는 ObjectDestroyMessage 또는 ObjectHideMessage로 클라이언트의 오브젝트가 파괴될 때 호출된다. 

이 때 UnLoadScene을 호출해서 모든 서브씬을 unload한다.

```cs
        public override void OnStopClient()
        {
            StartCoroutine(UnloadScenes());
        }
```

<br>

참조된 모든 서브씬을 로드한다.

SceneManager.LoadSceneAsync를 사용해서 Additive 모드로 씬을 로드한다.

```cs
        IEnumerator LoadSubScenes()
        {
            Debug.Log("Loading Scenes");

            foreach (string sceneName in subScenes)
            {
                yield return SceneManager.LoadSceneAsync(sceneName, LoadSceneMode.Additive);
                // Debug.Log($"Loaded {sceneName}");
            }
        }
```
<br>


씬의 유효성을 검사해서 유효한 씬이 있다면 unload한다.

그리고 사용하지 않는 에셋을 반환시키고 대기한다.

```cs
        IEnumerator UnloadScenes()
        {
            Debug.Log("Unloading Subscenes");

            foreach (string sceneName in subScenes)
                if (SceneManager.GetSceneByName(sceneName).IsValid() || SceneManager.GetSceneByPath(sceneName).IsValid())
                {
                    yield return SceneManager.UnloadSceneAsync(sceneName);
                    // Debug.Log($"Unloaded {sceneName}");
                }

            yield return Resources.UnloadUnusedAssets();
        }
    }
}
```

<br>

### ZoneHandler 

Zone 프리팹에 붙어있는 스크립트이다. Zone 오브젝트는 플레이어 레이어에 있으며 AdditiveNetworkManager의 OnStartServer에서 오직 서버에서만 인스턴스화된다.

클라이언트에서는 존재하지 않으며 (호스트 제외), OnTrigger 이벤트는 오직 서버에서만 발생하고 클라이언트에는 서브씬의 로드에 대한 메시지만 전송된다.

```cs
using UnityEngine;

namespace Mirror.Examples.AdditiveScenes
{
    // This script is attached to a prefab called Zone that is on the Player layer
    // AdditiveNetworkManager, in OnStartServer, instantiates the prefab only on the server.
    // It never exists for clients (other than host client if there is one).
    // The prefab has a Sphere Collider with isTrigger = true.
    // These OnTrigger events only run on the server and will only send a message to the
    // client that entered the Zone to load the subscene assigned to the subscene property.
    public class ZoneHandler : MonoBehaviour
    {
        [Scene]
        [Tooltip("Assign the sub-scene to load for this zone")]
        public string subScene;
```
<br>

다른 오브젝트가 감지되면 NetworkIdentity를 식별하고 SceneMessage를 해당 클라이언트에 전송한다.

```cs
        [ServerCallback]
        void OnTriggerEnter(Collider other)
        {
            // Debug.Log($"Loading {subScene}");

            NetworkIdentity networkIdentity = other.gameObject.GetComponent<NetworkIdentity>();
            SceneMessage message = new SceneMessage{ sceneName = subScene, sceneOperation = SceneOperation.LoadAdditive };
            networkIdentity.connectionToClient.Send(message);
        }

        [ServerCallback]
        void OnTriggerExit(Collider other)
        {
            // Debug.Log($"Unloading {subScene}");

            NetworkIdentity networkIdentity = other.gameObject.GetComponent<NetworkIdentity>();
            SceneMessage message = new SceneMessage{ sceneName = subScene, sceneOperation = SceneOperation.UnloadAdditive };
            networkIdentity.connectionToClient.Send(message);
        }
    }
}
```