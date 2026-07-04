---
title: "Input System - Input Actions"
excerpt: "Input System - Input Actions"
categories:
  - Unity
permalink: /develop/unity/164-input-system-input-actions/
tags:
  - "Unity"
  - "Game Development"
  - "input-actions"
  - "InputSystem"
  - "unity"
toc: true
toc_sticky: true
date: 2025-04-10
last_modified_at: 2025-04-10
source_url: https://b-note.tistory.com/164
---

<h3>Input System</h3>
<p>2019 버전을 발표할 시점인 19년도에 새로운 Input System을 업데이트하면서 기존까지 입력 처리를 담당했던 Input Manager에 대해서 앞으로 추가 업데이트 사항은 없다고 언급을 했었다. 그 후 아직까지도 호환성은 유지한 채 사용할 수 있도록 제공하고 있지만 공식 문서에서도 legacy로 표현하며 Input System을 권장하고 있다.&nbsp;</p>

<p>Input System을 권장하는 이유는 새로운 입력 처리 방식의 장점과 Input Manager의 오래된 기술로 인한 한계에 있다.</p>

<p><b>Input System 장점</b></p>
<p>- 다양한 입력 장치를 지원하며 사용자 정의가 가능하다. 이를 통해서 다양한 플랫폼에서 일관된 입력을 처리할 수 있다.&nbsp;</p>
<p>- 비동기 입력 처리를 지원하기 때문에 입력 이벤트를 더 효율적으로 관리할 수 있어 게임 성능의 향상을 모색할 수 있다.</p>
<p>- Input System의 API는 더 직관적이어서 사용하기 쉬워 코드의 가독성을 높인다.</p>

<p><b>Input Manager 한계</b></p>
<p>- 다양한 입력 장치를 동시에 처리하는 등의 현대의 게임 개발에서 요구되는 사항을 충족하기&nbsp; 어렵다.</p>
<p>- 기본적인 입력 처리만 가능하기 때문에 복잡한 입력에 대한 요구 사항을 처리하기 부적합하다.</p>

<p>Unity 6 버전을 기준으로 진행한다.</p>

<h3>Project Settings</h3>
<p>기본 선택은 both로 되어있는데 Input System만 을 사용하기 위해서 Project Settings &gt; Player &gt; Active Input Handling에서 Input System Package를 선택한다.&nbsp;</p>

<p>어느 버전부터인지 모르겠지만 이전에 사용했던 버전에서는 Input System을 선택 시 패키지 설치가 필요했는데 현재 버전에서는 패키지가 기본적으로 설치되어 있고 InputSystem_Actions 파일이 기본 생성되어 있다.</p>

<h3>Input Actions</h3>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="701" data-origin-height="306"><span data-alt="Input System - Input Actions"><img src="/assets/images/posts/2025/04/10/164-1.png" loading="lazy" width="701" height="306" data-origin-width="701" data-origin-height="306"/></span><figcaption>Input System - Input Actions</figcaption>
</figure>
</p>
<p><br />Input Actions Asset 파일을 열면 입력에 대한 처리를 맵핑과 세부 설정을 할 수 있는 Input Actions Editor 창이 열린다.</p>

<h4>Action Maps</h4>
<p>입력을 그룹으로 묶어 관리할 수 있는 단위이다. 기본적으로 Player, UI 맵이 제공된다.</p>
<p>각 Action Map은 관련된 여러 입력 동작인 Action들의 설정 묶음으로 하나의 Input Actions Asset에서 활성화되는 Map은 하나만 처리되므로 플레이어의 상태에 따라 Map을 전환하여 상황에 맞는 입력만 처리하도록 구성할 수 있어 게임 내 다양한 상태에 따라 입력 처리를 명확하게 구분하고 유지 보수 및 확장도 간편하다.</p>

<h4>Actions</h4>
<p>사용자 입력에 반응하여 수행될 동작을 정의하는 요소이다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="459" data-origin-height="256"><span data-alt="Input Actions - Actions"><img src="/assets/images/posts/2025/04/10/164-2.png" loading="lazy" width="459" height="256" data-origin-width="459" data-origin-height="256"/></span><figcaption>Input Actions - Actions</figcaption>
</figure>
</p>

