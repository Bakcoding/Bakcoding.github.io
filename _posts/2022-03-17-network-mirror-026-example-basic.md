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
last_modified_at: 2023-06-05
---  

***

<br>

## Basic Example

Mirror 에셋을 프로젝트에 설치했다면 Asset에 Mirror 패키지 폴더가 보인다.  

Asset > Mirror > Example > Basic > Scenes > Example 씬을 열어준다.

<br>

<br>

### Basic Scene

이 예제는 SyncVars그리고 Events와 함께 PlayerUI 프리팹으로 로컬 인스턴스화된 플레이어를 사용하여 플레이어 오브젝트에서 UI 오브젝트를 관리하는 방법을 보여 준다.

![basic_play](/assets/images/posting/20220317/basic-play.png)

<br>

### Hierarchy

하이어라키 창에는 NetworkManager, Canvas 게임 오브젝트를 볼 수 있다.

<br>

#### NetworkManager

![networkMng](/assets/images/posting/20220317/NetworkManager.png)

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

![canvas](/assets/images/posting/20220317/canvas.png)

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

#### PlayerUI

![hierarchy](/assets/images/posting/20220317/hierarchy.png)

<br>

게임을 플레이하고 Host를 선택하면 오브젝트가 생성되면서 Canvas의 자식들이 활성화 된다.

PlayersPanel에 PlayerUI가 생성된다. PlayerUI는 플레이어의 번호와 데이터 정보가 표시된다.

```cs
using UnityEngine;
using UnityEngine.UI;

namespace Mirror.Examples.Basic
{
    public class PlayerUI : MonoBehaviour
    {
        [Header("Player Components")]
        public Image image;

        [Header("Child Text Objects")]
        public Text playerNameText;
        public Text playerDataText;

        /// <summary>
        /// Caches the controlling Player object, subscribes to its events
        /// </summary>
        /// <param name="player">Player object that controls this UI</param>
        /// <param name="isLocalPlayer">true if the Player object is the Local Player</param>
        public void SetLocalPlayer()
        {
            // add a visual background for the local player in the UI
            image.color = new Color(1f, 1f, 1f, 0.1f);
        }

        // This value can change as clients leave and join
        public void OnPlayerNumberChanged(byte newPlayerNumber)
        {
            playerNameText.text = string.Format("Player {0:00}", newPlayerNumber);
        }

        // Random color set by Player::OnStartServer
        public void OnPlayerColorChanged(Color32 newPlayerColor)
        {
            playerNameText.color = newPlayerColor;
        }

        // This updates from Player::UpdateData via InvokeRepeating on server
        public void OnPlayerDataChanged(ushort newPlayerData)
        {
            // Show the data in the UI
            playerDataText.text = string.Format("Data: {0:000}", newPlayerData);
        }
    }
}
```

OnPlayerNumberChanged
OnPlayerColorChanged
OnPlayerDataChanged

이 메서드들이 Player 스크립트에서 Handler를 subscribe하여 클라이언트마다 다른 UI가 반영된다.

<br>

