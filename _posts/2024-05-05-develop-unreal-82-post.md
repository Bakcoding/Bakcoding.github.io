---
title: "언리얼 엔진 - 에디터 파일"
excerpt: "언리얼 엔진 - 에디터 파일"
categories:
  - Unreal
permalink: /develop/unreal/82-post/
tags:
  - "Unreal"
  - "Game Development"
  - "5.3"
  - "File"
  - "Menu Bar"
  - "Unreal Engine"
  - "메뉴바"
  - "언리얼 엔진"
  - "파일"
toc: true
toc_sticky: true
date: 2024-05-05
last_modified_at: 2024-05-05
source_url: https://b-note.tistory.com/82
---

<h2>Editor</h2>
<p>언리얼 프로젝트를 생성하게 되면 에디터가 열리게 되는데 우선 에디터가 어떤 기능들로 구성되어 있는지 살펴본다.</p>

<h3>Menu Bar</h3>
<p>에디터 상단에는 여러 메뉴들을 선택할 수 있는 메뉴 바가 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="440" data-origin-height="101"><span data-alt="Unreal Engine - Menu Bar"><img src="/assets/images/posts/2024/05/05/82-1.png" loading="lazy" width="440" height="101" data-origin-width="440" data-origin-height="101"/></span><figcaption>Unreal Engine - Menu Bar</figcaption>
</figure>
</p>

<h4>File</h4>
<p>'파일' 메뉴에는 프로젝트 파일과 관련된 기능들이 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="340" data-origin-height="509"><span data-alt="Unreal Engine - File"><img src="/assets/images/posts/2024/05/05/82-2.png" loading="lazy" width="340" height="509" data-origin-width="340" data-origin-height="509"/></span><figcaption>Unreal Engine - File</figcaption>
</figure>
</p>

<p><b>새 레벨</b></p>
<p>새 레벨을 선택하면 '새 레벨'을 선택하는 팝업창이 뜬다.&nbsp;</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="534" data-origin-height="455"><span data-alt="Unreal Engine - File &amp;gt; New Level"><img src="/assets/images/posts/2024/05/05/82-3.png" loading="lazy" width="405" height="345" data-origin-width="534" data-origin-height="455"/></span><figcaption>Unreal Engine - File &gt; New Level</figcaption>
</figure>
</p>

<p>언리얼에서 '레벨'은 게임 내의 오브젝트, 환경, 조명, 카메라 등의 요소를 포함하는 컨테이너 역할을 한다.&nbsp;</p>
<p>유니티로 치면 '씬'으로 볼 수 있다.</p>

<p>새로 생성된 레벨은 현재 레벨 저장(Ctrl + S)으로 저장하거나 다른 이름으로 저장(Ctrl + Alt + S)으로 저장할 수 있다.</p>

<p><b>레벨 열기</b></p>
<p>'레벨 열기'는 저장된 레벨을 선택하여 열 수 있다.</p>

<p><b>에셋 열기</b></p>
<p>현재 프로젝트에 설치된 에셋을 열 수 있다.</p>

<p>에셋은 <a style="background-color: #e6f5ff; color: #0070d1; text-align: start;" href="https://www.unrealengine.com/marketplace/ko/store">언리얼 엔진 마켓플레이스</a>에서 추가로 다운로드할 수 있다.</p>


<p><b>모두 저장</b></p>
<p>작업 중이던 내용 중 저장되지 않은 부분들을 모두 저장하는 기능이다.</p>

<p><b>저장할 파일 선택</b></p>
<p>저장되지 않은 변경 사항 중 선택해서 저장할 수 있는 기능이다. 클릭 시 저장할 콘텐츠의 목록 창이 팝업 된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="646" data-origin-height="529"><span data-alt="Unreal Engine - File &amp;gt; Contents Save"><img src="/assets/images/posts/2024/05/05/82-4.png" loading="lazy" width="646" height="529" data-origin-width="646" data-origin-height="529"/></span><figcaption>Unreal Engine - File &gt; Contents Save</figcaption>
</figure>
</p>


<p><b>레벨로 임포트</b></p>
<p>fbx 또는 obj 확장자 파일을 현재 레벨로 임포트 할 수 있다.&nbsp;</p>
<p>언리얼에서는 프로젝트에 사용되는 리소스들이 Content 폴더에 저장되고 콘텐츠들을 fbx 또는 obj 확장자 파일로 내보내기 할 수 있으며 이를 다시 프로젝트에 임포트 할 수 있다.</p>

<p>언리얼 엔진에서 파일과 에셋들은 크게 콘텐츠 폴더와 엔진 폴더에 구분되어서 저장된다.</p>

<p>콘텐츠 폴더에는 특정 프로젝트에 특화된 자산을 저장하는 데 사용되며 게임 플레이와 직접적으로 관련된 모든 콘텐츠가 포함된다. 개발자가 직접 생성하고 관리하는 파일들이 대부분이며 프로젝트별로 독립적이다.</p>

<p>엔진 폴더에는 언리얼 엔진 자체에 필요한 핵심 파일과 자산을 저장하는 데 사용된다. 엔진 코드, 표준 플러그인, 필수 라이브러리, 시스템 설정 파일 등이 포함되어 있다. 이 폴더에 저장된 파일들은 언리얼 엔진을 설치한 모든 프로젝트에서 공통적으로 사용되기 때문에 이 폴더의 내용이 수정되면 모든 프로젝트에 영향을 미칠 수 있다. 일반적으로 엔진 업그레이드 시 업데이트되는 파일들이다.</p>

<p>유니티로 비교하면 Assets, Packages 폴더와 유사하다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="329" data-origin-height="93"><span data-alt="Unreal Engine - File &amp;gt; Import/Export"><img src="/assets/images/posts/2024/05/05/82-5.png" loading="lazy" width="329" height="93" data-origin-width="329" data-origin-height="93"/></span><figcaption>Unreal Engine - File &gt; Import/Export</figcaption>
</figure>
</p>

<p><b>모두 익스포트</b></p>
<p>전체 레벨을 파일로 내보낸다.</p>

<p><b>선택 익스포트</b></p>
<p>선택된 오브젝트를 파일로 내보낸다.</p>

<p><b>새 프로젝트</b></p>
<p>새로운 프로젝트를 연다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="434" data-origin-height="100"><span data-alt="Unreal Engine - File &amp;gt; Project"><img src="/assets/images/posts/2024/05/05/82-6.png" loading="lazy" width="434" height="100" data-origin-width="434" data-origin-height="100"/></span><figcaption>Unreal Engine - File &gt; Project</figcaption>
</figure>
</p>

<p><b>프로젝트 열기</b></p>
<p>프로젝트를 선택하여 연다.</p>

<p><b>프로젝트 압축</b></p>
<p>현재 프로젝트를 압축하여 저장한다.</p>

<p><b>최근 프로젝트</b></p>
<p>최근에 연 프로젝트 목록이 리스트로 나타나며 선택하여 열 수 있다.</p>

<p><b>종료</b></p>
<p>현재 프로젝트를 종료한다.</p>
