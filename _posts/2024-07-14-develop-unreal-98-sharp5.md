---
title: "다짜고짜 만들어 보기 #5 - 플레이어 공격"
excerpt: "다짜고짜 만들어 보기 #5 - 플레이어 공격"
categories:
  - Unreal
permalink: /develop/unreal/98-sharp5/
tags:
  - "Unreal"
  - "Game Development"
  - "Fire"
  - "settimerbyevent"
  - "Unreal Engine"
  - "다짜고짜"
  - "발사"
  - "언리얼 엔진"
toc: true
toc_sticky: true
date: 2024-07-14
last_modified_at: 2024-07-14
source_url: https://b-note.tistory.com/98
---

<h2>무기 생성</h2>
<p>무기는 언리얼엔진의 1인칭 슈팅 게임 샘플에서 에셋을 가져다 사용했다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="614" data-origin-height="370"><span data-alt="Unreal Engine - Gun"><img src="/assets/images/posts/2024/07/14/98-1.png" loading="lazy" width="431" height="260" data-origin-width="614" data-origin-height="370"/></span><figcaption>Unreal Engine - Gun</figcaption>
</figure>
</p>

<p>플레이 시 캐릭터의 손에 위치하게 생성하도록 한다.</p>

<p>총에 대한 기능을 구현하고 참조하는 데 사용하기 위해서 BP_Gun 클래스를 만든다.</p>

<p>BP_Gun은 기본적인 클래스인 Actor를 상속하여 만들고 메시를 넣기 위해서 SkeletalMesh 컴포넌트를 추가한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="285" data-origin-height="113"><span data-alt="Unreal Engine - BP_Gun"><img src="/assets/images/posts/2024/07/14/98-2.png" loading="lazy" width="285" height="113" data-origin-width="285" data-origin-height="113"/></span><figcaption>Unreal Engine - BP_Gun</figcaption>
</figure>
</p>

<p>추가한 SkeletalMesh 컴포넌트에 무기 메시를 추가한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="368" data-origin-height="193"><span data-alt="Unreal Engine - Add Mesh"><img src="/assets/images/posts/2024/07/14/98-3.png" loading="lazy" width="368" height="193" data-origin-width="368" data-origin-height="193"/></span><figcaption>Unreal Engine - Add Mesh</figcaption>
</figure>
</p>

<h2>무기 장착</h2>
<p>만들어 놓은 BP_Gun을 사용해서 게임이 시작될 때 플레이어의 손 위치에 생성되도록 한다.</p>

<p>그렇게 하기 위해서 먼저 플레이어 캐릭터로 사용하고 있는 Skeletal Mesh 파일을 더블 클릭하여 열어준다.</p>

<p>Skeletaon Tree 창에서 적당한 위치에 무기를 장착할 위치로 사용할 소켓을 추가한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="452" data-origin-height="168"><span data-alt="Unreal Engine - Skeleton Tree"><img src="/assets/images/posts/2024/07/14/98-4.png" loading="lazy" width="452" height="168" data-origin-width="452" data-origin-height="168"/></span><figcaption>Unreal Engine - Skeleton Tree</figcaption>
</figure>
<figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="422" data-origin-height="354"><span data-alt="Unreal Engine - Weapon Socket"><img src="/assets/images/posts/2024/07/14/98-5.png" loading="lazy" width="422" height="354" data-origin-width="422" data-origin-height="354"/></span><figcaption>Unreal Engine - Weapon Socket</figcaption>
</figure>
</p>

<p>이제 BP_Player 파일을 열고 무기를 생성하는 함수를 추가한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1063" data-origin-height="400"><span data-alt="Unreal Engine - Equip Weapon"><img src="/assets/images/posts/2024/07/14/98-6.png" loading="lazy" width="1063" height="400" data-origin-width="1063" data-origin-height="400"/></span><figcaption>Unreal Engine - Equip Weapon</figcaption>
</figure>
</p>

<p>Spawn Actor from class는 특정 클래스를 선택하여 생성할 수 있다. 여기서 드롭다운을 열고 생성하려는 BP Gun을 선택한다.</p>

<p>Attach Actor to Component는 액터의 위치를 특정할 수 있다. 여기서 위에서 플레이어 캐릭터의 Skeleton Tree에 추가한 소켓에 위치하도록 설정한다.</p>

<p>그리고 Event Graph로 돌아가 BeginPlay에서 Equip Weapon을 호출한다.</p>

<h2>탄환 추가</h2>
<p>Actor를 상속한 BP_Bullet을 생성한다.</p>

<p>BP_Bullet에 Static Mesh 컴포넌트를 추가하여 탄환으로 사용할 적당한 메시를 추가한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="229" data-origin-height="230"><span data-alt="Unreal Engine - BP Bullet"><img src="/assets/images/posts/2024/07/14/98-7.png" loading="lazy" width="229" height="230" data-origin-width="229" data-origin-height="230"/></span><figcaption>Unreal Engine - BP Bullet</figcaption>
</figure>
</p>

<p>탄환의 기능을 담당할 Projectile Movement 컴포넌트를 추가하여 탄환의 동작을 세팅한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="369" data-origin-height="191"><span data-alt="Unreal Engine - Projectile"><img src="/assets/images/posts/2024/07/14/98-8.png" loading="lazy" width="369" height="191" data-origin-width="369" data-origin-height="191"/></span><figcaption>Unreal Engine - Projectile</figcaption>
</figure>
</p>

