---
title: "다짜고짜 만들어 보기 #2 - 플레이어, 카메라"
excerpt: "다짜고짜 만들어 보기 #2 - 플레이어, 카메라"
categories:
  - Unreal
permalink: /develop/unreal/95-sharp2/
tags:
  - "Unreal"
  - "Game Development"
  - "player move"
  - "Unreal Engine"
  - "다짜고짜"
  - "언리얼 엔진"
  - "움직이기"
toc: true
toc_sticky: true
date: 2024-07-09
last_modified_at: 2024-07-09
source_url: https://b-note.tistory.com/95
---

<h2>에디터 언어 변경</h2>
<p>에디터 언어를 영어로 변경하기로 한다.</p>
<p>이유는 영어로 된 자료의 양이 더 많고 번역된 한글이 직역으로 되어있는 단어들이 많다 보니 영어 그 자체로 의미를 파악하는 게 더 나을 것 같다는 판단에 있다.</p>

<h2>플레이어</h2>
<p>플레이어를 구현하기 위해서 Character 블루프린트를 상속해서 내가 사용할 캐릭터를 만든다.</p>

<p>콘텐츠 브라우저의 'BluePrints' 폴더에서 블루프린트를 추가한다. 'Character'를 상속하고 이름은 BP_Player로 한다.</p>

<p>생성한 'BP_Player'를 열고 세팅을 시작한다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1105" data-origin-height="720"><span data-alt="Unreal Engine - BP_Player"><img src="/assets/images/posts/2024/07/09/95-1.png" loading="lazy" width="1105" height="720" data-origin-width="1105" data-origin-height="720"/></span><figcaption>Unreal Engine - BP_Player</figcaption>
</figure>
</p>

<p>'Character'를 상속한 'BP_Player'는 'Capsule Component', 'Arrow', 'Mesh'로 구성되어있다.</p>

<p>우선 눈에 보이는 상태로 만들기 위해서 'Mesh' 컴포넌트에 기본 제공되는 리소스를 추가한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="483" data-origin-height="424"><span data-alt="Unreal Engine - Setting Mesh"><img src="/assets/images/posts/2024/07/09/95-2.png" loading="lazy" width="483" height="424" data-origin-width="483" data-origin-height="424"/></span><figcaption>Unreal Engine - Setting Mesh</figcaption>
</figure>
</p>

<p>그리고 추가한 메시의 정면을 일치시켜 주기 위해서 회전시키고 높이를 캡슐 컴포넌트와 맞게 세팅한다.</p>

<p style="text-align: start">참고로 유니티에서는 +z&nbsp; forward, +x right, +y up 이였지만 언리얼의 경우 +x forward, +y right, +z up이다.</p>
<p style="text-align: start">&nbsp;</p>
<p style="text-align: start">꼭 확인하고 가야 할 부분이다.</p>
<p style="text-align: start">&nbsp;</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="649" data-origin-height="633"><span data-alt="Unreal Engine - Setting Player"><img src="/assets/images/posts/2024/07/09/95-3.png" loading="lazy" width="489" height="633" data-origin-width="649" data-origin-height="633"/></span><figcaption>Unreal Engine - Setting Player</figcaption>
</figure>
</p>

<p>탑 다운 시점을 위해서 카메라도 추가해야 한다.</p>

<p>그전에 먼저 'SpringArm'을 살펴본다. 이 컴포넌트는 여러 가지 기본적인 카메라 제어 기능을 포함하고 있는데</p>

<p>유니티에서 카메라를 제어할 때는 Camera Rig라는 오브젝트를 추가하고 카메라를 회전하거나 트랙킹 시킬 때 이 오브젝트와 상호작용할 수 있도록 스크립트로 기능을 구현했는데 언리얼에서는 이러한 기능 자체를 가지고 있는 것이 'SpringArm'으로 보인다.</p>

<p>이 컴포넌트를 추가하고 살펴본다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="823" data-origin-height="492"><span data-alt="Unreal Engine - SpringArm"><img src="/assets/images/posts/2024/07/09/95-4.png" loading="lazy" width="433" height="259" data-origin-width="823" data-origin-height="492"/></span><figcaption>Unreal Engine - SpringArm</figcaption>
</figure>
</p>

<p>'SpringArm' 컴포넌트를 추가하면 이미지에서 처럼 레이를 -x 방향으로 쏘고 있다.&nbsp;</p>

<p>이번에 카메라를 추가해서 'SpringArm'의 하위로 위치시킨다.</p>

<p>카메라는 'SpringArm'의 하위로 들어가는 순간 위치가 자동으로 쏘고 있던 레이의 끝부분에 위치하는데 이 거리를 조절하기 위해서는 카메라의 로케이션을 조절하는 게 아닌 'SpringArm'의 디테일에서 Camer &gt; Target arm Length로 조절해야 한다.</p>

<p>이 값을 조절하면 카메라의 위치가 알아서 조절이 되는 걸 확인할 수 있다.</p>

<p>이렇게 구조를 해놓으면 카메라는 항상 스프링암을 바라보게 되고 카메라에 대한 대부분의 제어는 스프링암을 통해서 이루어지게 된다.</p>

