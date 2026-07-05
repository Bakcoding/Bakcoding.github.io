---
title: "Project Settings - Editor #1 (Unity Remote ~ Default Behaviour Mode)"
excerpt: "Project Settings - Editor #1 (Unity Remote ~ Default Behaviour Mode)"
categories:
  - Unity
permalink: /develop/unity/76-project-settings-editor-sharp1-unity-remote-default-behaviour-mode/
tags:
  - "Unity"
  - "Game Development"
  - "editor"
  - "project settings"
  - "unity"
toc: true
toc_sticky: true
date: 2024-02-14
last_modified_at: 2024-02-14
source_url: https://b-note.tistory.com/76
---

<p style="text-align: start"><span style="text-align: start">에디터 버전 : 2021.3.28f1 (LTS) </span></p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start">유니티 에디터의 전체적인 설정을 변경할 수 있는 항목이다.</p>
<h2 style="text-align: start"><span>Unity Remote [Depricated]</span></h2>
<p>Android, iOS 등 앱을 개발할 때 사용하기 위한 기능으로 유니티 플레이 모드에서 화면 출력과 입력이 디바이스와 연결되도록한다. 따라서 빌드 이전 단계에서 타겟 디바이스를 통한 테스트가 가능하다.</p>

<p>2020.1 및 이후 버전에서는 depricated 되었으며 Device Simulator Package가 기능을 대신한다.</p>

<p><b> Device Simulator Package </b></p>
<p style="text-align: start">2020 이후 버전이라면 에디터에 기능이 포함된 상태로 Window &gt; General &gt; Device Simulator 를 통해 사용할 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="531" data-origin-height="581"><span data-alt="Device Simulator"><img src="/assets/images/posts/2024/02/14/76-1.png" loading="lazy" width="338" height="581" data-origin-width="531" data-origin-height="581"/></span><figcaption>Device Simulator</figcaption>
</figure>
</p>

<p>이전 버전의 경우 패키지를 설치해 주어야 창을 열 수 있다.</p>
<p>패키지 매니저를 통해서 설치가 가능하며 이 때 패키지가 검색해도 나오지 않는 경우&nbsp;</p>
<p>패키지 매니저 창에서 어드밴스 설정에 들어가서&nbsp;</p>
<p>Pre-release Package 옵션을 활성한 이후에 패키지를 검색하면 찾을 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="252" data-origin-height="105"><span data-alt="Advanced Project Settings"><img src="/assets/images/posts/2024/02/14/76-2.png" loading="lazy" width="252" height="105" data-origin-width="252" data-origin-height="105"/></span><figcaption>Advanced Project Settings</figcaption>
</figure>
</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="299" data-origin-height="142"><span data-alt="Enable Pre-release Package"><img src="/assets/images/posts/2024/02/14/76-3.png" loading="lazy" width="255" height="142" data-origin-width="299" data-origin-height="142"/></span><figcaption>Enable Pre-release Package</figcaption>
</figure>
</p>

<h2 style="text-align: start"><span>Asset Serialization</span></h2>
<p><span>프로젝트를 저장할 때 에셋들의 정보를 저장하는 방식에 대해서 설정할 수 있는 옵션이다.</span></p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="372" data-origin-height="67"><span data-alt="Asset Serialization"><img src="/assets/images/posts/2024/02/14/76-4.png" loading="lazy" width="372" height="67" data-origin-width="372" data-origin-height="67"/></span><figcaption>Asset Serialization</figcaption>
</figure>
</p>

<p>Serialization 옵션에는 세가지가 있다.<b></b></p>

<p><b>Mixed</b></p>
<p>에셋이 바이너리와 문자열 각각의 저장된 상태로 유지된다. 새로 추가되는 에셋의 경우 바이너리가 적용된다.</p>

<p><b>Force Binary</b></p>
<p>에셋을 바이너리로 저장한다.&nbsp;</p>
<p>임의의 프리팹을 생성하고 파일을 열어보면 바이너리로 저장된걸 확인할 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="542" data-origin-height="278"><span data-alt="Unity .prefab binary view"><img src="/assets/images/posts/2024/02/14/76-5.png" loading="lazy" width="485" height="249" data-origin-width="542" data-origin-height="278"/></span><figcaption>Unity .prefab binary view</figcaption>
</figure>
</p>

<p>비주얼 스튜디오에서 파일이 열리지 않는 경우 Extensions &gt; Manage Extensions 에서 HexVisualizer 를 설치하면 된다. 이때 실행중인 비주얼 스튜디오는 모두 종료해야 설치가 진행된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="934" data-origin-height="252"><span data-alt="VS Manage Extensions-HexVisualizer"><img src="/assets/images/posts/2024/02/14/76-6.png" loading="lazy" width="575" height="252" data-origin-width="934" data-origin-height="252"/></span><figcaption>VS Manage Extensions-HexVisualizer</figcaption>
</figure>
</p>

