---
title: "[Flutter] Windows에서 개발환경 세팅"
excerpt: "[Flutter] Windows에서 개발환경 세팅"
categories:
  - Flutter
permalink: /develop/flutter/168-flutter-windows/
tags:
  - "Flutter"
  - "win"
toc: true
toc_sticky: true
date: 2025-04-24
last_modified_at: 2025-04-24
source_url: https://b-note.tistory.com/168
---

<h3>Flutter SDK 설치</h3>
<p>먼저 Flutter를 설치하는 방법은 크게 두 가지가 있다.</p>

<p>첫 번째는 공식 홈페이지에 들어가서 직접 파일을 다운로드하여 압축을 풀고 환경변수 설정을 하는 것이다.</p>

<p>두 번째로는 Visual Studio Code를 활용해서 여기서 Flutter를 설치하는 방법이 있다.</p>

<p>해당 내용은 <a href="https://docs.flutter.dev/get-started/install/windows/mobile" target="_blank" rel="noopener">플러터 공식 홈페이지</a>에서도 확인 가능하다.</p>

<h4>첫 번째 방법</h4>
<p>먼저 공식 홈페이지에서 SDK 압축 파일을 다운로드한 다음 적절한 경로에 옮겨두고 압축을 푼다.</p>
<p>이 경로에는 특수 문자나 공백을 포함해선 안되며 또한 권한이 필요한 폴더 내에 위치해서도 안된다.</p>

<p>저장한 위치의 경로를 복사해 둔 다음 이 경로 사용자 변수 또는 시스템 변수의 PATH에 등록한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="175" data-origin-height="28"><span data-alt="Flutter - Env var"><img src="/assets/images/posts/2025/04/24/168-1.png" loading="lazy" width="175" height="28" data-origin-width="175" data-origin-height="28"/></span><figcaption>Flutter - Env var</figcaption>
</figure>
</p>

<h4>두 번째 방법</h4>
<p>VSCode를 열고 확장 프로그램 마켓을 열고 flutter를 검색해서 가장 상단에 있는 걸 설치한다.</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1057" data-origin-height="288"><span data-alt="Flutter - VSCode market place"><img src="/assets/images/posts/2025/04/24/168-2.png" loading="lazy" width="1057" height="288" data-origin-width="1057" data-origin-height="288"/></span><figcaption>Flutter - VSCode market place</figcaption>
</figure>
</p>

<h3>프로젝트 생성</h3>
<p>플러터 SDK의 설치가 끝났다면 VSCode를 열고 팔레트를 열어서(Ctrl + Shift + P) 새로운 플러터 프로젝트를 생성한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="595" data-origin-height="67"><span data-alt="Flutter - New Project"><img src="/assets/images/posts/2025/04/24/168-3.png" loading="lazy" width="595" height="67" data-origin-width="595" data-origin-height="67"/></span><figcaption>Flutter - New Project</figcaption>
</figure>
</p>

<p>New Project를 선택하면 &gt; 프로젝트 템플릿 &gt; 프로젝트 생성 경로 &gt; 프로젝트 이름</p>

<p><b> 프로젝트 템플릿 </b></p>
<p>프로젝트 템플릿은 Application, Empty, Skeleton이 있다.</p>

<p>Application은 기본적인 UI 구성 요소가 만들어져 있어 처음에 Flutter의 계층 구조나 State 개념을 파악하는데 괜찮을 듯하다.</p>

<p>Empty는 뜻 그대로 기본 main 함수와 MaterailApp()만 작성되어 있는 실행가능한 최소 상태이다.</p>

<p>Skeleton은 기본 페이지 구성과 라우팅 구조를 갖춘 템플릿으로 어느 정도 숙련도가 있다면 빠른 작업 진행에 유용할 것 같다.</p>

<p><b>생성 경로</b></p>
<p>해당 경로에 '프로젝트 이름' 폴더가 생성되고 IDE에서 해당 폴더를 연다. 이름은 경로 설정 후 입력가능하며 기본 이름값이 주어진다.</p>

<p><b>프로젝트 이름</b></p>
<p>프로젝트 폴더 이름뿐만 아니라 앱의 이름인 pubspec.yml 파일의 name 필드의 값도 해당 이름으로 설정된다.&nbsp;</p>

<h3>추가 패키지 설치</h3>
<p>Flutter 프로젝트의 생성이 끝났다면 먼저 IDE에서 터미널을 열고, flutter doctor 명령어를 실행시켜 문제가 없는지 확인한다.</p>

<p>해당 명령어의 실행이 끝나면 체크 항목과 문제 사항을 볼 수 있는데 여기서 문제가 되는 부분들을 하나씩 해결해 주도록 한다.</p>

<p>이미 한 번 작업을 마친 상태였기 때문에 현재는 문제가 발생하지 않지만 일반적으로 색칠한 부분에서 문제가 발생할 것이다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="695" data-origin-height="200"><span data-alt="Flutter Doctor"><img src="/assets/images/posts/2025/04/24/168-4.png" loading="lazy" width="695" height="200" data-origin-width="695" data-origin-height="200"/></span><figcaption>Flutter Doctor</figcaption>
</figure>
</p>

<p>Android Studio - 안드로이드 스튜디오가 없다면 요구되는 버전을 확인 후 설치한다.</p>
<p>Android toolchain - 안드로이드 스튜디오의 SDK 매니저에서 Android toolchain을 찾아서 설치한다.</p>
<p>Visual Studio - VS를 버전에 맞게 설치하고 추가 설치 항목에서 develop Windows apps를 설치한다.</p>

<p>문제가 모두 해결되었는지 다시 flutter doctor를 실행해서 확인한다.</p>

<p>여기까지 완료되었다면 기본적인 준비가 완료되었다.</p>

<p>다시 팔레트를 열어서 Flutter: Launch Emulator를 클릭해서 가상 머신을 실행시킨 후 터미널에서 flutter run을 실행시켜 앱을 띄워본다.</p>

<p>IDE의 이 버튼을 눌러도 실행을 시킬 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="89" data-origin-height="64"><span data-alt="Flutter - Run"><img src="/assets/images/posts/2025/04/24/168-5.png" loading="lazy" width="89" height="64" data-origin-width="89" data-origin-height="64"/></span><figcaption>Flutter - Run</figcaption>
</figure>
</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="475" data-origin-height="883"><span data-alt="Flutter - Run with vm"><img src="/assets/images/posts/2025/04/24/168-6.png" loading="lazy" width="337" height="626" data-origin-width="475" data-origin-height="883"/></span><figcaption>Flutter - Run with vm</figcaption>
</figure>
</p>

<p>애뮬레이터를 추가하려면 안드로이드 스튜디오의 디바이스 매니저에서 추가하면 된다.</p>