<p>속도는 발사하는 기능까지 구현한 이후에 테스트를 하면서 적당한 속도를 세팅하기로 하고 Projectile Gravity Scale의 값은 0으로 설정하여 중력의 영향을 받지 않고 직선방향으로 날아가도록 한다.</p>

<h2>탄환 발사</h2>
<p>BP_Gun에 Fire 함수를 추가하여 탄환을 발사하는 기능을 구현한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="991" data-origin-height="353"><span data-alt="Unreal Engine - BP Gun Fire"><img src="/assets/images/posts/2024/07/14/98-9.png" loading="lazy" width="991" height="353" data-origin-width="991" data-origin-height="353"/></span><figcaption>Unreal Engine - BP Gun Fire</figcaption>
</figure>
</p>

<p>Spawn Actor from class를 사용해서 BP_Bullet을 생성하고 탄환이 생성될 위치는 총의 SkeletalMesh에서 총구의 위치에 소켓을 만들고 Spawn Transform의 위치로 사용한다.</p>

<p>탄환의 발사를 위해서 새로운 Input Action과 맵핑을 추가한다.</p>

<p>IA_Fire, 마우스 좌클릭으로 맵핑한다.&nbsp;</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1035" data-origin-height="162"><span data-alt="Unreal Engine - IA_Fire"><img src="/assets/images/posts/2024/07/14/98-10.png" loading="lazy" width="1035" height="162" data-origin-width="1035" data-origin-height="162"/></span><figcaption>Unreal Engine - IA_Fire</figcaption>
</figure>
</p>


<p>Down으로 트리거를 세팅하여 누른 상태에서 인풋이 리턴되도록 하고 밸류는 bool타입으로 한다.</p>

<h2>BP_Gun 수정</h2>
<p>발사 속도를 설정하기 위해서 BP_Gun을 수정한다.</p>

<p>발사 속도 FireRate(float), 시간을 확인하기 위한 Timer(float), 발사 가능 여부를 확인하기 위한 CanFire(Boolean) 변수를 추가한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="786" data-origin-height="322"><span data-alt="Unreal Engine - Check FireRate"><img src="/assets/images/posts/2024/07/14/98-11.png" loading="lazy" width="786" height="322" data-origin-width="786" data-origin-height="322"/></span><figcaption>Unreal Engine - Check FireRate</figcaption>
</figure>
</p>

<p>FireRate는 0.5로 설정하고</p>
<p>매프레임 시간을 체크하여 발사를 했다면 FireRate만큼 대기 후 CanFire가 되도록 만든다.</p>

<p>그리고 CanFire를 확인하여 발사되도록 Fire함수를 수정한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="887" data-origin-height="298"><span data-alt="Unreal Engine - Fire Function"><img src="/assets/images/posts/2024/07/14/98-12.png" loading="lazy" width="887" height="298" data-origin-width="887" data-origin-height="298"/></span><figcaption>Unreal Engine - Fire Function</figcaption>
</figure>
</p>

<p>Fire 함수 호출 시 CanFire를 확인하고 True일 때만 발사가 되도록 한다.</p>

<p>발사가 진행되고 나면 CanFire를 False로 만든다.</p>

> 용량 문제로 `Unreal Engine - Test Play` 애니메이션 이미지는 [원문](https://b-note.tistory.com/98)에서 확인한다.
</figure>
</p>

<p>좌클릭을 누르고 있는동안 Fire가 호출되고 이때 CanFire를 체크하고 FireRate 간격으로 탄환이 발사된다.</p>

<h2>이벤트 그래프 수정</h2>
<p>Event Tick에서 CanFire를 체크하는 과정을 단순화할 필요가 있어 보인다.</p>

<p>찾아보니 SetTimerbyEvent라는 함수가 있어서 이걸 사용하기로 한다.</p>

<p>SetTimer by Event는 호출된 이후 Time 파라미터만큼 대기한 후 Event를 실행시킨다.</p>

<p>BP_Gun의 Event Graph로 이동한다.</p>

<p>CanFire를 True로 바꾸어 주는 Custom Event를 생성한다.</p>

<p>Event Graph &gt; Add Custom Event &gt; ResetCanFire &gt; SetCanFire = true</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="472" data-origin-height="179"><span data-alt="Unreal Engine - Custom Event"><img src="/assets/images/posts/2024/07/14/98-14.png" loading="lazy" width="472" height="179" data-origin-width="472" data-origin-height="179"/></span><figcaption>Unreal Engine - Custom Event</figcaption>
</figure>
</p>

<p>Fire 함수로 이동해서 SetCanFire = false 뒤에 SetTimerbyEvent 노드를 추가한다.</p>

<p>Event를 끌어서 Create Event 노드를 만들고 실행시킬 ResetCanFireEvent를 선택한다.</p>

<p>Time 파라미터는 GetFireRate를 가져와 연결해 준다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="841" data-origin-height="316"><span data-alt="Unreal Engine - SetTimerbyEvent"><img src="/assets/images/posts/2024/07/14/98-15.png" loading="lazy" width="841" height="316" data-origin-width="841" data-origin-height="316"/></span><figcaption>Unreal Engine - SetTimerbyEvent</figcaption>
</figure>
</p>

<p>플레이했을 때 문제없이 동작하는 걸 확인했다.</p>

<p>제공되는 함수를 잘 파악하고 있으면 동일한 기능을 더 간단하면서 효율적으로 구현할 수 있을 것 같다.</p>
