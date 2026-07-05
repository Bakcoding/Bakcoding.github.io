---
title: "다짜고짜 만들어 보기 #1 - UMG UI"
excerpt: "다짜고짜 만들어 보기 #1 - UMG UI"
categories:
  - Unreal
permalink: /develop/unreal/94-sharp1-umg-ui/
tags:
  - "Unreal"
  - "Game Development"
  - "open level"
  - "Unreal Engine"
  - "다짜고짜"
  - "언리얼 엔진"
toc: true
toc_sticky: true
date: 2024-07-08
last_modified_at: 2024-07-08
source_url: https://b-note.tistory.com/94
---

<h2>UMG UI</h2>
<p>Unreal Motion Graphic UI</p>
<p>언리얼에서 UI를 구현하는 데 사용할 수 있도록 제공되는 기능이다.</p>

<p>먼저 게임의 메인화면에서 게임시작 버튼을 눌러서 플레이 레벨로 전환되는 걸 만들어 본다.</p>

<h3>레벨 추가</h3>
<p>메인레벨과 플레이레벨 두 가지를 만든다.</p>
<p>MainLevel에서 게임시작 버튼을 누르면 PlayLevel로 넘어가는 구조이다.</p>

<p>콘텐츠 브라우저에 Level 파일을 저장할 Levels라는 폴더를 만든다. 대부분 이러한 폴더의 네이밍이나 파일의 네이밍은 일반적으로 많이 사용하는 규칙이 있지만 지금은 그것조차 모르는 상태이기 때문에 내 마음대로 만들 것이다.</p>

<p>Levels 폴더 내에서 우클릭하여 MainLevel과 PlayLevel을 추가한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="572" data-origin-height="196"><span data-alt="Unreal Engine - Create Level"><img src="/assets/images/posts/2024/07/08/94-1.png" loading="lazy" width="572" height="196" data-origin-width="572" data-origin-height="196"/></span><figcaption>Unreal Engine - Create Level</figcaption>
</figure>
</p>


<p>언리얼에서 Map, Level, World라는 단어들이 자주 사용되는데 이 용어들이 혼용돼서 사용되기도 하다 보니 헷갈리는 개념들이다.&nbsp;</p>

<p>검색해 보니 이 부분에 대해서 혼동하는 사람들이 꽤 있어 보인다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="709" data-origin-height="291"><span data-alt="Unreal Engine - Map, Level, World"><img src="/assets/images/posts/2024/07/08/94-2.png" loading="lazy" width="709" height="291" data-origin-width="709" data-origin-height="291"/></span><figcaption>Unreal Engine - Map, Level, World</figcaption>
</figure>
</p>

<p>글들을 읽어보면 level=map으로 보인다. level을 저장하면 파일의 확장자가 .umap인데 그렇기 때문에 level을 map이라고 부르기도 하는 것 같다.</p>

<p>level은 게임의 플레이 공간을 정의하는 기본 단위이고 지형, 라이트, 액터, 블루프린트, 사운드 등의 게임요소들을 포함하고 있다. 유니티의 scene이 level과 유사해 보인다.</p>

<p>world는 단일 또는 복수의 level로 구성되고 그 안에 포함된 모든 컴포넌트 등을 관리하는 개념으로 보이는데 여러 레벨을 로드 또는 언로드 하거나 전반적인 게임 환경을 관리하는 데 사용되는 걸로 보인다.</p>

<p>글들을 읽던 중 눈에 띄는 답변이 있었다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="662" data-origin-height="105"><span data-alt="Unreal Engine - Ambiguous Terminology"><img src="/assets/images/posts/2024/07/08/94-3.png" loading="lazy" width="662" height="105" data-origin-width="662" data-origin-height="105"/></span><figcaption>Unreal Engine - Ambiguous Terminology</figcaption>
</figure>
</p>

<p>'언리얼의 모든 모호한 용어들을 정리하면&nbsp; 일을 못할 것이다.'라고 하는데 이외에도 애매한 용어들이 많을 것으로 예상된다. 하나하나 이해하려고 하지 말고 그냥 사용해 보면서 그대로 받아들이는 방법이 최선인 거 같다.</p>

<h3>UI 배치</h3>
<p>블루프린트를 추가해서 UI를 만들어 본다.</p>
<p>마찬가지로 BluePrints 폴더를 만들고 이 안에서 파일을 생성한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="799" data-origin-height="314"><span data-alt="Unreal Engine - Create Widget BP"><img src="/assets/images/posts/2024/07/08/94-4.png" loading="lazy" width="799" height="314" data-origin-width="799" data-origin-height="314"/></span><figcaption>Unreal Engine - Create Widget BP</figcaption>
</figure>
</p>
<p><br />콘텐츠 브라우저 창에서 우클릭하여 User Interface &gt; Widget Blue Print를 생성한다.</p>
<p>파일이름은 BP_MainMenuWidget</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1918" data-origin-height="976"><span data-alt="Unreal Engine - BP_Widget"><img src="/assets/images/posts/2024/07/08/94-5.png" loading="lazy" width="1918" height="976" data-origin-width="1918" data-origin-height="976"/></span><figcaption>Unreal Engine - BP_Widget</figcaption>
</figure>
</p>

