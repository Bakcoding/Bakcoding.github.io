---
title:  "Mirror Example - basic"
excerpt: "Network, Mirror, Example, basic"

categories:
  - Mirror
tags:
  - [Network, Mirror, Example, basic]

toc: true
toc_sticky: true
 
date: 2022-03-17
last_modified_at: 2022-03-17
---  

***

<br>

### Basic Example

Mirror 에셋을 프로젝트에 설치했다면 Asset에 Mirror 패키지 폴더가 보인다.  

Asset > Mirrkr > Example > Basic > Scene > Example 씬을 열어준다.

<br>

### Basic Scene

이 예제는 SyncVars그리고 Events와 함께 PlayerUI 프리팹으로 로컬 인스턴스화된 플레이어를 사용하여 플레이어 오브젝트에서 UI 오브젝트를 관리하는 방법을 보여 준다.

![basic_play](/assets/images/20220317_Posting/basic-play.png)

<br>

### Hierarchy

하이어라키 창에는 NetworkManager, Canvas 게임 오브젝트를 볼 수 있다.

#### NetworkManager

![networkMng](/assets/images/20220317_Posting/NetworkManager.png)

<br>

NetwrokManager 게임 오브젝트의 컴포넌트 중 Basci Net Manager 스크립트는 NetworkManager를 상속해서 오버라이드한 컴포넌트이다.

```cs
// BasicNetManager.cs
using UnityEngine;

/*
	Documentation: https://mirror-networking.gitbook.io/docs/components/network-manager
	API Reference: https://mirror-networking.com/docs/api/Mirror.NetworkManager.html
*/

namespace Mirror.Examples.Basic
{
    [AddComponentMenu("")]
    public class BasicNetManager : NetworkManager
    {
        /// <summary>
        /// Called on the server when a client adds a new player with NetworkClient.AddPlayer.
        /// <para>The default implementation for this function creates a new player object from the playerPrefab.</para>
        /// </summary>
        /// <param name="conn">Connection from client.</param>
        public override void OnServerAddPlayer(NetworkConnectionToClient conn)
        {
            base.OnServerAddPlayer(conn);
            Player.ResetPlayerNumbers();
        }

        /// <summary>
        /// Called on the server when a client disconnects.
        /// <para>This is called on the Server when a Client disconnects from the Server. Use an override to decide what should happen when a disconnection is detected.</para>
        /// </summary>
        /// <param name="conn">Connection from client.</param>
        public override void OnServerDisconnect(NetworkConnectionToClient conn)
        {
            base.OnServerDisconnect(conn);
            Player.ResetPlayerNumbers();
        }
    }
}
```

*   OnServerAddPlayer

    ClientScene.AddPlayer를 사용해서 클라이언트에서 새 플레이어가 추가될 때 서버에서 호출된다.

*   OnServerDisconnect

    클라이언트가 연결이 해제될 때 서버에서 호출된다.

<br>

#### Canvas

![canvas](/assets/images/20220317_Posting/canvas.png)

<br>

Canvas 오브젝트는 자식으로 MainPanel, BorderPanel, PlayerPanel을 포함하고 있다.

기본적으로 비활성화 상태이다.

Canvas의 CanvasUI 컴포넌트에는 Main Panel과 Player Panel이 참조되어있다.

```cs
// CanvasUI.cs
using UnityEngine;

namespace Mirror.Examples.Basic
{
    public class CanvasUI : MonoBehaviour
    {
        [Tooltip("Assign Main Panel so it can be turned on from Player:OnStartClient")]
        public RectTransform mainPanel;

        [Tooltip("Assign Players Panel for instantiating PlayerUI as child")]
        public RectTransform playersPanel;

        // static instance that can be referenced directly from Player script
        public static CanvasUI instance;

        void Awake()
        {
            instance = this;
        }
    }
}
```

*   public static CanvasUI instance

    player 스크립트에서 직접 참조할 수 있도록 정적으로 선언했다.

특별한 기능은 구현되어있지 않으며 참조된 Panel에 대한 접근을 위해서 정적으로 만들기 위한 스크립트이다.