<p>이동, 점프, 공격 등과 같이 플레이어의 입력 행동 단위이다. 각 Action은 하나 이상의 입력 Binding과 연결되고 키보드, 마우스, 게임 패드 등 다양한 장치의 입력을 조합하여 정의할 수 있다.</p>

<p>Action은 하나의 입력 동작에 대한 정의이며 Binding은 Action을 어떤 입력 장치에 매핑할지 설정한다.</p>

<p>각각 Properties에서 세부적인 옵션 설정을 할 수 있다.</p>

<h4>Action Properties</h4>
<p>각 Action의 동작 방식과 입력값의 처리 형태를 세부적으로 설정할 수 있는 항목이다.</p>
<p>입력의 종류, 처리 방식, 반환 값의 형태 등을 정의하여 다양한 입력 상황에 대응할 수 있도록 옵션이 제공된다.</p>
<p><br />각 옵션의 기본 설정은 Project Settings &gt; Input System &gt; Settings의 값을 따르며 개별 값을 조정하려면 Default 플래그를 끄고 직접 수정하거나 Settings Asset을 생성하여 값을 커스텀한다.</p>

<p>Action Type</p>
<p style="color: #333333; text-align: start;">입력 시스템의 동작 방식을 정의하는 요소로 각 타입마다 입력 이벤트를 처리하는 방식에 따라 다르게 동작한다.</p>
<p style="color: #333333; text-align: start;">Value, Button, Pass Through 세 가지 방식이 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="276" data-origin-height="141"><span data-alt="Action Properties - Action Type"><img src="/assets/images/posts/2025/04/10/164-3.png" loading="lazy" width="276" height="141" data-origin-width="276" data-origin-height="141"/></span><figcaption>Action Properties - Action Type</figcaption>
</figure>
</p>

<p><b>Value</b></p>
<p>지속적인 입력 값을 반환한다. 입력이 활성화된 동안 현재 상태 값을 계속해서 업데이트한다. 주로 조이스틱의 위치나 슬러이더처럼 지속적으로 변화하는 값을 처리할 때 유용하다.</p>

<p><b>Button</b></p>
<p>버튼의 누름 상태를 감지한다. 점프, 공격, 상호작용처럼 단일 이벤트 트리거에 적합하다.</p>

<p><b>PassThrough</b></p>
<p>입력을 필터링 없이 그대로 전달한다. 가공되지 않고 호출 대상에 직접 전달되며 주로 복잡한 입력 로직, 멀티 컨트롤 입력, UI 입력 등에 활용한다.</p>

<p>Control Type</p>
<p>Action Type에 따라 달라지는데 Value인 경우 다양한 값 형식으로 가공해서 받을 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="260" data-origin-height="398"><span data-alt="Value - Control Type"><img src="/assets/images/posts/2025/04/10/164-4.png" loading="lazy" width="260" height="398" data-origin-width="260" data-origin-height="398"/></span><figcaption>Value - Control Type</figcaption>
</figure>
</p>

