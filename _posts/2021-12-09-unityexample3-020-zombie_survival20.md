---
title:  "[레트로의 유니티] 좀비서바이벌20 - 로비"
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

### 멀티플레이 만들기  

#### 개요  

* 최대 4명의 플레이어가 서로 협동하여 좀비를 학살한다.  

* 기본 게임 플레이 구성은 싱글 플레이어 버전과 같다.  

* 사망한 플레이어는 5초 뒤에 다시 부활한다.  

* 매치메이킹 시스템을 지원한다. 로비에서 인터넷을 통해 자동으로 빈 룸을 찾아 다른 플레이어의 게임에 참가한다.  

<br>

#### 조작키 

* 추가

  ESC : 룸 나가기


<br>

### 포톤  

포톤을 유니티 프로젝트에 연동해 본다.  

포톤은 다양한 플랫폼과 게임 엔진을 지원하는 네트워크 종합 솔루션이다. 포톤은 멀티플레이어 게임에 필요한 클라우드 서버 대여 서비스, 실시간으로 게임 서버를 관리할 수 있는 웹 서비스, 여러 게임 엔진에 플러그인 형태로 삽입할 수 있는 네트워크 엔진 등을 제공한다.  

<br>

#### PUN2

Photon Unity Network

유니티용으로 제작된 포톤 네트워크 엔진이다. 본래 포톤의 여러 기능은 플랫폼과 상관없이 동작하지만 PUN의 기능 중 하나인 Photon Realtime 등 포톤의 여러 API를 유니티 컴포넌트로 랩핑하여 제공한다. 따라서 PUN을 사용해 포톤의 여러 기능을 게임 오브젝트에 컴포넌트로 추가할 수 있다.  

<br>

#### PUN2 세팅

* 패키지 설치

  * 예제 18 폴더의 Zombie Multiplayer 프로젝트를 유니티로 연다.  

  * Assets > General > Asset Store

  * PUN2 - Free > Download > Import

* 설정

  * Window > Photon Unity Networking > PUN Wizard

  * Setup Project 클릭

  * Appid 입력 또는 이메일로 신규가입

<br>

### 로비 씬

Project > Scenes > Lobby 씬 열기

**Lobby Scene 구성**

* Main Camera

  카메라

* Lobby Manager 

  네트워크 로비 관리자

* Canvas 

  UI 캔버스

  - Panel : 배경 패널 

    - Title Text : 제목 텍스트

    - Connection Info Text : 네트워크 접속 정보 표시 텍스트

    - Join Button : 룸 접속 시작 버튼  

* EventSystem  

  UI 이벤트 관리자 


Lobby Manager 오브젝트에는 LobbyManager 스크립트가 포함되어있다. 실제로 로비를 생성하는 기능을 담당한다. 

<br>

#### Start()  

```cs
// 게임 실행과 동시에 마스터 서버 접속 시도
private void Start() {
    // 접속에 필요한 정보(게임 버전) 설정
    PhotonNetwork.GameVersion = gameVersion;
    // 설정한 정보로 마스터 서버 접속 시도
    PhotonNetwork.ConnectUsingSettings();

    // 룸 접속 버탄 잠시 비활성화
    joinButton.interactable = false;
    // 접속 시도 중임을 텍스트로 표시
    connectionInfoText.text = "마스터 서버에 접속 중...";
}
```

마스터 서버에 접속하기 전에 접속 옵션을 먼저 설정한다. 설정 가능한 네트워크 옵션은 많지만 여기서는 버전만 설정하고 그 외의 옵션은 기본 설정을 사용한다.  

<br>

#### OnConnectedToMaster()

포톤 마스터 서버에 접속한 경우 자동으로 실행되는 메서드이다.

```cs
// 마스터 서버 접속 성공시 자동 실행
public override void OnConnectedToMaster() {
    // 룸 접속 버튼 활성화
    joinButton.interactable = true;
    // 접속 정보 표시
    connectionInfoText.text = "온라인 : 마스터 서버와 연결됨";
}
```
접속 성공시 접속 성공 메시지와 Join 버튼을 활성화 시킨다.  

<br>

#### OnDisconnected()

