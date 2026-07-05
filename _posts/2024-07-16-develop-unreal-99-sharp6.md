---
title: "다짜고짜 만들어 보기 #6 - 적 구현"
excerpt: "다짜고짜 만들어 보기 #6 - 적 구현"
categories:
  - Unreal
permalink: /develop/unreal/99-sharp6/
tags:
  - "Unreal"
  - "Game Development"
  - "Ai"
  - "Enemy"
  - "Unreal Engine"
  - "언리얼 엔진"
  - "인공지능"
  - "적"
toc: true
toc_sticky: true
date: 2024-07-16
last_modified_at: 2024-07-16
source_url: https://b-note.tistory.com/99
---

<h2>적</h2>
<p>적을 생성하고 총알과 상호작용할 수 있도록 만들어 본다.</p>
<p>적은 Character를 상속하여 구현하고 리소스는 언리얼엔진의 다른 샘플에서 가져다 쓰기로 한다.</p>

<p>플레이어를 만들 때처럼 콜라이더 크기와 메시의 위치를 조절하고 정면을 방향을 맞춘다.</p>
<p><br /><span style="text-align: start">그리고 BP_Enemy는 플레이어와 동일한<span>&nbsp;</span></span>스켈레탈 메시를 사용하고 구분하기 위해서 머티리얼은 복사하여 새로 생성하고 색만 바꾸어서 적용했다.</p>

<p>애니메이션은 언리얼에서 제공하는 3인칭 시점 게임 샘플에서 Idle과&nbsp; RunForward만 가져다 사용했다.</p>
<p><br />가지고 온 애니메이션을 적용하니 메시가 이상하게 변형되었다. 아마도 리깅이 달라서 생긴 문제로 보인다.&nbsp;</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="319" data-origin-height="508"><span data-alt="Unreal Engine - Enemy Mesh"><img src="/assets/images/posts/2024/07/16/99-1.png" loading="lazy" width="259" height="412" data-origin-width="319" data-origin-height="508"/></span><figcaption>Unreal Engine - Enemy Mesh</figcaption>
</figure>
</p>

<p>이 상태로 작업해도 크게 문제는 없을 것 같아 그대로 진행한다.</p>

<p>애니메이션 에셋을 더블클릭하여 에셋의 디테일창을 연다. Idle과 Run 모두 Loop는 체크해 준다.</p>

<p>RunForward의 경우 애니메이션이 위치를 수정하는 게 포함되어 있어서 Root Motion &gt; Force Root Lock을 체크해 준다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="368" data-origin-height="165"><span data-alt="Unreal Engine - Root Motion"><img src="/assets/images/posts/2024/07/16/99-2.png" loading="lazy" width="368" height="165" data-origin-width="368" data-origin-height="165"/></span><figcaption>Unreal Engine - Root Motion</figcaption>
</figure>
</p>

<p>보통 Enable Root Motion이 체크된 경우 애니메이션 동작이 위치 변형이 반영되는데 이 애니메이션은 RootMotion은 비활성화되어 있어도 위치가 변형되어 Force Root Lock을 체크했더니 해결되었다.</p>

<h2>BP_EnemyAnimation</h2>
<p>플레이어와 마찬가지로 Speed 변수를 만들어서 에너미의 Velocity의 크기를 가져다 상태를 전환하는 값으로 사용했다.</p>

<p>BP_Enemy의 Anim Class에 BP_EnemyAnimation을 적용시킨다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="474" data-origin-height="239"><span data-alt="Unreal Engine - Anim Graph"><img src="/assets/images/posts/2024/07/16/99-3.png" loading="lazy" width="387" height="195" data-origin-width="474" data-origin-height="239"/></span><figcaption>Unreal Engine - Anim Graph</figcaption>
</figure>
<figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="405" data-origin-height="312"><span data-alt="Unreal Engine - Anim State"><img src="/assets/images/posts/2024/07/16/99-4.png" loading="lazy" width="405" height="312" data-origin-width="405" data-origin-height="312"/></span><figcaption>Unreal Engine - Anim State</figcaption>
</figure>
<figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="584" data-origin-height="165"><span data-alt="Unreal Engine - Run to Idle"><img src="/assets/images/posts/2024/07/16/99-5.png" loading="lazy" width="584" height="165" data-origin-width="584" data-origin-height="165"/></span><figcaption>Unreal Engine - Run to Idle</figcaption>
</figure>
<figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="591" data-origin-height="143"><span data-alt="Unreal Engine - Idle to Run"><img src="/assets/images/posts/2024/07/16/99-6.png" loading="lazy" width="591" height="143" data-origin-width="591" data-origin-height="143"/></span><figcaption>Unreal Engine - Idle to Run</figcaption>
</figure>
</p>

