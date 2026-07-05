---
title: "언리얼 엔진 - 에디터 개인설정 - 일반 라이브 코딩"
excerpt: "언리얼 엔진 - 에디터 개인설정 - 일반 라이브 코딩"
categories:
  - Unreal
permalink: /develop/unreal/90-post/
tags:
  - "Unreal"
  - "Game Development"
  - "editor setting"
  - "Unreal Engine"
  - "언리얼 엔진"
toc: true
toc_sticky: true
date: 2024-05-18
last_modified_at: 2024-05-18
source_url: https://b-note.tistory.com/90
---

<p>엔진 실행 도중 C++ 코드 리컴파일 세팅</p>

<h2>일반</h2>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1000" data-origin-height="134"><span data-alt="Unreal Engine - Editor Setting - Live Coding - General"><img src="/assets/images/posts/2024/05/18/90-1.png" loading="lazy" width="1000" height="134" data-origin-width="1000" data-origin-height="134"/></span><figcaption>Unreal Engine - Editor Setting - Live Coding - General</figcaption>
</figure>
</p>

<p>개발자가 코드 변경 사항을 즉시 테스트하고 결과를 확인할 수 있게 해주는 기능이다.&nbsp;</p>
<p>라이브 코딩을 사용하면 에디터를 재시작하지 않고도 코드를 수정하고 결과를 실시간으로 확인할 수 있다.&nbsp;</p>

<h3>라이브 코딩 활성화</h3>
<p>라이브 코딩 기능을 활성화 또는 비활성화한다. 활성화 시 코드 변경 사항을 실시간으로 컴파일하고 적용할 수 있다.<br></p>
<h3>시작</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="327" data-origin-height="76"><span data-alt="Unreal Engine - Editor Setting - Live Coding - General Start"><img src="/assets/images/posts/2024/05/18/90-2.png" loading="lazy" width="327" height="76" data-origin-width="327" data-origin-height="76"/></span><figcaption>Unreal Engine - Editor Setting - Live Coding - General Start</figcaption>
</figure>
</p>

<p>- Start automatically and show console</p>
<p>- Start automatically but hide console until summoned</p>
<p>- Manual</p>

<p>세가지 선택 옵션이 있으며 기본 설정으로는 'Start automatically but hide console until summoned'로 되어있다.</p>

<p><b>Start automatically and show console</b></p>
<p>에디터를 실행할 때마다 라이브 코딩 기능이 자동으로 활성화되며 콘솔 창이 표시되어 현재 라이브 코딩의 상태를 확인할 수 있다. 라이브 코딩 콘솔은 컴파일로 그와 상태 정보를 제공하여 코드 변경 사항을 실시간으로 모니터링할 수 있다.</p>

<p><b> Start automatically but hide console until summoned</b></p>
<p>에디터를 실행할 때 라이브 코딩이 백그라운드에서 자동으로 시작되지만, 콘솔 창이 화면에 나타나지 않는다.</p>
<p>콘솔을 확인하려면 수동으로 호출해야 하기 때문에 라이브 코딩의 로그를 지속적으로 확인할 필요가 없고 콘솔 창이 화면을 차지하는 것을 원하지 않을 때 유용하다.</p>

<p><b> Manual</b></p>
<p>에디터를 실행한 후 사용자가 직접 라이브 코딩을 시작해야한다.&nbsp;</p>
<p>이 설정은 라이브 코딩이 항상 필요한 것은 아니고 특정 작업을 할 때만 사용하고자 할 때 유용하다.</p>

<h3>리인스턴싱 활성화</h3>
<p>라이브 코딩을 통해 컴파일된 코드 변경 사항을 실시간으로 게임에 적용할 때 객체를 재인스턴스 화하여 변경된 코드를 적용하는 방법을 제어한다.</p>

<p>해당 설정의 활성화시 라이브 코딩 기능이 코드 변경 사항을 적용할 때 이미 메모리에 로드된 객체들을 새로 컴파일된 코드로 대체(재인스턴스화)하는 기능을 활성화한다. 기존 객체들이 새로운 코드에 맞게 다시 인스턴스화되어 변경 사항이 즉시 반영되고 게임을 재시작하거나 객체를 수동으로 재로드 하지 않아도 변경 사항을 실시간으로 테스트할 수 있다. 특히 게임 플레이 로직이나 UI와 같이 자주 변경되는 코드에서 유용하다.</p>

<h3>새로 추가된 C++ 클래스 자동 컴파일</h3>
<p>새로운 C++ 클래스를 추가할 때 이를 자동으로 컴파일하는 기능을 제어하는 설정이다.&nbsp;</p>
<p>활성화시 새로운 C++ 클래스를 생성할 때마다 자동으로 컴파일이 시작된다. 이를 통해 개발자는 추가한 클래스를 바로 사용할 수 있으며 프로젝트에 제대로 통합이 되었는지 빠르게 확인할 수 있다.</p>

<h2>모듈</h2>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="867" data-origin-height="120"><span data-alt="Unreal Engine - Editor Setting - Live Coding - Module"><img src="/assets/images/posts/2024/05/18/90-3.png" loading="lazy" width="867" height="120" data-origin-width="867" data-origin-height="120"/></span><figcaption>Unreal Engine - Editor Setting - Live Coding - Module</figcaption>
</figure>
</p>


<h3>프로젝트 모듈 미리 로드</h3>
<p>라이브 코딩을 시작할 때 필요한 모듈들을 미리 로드하는 기능이다.&nbsp;</p>
<p>라이브 코딩 중에 모듈이 처음 로드될 때&nbsp; 발생할 수 있는 지연을 줄일 수 있다. 활성화 시 모듈들이 자동으로 미리 로드되며 이는 라이브 코딩 작업 중 처음으로 해당 모듈을 사용할 때의 지연을 방지한다.</p>

<h3>프로젝트 플러그인 모듈 미리 로드</h3>
<p>라이브 코딩 세션이 시작될 때 프로젝트에 포함된 플러그인 모듈들을 미리 로하는 기능이다. 플러그인 모듈은 프로젝트에 추가적인 기능을 제공하는데 이를 미리 로드하여 최적화할 수 있어 플러그인 로드로 인한 초기 지연을 줄일 수 있다.</p>

<h3>네임드 모듈 미리 로드</h3>
<p>특정 이름의 모듈들을 미리 로드하는 기능이다.</p>
<p>프로젝트에서 중요한 역할을 하는 특정 모듈의 이름을 지정하면 라이브 코딩을 시작할 때 지정된 모듈들이 미리 로드된다.</p>

<p>모듈들의 이름은 배열에서 추가가 가능하다.</p>