<table style="border-collapse: collapse; width: 100%; height: 299px;" border="1">
<tbody>
<tr style="height: 21px;">
<td style="width: 11.5117%; height: 21px;">Type</td>
<td style="width: 38.1396%; height: 21px;">설명</td>
<td style="width: 12.7905%; height: 21px;">반환 타입</td>
<td style="width: 37.5583%; height: 21px;">예</td>
</tr>
<tr style="height: 21px;">
<td style="width: 11.5117%; height: 21px;">Axis</td>
<td style="width: 38.1396%; height: 21px;">단일&nbsp;축(1차원)의&nbsp;연속적인&nbsp;값&nbsp;(-1&nbsp;~&nbsp;1)</td>
<td style="width: 12.7905%; height: 21px;">float</td>
<td style="width: 37.5583%; height: 21px;">조이스틱 축, 키보드 이동, 마우스 휠 등</td>
</tr>
<tr style="height: 21px;">
<td style="width: 11.5117%; height: 21px;">Analog</td>
<td style="width: 38.1396%; height: 21px;">0.0&nbsp;~&nbsp;1.0&nbsp;범위의&nbsp;연속&nbsp;아날로그&nbsp;값</td>
<td style="width: 12.7905%; height: 21px;">float</td>
<td style="width: 37.5583%; height: 21px;">게임패드의 트리거, 슬라이더 등</td>
</tr>
<tr style="height: 21px;">
<td style="width: 11.5117%; height: 21px;">Integer</td>
<td style="width: 38.1396%; height: 21px;">정수&nbsp;값</td>
<td style="width: 12.7905%; height: 21px;">int</td>
<td style="width: 37.5583%; height: 21px;">타임라인, 메뉴 인덱스 등</td>
</tr>
<tr style="height: 21px;">
<td style="width: 11.5117%; height: 21px;">Digital</td>
<td style="width: 38.1396%; height: 21px;">이진&nbsp;값&nbsp;(0&nbsp;또는&nbsp;1,&nbsp;true/false)</td>
<td style="width: 12.7905%; height: 21px;">float or bool</td>
<td style="width: 37.5583%; height: 21px;">버튼 입력, 온/오프 스위치 등</td>
</tr>
<tr style="height: 21px;">
<td style="width: 11.5117%; height: 21px;">Double</td>
<td style="width: 38.1396%; height: 21px;">높은 정밀도 실수</td>
<td style="width: 12.7905%; height: 21px;">double</td>
<td style="width: 37.5583%; height: 21px;">정밀 제어, 시뮬레이션 등</td>
</tr>
<tr style="height: 21px;">
<td style="width: 11.5117%; height: 21px;">Vector2</td>
<td style="width: 38.1396%; height: 21px;">2D&nbsp;벡터</td>
<td style="width: 12.7905%; height: 21px;">Vector2</td>
<td style="width: 37.5583%; height: 21px;">2D 이동, 마우스/터치 위치, 텍스처 좌표 등</td>
</tr>
<tr style="height: 21px;">
<td style="width: 11.5117%; height: 21px;">Vector3</td>
<td style="width: 38.1396%; height: 21px;">3D&nbsp;벡터</td>
<td style="width: 12.7905%; height: 21px;">Vector3</td>
<td style="width: 37.5583%; height: 21px;">3D 위치, 방향 등</td>
</tr>
<tr style="height: 17px;">
<td style="width: 11.5117%; height: 17px;">Delta</td>
<td style="width: 38.1396%; height: 17px;">변화량을 나타내는 값(차이값)</td>
<td style="width: 12.7905%; height: 17px;">Vector2</td>
<td style="width: 37.5583%; height: 17px;">마우스 드래그, 터치 슬라이드 변화량</td>
</tr>
<tr style="height: 21px;">
<td style="width: 11.5117%; height: 21px;">Quaternion</td>
<td style="width: 38.1396%; height: 21px;">3D 회전을 나타내는 사원수</td>
<td style="width: 12.7905%; height: 21px;">Quaternion</td>
<td style="width: 37.5583%; height: 21px;">컨트롤러 회전, 장치 방향</td>
</tr>
<tr style="height: 21px;">
<td style="width: 11.5117%; height: 21px;">Stick</td>
<td style="width: 38.1396%; height: 21px;">아날로그 스틱 입력</td>
<td style="width: 12.7905%; height: 21px;">StickControl</td>
<td style="width: 37.5583%; height: 21px;">게임 패드의 조이스틱</td>
</tr>
<tr style="height: 17px;">
<td style="width: 11.5117%; height: 17px;">Dpad</td>
<td style="width: 38.1396%; height: 17px;">4방향 디지털 입력</td>
<td style="width: 12.7905%; height: 17px;">DpadControl</td>
<td style="width: 37.5583%; height: 17px;">게임 패드의 십자키</td>
</tr>
<tr style="height: 17px;">
<td style="width: 11.5117%; height: 17px;">Touch</td>
<td style="width: 38.1396%; height: 17px;">단일 터치 정보</td>
<td style="width: 12.7905%; height: 17px;">TouchControl</td>
<td style="width: 37.5583%; height: 17px;">터치 스크린</td>
</tr>
<tr style="height: 17px;">
<td style="width: 11.5117%; height: 17px;">Pose</td>
<td style="width: 38.1396%; height: 17px;">위치 + 회전 정보</td>
<td style="width: 12.7905%; height: 17px;">PoseControl</td>
<td style="width: 37.5583%; height: 17px;">VR, AR 디바이스</td>
</tr>
<tr style="height: 21px;">
<td style="width: 11.5117%; height: 21px;">Eyes</td>
<td style="width: 38.1396%; height: 21px;">시선 추적 데이터</td>
<td style="width: 12.7905%; height: 21px;">EyesControl</td>
<td style="width: 37.5583%; height: 21px;"><span style="color: #333333; text-align: start;">VR HMD, </span>아이 트래킹 장비</td>
</tr>
</tbody>
</table>