#### Player

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
    ```

    위 event를 PlayerUI 함수가 subscribe하면서 정보가 서버에 업데이트 될 때 UI의 요소들도 업데이트 된다.


    <br>
    
* SyncVar

    ```cs
    [SyncVar(hook = nameof(PlayerNumberChanged))]
    public byte playerNumber = 0;
    [SyncVar(hook = nameof(PlayerColorChanged))]
    public Color32 playerColor = Color.white;
    [SyncVar(hook = nameof(PlayerDataChanged))]
    public ushort playerData = 0;
    ```

    각각 플레이어 이름, 색, 데이터로 모든 클라이언트가 공유해야할 정보이기 때문에 SyncVar를 사용해서 변수를 동기화한다.
    
    <br>

*   Changed

    ```cs
    void PlayerNumberChanged(byte _, byte newPlayerNumber)
    {
            OnPlayerNumberChanged?.Invoke(newPlayerNumber);
    }
    void PlayerColorChanged(Color32 _, Color32 newPlayerColor){}
    void PlayerDataChanged(ushort _, ushort newPlayerData){}
    ```

    SyncVar를 통해서 동기화시킨 변수들에 의해서 호출되는 메서드이다. 

    <br>

*   OnStartServer

    서버에 NetworkBehivour 오브젝트가 활성화되면 호출된다.
     
    따라서 Host로 접속하거나 ServerOnly로 접속해서 클라이언트가 들어올 때 호출된다.

    ```cs
    public override void OnStartServer()
    {
        base.OnStartServer();
        playersList.Add(this);
        playerColor = Random.ColorHSV(0f, 1f, 0.9f, 0.9f, 1f, 1f);
        playerData = (ushort)Random.Range(100, 1000);
        InvokeRepeating(nameof(UpdateData), 1, 1);
    }
    ```

    상속받은 NetworkManager에서 OnStartServer메서드를 실행한다.

    플레이어를 저장하는 리스트에 현재 클라이언트의 플레이어를 저장한다.

    색상과 데이터는 범위 내에서 랜덤하게 찍어낸다.

    데이터의 경우 InvokeReapeating으로 실행시켜 주기적으로 값이 변한다.

    >InvokeRepeating(string methodName, float time, float repeatRate)
    >메서드를 time 동안 실행하고 repeatRate간격으로 반복한다.

<br>

*   \[ServerCallback\]

    서버에서 호출할 수 있는 메서드이다. \[Server\] 와 유사하지만 클라이언트에서 호출해도 에러가 발생하지 않는다는 차이가 있다.


    ResetPlayerNumbers 메서드는 BasicNetManager, OnServerAddPlayer, OnServerDisconnect에서 호출된다. 

    Player 숫자는 참가/ 퇴장시 초기화 된다.

    ```cs
    [ServerCallback]
    internal static void ResetPlayerNumbers()
    {
        byte playerNumber = 0;
        foreach (Player player in playersList)
            player.playerNumber = playerNumber++;
    }
    ```

    서버에서만 호출된다. InvokeRepeating을 통해서 OnStartSever에서 호출된다.

    ```cs
    [ServerCallback]
    void UpdateData()
    {
        playerData = (ushort)Random.Range(100, 1000);
    }
    ```

    <br>

*   OnStopServer

    서버에서 오브젝트가 unspawned 될 때 호출된다.

    스토리지의 지속적인 오브젝트 데이터를 절약하는데 유용하다.

    ```cs
    public override void OnStopServer()
    {
        CancelInvoke();
        playersList.Remove(this);
    }  
    ```

    CancelInvoke()로 playerDate가 변경되는걸 멈춘다.
    리스트에서 해당 플레이어를 지운다.

    >CancelInvoke()
    >모든 Invoke 호출을 중단시킨다.

    <br>

*   OnStartClient

    클라이언트가 활성화 됐을 때 모든 NetworkBehaviour에서 호출된다.

    로컬 클라이언트가 있는 호스트에서도 호출된다. 

    플레이어를 PlayersPanel 위치에 프리팹을 통해서 생성한다.

    ```cs
    public override void OnStartClient()
    {
        Debug.Log("OnStartClient");

        playerUIObject = Instantiate(playerUIPrefab, CanvasUI.instance.playersPanel);
        playerUI = playerUIObject.GetComponent<PlayerUI>();
    ```

    PlayerUI 스크립트의 UI를 갱신하는 메서드를 Handler에 등록한다.

    ```cs
        OnPlayerNumberChanged = playerUI.OnPlayerNumberChanged;
        OnPlayerColorChanged = playerUI.OnPlayerColorChanged;
        OnPlayerDataChanged = playerUI.OnPlayerDataChanged;
    ```

    각 handler에 있는 모든 이벤트를 Invoke로 실행시켜서 해당 값으로 플레이어에 반영시킨다.

    ```cs
        OnPlayerNumberChanged.Invoke(playerNumber);
        OnPlayerColorChanged.Invoke(playerColor);
        OnPlayerDataChanged.Invoke(playerData);
    }
    ```

    >핸들러의 Invoke는 지연시켜 실행하는 함수인 MonoBehaviour.Invoke와 달리
    >강제로 이벤트를 발동시키는 동작을 한다.

    <br>

*   OnStartLocalPlayer

    로컬 플레이어가 만들어졌을 때 호출된다. 

    로컬 플레이어가 만들어지면 playerUI를 생성하고 오브젝트를 활성화시킨다.

    ```cs
    public override void OnStartLocalPlayer()
    {
        Debug.Log("OnStartLocalPlayer");
        playerUI.SetLocalPlayer();
        CanvasUI.instance.mainPanel.gameObject.SetActive(true);
    }
    ```

    <br>

*   OnStopLocalPlayer

    로컬 플레이어 오브젝트가 정지할 때 호출된다. OnStopClient 이전에 호출된다.

    CanvasUI를 비활성화 시킨다.

    ```cs
    public override void OnStopLocalPlayer()
    {
        CanvasUI.instance.mainPanel.gameObject.SetActive(false);
    }
    ```

*   OnStopClient

    서버에서 오브젝트가 파괴될 때 클라이언트에서 동작한다.

    사용한 변수 값들을 null로 만들고 playerUI 오브젝트를 파괴한다.

    ```cs
    public override void OnStopClient()
    {
        OnPlayerNumberChanged = null;
        OnPlayerColorChanged = null;
        OnPlayerDataChanged = null;

        Destroy(playerUIObject);
    }
    ```
    
    <br>

### 전체적인 코드의 흐름

**호스트 연결**

*   BasicNetManager의 OnServerAddPlayer 내부의 base.OnServerAddPlayer 동작

*   Player의 OnStartServer의 base.OnStartServer 실행, PlayerList에 현재 플레이어 추가

*   playerColor가 랜덤으로 세팅되면서 PlayerColorChanged가 실행되고 색상이 정해진 다음 playerData는 RepeatInvoke에 등록된다.

*   다시 BasicNetManager로 가서 다음 코드인 Player.ResetPlayerNumbers를 동작시켜 플레이어의 숫자가 초기화 후 다시 설정된다. 

*   이 때 PlayerNumberChanged가 실행되면서 플레이어의 숫자가 동기화된다.

    이 프로젝트에서 플레어의 번호는 들어온 순서대로 매겨지며 중간에 참여하거나 나갔을을 경우 전체 플레이어의 번호가 다시 매겨진다.

*   playerNumber 설정이 끝나면 OnStartClient로 넘어간다. 그리고 playerUI 오브젝트를 해당 위치에서 인스턴스화한 다음 UI값들을 해당 플레이어의 값들로 변경시킨다.

<br>

**호스트 연결해제**

* BasicNetManager의 OnServerDisconnect에서 base.OnServerDisconnect가 실행된다.

* Player의 OnStopLocalPlayer가 호출되면서 CanvasUI 오브젝트가 비활성화된다.

* OnStopClient에서 Player의 변수 값들을 null로 만들고 PlayerUI 오브젝트를 파괴한다. 

* OnStopServer가 호출되면서 playerList 안에 해당 플레이어가 제거되고 연결이 해제된다.
