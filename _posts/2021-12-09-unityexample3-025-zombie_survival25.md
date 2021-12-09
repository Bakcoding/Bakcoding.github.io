---
title:  "[레트로의 유니티] 좀비서바이벌25 - 네트워크 - 게임매니저"
excerpt: "unity3d, retro, example, zombie, multiplayer, photon"

categories:
  - UnityExample
tags:
  - [unity3d, retro, example, zombie, multiplayer, photon]

toc: true
toc_sticky: true
 
date: 2021-12-09 
last_modified_at: 2021-12-09
---  

***  

### Game Manager

Game Manager 오브젝트의 컴포넌트가 변경된다. 

* GameManager 스크립트 부분에는 Player Prefab을 받는 필드가 생성됐다. 

* Pohton View 컴포넌트가 추가되고 Observed Components에 GameManager 컴포넌트가 추가된다. 

<br>

### GameManager

MonoBehaviour 대신 MonoBehaviourPunCallbacks, IPunObservable 를 상속받는다.

게임 점수와 게임 오버 상태를 관리하던 스크립트이다. 네트워크 플레이어 캐릭터를 생성하고 점수를 동기화하며 룸 나가기를 구현한다.  

#### MonoBehaviourPunCallbacks 

이 클래스를 상속한 스크립트는 여러 Photon의 이벤트를 감지할 수 있다. 

GameManager 스크립트는 룸 나가기 구현을 할것이기 때문에 OnLeftRoom() 이벤트를 감지하고 해당 메서드를 자동 실행하기 위해 해당 클래스를 상속한다. 

<br>

#### OnLeftRoom()

```cs
// 룸을 나갈때 자동 실행되는 메서드
public override void OnLeftRoom() {
    // 룸을 나가면 로비 씬으로 돌아감
    SceneManager.LoadScene("Lobby");
}
```

이 메서드는 룸을 나갈 경우 자동으로 실행된다. 로컬 클라이언트에서만 실행되며 다른 클라이언트에게는 여전히 룸에 접속된 상태로 남는다.  

<br>

#### Update()

```cs
// 키보드 입력을 감지하고 룸을 나가게 함
private void Update() {
    if (Input.GetKeyDown(KeyCode.Escape))
    {
        PhotonNetwork.LeaveRoom();
    }
}
```

룸을 나가기 위한 ESC키 입력을 감지하고 룸을 나가는 동작일 실행한다. 

<br>

#### OnPhotonSerializeView()

Photon View 컴포넌트가 추가된 네트워크 게임 오브젝트가 PhotonNetwork.Instantiate()를 사용해 게임 도중에 생성된 것이 아닌 처음부터 씬에 있었던 게임 오브젝트라면 그 소유권은 호스트에 있다. 

즉, Game Manager 오브젝트는 호스트 클라이언트에 로컬인 게임 오브젝트이다.

Enemy Spawner에서 좀비가 사망 시 호스트의 GameManger 컴포넌트에서만 AddScore() 메서드를 실행시킬것이다.  

그러기 위해서 호스트의 GameManager 컴포넌트에서 다른 클라이언트의 GameManager 컴포넌트로 점수를 동기화해야한다.  

호스트 입장에서 Game Manager 오브젝트는 로컬이기 때문에 IPunObservable 인터페이스를 상속하고 OnPhotonSerializeView() 메서드를 구현하여 로컬에서 리모트로의 점수 동기화를 구현하면 호스트에 갱신된 점수가 다른 클라이언트에도 자동 반영된다.  

```cs
// 주기적으로 자동 실행되는, 동기화 메서드
public void OnPhotonSerializeView(PhotonStream stream, PhotonMessageInfo info) {
    // 로컬 오브젝트라면 쓰기 부분이 실행됨
    if (stream.IsWriting)
    {
        // 네트워크를 통해 score 값을 보내기
        stream.SendNext(score);
    }
    else
    {
        // 리모트 오브젝트라면 읽기 부분이 실행됨         

        // 네트워크를 통해 score 값 받기
        score = (int) stream.ReceiveNext();
        // 동기화하여 받은 점수를 UI로 표시
        UIManager.instance.UpdateScoreText(score);
    }
}
```

리모트 GameManager는 네트워크를 통해 점수를 받아오는 시점에서 UIManager.instance.UpdateScoreText(score)를 실행하여 UI가 갱신되도록 작성한다.  

호스트에서는 AddScore() 메서드가 실행되면서 UIManager.instance.UpdateScoreText(score)에 의해 UI가 생신된다. 하지만 다른 클라이언트에서는 AddScore() 메서드가 실행되지 못하므로 실행되는 시점에 UI를 갱신하도록 한다.

<br>

#### Start()

룸에 접속한 클라이언트들은 서로의 클라이언트에서 분신 캐릭터를 생성해야 한다.  

```cs
// 게임 시작과 동시에 플레이어가 될 게임 오브젝트를 생성
private void Start() {
    // 생성할 랜덤 위치 지정
    Vector3 randomSpawnPos = Random.insideUnitSphere * 5f;
    // 위치 y값은 0으로 변경
    randomSpawnPos.y = 0f;

    // 네트워크 상의 모든 클라이언트들에서 생성 실행
    // 단, 해당 게임 오브젝트의 주도권은, 생성 메서드를 직접 실행한 클라이언트에게 있음
    PhotonNetwork.Instantiate(playerPrefab.name, randomSpawnPos, Quaternion.identity);
}
```

이 때 GameManager 스크립트의 Start() 메서드와 그 안의 PhotonNetwork.Instantiate() 메서드는 각각의 클라이언트에서 따로 실행된다.  

만약 클라이언트 A와 B가 있을 때 A가 이미 접속한 상태에서 B가 나중에 룸에 접속했다면  

1. 클라이언트 B가 룸에 접속 -> B에서 GameManager Start() 실행  

2. PhotonNetwork.Instantiate()에 의해 플레이어 캐릭터 b를 A와 B에 생성  

A가 먼저 룸을 만들고 들어가면서 이미 Start() 메서드를 실행한 상태이기 때문에 클라이언트 B에서 Start() 메서드가 실행될 때 A에서는 실행되지 않는다. 

PhotonNetwork.Instantiate() 메서드는 생성된 네트워크 오브젝트의 소유권을 해당 코드를 직접 실행한 클라이언트에 준다.  

또한 PUN은 어떤 클라이언트가 룸에 접속하기 전에 해당 룸에서 PhotonNetwork.Instantiate()를 사용해 이미 생성된 오브젝트가 있을 때 뒤늦게 들어온 클라이언트에도 해당 네트워크 오브젝트를 자동 생성해주게된다.  

즉 

1. 클라이언트 A가 룸을 생성 및 접속

2. A에서 GameManager의 Start() 실행

3. A가 PhotonNetwork.Instantiate()에 의해 플레이어 캐릭터 a를 A에 생성

4. 클라이언트 B가 룸에 접속 -> 클라이언트 B에 자동으로 a가 생성

5. B에서 GameManager의 Start() 실행

6. B가 PhotonNetwork.Instantiate()에 의해 플레이어 캐릭터 b를 A와 B에 생성  

으로 진행된다.