<p>PlayerInput의 Behavior 방식에 따라 다르지만 Stick, Dpad, Touch, Pose, Eyes와 같은 타입들은 내부적으로 해당 클래스 타입(StickControl, DpadControl 등)으로 처리되며, Callback 방식에서 해당 클래스를 직접 참조하여 세부 데이터를 추출할 수 있다.</p>

<p>Interactions</p>
<p>&nbsp;Action의 세 가지 이벤트 상태(started, performed, canceled)에 도달하기 위한 조건을 세부적으로 정의하는 항목이다.</p>

<p>Action 상태</p>
<p>- started : 입력의 시작점</p>
<p>- performed : 입력이 성공적으로 완료된 시점</p>
<p>- canceled : 입력이 도중에 중단 또는 실패한 경우</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="361" data-origin-height="124"><span data-alt="Action Properties - Interactions"><img src="/assets/images/posts/2025/04/10/164-5.png" loading="lazy" width="361" height="124" data-origin-width="361" data-origin-height="124"/></span><figcaption>Action Properties - Interactions</figcaption>
</figure>
</p>

<p><b>Hold</b></p>
<p>일정 시간 동안 누르고 있을 때만 유효한 입력으로 인식한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="421" data-origin-height="180"><span data-alt="Interactions - Hold"><img src="/assets/images/posts/2025/04/10/164-6.png" loading="lazy" width="421" height="180" data-origin-width="421" data-origin-height="180"/></span><figcaption>Interactions - Hold</figcaption>
</figure>
</p>

<p>Press Point : 입력 강도를 판정하는 것으로 어느 정도 눌렸을 때 Press로 보는지 판단하는 기준으로 트리거나 스틱 같이 값 변경이 미세한 경우에서 중요하게 판단된다.</p>

<p>Hold Time : Press Point를 넘은 후 이 시간만큼 입력이 유지됐을 때 performed 상태가 되고 그전에 입력이 중단되면 canceled 상태가 된다.</p>

<p><b>Multi Tap</b></p>
<p>일정 시간 안에 특정 횟수만큼의 입력이 발생했을 때 작동한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="402" data-origin-height="235"><span data-alt="Interactions - Multi Tap"><img src="/assets/images/posts/2025/04/10/164-7.png" loading="lazy" width="402" height="235" data-origin-width="402" data-origin-height="235"/></span><figcaption>Interactions - Multi Tap</figcaption>
</figure>
</p>

<p>Tap Count : 몇 번을 입력해야 performed 되는지</p>
<p>Max Tap Spacing : 탭과 탭 사이 최대 허용 시간</p>
<p>Max Tap Duration : 각 탭이 유지될 수 있는 최대 시간</p>
<p>Press Point : 유효한 입력으로 판단할 최소 세기</p>

<p>입력 사이 간격이 Max Tap Spacing을 넘거나, 각 탭 유지 시간이 Max Tap Duration을 넘기면 canceled</p>

<p><b>Press</b></p>
<p>버튼을 누르거나 뗄 때 발생하는 단순 입력을 세밀하게 제어할 때 사용한다.&nbsp;</p>
<p>단순 버튼의 입력에 대한 처리라면 Action Type의 Button으로 설정하면 되고 세부 제어가 필요한 경우 Press Interaction을 사용한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="408" data-origin-height="159"><span data-alt="Interactions - Press"><img src="/assets/images/posts/2025/04/10/164-8.png" loading="lazy" width="408" height="159" data-origin-width="408" data-origin-height="159"/></span><figcaption>Interactions - Press</figcaption>
</figure>
</p>

<p>Trigger Behavior :&nbsp;Press Only, Release Only, Press and Release 세 가지 상태가 있으며 각 상태는 버튼을 눌리는 순간, 떼는 순간, 누를 때 started 뗄 때 performed로 처리한다.</p>

<p><b>Slow Tap</b></p>
<p>버튼을 누른 뒤 일정 시간 후에 뗄 때 performed 상태가 된다.</p>
<p>Min Tap Duration : 탭이 performed 되기 위한 최소 시간</p>