<p>1. 팔레트 : 여기에서 필요한 컴포넌트를 골라서 빈 공간이나 계층 구조에 끌어다 놓으면 UI가 생성된다.</p>
<p>2. 계층구조 : 생성된 UI의 계층구조를 보고 수정할 수 있다.</p>
<p>3. 디테일 : 생성한 UI에 대한 세부사항을 설정한다.</p>
<p>4. 디자인/그래프 : 디자인은 UI의 배치, 스타일 등 외부적인 것들을 세팅하고 그래프에서 동작들을 구현한다.</p>

<p>원하는 UI 배치는 화면 전체를 기준으로 가운데 버튼 몇 개를 세로로 정렬하려고 한다.</p>
<p>UI의 전체 틀을 담당할 Canvas Panel을 먼저 생성하고 세로로 정렬시키기 위해 세로 박스(vertical box)를 추가한다.</p>
<p>이 세로 박스 안에 사용할 버튼들을 자식으로 넣어준다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="308" data-origin-height="262"><span data-alt="Unreal Engine - BP_Widget Layer"><img src="/assets/images/posts/2024/07/08/94-6.png" loading="lazy" width="308" height="262" data-origin-width="308" data-origin-height="262"/></span><figcaption>Unreal Engine - BP_Widget Layer</figcaption>
</figure>
</p>

<p>세로 박스의 디테일을 설정한다.</p>
<p>앵커는 가운데로 맞춰준다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="495" data-origin-height="343"><span data-alt="Unreal Engine - BP_Widget Anchor"><img src="/assets/images/posts/2024/07/08/94-7.png" loading="lazy" width="495" height="343" data-origin-width="495" data-origin-height="343"/></span><figcaption>Unreal Engine - BP_Widget Anchor</figcaption>
</figure>
</p>

<p>이때 Shift와 Ctrl을 누른 상태에서 앵커 포지션을 선택하면 위치와 정렬이 함께 업데이트된다.</p>

<p>하위 버튼들은 동일하게 크기와 정렬을 맞춰준다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="470" data-origin-height="185"><span data-alt="Unreal Engine - BP_Widget Size/Sort"><img src="/assets/images/posts/2024/07/08/94-8.png" loading="lazy" width="470" height="185" data-origin-width="470" data-origin-height="185"/></span><figcaption>Unreal Engine - BP_Widget Size/Sort</figcaption>
</figure>
</p>

<p>각 버튼의 하위에는 텍스트를 추가해서 무슨 버튼인지 알 수 있도록 한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="475" data-origin-height="126"><span data-alt="Unreal Engine - BP_Widget Text"><img src="/assets/images/posts/2024/07/08/94-9.png" loading="lazy" width="475" height="126" data-origin-width="475" data-origin-height="126"/></span><figcaption>Unreal Engine - BP_Widget Text</figcaption>
</figure>
</p>

<p>계층구조에서 텍스트를 선택하고 디테일에서 '콘텐츠&gt; 텍스트'에 값을 변경해 원하는 텍스트를 입력할 수 있다.</p>
<p>색상은 버튼의 배경색과 구분되도록 '컬러 및 오파시티'에서 색만 바꾼다.</p>

<p>이렇게 만들고 실행을 해보면 아무것도 뜨지가 않는다.&nbsp;</p>

<h3>UI&nbsp; 생성</h3>
<p>이제 만들어 놓은 UI를 Level에서 생성할 수 있도록 한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="553" data-origin-height="307"><span data-alt="Unreal Engine - Level BP"><img src="/assets/images/posts/2024/07/08/94-10.png" loading="lazy" width="553" height="307" data-origin-width="553" data-origin-height="307"/></span><figcaption>Unreal Engine - Level BP</figcaption>
</figure>
</p>

<p>레벨 창을 열어서 블루프린트 리스트를 열고 '레벨 블루프린트 열기'를 선택한다.</p>

<p>열린 '이벤트 그래프' 창에서 빈 공간에 우클릭을 하여 기능을 추가하여 플로우를 만들 수 있다.</p>

<p>UI는 게임이 시작될 때 바로 보이게 할 것이기 때문에 'Event&nbsp; BeginPlay'를 추가하고 실행을 끌어다 놓고 위에서 만들어 놓은 'BP_MainMenuWidget'을 불러온다.</p>

<p>그리고 'BP_MainMenuWidget'의 'Return Value'를 끌어서 'Add to Viewport'를 만든다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="971" data-origin-height="296"><span data-alt="Unreal Engine - MainLevel Event Graph"><img src="/assets/images/posts/2024/07/08/94-11.png" loading="lazy" width="971" height="296" data-origin-width="971" data-origin-height="296"/></span><figcaption>Unreal Engine - MainLevel Event Graph</figcaption>
</figure>
</p>


