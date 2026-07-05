---
title: "다짜고짜 만들어 보기 #3 - 플레이어 회전"
excerpt: "다짜고짜 만들어 보기 #3 - 플레이어 회전"
categories:
  - Unreal
permalink: /develop/unreal/96-sharp3/
tags:
  - "Unreal"
  - "Game Development"
  - "player rotation"
  - "Unreal Engine"
  - "다짜고짜"
  - "언리얼 엔진"
  - "플레이어 회전"
toc: true
toc_sticky: true
date: 2024-07-13
last_modified_at: 2024-07-13
source_url: https://b-note.tistory.com/96
---

<h2>마우스 커서 활성화</h2>
<p>플레이어는 마우스 커서의 위치를 바라보도록 회전시킬 것이기 때문에 먼저 플레이 시 마우스 커서가 보이는 상태로 유지되도록 수정한다.</p>

<p>'BP_PlayerController' BeginPlay 노드에서 새로운 노드를 추가해 준다.</p>

<p>'Show Mouse Cursor'를 추가하고 체크박스에 체크를 해준다.&nbsp;</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1068" data-origin-height="426"><span data-alt="Unreal Engine - Show Mouse Cursor"><img src="/assets/images/posts/2024/07/13/96-1.png" loading="lazy" width="732" height="426" data-origin-width="1068" data-origin-height="426"/></span><figcaption>Unreal Engine - Show Mouse Cursor</figcaption>
</figure>
</p>

<h2>플레이어 회전</h2>
<p>플레이어의 회전을 구현하기 전에 현재 카메라는 캐릭터의 하위에 들어있다.&nbsp;</p>

<p>이 상태로 플레이어를 회전시키면 카메라도 함께 회전하기 때문에 회전값이 카메라에는 적용되지 않도록 처리한다.</p>
<p><br />'Spring Arm'의 Camera Settings&gt; Inherit Pitch, Inherit Yaw, Inherit Roll을 체크해제하면 카메라는 캐릭터의 회전에 영향을 받지 않게 된다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="364" data-origin-height="140"><span data-alt="Unreal Engine - Spring Arm Setting"><img src="/assets/images/posts/2024/07/13/96-2.png" loading="lazy" width="364" height="140" data-origin-width="364" data-origin-height="140"/></span><figcaption>Unreal Engine - Spring Arm Setting</figcaption>
</figure>
</p>

<p>그리고 마우스 커서의 위치를 가지고 플레이어를 회전시키도록 한다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="971" data-origin-height="253"><span data-alt="Unreal Engine - BP_Player"><img src="/assets/images/posts/2024/07/13/96-3.png" loading="lazy" width="971" height="253" data-origin-width="971" data-origin-height="253"/></span><figcaption>Unreal Engine - BP_Player</figcaption>
</figure>
</p>

<p>Event Tick 은 프레임마다 실행하는 유니티의 업데이트와 동일한 기능을 한다.</p>

<p>카메라의 회전은 매 프레임마다 마우스의 위치를 확인하고 그 위치를 변환해서 회전시켜야 하기 때문에 'Event Tick'에서 노드를 뻗어나간다.</p>

<p>마우스의 위치를 가져올 수 있는 걸 찾다 적당해 보이는 'Convert Mouse Location To World Space'를 사용하기로 한다.</p>

<p>이 함수를 사용하기 위해서는 'PlayerController'가 필요하기 때문에 'GetPlayerController'를 통해서 플레이어 컨트롤러를 가져온 다음 해당 함수를 불러온다.</p>

<p>'GetPlayerController'는 화면상에 위치한 마우스 커서의 위치를 게임 상의 월드 좌표로 변경한 값을 리턴한다.&nbsp;</p>

<p>이 리턴값을 플레이어가 바라보도록 회전을 시키게 되면 원하는 기능의 구현이 완성된다.</p>