<p>Hold와 비슷하지만 hold는 시간 조건이 됐을 때 performed, slow tap은 시간을 채우고 뗄 때 performed 되는 차이가 있다. 하지만 겹치는 동작이 발생할 수 있기 때문에 동일한 Action에서 Hold와 Slow Tap 두 인터랙션을 동시에 사용할 때는 조건을 명확하게 하여 구분할 필요가 있다.</p>

<p><b>Tap<br /></b></p>
<p>버튼을 빠르게 누르고 떼는 동작을 인식한다.</p>
<p>Max Tap Duration : 입력이 Press Point 이상으로 감지된 이후에 started 상태가 되고 Max Tap Duration 안에 입력을 뗄 때 performed 된다.</p>

<p>Processors</p>
<p>입력값을 처리하여 최종적으로 Action에 전달되는 값을 조정하는 기능이다.</p>
<p>컨트롤러의 조이스틱, 마우스, 트리거 등 다양한 입력 장치에서 입력된 원시 값을 자동으로 보정, 변환, 필터링할 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="602" data-origin-height="279"><span data-alt="Action Properties - Processors"><img src="/assets/images/posts/2025/04/10/164-9.png" loading="lazy" width="602" height="279" data-origin-width="602" data-origin-height="279"/></span><figcaption>Action Properties - Processors</figcaption>
</figure>
</p>

<p><b>Axis Deadzone, Stick Deadzone</b></p>
<p>Axis Deadzone은 축 단위(float)의 선형적인 입력값에 대해 deadzone을 적용한다.</p>
<p>입력값이 min 보다 작으면 0, max 보다 크면 1, 그 사이의 값은 0 ~ 1 사이로 정규화된 값</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="405" data-origin-height="140"><span data-alt="Processors - Deadzone"><img src="/assets/images/posts/2025/04/10/164-10.png" loading="lazy" width="405" height="140" data-origin-width="405" data-origin-height="140"/></span><figcaption>Processors - Deadzone</figcaption>
</figure>
</p>

<p>주로 게임패드의 트리거와 같이 선형적인 입력에서 의도치 않은 작은 입력을 무시하거나 거의 끝까지 입력된 경우 1로 보정한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="420" data-origin-height="460"><span data-alt="Example - Trigger Axis Deadzone"><img src="/assets/images/posts/2025/04/10/164-11.png" loading="lazy" width="243" height="266" data-origin-width="420" data-origin-height="460"/></span><figcaption>Example - Trigger Axis Deadzone</figcaption>
</figure>
</p>

<p>Stick Deadzone은 2D Vector 입력에 대해서 방사형 범위의 deadzone을 적용한다.</p>
<p>입력된 벡터의 길이(magnitude)가 min 보다 작으면 0, max 보다 크면 1, 그 사이값은 정규화하여 보정한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="454" data-origin-height="156"><span data-alt="Processor - Stick Deadzone"><img src="/assets/images/posts/2025/04/10/164-12.png" loading="lazy" width="454" height="156" data-origin-width="454" data-origin-height="156"/></span><figcaption>Processor - Stick Deadzone</figcaption>
</figure>
</p>

<p>게임패드의 아날로그 스틱 입력에서 중앙 근처의 미세한 입력을 무시하고 가장자리에 가까우면 1, 범위 내의 값은 정규화하여 보정한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="599" data-origin-height="547"><span data-alt="Example - Stick Deadzone"><img src="/assets/images/posts/2025/04/10/164-13.png" loading="lazy" width="277" height="253" data-origin-width="599" data-origin-height="547"/></span><figcaption>Example - Stick Deadzone</figcaption>
</figure>
</p>


<p><b>Clamp</b></p>
<p>입력값이 특정 범위를 벗어나지 않도록 제한해 주는 기능이다. 즉, 최소와 최댓값을 지정하고 그 범위를 벗어나는 값은 경곗값으로 보정한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="409" data-origin-height="69"><span data-alt="Processors - Clamp"><img src="/assets/images/posts/2025/04/10/164-14.png" loading="lazy" width="409" height="69" data-origin-width="409" data-origin-height="69"/></span><figcaption>Processors - Clamp</figcaption>
</figure>
</p>

<p>Min : 입력값의 최솟값</p>
<p>Max : 입력값의 최댓값</p>

