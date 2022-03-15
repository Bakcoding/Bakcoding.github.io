---
title:  "Mirror의 탄생"
excerpt: "Network, Mirror, UNet"

categories:
  - Mirror
tags:
  - [Network, Mirror, UNet]

toc: true
toc_sticky: true
 
date: 2022-03-15
last_modified_at: 2022-03-15
---  

***

<br>

### UNet 

유니티 자체로 제공하던 네트워크 서비스였지만 2018.4 에디터 이후로 더 이상 제공되지 않는다. 

UNET은 뚜렷한 특징을 가지고 있었다.

*   Server & Client in one project

    대부분의 코드가 공유되며 몇 개는 \[Server\]와 \[Client\] 표시만으로 구분이 되었다.  

    지형, 모델, 에셋 및 코드가 모두 서버와 클라이언트 간에 공유되기 때문에 생산성을 높일 수 있다.

*   \[SyncVars\] 

    선택한 변수를 자동으로 직렬화 한다.

    수작업으로 직렬화/ 직렬화 해제 기능들과 비교했을 때 \[SyncVar\]를 추가하는것 만으로 직렬화가 자동으로 수행된다.

*   \[Commands/Rpcs\]

    \[Command\] 로 감싼 메서드는 자동으로 서버에서 호출을 하고 \[Rpcs\] 는 자동으로 클라이언트에서 호출이 되도록 만든다.
    
    수동으로 메시지를 전송한다고 했을 떄 모든 파라미터를 역직렬화하고 함수를 수동으로 호출해야하는데 이와 비교해서 생산성이 크게 높다고 할 수 있다.


<br>

### Mirror

UNet은 초창기 흥미로운 기술과 열정적인 개발담당자들의 모습에 많은 주목을 받았다. 하지만 시간이 거듭할수록 그 사람들의 열정도 식어가고 버그는 계속해서 넘처나더니 결국 deprication을 하게된다.

Mirror는 그런 UNet을 처음부터 믿고 따라가던 개발자들이 만들어낸 결과물이다.

<a href="https://mirror-networking.gitbook.io/docs/trivia/a-history-of-mirror#whats-next">A Brief History of Mirror</a>

UNet의 장점을 그대로 들고가면서 수 많은 버그들 고쳐서 완성된게 Mirror이다.

<br>

### Mirror 특징

#### Script Templates

베이스 클래스를 상속해서 쉽게 파생클래스를 생성할 수 있다.

* 가능한 모든 오버라이드는 사용자를 위해 이미 재정의 되어있다.

* 각 기능들은 무슨 기능을 하는지 주석이 달려있다.

* 베이스 메서드 호출은 모두 필요한 위치에 있으므로 이미 그것들이 무슨 기능을 하는지 파악할 수 있다.

* 각 스크립트 상단에는 mirror documents 링크가 첨부되어있다. 


Mirror 패키지를 설치하면 Unity Editor의 Assets > Create Menu 에서 생성된 항목을 확인할 수 있다. 

<br>


#### High Level Scripting API

Mirror는 high-level 네트워킹 라이브러리이다.  

이를 통해 멀티 유저 게임의 일반적인 요건 대부분을 커버하는 명령어에 액세스 할 수 있다.

이것에 의해 lower level의 구현에 대한 자세한 걱정은 할필요가 없다.

* NetworkManager를 사용하여 게임의 네트워크 상태를 제어한다.

* 호스트가 플레이어 클라이언트인 클라이언트-호스트 방식으로 작동한다.

* 범용 직렬화를 사용하여 데이터를 직렬화한다.

* 네트워크 메시지를 송수신한다.

* 클라이언트에서 서버로 네트워크 명령어를 송신한다.

* 서버에서 클라이언트로 원격 프로시저 콜(RPC)를 호출한다.

* 서버에서 클라이언트로 네트워크 이벤트를 보낸다.

<br>

#### Low Level Transport API

Mirror는 연결/연결 해제/송신/수신 메시지를 byte수준에서 사용하기 위해 낮은 수준 전송을 요구한다.

<br>


#### Engine & Editor integration

Mirror의 네트워크는 엔진과 에디터와 통합되어 있어 컴포넌트 및 시각적인 재료를 사용해서 멀티 플레이 게임을 만들 수 있다.

* 네트워크 객체의 NetworkIdentity 컴포넌트

* 네트워크 스크립트의 NetworkBehaviour

* 오브젝트 변환의 자동 동기화 설정 가능

* 스크립트 변수 자동 동기화

* Unity 장면에 네트워크 오브젝트를 배치할 수 있다.

* 네트워크 컴포넌트

<br>


#### Deprication

UNet에 있던 특정 기능들은 Mirror에서 여러가지 이유로 수정되거나 제거되었다.

<a href="https://mirror-networking.gitbook.io/docs/general/deprecations">Deprication</a>

<br>

### Integrations

Mirror와 호환되는 assets들의 모음

#### Dissonance Voice Chat

<a href="https://assetstore.unity.com/packages/tools/audio/dissonance-voice-chat-70078">Dissonance Voice Chat</a>

실시간 음성채팅을 게임에 쉽게 추가할 수 있다.

#### Steamworks Complete v2

<a href="https://assetstore.unity.com/packages/tools/integration/steamworks-complete-v2-190316">Steamworks Complete v2</a>

Steam API와의 통합을 쉽고 빠르게 해주는 툴

#### Smooth Sync

<a href="https://assetstore.unity.com/packages/tools/network/smooth-sync-96925">Smooth Sync</a>

움직이는 모든 것을 동기화하는데 이상적이다.

#### Noble Connect Free

<a href="https://assetstore.unity.com/packages/tools/network/noble-connect-free-141599">Noble Connect Free</a>

Relays와 Punchthrough를 추가한다.

Relays : 상대적으로 비용과 대기시간이 더 들지만 안정적 연결이 보장된다.

Punchthrough : 대기 시간을 줄이고 가능하면 플레이어와 직접 연결하여 비용을 절약한다.

#### Weather Maker

<a href="https://assetstore.unity.com/packages/tools/particles-effects/weather-maker-volumetric-clouds-and-weather-system-for-unity-60955">Weather Maker-Volumetric Clouds and Weather System for Unity</a>

프리팹을 통해 쉽게 하늘과 날씨 등 효과를 만들 수 있다.

#### RTS Engine 2022

<a href="https://assetstore.unity.com/packages/tools/game-toolkits/rts-engine-2022-79732">RTS Engine 2022</a>

RTS 게임을 만드는데 필요한 기능 제공

#### Master Audio 2022: AAA Sound

<a href="https://assetstore.unity.com/packages/tools/audio/master-audio-2022-aaa-sound-212962">Master Audio 2022</a>

멀티플레이에서 쉽게 오디오를 구현할 수 있다.

<br> 