<p>'Find Look at Rotation'는 'Start' 위치에서 'Target'을 바라보도록 회전하는 값을 반환한다.</p>

<p>'Start'에는 'GetActorLocation'으로 캐릭터의 위치를 가져와 연결하고 'Target'에는 'ConvertMouseLocationToWorldSpace'의 'World Location'과 연결시킨다. 이렇게 구해온 회전값을 이제 캐릭터의 회전에 적용시키면 되는데 여기서 Z축의 회전값만 필요하기 때문에 'Break Rotator'와 'Make Rotator'를 사용해서 필요한 값만 리턴되도록 만들어 'Set Actor Rotation'의 'New Rotation'에 연결시킨다.</p>

<p>플레이를 해서 테스트를 해본다.</p>
<p><figure class="imageblock alignLeft"><span data-alt="Unreal Engine - Character Rotate"><img src="/assets/images/posts/2024/07/13/96-13.gif" loading="lazy" width="355" height="295"/></span><figcaption>Unreal Engine - Character Rotate</figcaption></figure></p>

<p>회전만 했을 때 원하는 대로 동작하지만 움직이면서 회전시킬 경우 캐릭터의 회전이 이상하게 동작한다.</p>

<p>아마도 움직이기 시작하면서 'Find Look at Rotation'에서 'Start'나 'Target'의 값에 문제가 생긴 거 같아 정확히 확인해 보기 위해서 디버깅을 해본다.</p>


<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="319" data-origin-height="217"><span><img src="/assets/images/posts/2024/07/13/96-5.png" loading="lazy" width="319" height="217" data-origin-width="319" data-origin-height="217"/></span></figure>
</p>

<p>'Draw Debug Line'을 사용해서 시작점과 끝점을 각각 플레이어 위치, 마우스 커서의 위치로 값을 연결한다.</p>
<p><figure class="imageblock alignLeft"><span data-alt="Unreal Engine - Debug Draw Line"><img src="/assets/images/posts/2024/07/13/96-14.png" loading="lazy" width="319" height="217"/></span><figcaption>Unreal Engine - Debug Draw Line</figcaption></figure></p>

<p>움직이기 전에는 라인이 제대로 캐릭터와 커서 사이에 그려지는 게 보이지만 움직이기 시작하면 커서의 위치가 이상하게&nbsp;</p>
<p>리턴되고 있다.</p>

<p>혹시 현재 인풋 이벤트가 발생할 때 값을 'PlayerControlloer'에서 리턴하고 있는데 회전에 대한값을 'PlayerCharacter'에서 따로 추가해서 발생하는 문제일까?&nbsp;</p>

<p>일단 한 곳에서 값을 리턴 받아 사용하도록 &nbsp;'BP_Player'에서는 회전의 기능만 추가하고 인풋처리는 'BP_PlayerController'에서만 하도록 수정해 본다.</p>

<h2>플레이어 회전 함수</h2>
<p>함수는 블루 프린트 창의 GRAPHS 탭에서 추가하고 커스텀하여 사용할 수 있다.</p>
<p>'BP_Player'에 Look Target이라는 타깃을 기능만 담당하는 함수를 추가한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="303" data-origin-height="316"><span data-alt="Unreal Engine - Add Function"><img src="/assets/images/posts/2024/07/13/96-7.png" loading="lazy" width="303" height="316" data-origin-width="303" data-origin-height="316"/></span><figcaption>Unreal Engine - Add Function</figcaption>
</figure>
</p>