<br>

#### Player

![hierarchy](/assets/images/20220317_Posting/hierarchy.png)

<br>

게임을 플레이하고 Host를 선택하면 오브젝트가 생성되면서 Canvas의 자식들이 활성화 된다.

이 동작들은 모두 Player 스크립트와 관련있다.

```cs
//Player.cs
using System.Collections.Generic;
using UnityEngine;

namespace Mirror.Examples.Basic
{
    public class Player : NetworkBehaviour
    {
        // Events that the PlayerUI will subscribe to
        public event System.Action<byte> OnPlayerNumberChanged;
        public event System.Action<Color32> OnPlayerColorChanged;
        public event System.Action<ushort> OnPlayerDataChanged;

        // Players List to manage playerNumber
        static readonly List<Player> playersList = new List<Player>();

        [Header("Player UI")]
        public GameObject playerUIPrefab;

        GameObject playerUIObject;
        PlayerUI playerUI = null;

        #region SyncVars

        [Header("SyncVars")]

        /// <summary>
        /// This is appended to the player name text, e.g. "Player 01"
        /// </summary>
        [SyncVar(hook = nameof(PlayerNumberChanged))]
        public byte playerNumber = 0;

        /// <summary>
        /// Random color for the playerData text, assigned in OnStartServer
        /// </summary>
        [SyncVar(hook = nameof(PlayerColorChanged))]
        public Color32 playerColor = Color.white;

        /// <summary>
        /// This is updated by UpdateData which is called from OnStartServer via InvokeRepeating
        /// </summary>
        [SyncVar(hook = nameof(PlayerDataChanged))]
        public ushort playerData = 0;

        // This is called by the hook of playerNumber SyncVar above
        void PlayerNumberChanged(byte _, byte newPlayerNumber)
        {
            OnPlayerNumberChanged?.Invoke(newPlayerNumber);
        }

        // This is called by the hook of playerColor SyncVar above
        void PlayerColorChanged(Color32 _, Color32 newPlayerColor)
        {
            OnPlayerColorChanged?.Invoke(newPlayerColor);
        }

        // This is called by the hook of playerData SyncVar above
        void PlayerDataChanged(ushort _, ushort newPlayerData)
        {
            OnPlayerDataChanged?.Invoke(newPlayerData);
        }

        #endregion

        #region Server

        /// <summary>
        /// This is invoked for NetworkBehaviour objects when they become active on the server.
        /// <para>This could be triggered by NetworkServer.Listen() for objects in the scene, or by NetworkServer.Spawn() for objects that are dynamically created.</para>
        /// <para>This will be called for objects on a "host" as well as for object on a dedicated server.</para>
        /// </summary>
        public override void OnStartServer()
        {
            base.OnStartServer();

            // Add this to the static Players List
            playersList.Add(this);

            // set the Player Color SyncVar
            playerColor = Random.ColorHSV(0f, 1f, 0.9f, 0.9f, 1f, 1f);

            // set the initial player data
            playerData = (ushort)Random.Range(100, 1000);

            // Start generating updates
            InvokeRepeating(nameof(UpdateData), 1, 1);
        }

        // This is called from BasicNetManager OnServerAddPlayer and OnServerDisconnect
        // Player numbers are reset whenever a player joins / leaves
        [ServerCallback]
        internal static void ResetPlayerNumbers()
        {
            byte playerNumber = 0;
            foreach (Player player in playersList)
                player.playerNumber = playerNumber++;
        }

        // This only runs on the server, called from OnStartServer via InvokeRepeating
        [ServerCallback]
        void UpdateData()
        {
            playerData = (ushort)Random.Range(100, 1000);
        }

        /// <summary>
        /// Invoked on the server when the object is unspawned
        /// <para>Useful for saving object data in persistent storage</para>
        /// </summary>
        public override void OnStopServer()
        {
            CancelInvoke();
            playersList.Remove(this);
        }

        #endregion

        #region Client

        /// <summary>
        /// Called on every NetworkBehaviour when it is activated on a client.
        /// <para>Objects on the host have this function called, as there is a local client on the host. The values of SyncVars on object are guaranteed to be initialized correctly with the latest state from the server when this function is called on the client.</para>
        /// </summary>
        public override void OnStartClient()
        {
            Debug.Log("OnStartClient");

            // Instantiate the player UI as child of the Players Panel
            playerUIObject = Instantiate(playerUIPrefab, CanvasUI.instance.playersPanel);
            playerUI = playerUIObject.GetComponent<PlayerUI>();

            // wire up all events to handlers in PlayerUI
            OnPlayerNumberChanged = playerUI.OnPlayerNumberChanged;
            OnPlayerColorChanged = playerUI.OnPlayerColorChanged;
            OnPlayerDataChanged = playerUI.OnPlayerDataChanged;

            // Invoke all event handlers with the initial data from spawn payload
            OnPlayerNumberChanged.Invoke(playerNumber);
            OnPlayerColorChanged.Invoke(playerColor);
            OnPlayerDataChanged.Invoke(playerData);
        }

        /// <summary>
        /// Called when the local player object has been set up.
        /// <para>This happens after OnStartClient(), as it is triggered by an ownership message from the server. This is an appropriate place to activate components or functionality that should only be active for the local player, such as cameras and input.</para>
        /// </summary>
        public override void OnStartLocalPlayer()
        {
            Debug.Log("OnStartLocalPlayer");

            // Set isLocalPlayer for this Player in UI for background shading
            playerUI.SetLocalPlayer();

            // Activate the main panel
            CanvasUI.instance.mainPanel.gameObject.SetActive(true);
        }

        /// <summary>
        /// Called when the local player object is being stopped.
        /// <para>This happens before OnStopClient(), as it may be triggered by an ownership message from the server, or because the player object is being destroyed. This is an appropriate place to deactivate components or functionality that should only be active for the local player, such as cameras and input.</para>
        /// </summary>
        public override void OnStopLocalPlayer()
        {
            // Disable the main panel for local player
            CanvasUI.instance.mainPanel.gameObject.SetActive(false);
        }

        /// <summary>
        /// This is invoked on clients when the server has caused this object to be destroyed.
        /// <para>This can be used as a hook to invoke effects or do client specific cleanup.</para>
        /// </summary>
        public override void OnStopClient()
        {
            // disconnect event handlers
            OnPlayerNumberChanged = null;
            OnPlayerColorChanged = null;
            OnPlayerDataChanged = null;

            // Remove this player's UI object
            Destroy(playerUIObject);
        }

        #endregion
    }
}
```