<h2>적의 인공지능</h2>
<p>적은 플레이어를 추적해서 공격하는 기능이 필요한데 우선 플레이어를 타깃으로 추적하는 부분까지만 구현하기로 한다.</p>

<p>AIController 블루프린트를 상속한 BP_EnemyAIController를 생성한다.</p>

<p>먼저 BP_Player 타입의 Target 변수를 만들고 시작할 때 GetPlayerCharacter를 캐스트 해서 변수를 저장한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="644" data-origin-height="120"><span data-alt="Unreal Engine - BP_EnemyAIController &amp;gt; BeginePlay"><img src="/assets/images/posts/2024/07/16/99-7.png" loading="lazy" width="644" height="120" data-origin-width="644" data-origin-height="120"/></span><figcaption>Unreal Engine - BP_EnemyAIController &gt; BeginePlay</figcaption>
</figure>
</p>

<p>타겟을 향해 이동하는 함수는 Move to Location을 사용한다.</p>

<p>타겟을 향해 이동할 때 타겟의 방향으로 회전하면서 이동하기 때문에 따로 회전하는 기능은 추가할 필요가 없다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="917" data-origin-height="261"><span data-alt="Unreal Engine - Event Tick &amp;gt; MovetoLocation"><img src="/assets/images/posts/2024/07/16/99-8.png" loading="lazy" width="917" height="261" data-origin-width="917" data-origin-height="261"/></span><figcaption>Unreal Engine - Event Tick &gt; MovetoLocation</figcaption>
</figure>
</p>

<p>저장해 놓은 Target에서 위치를 가져와서 Move to Location의 Dest, 목표로 설정해 준다.</p>

<p>이렇게 만들어 놓은 AI 컨트롤러는 BP_Enemy &gt; Details &gt; Pawn &gt; AI Controller Class에 할당한다.</p>

<h2>적 스폰</h2>
<p>이제 만들어 놓은 Enemy를 스폰해 본다.</p>

<p>스폰을 어디서 처리할지가 애매했는데 일단 게임의 전반적인 기능을 담당하는 BP_MyGameMode에서 스폰 기능을 구현하기로 한다.</p>

<p>BP_MyGameMode에 Spawn Enemy 함수를 추가한다.</p>

<p>적은 플레이어 위치를 기준으로 일정한 범위 내에서 랜덤 한 위치에 생성되도록 한다.</p>

<p>먼저 플레이어 위치 벡터를 가지고 와서 일정 범위 안에서 랜덤 한 값만큼을 오프셋으로 사용해서 생성될 위치를 정한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1087" data-origin-height="399"><span data-alt="Unreal Engine - BP_MyGameMode &amp;gt; Spawn Enemy Func"><img src="/assets/images/posts/2024/07/16/99-9.png" loading="lazy" width="1087" height="399" data-origin-width="1087" data-origin-height="399"/></span><figcaption>Unreal Engine - BP_MyGameMode &gt; Spawn Enemy Func</figcaption>
</figure>
</p>

<p>Random Float in Range를 사용해서 Min ~ Max 범위 안의 값을 오프셋으로 사용한다.</p>

<p>Spawn Actor BP Enemy의 Spawn Transform에 생성한 무작위 위치를 할당하고 class는 BP_Enemy로 설정해 준다.</p>

<p>이제 이 함수를 호출해서 적을 생성하면 된다.</p>

<p>방식은 일정 시간 간격으로 생성되도록 할 것이다.</p>

<p>BP_MyGameMode의 Event Begin Play에서 Set Timer by Event를 호출하고 Custom Event인 EnemySpawnEvent를 만든다. EnemySpawnEvent는 SpawnEnemy를 호출하는 기능만 하며 Set Timer by Event의 Event 파라미터에 등록한다.</p>

<p>Time에 적을 생성할 주기를 정해주는데 일단 3초 간격으로 적이 생성되도록 한다.</p>