<p><b>Invert, Invert Vector2, Invert Vector3</b></p>
<p>입력값의 부호를 반전시킨다.&nbsp;</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="444" data-origin-height="167"><span data-alt="Processors - Invert"><img src="/assets/images/posts/2025/04/10/164-15.png" loading="lazy" width="444" height="167" data-origin-width="444" data-origin-height="167"/></span><figcaption>Processors - Invert</figcaption>
</figure>
</p>

<p>단일 수치(float) 뿐 아니라 Vector2, Vector3 타입의 입력에도 사용 가능하며, 각 축별로 플래그로 개별 설정할 수 있다.</p>

<p><b>Normalize, Normalize Vector2, Normalize Vector3</b></p>
<p>입력값을 -1 ~ 1 사이로 정규화한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="454" data-origin-height="134"><span data-alt="Processors - Normalize"><img src="/assets/images/posts/2025/04/10/164-16.png" loading="lazy" width="454" height="134" data-origin-width="454" data-origin-height="134"/></span><figcaption>Processors - Normalize</figcaption>
</figure>
</p>

<p>벡터의 크기는 무시하고 방향성만 필요한 경우에 사용한다.</p>

<p><b>Scale, Scale Vector2, Scale Vector3</b></p>
<p>입력 값에 곱셈 계수 Factor를 적용한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="455" data-origin-height="199"><span data-alt="Processors - Scale"><img src="/assets/images/posts/2025/04/10/164-17.png" loading="lazy" width="455" height="199" data-origin-width="455" data-origin-height="199"/></span><figcaption>Processors - Scale</figcaption>
</figure>
</p>

<p>마우스 민감도 등 감도 조정에 사용할 수 있다.</p>

<h4 style="color: #000000; text-align: start;">Binding Properties</h4>
<p>Binding</p>
<p>단일 입력 바인딩</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="878" data-origin-height="210"><span data-alt="Binding Properties - Binding"><img src="/assets/images/posts/2025/04/10/164-18.png" loading="lazy" width="878" height="210" data-origin-width="878" data-origin-height="210"/></span><figcaption>Binding Properties - Binding</figcaption>
</figure>
</p>

<p><b>Path</b></p>
<p>이 Binding이 참조하는 입력 장치와 입력 경로를 지정하며 기본 입력 연결 포인트로, 해당 Action이 어떤 입력에서 데이터를 받을지 결정한다.</p>

<p>Show Drived Bdings : 입력 장치마다 자동으로 파생되는 바인딩 목록을 확인할 수 있다.</p>

<p><b>Use in control scheme</b></p>
<p>특정 Control Scheme에 이 Binding을 포함할지 여부를 정한다.</p>
<p>예를 들어서 Keyboard&amp;Mouse, Gamepad, Touch 등으로 나누어진 스킴에서 이 바인딩이 어떤 스킴에서 사용되는지 지정한다.</p>

<p>Composite</p>
<p>복합 입력 바인딩</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="886" data-origin-height="184"><span data-alt="Binding Properties - Composite Binding"><img src="/assets/images/posts/2025/04/10/164-19.png" loading="lazy" width="886" height="184" data-origin-width="886" data-origin-height="184"/></span><figcaption>Binding Properties - Composite Binding</figcaption>
</figure>
</p>

<p>여러 입력 값을 조합해서 하나의 논리적 입력으로 만들 때 사용한다.</p>
<p>대표적으로 WASD 나 방향키 조합으로 Vector2 이동을 구현하는 것이 있다.</p>

<p><b>Composite Type</b></p>
<p>어떤 형태의 입력 조합인지 지정한다.</p>

<p><b><i>1D Axis</i>&nbsp;</b></p>
<p>두 개의 입력을 받아서 -1 ~ 1 사이의 float 값으로 반환한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="233" data-origin-height="66"><span data-alt="1D Axis"><img src="/assets/images/posts/2025/04/10/164-20.png" loading="lazy" width="233" height="66" data-origin-width="233" data-origin-height="66"/></span><figcaption>1D Axis</figcaption>
</figure>
</p>
<p>Negative 입력 -1, Positive 입력 +1 두 입력이 동시에 있다면 Which Side Wins에 따라 결과가 달라진다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="469" data-origin-height="131"><span data-alt="Composite - 1D Axis"><img src="/assets/images/posts/2025/04/10/164-21.png" loading="lazy" width="469" height="131" data-origin-width="469" data-origin-height="131"/></span><figcaption>Composite - 1D Axis</figcaption>
</figure>
</p>
<p>Neither : 두 입력이 상쇄되어 0</p>
<p>Positive : Positive 입력 우선, +1 반환</p>
<p>Negative : Negative 입력 우선, -1 반환</p>

