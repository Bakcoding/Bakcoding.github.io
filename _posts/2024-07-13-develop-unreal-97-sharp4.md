---
title: "다짜고짜 만들어 보기 #4 - 플레이어 애니메이션"
excerpt: "다짜고짜 만들어 보기 #4 - 플레이어 애니메이션"
categories:
  - Unreal
permalink: /develop/unreal/97-sharp4/
tags:
  - "Unreal"
  - "Game Development"
  - "ANIMATION"
  - "Unreal Engine"
  - "다짜고짜"
  - "애니메이션"
  - "언리얼 엔진"
toc: true
toc_sticky: true
date: 2024-07-13
last_modified_at: 2024-07-13
source_url: https://b-note.tistory.com/97
---

<h2>플레이어 애니메이션</h2>
<p>언리얼 엔진에서 기본으로 포함된 모델에는 애니메이션도 포함되어 있어 이걸 활용해 움직일 때 플레이어가 애니메이션이 재생되도록 만들어 본다.</p>

<p>애니메이션은 Idle,&nbsp; Wakl_Fwd 두 가지밖에 없어 일단 두 가지 동작만 추가한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="301" data-origin-height="79"><span data-alt="Unreal Engine - Tutorial Animation"><img src="/assets/images/posts/2024/07/13/97-1.png" loading="lazy" width="301" height="79" data-origin-width="301" data-origin-height="79"/></span><figcaption>Unreal Engine - Tutorial Animation</figcaption>
</figure>
</p>

<h2>BP_PlayerAnimation 추가</h2>
<p>먼저 블루프린트를 추가한다.&nbsp;</p>
<p>BluePrints 폴더 우클릭 &gt; Animation &gt; Animation Blue Print &gt; BP_PlayerAnimation</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="419" data-origin-height="539"><span data-alt="Unreal Engine - Animation Blue Print"><img src="/assets/images/posts/2024/07/13/97-2.png" loading="lazy" width="419" height="539" data-origin-width="419" data-origin-height="539"/></span><figcaption>Unreal Engine - Animation Blue Print</figcaption>
</figure>
</p>

<p>애니메이션 블루프린트를 생성할 때 어떤 모델을 사용할 것인지 스켈레톤을 특정하는 창이 뜬다.</p>

<p>플레이어의 스켈레톤인 TutorialTPP_Skeleton을 선택하여 생성한다.</p>

<p>애니메이션 블루프린트 창을 열면 Event Graph와 Anim Graph 탭이 보인다.</p>

<p>먼저 Anim Graph 창에서 State Machine을 추가한다.</p>

<h2>Animation State Machine</h2>
<p>빈 공간을 우클릭하여 추가하거나 Output Pose에서 Result를 드래그하여 추가할 수 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="496" data-origin-height="264"><span data-alt="Unreal Engine - Animation State Machine"><img src="/assets/images/posts/2024/07/13/97-3.png" loading="lazy" width="496" height="264" data-origin-width="496" data-origin-height="264"/></span><figcaption>Unreal Engine - Animation State Machine</figcaption>
</figure>
</p>

<p>생성한 StateMachine은 Output Pose의 Result와 연결한다.</p>

<p>StateMachine을 더블클릭하면 상태머신 내부로 이동하고 여기서 애니메이션을 추가할 수 있다.</p>

<p>내부에는 Entry 노드가 있는데 여기서 화살표 아이콘을 드래그하여 빈 곳에 놓고 Add State를 선택하면 애니메이션을 추가할 수 있다.</p>

<p>또는 애니메이션 에셋을 드래그하여 빈 공간에 놓아도 추가할 수 있다.</p>

<p>이때 사용할 수 있는 애니메이션 리스트를 볼 수 있는 창이 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="481" data-origin-height="312"><span data-alt="Unreal Engine - State Machine Select Animation"><img src="/assets/images/posts/2024/07/13/97-4.png" loading="lazy" width="481" height="312" data-origin-width="481" data-origin-height="312"/></span><figcaption>Unreal Engine - State Machine Select Animation</figcaption>
</figure>
</p>

<p>위 사진에서 점 세 개로 된&nbsp;아이콘을 클릭하면 사용가능한 애니메이션 목록이 보이는데 블루프린트를 생성할 때 특정한 스켈레톤에서 사용가능한 애니메이션 목록으로 보인다.</p>

<p>여기서 Idle과 Walk 애니메이션 두 가지를 일단 끌어다 놓는다.</p>