<p>탑뷰로 하기 위해서 스프링암의 정면을 바닥을 향하게 한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="402" data-origin-height="528"><span data-alt="Unreal Engine - Player Top Down"><img src="/assets/images/posts/2024/07/09/95-5.png" loading="lazy" width="321" height="422" data-origin-width="402" data-origin-height="528"/></span><figcaption>Unreal Engine - Player Top Down</figcaption>
</figure>
</p>

<p>이제 이 플레이어가 PlayLevel 이 시작될 때 생성되도록 한다.</p>

<h2>플레이어 로드</h2>
<p>플레이 시 자동으로 생성되던 Character나 PlayerController 등의 엑터들은 'GameMode'에 의해서 결정되던 것이다.</p>

<p>게임모드 역시 블루프린트로 상속해서 사용할 수 있으며 이 게임모드를&nbsp; Project &gt; Maps &amp; Modes에 적용시켜 프로젝트 전체에 사용할 게임모드로 설정하거나 World Settings 창에서 GameMode Override를 통해서 사용할 수 있다.</p>

<p>월드 설정을 통해서 게임모드를 변경해 본다.</p>

<p>'BP_MyGameMode'를 생성하고 'World Settings'의 GameMode Override에 추가한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="383" data-origin-height="275"><span data-alt="Unreal Engine - World Settings"><img src="/assets/images/posts/2024/07/09/95-6.png" loading="lazy" width="383" height="275" data-origin-width="383" data-origin-height="275"/></span><figcaption>Unreal Engine - World Settings</figcaption>
</figure>
</p>

<p>그리고 이 상태에서 플레이를 해서 내가 의도한 대로 동작하는지 확인해 본다.</p>> 용량 문제로 `Unreal Engine - Test Play` 이미지는 [원문](/develop/unreal/95-sharp2/)에서 확인한다.
</figure>
</p>

<p>플레이 시 원하는 대로 'BP_Player'가 PlayerStart 위치에 생성된다.&nbsp;</p>

<p>이 플레이어를 조작하기 위해서는 이번엔 'PlayerController'를 만들고 마찬가지로 게임모드에 추가해 주면 될듯하다.</p>

<h2>Enhanced Input</h2>
<p>'BP_PlayerController'를 생성한다.</p>

<p>플레이어 컨트롤러를 열어서 'Event Graph'를 열고 노드를 생성하여 조작을 구현하면 된다.</p>

<p>그전에 플레이어를 조작하기 위해서는 입력을 받는 부분에 대한 정의가 필요하다.</p>

<p>이 부분은 키를 맵핑해 주는 작업을 통해서 처리되는데 Project Settings &gt; Engine &gt; Input &gt; Bindings에서 맵핑을 한다.</p>

<p>그런데 기존에 일반적으로 사용하던 Axis, Action 맵핑 방식이 이제는 deprecated 되고 Enhanced Input Actions, Input Mapping Contests로 대체된다고 한다.&nbsp;</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1507" data-origin-height="303"><span data-alt="Unreal Engine - Axis and Action deprecated"><img src="/assets/images/posts/2024/07/09/95-8.png" loading="lazy" width="1507" height="303" data-origin-width="1507" data-origin-height="303"/></span><figcaption>Unreal Engine - Axis and Action deprecated</figcaption>
</figure>
</p>

<p>새로운 방식인 Enhanced를 사용해 본다.</p>

<p>해당 기능을 사용하기 위해서는 우선 플러그인이 활성화되어있는지 확인한다.&nbsp;</p>

<p>Edit &gt; Plugins &gt; Enhanced Input&nbsp;</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1079" data-origin-height="203"><span data-alt="Unreal Engine - Edit&amp;gt;Plugin&amp;gt;Enhanced Input"><img src="/assets/images/posts/2024/07/09/95-9.png" loading="lazy" width="1079" height="203" data-origin-width="1079" data-origin-height="203"/></span><figcaption>Unreal Engine - Edit&gt;Plugin&gt;Enhanced Input</figcaption>
</figure>
</p>

<p>현재 사용 중인 버전인 5.4에서는 기본적으로 해당 플러그인이 활성화되어 있다.</p>

<p>콘텐츠 브라우저에서 인풋과 관련된 파일들을 관리할 'Inputs' 폴더를 새로 생성한다.</p>

<p>그리고 해당 폴더에서 Input Action을 생성한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="152" data-origin-height="100"><span data-alt="Unreal Engine - Input Action"><img src="/assets/images/posts/2024/07/09/95-10.png" loading="lazy" width="152" height="100" data-origin-width="152" data-origin-height="100"/></span><figcaption>Unreal Engine - Input Action</figcaption>
</figure>
</p>

<p>간단하게 플레이어는 앞, 뒤, 좌, 우로만 조작할 것이기 때문에 두 개의 액션만 만든다.</p>

<p>'IA_MoveForwad',&nbsp; 'IA_MoveRight'</p>

<p>생성한 두 개의 인풋 액션 모두 'Value Type'을 'Axis 1D'로 설정한다.</p>