<p>그러고 나서 다시 플레이를 해보면 프리뷰 창에서 내가 만든 UI가 뜨는 걸 확인할 수 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1269" data-origin-height="742"><span data-alt="Unreal Engine - Test Preview"><img src="/assets/images/posts/2024/07/08/94-12.png" loading="lazy" width="600" height="351" data-origin-width="1269" data-origin-height="742"/></span><figcaption>Unreal Engine - Test Preview</figcaption>
</figure>
</p>

<h3>레벨 전환</h3>
<p>세 개의 버튼 중 '새로 하기' 버튼을 클릭했을 때 레벨이 전환되도록 해본다.</p>

<p>다시 'BP_MainMenuWidget'을 열고 '계층구조'에서 원하는 버튼을 선택하고 디테일의 가장 하단으로 내려서 이벤트 탭을 연다.&nbsp;</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="470" data-origin-height="49"><span data-alt="Unreal Engine - Button Event"><img src="/assets/images/posts/2024/07/08/94-13.png" loading="lazy" width="470" height="49" data-origin-width="470" data-origin-height="49"/></span><figcaption>Unreal Engine - Button Event</figcaption>
</figure>
</p>

<p>이벤트를 보려면 변수 여부 세팅을 활성화해야 한다고 한다.</p>

<p>디테일의 상단을 보면 이름을 수정하는 곳 옆에 변수 여부를 설정하는 체크 박스가 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="399" data-origin-height="68"><span data-alt="Unreal Engine - Variable"><img src="/assets/images/posts/2024/07/08/94-14.png" loading="lazy" width="399" height="68" data-origin-width="399" data-origin-height="68"/></span><figcaption>Unreal Engine - Variable</figcaption>
</figure>
</p>

<p>이제는 이벤트 탭에서 사용할 수 있는 이벤트 리스트가 보인다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="465" data-origin-height="159"><span data-alt="Unreal Engine - Button Event List"><img src="/assets/images/posts/2024/07/08/94-15.png" loading="lazy" width="465" height="159" data-origin-width="465" data-origin-height="159"/></span><figcaption>Unreal Engine - Button Event List</figcaption>
</figure>
</p>

<p>원하는 기능은 클릭 시 밖에 없다.</p>
<p>'클릭 시' / '눌림 시'가 있는데 '클릭 시'가 버튼이 눌렸을 때 이벤트가 호출되고 '눌림 시'는 버튼이 눌린 동안 호출된다.&nbsp;</p>

<p>'클릭 시'의 우측에 있는 + 를 누르면 그래프 창으로 전환되고 해당 버튼의 On Clicked 가 이벤트 그래프에 추가된다.</p>

<p>버튼의 기능은 레벨 전환이기 때문에 해당 이벤트의 실행을 끌어다 'Open Level (by name)'을 만든다.</p>

<p>그리고 'Level Name'에 만들어 놓은 'PlayLevel'을 써준다.</p>

<h3>PlayLevel 수정</h3>
<p>씬 전환이 된걸 제대로 확인하기 위해서 한눈에 확인 가능하도록 'PlayLevel'에 몇 가지 추가한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="370" data-origin-height="119"><span data-alt="Unreal Engine - Modes"><img src="/assets/images/posts/2024/07/08/94-16.png" loading="lazy" width="370" height="119" data-origin-width="370" data-origin-height="119"/></span><figcaption>Unreal Engine - Modes</figcaption>
</figure>
</p>

<p>PlayerStart를 추가해서 플레이 시 화면이 보이도록 한다.</p>
<p>정확하게 이 클래스를 어떻게 사용하는지 모르겠지만 일단 화면만 확인하는 용도로 추가했다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1513" data-origin-height="724"><span data-alt="Unreal Engine - PlayLevel"><img src="/assets/images/posts/2024/07/08/94-17.png" loading="lazy" width="1513" height="724" data-origin-width="1513" data-origin-height="724"/></span><figcaption>Unreal Engine - PlayLevel</figcaption>
</figure>
</p>

<p>'MainLevel'과 구분될 정도로만 'PlayLevel'을 세팅한다.</p>

<p>다시 'MainLevel'로 돌아와서 플레이해 본다.</p>> 용량 문제로 `Unreal Engine - Test Play` 애니메이션 이미지는 [원문](/develop/unreal/94-sharp1-umg-ui/)에서 확인한다.
</figure>
</p>

<p>'MainLevel' UI 생성 &gt; 버튼 클릭, 레벨 오픈&gt; 'PlayLevel' 오픈</p>

<p>언리얼은 유니티처럼 씬의 편집을 담당하는 뷰와 인풋을 받아 게임 플레이가 가능한 게임 뷰의 구분이 없는 것 같다.</p>

<p>플레이를 하면 레벨에 자동으로 생성되는 엑터들이 있는데 이 중에 Player Controller가 있어서 별도로 추가한 게 없음에도 PlayLevel에서 움직이는 게 가능하다.</p>

<h4>추가로 정리가 필요한 부분</h4>
<p>- 구현된 플레이어가 있으면 플레이 시 Player Controller가 자동으로 생성되지 않는지 여부</p>
<p>- level 뿐만 아니라 world도 로드할 수 있던데 level을 로드하는 것과 world를 로드하는 방식의 차이</p>