*   Event

    ```cs
    public event System.Action<byte> OnPlayerNumberChanged;
    public event System.Action<Color32> OnPlayerColorChanged;
    public event System.Action<ushort> OnPlayerDataChanged;

    [SyncVar(hook = nameof(PlayerNumberChanged))]
    public byte playerNumber = 0;
    [SyncVar(hook = nameof(PlayerColorChanged))]
    public Color32 playerColor = Color.white;
    [SyncVar(hook = nameof(PlayerDataChanged))]
    public ushort playerData = 0;
    ```

    플레이어 오브젝트가 생성되면 event는 PlayerUI 에 요청된다.
    각각 플레이어 이름, 색, 데이터로 모든 클라이언트가 공유해야할 정보이기 때문에 SyncVar가 사용되었다.
    

*   Changed

    ```cs
    void PlayerNumberChanged(byte _, byte newPlayerNumber)
    {
            OnPlayerNumberChanged?.Invoke(newPlayerNumber);
    }
    void PlayerColorChanged(Color32 _, Color32 newPlayerColor){}
    void PlayerDataChanged(ushort _, ushort newPlayerData){}
    ```

    Hook 이 호출되고 나서 동작하는 함수이다. 플레이어가 추가될 때마다 새로운 정보로 갱신한다.

    EventHandler?.Invoke() : 해당 이벤트가 실행되고 나서 input이 진행된다.