<p>그리고 Entry에서 바로 연결되는 State는 기본상태로 Idle과 연결시켜 주고 Idle은 테두리 부분에 마우스를 올리면 색이 변경되는데 이 상태에서 드래그하면 다른 애니메이션과 연결할 수 있는 상태가 된다.</p>

<p>Idle과 Walk를 서로 왔다 갔다 할 수 있도록 연결시켜 놓는다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="473" data-origin-height="294"><span data-alt="Unreal Engine - State Transition"><img src="/assets/images/posts/2024/07/13/97-5.png" loading="lazy" width="473" height="294" data-origin-width="473" data-origin-height="294"/></span><figcaption>Unreal Engine - State Transition</figcaption>
</figure>
</p>

<p>추가한 애니메이션을 더블 클릭하면 애니메이션 세부 설정을 할 수 있는 창을 열어준다.</p>

<p>이때 테두리가 아닌 중심을 잘 선택해야 하는데 이 상태는 마우스 커서가 십자 모양이다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="268" data-origin-height="265"><span data-alt="Unreal Engine - Animation Detail"><img src="/assets/images/posts/2024/07/13/97-6.png" loading="lazy" width="268" height="265" data-origin-width="268" data-origin-height="265"/></span><figcaption>Unreal Engine - Animation Detail</figcaption>
</figure>
</p>

<p>세부설정에서 해당 애니메이션 노드를 선택하고 디테일 창 &gt; Settings &gt; Loop Animation을 체크해서 반복 재생하도록 한다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1105" data-origin-height="267"><span data-alt="Unreal Engine - Animation Loop"><img src="/assets/images/posts/2024/07/13/97-7.png" loading="lazy" width="1105" height="267" data-origin-width="1105" data-origin-height="267"/></span><figcaption>Unreal Engine - Animation Loop</figcaption>
</figure>
</p>

<p>Walk 애니메이션도 움직이는 상태인 동안 계속해서 재생되어야 하기 때문에 해당 옵션을 체크해 준다.</p>

<h2>Animation Event Graph</h2>
<p>스테이트 머신에 추가한 두 애니메이션 사이에 연결한 트랜지션에는 어떤 조건에서 애니메이션이 전환되는지 상태가 필요하다.</p>

<p>이동에 관련된 애니메이션이기 때문에 플레이어가 움직임과 관련된 값인 Velocity를 가지고 조건을 만들어 본다.</p>

<p>이벤트 그래프에는 Event Blueprint Update Animation과 Try Get Pawn Owner 노드가 기본으로 있다.</p>

<p>Try Get Pawn Owner 노드에서는 이 애니메이션 블루프린트가 연결된 Pawn 즉 플레이어의 정보들을 가지고 올 수 있다.</p>

<p>Return Value를 드래그하여 GetVelocity 노드를 추가한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="431" data-origin-height="176"><span data-alt="Unreal Engine - Animation Event Graph GetVelocity"><img src="/assets/images/posts/2024/07/13/97-8.png" loading="lazy" width="431" height="176" data-origin-width="431" data-origin-height="176"/></span><figcaption>Unreal Engine - Animation Event Graph GetVelocity</figcaption>
</figure>
</p>

<p>Velocity는 방향을 포함한 Vector3 값인데 현재 움직이는지 여부만 판단하면 되기 때문에 이 값을 float 형태로 사용하기 위해서 Vector Length 함수로 크기만 가지는 값의 형태로 만든다.</p>

<p>그리고 이 값을 State에서 사용하기 편하도록 변수를 추가해 값만 가져다 쓸 수 있도록 한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="475" data-origin-height="412"><span data-alt="Unreal Engine - Event Graph Add Variable"><img src="/assets/images/posts/2024/07/13/97-9.png" loading="lazy" width="475" height="412" data-origin-width="475" data-origin-height="412"/></span><figcaption>Unreal Engine - Event Graph Add Variable</figcaption>
</figure>
</p>

<p>이벤트 그래프 창에서 My Blue Print 탭을 보면 VARIABLES 목록이 있고 여기에 변수를 추가할 수 있다.</p>

<p>Speed 이름의 Float 타입 변수를 추가한다.</p>

<p>이벤트 그래프에 Vector Length의 리턴값을 끌어다 놓고 SetSpeed와 연결한다.</p>