<p>아마도 키를 입력받으면 해당 값이 0~1 사이의 소수점으로 리턴하고 이걸 사용해서 움직이면 되는 듯하다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="479" data-origin-height="108"><span data-alt="Unreal Engine - Input Action&amp;gt;Value Type"><img src="/assets/images/posts/2024/07/09/95-11.png" loading="lazy" width="479" height="108" data-origin-width="479" data-origin-height="108"/></span><figcaption>Unreal Engine - Input Action&gt;Value Type</figcaption>
</figure>
</p>
<p><br />그리고 다시 Input 폴더로 돌아와서 이번엔 'Input Mapping Context'를 추가한다.&nbsp;</p>
<p>'IMC_Player'</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="202" data-origin-height="98"><span data-alt="Unreal Engine - Input Mapping Context"><img src="/assets/images/posts/2024/07/09/95-12.png" loading="lazy" width="202" height="98" data-origin-width="202" data-origin-height="98"/></span><figcaption>Unreal Engine - Input Mapping Context</figcaption>
</figure>
</p>

<p>생성한 인풋 맵핑 콘텍스트를 열고 맵핑을 시작한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1018" data-origin-height="195"><span data-alt="Unreal Engine - Input Mapping Context"><img src="/assets/images/posts/2024/07/09/95-13.png" loading="lazy" width="1005" height="193" data-origin-width="1018" data-origin-height="195"/></span><figcaption>Unreal Engine - Input Mapping Context</figcaption>
</figure>
</p>

<p>사용할 인풋 액션을 선택하고 키를 설정해 주는데 키 입력은 드롭다운을 열어서 선택하거나 옆에 아이콘을 한번 클릭하면&nbsp; 주황색으로 바뀌면서 키를 입력을 받을 수 있는 상태가 되는데 이 상태에서 원하는 키를 입력하면 한 번에 설정된다.</p>

<p>플레이어의 움직임은 기본적인 WASD로 설정한다.</p>

<p>W, D의 경우 입력받은 값을 그대로 사용하면 되지만 A, S의 경우 입력받은 값을 반전시켜 사용할 수 있도록 해야 하는데 이때 Modifiers 배열에 Negate 요소를 추가하면 된다. 이외에도 다양한 요소들이 있는데 이건 나중에 정리해보기로 한다.</p>

<p>나머지 키 맵핑도 해준 후 이제 'PlayerController'와 'Character'의 이벤트를 추가하면서 조작을 완성해 본다.</p>

<h2>플레이어 컨트롤러 이벤트 그래프</h2>
<p>플레이어 컨트롤러는 시작할 때 컨트롤러를 가지고 온 다음 키 입력을 리턴하여 맵핑된 키들이 입력될 때 값이 리턴되는 구조로 만들어 놓는다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1192" data-origin-height="412"><span data-alt="Unreal Engine - PlayerController Event Graph"><img src="/assets/images/posts/2024/07/09/95-14.png" loading="lazy" width="1192" height="412" data-origin-width="1192" data-origin-height="412"/></span><figcaption>Unreal Engine - PlayerController Event Graph</figcaption>
</figure>
</p>

<h2>캐릭터 이벤트 그래프</h2>
<p>캐릭터에서는 인풋에 의해서 변경되는 값들을 가지고 와서 플레이어의 로케이션을 변경시키도록 하면 될듯하다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="898" data-origin-height="500"><span data-alt="Unreal Engine - Character Event Graph"><img src="/assets/images/posts/2024/07/09/95-15.png" loading="lazy" width="898" height="500" data-origin-width="898" data-origin-height="500"/></span><figcaption>Unreal Engine - Character Event Graph</figcaption>
</figure>
</p>


<p>이벤트는 아마도 다음과 같이 진행되는 것으로 예상된다.</p>

<p>"플레이 시 컨트롤러에서는 전체적인 키의 인풋을 감지하게 된다. 이 중, 따로 맵핑해 놓은 키들(Input Mapping Context)이 입력될 때 특정한 값이 리턴(Input Action) 되도록 한다. 그리고 캐릭터는 위에서 키 입력 시 리턴되는 값을 가져와서 움직이는 데 사용한다."</p>

<p>아직 정확한 흐름은 파악이 잘 안 되지만 일단 이렇게 이벤트 그래프를 만들고 플레이해본다.</p>> 용량 문제로 `Unreal Engine - Player Move` 애니메이션 이미지는 [원문](/develop/unreal/95-sharp2/)에서 확인한다.
</figure>
</p>

<p>카메라는 너무 가까운 거 같아서 Target arm Length를 조절해 주었다.</p>

<p>테스트해보니 입력한 키에 맞춰 원하는 대로 움직이는 게 확인된다. 이벤트 그래프가 복잡하다고 생각했는데 의외로 직관적으로 원하는 기능들을 이어가다 보니 동작이 완성되긴 하는듯하다. 익숙해지기만 한다면 정말 수월하게 작업이 가능할듯하다. 그리고 여기까지 코드 한 줄 없이 작업을 했다는 것도 신기한 부분이다.</p>