<p>필요한 값은 'Find Look at Rotation'에 필요한 'Start'와 'Target'의 벡터 값이다.</p>
<p>여기서 'BP_PlayerController'에서 호출하고 'Event Tick'으로 연결시킬 것이기 때문에 마우스 커서의 위치만 받도록 한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="376" data-origin-height="48"><span data-alt="Unreal Engine - Function Inputs"><img src="/assets/images/posts/2024/07/13/96-8.png" loading="lazy" width="376" height="48" data-origin-width="376" data-origin-height="48"/></span><figcaption>Unreal Engine - Function Inputs</figcaption>
</figure>
</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="923" data-origin-height="574"><span data-alt="Unreal Engine - Func Look Target"><img src="/assets/images/posts/2024/07/13/96-9.png" loading="lazy" width="923" height="574" data-origin-width="923" data-origin-height="574"/></span><figcaption>Unreal Engine - Func Look Target</figcaption>
</figure>
</p>

<p>'Target Location'은 마우스 커서의 위치이고 나머지는 'BP_Player'의 값에서 가져다 사용한다.</p>

<h2>플레이어 컨트롤러 함수 호출</h2>
<p>이제 위에서 만든 함수를 'BP_PlayerController'에서 호출하도록 한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1102" data-origin-height="358"><span data-alt="Unreal Engine - Player Controller"><img src="/assets/images/posts/2024/07/13/96-10.png" loading="lazy" width="1102" height="358" data-origin-width="1102" data-origin-height="358"/></span><figcaption>Unreal Engine - Player Controller</figcaption>
</figure>
</p>

<p>우선 해당 함수에 접근하기 위해서는 'BP_Player'를 가지고 와야 하는데 이걸 직접 가지고 올 수 있는 방법은 없는 건지&nbsp;못 찾는 건지 일단 'GetPlayerController'를 가지고 온 다음 'BP_Player'로 캐스트 하여 접근한다.</p>
<p>('BP_Player'가 'PlayerCharacter'를 상속했기 때문에)</p>

<p>이렇게 접근한 'Look Target' 함수에 'Convert Mouse Location To World Space'의 'World Location' 값을 연결하고 이 함수를 'Event Tick'으로 호출한다.</p>

<h2>수정 후 테스트</h2>
<p><figure class="imageblock alignLeft"><span data-alt="Unreal Engine - Play Test"><img src="/assets/images/posts/2024/07/13/96-15.gif" loading="lazy" width="266" height="294"/></span><figcaption>Unreal Engine - Play Test</figcaption></figure></p>

<p>테스트 결과 움직일 때도 마우스 커서를 향하도록 제대로 회전하게 되었다.</p>
<p>하지만 여전히 디버그 라인에서 보이는 마우스 커서의 위치가 움직일 때 이상한 값이 리턴되는 걸로 보인다. 이 부분은 체크해 두고 나중에 다시 확인해야겠다.</p>

<h2>추가 테스트</h2>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="531" data-origin-height="275"><span data-alt="Unreal Engine - BP_PlayerController"><img src="/assets/images/posts/2024/07/13/96-12.png" loading="lazy" width="531" height="275" data-origin-width="531" data-origin-height="275"/></span><figcaption>Unreal Engine - BP_PlayerController</figcaption>
</figure>
</p>

<p>혹시 'BP_Player'에서 플레이어 컨트롤러를 가지고 올 때 'BP_PlayerController'로 캐스트 하지 않아서 생긴 문제인가 싶어서 테스트해 보았는데 문제가 있던 상황가 동일하게 플레이되어서 이 문제는 아닌 걸로 보인다.</p>


<h2>정리</h2>
<p>'PlayerController'에서는 전반적인 이벤트의 처리를 하도록 노드를 구성하고 'PlayerCharacter'에서는 기능만 가지고 있도록 하는 것이 문제를 줄일 수 있고 구조적으로도 정돈된 느낌을 주는 것 같다. 더 나은 구조에 대해서 판단하기 위해서는 나중에 예제를 따라 만들면서 정석적인 방법을 학습할 필요가 있을 것 같다.</p>

<p>이번에 발생한 문제의 원인은 아마도 이벤트 충돌이나 우선순위 문제라고 추측만 해본다. 추후에 정확한 원인 파악을 위해서 문제를 기록해 둔다.</p>