<p><b>Force Text</b></p>
<p>에셋을 문자열로 저장한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="461" data-origin-height="759"><span data-alt="Unity .prefab Text"><img src="/assets/images/posts/2024/02/14/76-7.png" loading="lazy" width="407" height="670" data-origin-width="461" data-origin-height="759"/></span><figcaption>Unity .prefab Text</figcaption>
</figure>
</p>
<p>저장된 정보는 텍스트 기반으로 데이터 직렬화 언어로 많이 사용되는 YAML 형식이다.</p>
<p>프리팹의 정보가 키&amp;밸류 형태로 정리되어있어&nbsp; 바이너리와 달리 사람이 쉽게 읽을 수 있도록 표현되었다.</p>

<p>Force Text 모드에서 프리팹을 생성하고 Mixed 모드로 변경시 기존 프리팹은 텍스트, 새로 생성된 프리팹은 바이너리로 저장된다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1074" data-origin-height="240"><span data-alt="Left Text, Right Binary"><img src="/assets/images/posts/2024/02/14/76-8.png" loading="lazy" width="493" height="240" data-origin-width="1074" data-origin-height="240"/></span><figcaption>Left Text, Right Binary</figcaption>
</figure>
</p>

<p>Mixed 또는 Force Text 를 선택한 경우 Serialize Inline Mappings On One Line 토글이 활성화된다.</p>
<p>이 옵션은 참조 및 인라인 맵핑을 한 줄에 쓸것인지 여부를 정한다. 비활성화시 한 줄의 총 문자가 80자 이상이 되면 텍스트가 분할된다.</p>

<h2>Default Behaviour Mode</h2>
<p>프로젝트를 처음 생성시 2D 또는 3D를 선택하는데 프로젝트 생성 이후에도 해당 설정에서 변경이 가능하다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="317" data-origin-height="47"><span data-alt="Unity Default Behaviour Mode"><img src="/assets/images/posts/2024/02/14/76-9.png" loading="lazy" width="317" height="47" data-origin-width="317" data-origin-height="47"/></span><figcaption>Unity Default Behaviour Mode</figcaption>
</figure>
</p>

<p>유니티에서는 프로젝트가 Full 2D 인 경우 이외에는 모두 3D 로 작업환경을 정할 것을 추천한다.</p>

<p>2D와 3D 설정에는 프로젝트의 몇가지 기본세팅에서 차이가 있다.</p>

<p><b>2D</b></p>
<p>- Import 하는 모든 영상은 2D 이미지로 간주되며 Sprtie로 설정된다.</p>
<p>- Scene View 가 2D로 세팅된다.</p>
<p>- 게임 오브젝트가 기본적으로 실시간 Directional light 의 광원을 받지 않는다.</p>
<p>- 카메라의 기본 위치가 0, 0, -10 으로 설정된다.</p>
<p>- 카메라가 Orthographic 으로 설정된다.</p>
<p>- Lighting 창의 옵션의 경우</p>
<p>&nbsp; &nbsp;* 새로운 씬에 대해서 Skybox가 비활성화</p>
<p>&nbsp; &nbsp;* Ambient Source 는 Color(54, 58, 66) 로 설정</p>
<p>&nbsp; &nbsp;* Realtime Global Illumination(Enlighten) 꺼짐 상태</p>
<p>&nbsp; &nbsp;* Baked Global Illumination 꺼짐 상태</p>
<p>&nbsp; &nbsp;* Auto-Building 꺼짐 상태</p>

<p><b>3D</b></p>
<p>- Import 한 모든 이미지가 2D 이미지로 간주되지 않는다.</p>
<p>- Sprite Packer 가 비활성화된다.</p>
<p>- Scene View 는 3D로 설정된다.</p>
<p>- 기본 게임 오브젝트가 리얼 타임 Directional Light 광원을 받는다.</p>
<p>- 카메라의 기본 포지션은 0, 1, -10 으로 설정된다.</p>
<p>- 카메라가 Perspective 로 설정된다.</p>
<p>- Lighting 창의 경우</p>
<p>&nbsp; * Skybox 는 built-in Default Skybox 로 설정</p>
<p>&nbsp; * Ambient Source 는 Skybox 로 설정</p>
<p>&nbsp; * Realtime Global Illumination (Enlighten) 켜짐 상태</p>
<p>&nbsp; * Baked Global Illumination 켜짐 상태</p>
<p>&nbsp; * Auto-Building 켜짐 상태</p>

<p>차이점을 보면 2D에서 3D 작업을 한다고 해서 치명적인 문제가 발생하지는 않는다.</p>
<p>하지만 몇가지 기본 설정들은 각 상황에서만 사용하는 경우가 많기 때문에 맞춰서 작업하는것이 권장된다.</p>