마스터 서버 접속 실패 또는 이미 마스터 서버에 접속 중일 때 연결이 끊기면 실행되는 메서드이다.

```cs
// 마스터 서버 접속 실패시 자동 실행
public override void OnDisconnected(DisconnectCause cause) {
    // 룸 접속 버튼 비활성화
    joinButton.interactable = false;
    // 접속 정보 표시
    connectionInfoText.text = "오프라인 : 마스터 서버와 연결되지 않음\n접속 재시도 중...";

    // 마스터 서버로의 재접속 시도
    PhotonNetwork.ConnectUsingSettings();
}
```

<br>

#### Connect()

Join 버튼을 클릭했을 때 실행할 메서드이다. 매치메이킹 서버를 통해 빈 무작위 룸에 접속을 시도한다.  

```cs
// 룸 접속 시도
public void Connect() {
    // 중복 접속 시도를 막기 위해 접속 버튼 잠시 비활성화
    joinButton.interactable = false;

    // 마스터 서버에 접속 중이라면
    if (PhotonNetwork.IsConnected)
    {
        // 룸 접속 실행
        connectionInfoText.text = "룸에 접속...";
        PhotonNetwork.JoinRandomRoom();
    }
    else
    {
        // 마스터 서버에 접속 중이 아니라면 마스터 서버에 접속 시도
        connectionInfoText.text = "오프라인 : 마스터 서버와 연결되지 않음\n접속 재시도 중...";
        // 마스터 서버로의 재접속 시도
        PhotonNetwork.ConnectUsingSettings();
    }
}
```

Join 버튼의 상호작용을 비활성화 시켜 룸 접속 처리가 끝나기 전에 버튼을 다시 클릭하여 중복 시도되는 상황을 방지한다.  

그리고 마스터 서버에 접속이 안 된 상태에서 접속을 시도하는 예외 상황을 막기 위해 조건문을 통해서 접속을 검사한 뒤 마스터 서버에 접속된 상태에서만 랜덤 룸 접속을 시도하고 접속 정보 텍스트의 내용을 갱신한다.  

마스터 서버에 접속되지 않은 채로 룸 접속시 마스터 서버의 재접속을 시도하도록 한다.

<br>

#### OnJoinRandomFailed()

룸 접속에 실패한 경우 자동 실행된다. 마스터 서버와의 연결이 아니란 점에 주의한다.  

```cs
// (빈 방이 없어)랜덤 룸 참가에 실패한 경우 자동 실행
public override void OnJoinRandomFailed(short returnCode, string message) {
    // 접속 상태 표시
    connectionInfoText.text = "빈 방이 없음, 새로운 방 생성...";
    // 최대 4명을 수용 가능한 빈 방 생성
    PhotonNetwork.CreateRoom(null, new RoomOptions { MaxPlayers = 4 });
}
```
PhotonNetwork.CreateRoom() 메서드는 입력으로 생성할 룸의 이름을 string 타입, 생성할 룸의 옵션을 RoomOptions 타입으로 받는다.  

따로 생성된 룸 목록을 확인하는 기능은 만들지 않으므로 룸의 이름은 입력하지 않고 null을 입력한다. 

<br>

#### OnJoinedRoom()

룸 참가에 성공한 경우 자동 실행된다. 대부분의 네트워크 게임은 룸에 접속한 다음 모든 플레이어가 준비가 될 때까지 대기 시간을 제공한다.  

하지만 여기서는 간단하게 룸에 접속하자마자 바로 게임이 시작되도록한다. 따라서 OnJoinedRoom() 메서드에서는 본격적인 게임이 진행되는 Main 씬을 로드한다.  

```cs
// 룸에 참가 완료된 경우 자동 실행
public override void OnJoinedRoom() {
    // 접속 상태 표시
    connectionInfoText.text = "방 참가 성공";
    // 모든 룸 참가자가 Main 씬을 로드하게 한다.
    PhotonNetwork.LoadLevel("Main");
}
```

씬을 로드할 때 SceneManager를 사용하면 이전 씬의 모든 게임 오브젝트를 삭제하고 다음 씬을 로드하기 때문에 정보가 유지되지 않지만 PhotonNetwork로 씬을 로드하면 플레이어 사이에서 동기화되도록 정보를 유지할 수 있다. 