<p>그리고 3초마다 계속 생성되도록 Looping은 True로 체크해 준다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="789" data-origin-height="274"><span data-alt="Unreal Engine - BP_MyGameMode &amp;gt; EventGraph"><img src="/assets/images/posts/2024/07/16/99-10.png" loading="lazy" width="789" height="274" data-origin-width="789" data-origin-height="274"/></span><figcaption>Unreal Engine - BP_MyGameMode &gt; EventGraph</figcaption>
</figure>
</p>

<p>여기까지 진행하고 테스트를 해보는데 적이 플레이어 주변 랜덤한 위치에 생성은 되지만 움직이지 않는다.</p>

<h2>Auto Possess AI</h2>
<p>BP_Enemy의 디테일 창으로 다시 돌아가서 Pawn 탭의 Auto Possess AI 옵션을 확인한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="319" data-origin-height="133"><span data-alt="Unreal Engine - Auto Possess AI"><img src="/assets/images/posts/2024/07/16/99-11.png" loading="lazy" width="319" height="133" data-origin-width="319" data-origin-height="133"/></span><figcaption>Unreal Engine - Auto Possess AI</figcaption>
</figure>
</p>

<p>해당 옵션은 기본 값으로 Placed in World로 되어있는데 이 옵션은 미리 맵에 생성된 액터에게만 해당하며 플레이 도중에 생성된 액터는 동작하지 않는다.</p>

<p>각 옵션의 사용법을 알아둔다.</p>

<p><b>Disabled</b></p>
<p>AI 컨트롤러가 캐릭터를 자동으로 제어하지 않는다. AI 컨트롤러를 수동으로 할당해한다.</p>

<p><b>Placed in World </b></p>
<p>맵에 배치된 AI 캐릭터가 게임 시작 시 AI 컨트롤러에 의해 자동으로 제어된다. 주로 에디터에서 맵에 직접 배치된 AI 캐릭터에 사용된다.</p>

<p><b>Spawned</b></p>
<p>게임 도중 스폰된 AI 캐릭터가 AI 컨트롤러에 의해 자동으로 제어된다. 런타임 중에 생성된 AI 캐릭터에 사용된다.</p>

<p><b>Placed in World or Spawned</b></p>
<p>맵에 배치된 AI 캐릭터와 게임 도중 스폰된 AI 캐릭터 모두 AI 컨트롤러에 의해 자동으로 제어된다. 모든 상황에서 AI 캐릭터를 자동으로 제어할 때 사용한다.</p>

<p>이 옵션을 적의 배치 방식에 맞는 Spawned로 설정한다.</p>

<p>이제 다시 플레이해 보면 여전히 동작하지 않는다.</p>

<h2>NavMeshBoundsVolume</h2>
<p>만들어놓은 지형에 AI가 돌아다닐 수 있는 범위를 정해주어야 한다.</p>

<p>해당 범위만큼 내비게이션의 길 찾기 연산에 포함되기 때문에 복잡하고 넓을수록 많은 연산을 차지하게 된다.</p>

<p>Place Actor에서 NavMeshBoundsVolume을 찾아서 레벨에 생성한다. 그리고 AI가 돌아다닐 수 있는 범위만큼 크기와 높이를 조절한다.</p>

<p>범위가 원하는 대로 지정됐는지 확인하려면 플레이하지 않고 뷰포트에서 키보드 'P'를 누르면 지정된 범위만큼 녹색으로 표시가 된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1260" data-origin-height="611"><span data-alt="Unreal Engine - NavMeshBoundsVolume"><img src="/assets/images/posts/2024/07/16/99-12.png" loading="lazy" width="1260" height="611" data-origin-width="1260" data-origin-height="611"/></span><figcaption>Unreal Engine - NavMeshBoundsVolume</figcaption>
</figure>
</p>

<p>이제 진짜로 테스트 플레이를 해본다.</p>> 용량 문제로 `Unreal Engine - Test Play` 애니메이션 이미지는 [원문](/develop/unreal/99-sharp6/)에서 확인한다.
</figure>
</p>

<p>랜덤 한 위치에서 적이 생성되고 생성된 적은 플레이어를 추적하기 시작한다.</p>

<p>추적하는 동안 이동하는 애니메이션이 재생되고 목적지에 도착하면 일반 상태의 애니메이션이 재생된다.</p>

<p>플레이어가 이동하면 변경된 위치를 계속해서 따라가게 된다. 여기까지 원하는 대로 잘 동작하게 되었다.</p>