<p>이 값은 매번 업데이트 되어야하기 때문에 Event BluePrint Update Animation과 연결이 필요하다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="800" data-origin-height="238"><span data-alt="Unreal Engine - Animation Event Graph Flow"><img src="/assets/images/posts/2024/07/13/97-10.png" loading="lazy" width="800" height="238" data-origin-width="800" data-origin-height="238"/></span><figcaption>Unreal Engine - Animation Event Graph Flow</figcaption>
</figure>
</p>

<p>이제 Speed에는 플레이어가 움직일 때마다 변경되는 값이 저장된다.</p>

<h2>상태 머신 트랜지션 조건</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="240" data-origin-height="191"><span data-alt="Unreal Engine - State Transition"><img src="/assets/images/posts/2024/07/13/97-11.png" loading="lazy" width="240" height="191" data-origin-width="240" data-origin-height="191"/></span><figcaption>Unreal Engine - State Transition</figcaption>
</figure>
</p>

<p>다시 상태머신 창으로 돌아와서 위 트랜지션 아이콘을 더블 클릭하면 트랜지션 창이 열린다.</p>
<p><br />해당 창에는 Result 노드가 기본으로 있다. 이 노드의 인풋 값인 Can Enter Transition은 Boolen 타입의 값을 받고 있다.</p>

<p>따라서 Speed 값의 상태에 따라서 Boolean 타입을 반환하도록 연산자를 추가해주어야 한다.</p>

<p>Speed 값은 0일 때는 Idle , 0이 아니면 Walk이다. 이걸 연산자를 사용해 표현한다.</p>

<p>먼저 사용할 값인 Speed의 값을 GetSpeed를 통해서 가지고 온다.</p>

<p>그리고 링크를 끌어다 놓고 Operator를 검색해 보면 다양한 연산자들이 나오는데 현재 Idle -&gt; Walk로 전환되는 상태가 어떨 때인지 조건이기 때문에 != 연산자와 연결한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="603" data-origin-height="271"><span data-alt="Unreal Engine - Transition Idle to Walk"><img src="/assets/images/posts/2024/07/13/97-12.png" loading="lazy" width="603" height="271" data-origin-width="603" data-origin-height="271"/></span><figcaption>Unreal Engine - Transition Idle to Walk</figcaption>
</figure>
</p>

<p>밑에 비교할 값은 연결된 게 없으면 상수를 입력해서 결정할 수 있어 보인다. 비교할 값은 0이기 때문에 기본값 그대로 둔다. 그리고 리턴되는 Boolean 값을 Result와 연결한다.</p>

<p>Walk -&gt; Idle 도 마찬가지로 노드를 구성하는데 여기서는 연산자를 == 를 사용해서 속도가 0일 때 즉 움직이지 않을 때는 Idle 애니메이션이 재생되도록 하면 된다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="573" data-origin-height="181"><span data-alt="Unreal Engine - Transition Walk to Idle"><img src="/assets/images/posts/2024/07/13/97-13.png" loading="lazy" width="573" height="181" data-origin-width="573" data-origin-height="181"/></span><figcaption>Unreal Engine - Transition Walk to Idle</figcaption>
</figure>
</p>

<p>연산자는 A (연산자) B 형태로 위에 들어오는 값이 A, 아래가 B라는 점을 염두한다.</p>

<h2>플레이어 애니메이션 블루프린트 연결</h2>
<p>이제 지금까지 만든 애니메이션 블루프린트를 플레이어에서 사용하도록 한다.</p>

<p>BP_Player &gt; Details &gt; Animation &gt; Anim Class</p>

<p>여기서 파일 검색 아이콘을 눌러서 위에서 만든 BP_PlayerAnimation를 검색해서 등록한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="365" data-origin-height="212"><span data-alt="Unreal Engine - Add Anim Class"><img src="/assets/images/posts/2024/07/13/97-14.png" loading="lazy" width="365" height="212" data-origin-width="365" data-origin-height="212"/></span><figcaption>Unreal Engine - Add Anim Class</figcaption>
</figure>
</p>


<h2>결과&nbsp;</h2>
<p><figure class="imageblock alignLeft"><span data-alt="Unreal Engine - Test Play"><img src="/assets/images/posts/2024/07/13/97-15.gif" loading="lazy" width="278" height="320"/></span><figcaption>Unreal Engine - Test Play</figcaption></figure></p>

<p>움직일 때 애니메이션이 잘 전환되고 기존 동작들과도 문제가 없어 보인다.</p>