<p><b><i>2D Vector</i></b></p>
<p><span style="color: #333333; text-align: start;">네 개의 입력을 받아 Vector2(x, y) 값으로 결합하여 반환</span></p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="252" data-origin-height="107"><span data-alt="Composite - 2D Vector"><img src="/assets/images/posts/2025/04/10/164-22.png" loading="lazy" width="252" height="107" data-origin-width="252" data-origin-height="107"/></span><figcaption>Composite - 2D Vector</figcaption>
</figure>
</p>
<p>Up : +y</p>
<p>Down : -y</p>
<p>Left : -x</p>
<p>Right : +x</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="467" data-origin-height="134"><span data-alt="2D Vector - Mode"><img src="/assets/images/posts/2025/04/10/164-23.png" loading="lazy" width="467" height="134" data-origin-width="467" data-origin-height="134"/></span><figcaption>2D Vector - Mode</figcaption>
</figure>
</p>

<p>Analog : 아날로그 입력 값을 그대로 사용</p>
<p>Digital Normalized : 디지털 입력의 정규화 값</p>
<p>Digital : 입력이 있는 방향에 대해 -1/0/1의 벡터 구성</p>

<p><b><i>3D Vector</i></b></p>
<p>여섯 개의 입력을 받아 Vector3(x, y, z) 값으로 결합</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="393" data-origin-height="139"><span data-alt="Composite - 3D Vector"><img src="/assets/images/posts/2025/04/10/164-24.png" loading="lazy" width="393" height="139" data-origin-width="393" data-origin-height="139"/></span><figcaption>Composite - 3D Vector</figcaption>
</figure>
</p>
<p>2D Vector에서&nbsp;</p>
<p>Forward : +z</p>
<p>Backward : -z</p>
<p>추가</p>

<p>모드는 동일하다.</p>

<p><b><i>Button With One/Two Modifiers</i></b></p>
<p>하나 또는 두 개의 Modifier 키와 Button의 조합이다.</p>
<p>Modifier의 입력이 있으며 Button이 눌려야 Action이 발생한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="245" data-origin-height="83"><span data-alt="Composite - Button With Two Modifiers"><img src="/assets/images/posts/2025/04/10/164-25.png" loading="lazy" width="245" height="83" data-origin-width="245" data-origin-height="83"/></span><figcaption>Composite - Button With Two Modifiers</figcaption>
</figure>
</p>

<p>일반적으로 shift, ctrl, alt 등의 키를 modifier 키지만 일반키를 Modifier로 사용할 수 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="472" data-origin-height="70"><span data-alt="Button With Two Modifiers"><img src="/assets/images/posts/2025/04/10/164-26.png" loading="lazy" width="472" height="70" data-origin-width="472" data-origin-height="70"/></span><figcaption>Button With Two Modifiers</figcaption>
</figure>
</p>

<p>Override Modifiers Need To Be Pressed First : Modifier 키가 먼저 눌려야 Action이 발동되는지 결정하는 옵션</p>
<p>활성화 시 Modifier 키들이 먼저 입력된 상태에서 Button이 입력되어야 동작 비활성화 시 순서 상관없이 모두 눌려지면 동작</p>

<p><i>One/Two Modifiers</i></p>
<p>하나 또는 두 개의 Modifier 키의 조합이다.</p>
<p>Binding이 있지만 이 키의 입력은 상관없이 Modifier의 입력만으로 판단한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="397" data-origin-height="95"><span data-alt="Composite - Two Modifiers"><img src="/assets/images/posts/2025/04/10/164-27.png" loading="lazy" width="397" height="95" data-origin-width="397" data-origin-height="95"/></span><figcaption>Composite - Two Modifiers</figcaption>
</figure>
</p>

<p>Button의 입력이 중요한 Button With ~ Modifier와 달리 Modifier의 입력만으로 동작의 조건이 충족된다.</p>
<p>Binding은 Modifier 입력을 기반으로 추가 입력을 받을 수 있는 여지를 만들어 주는 역할을 한다.</p>
