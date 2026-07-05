---
title: "Input System - Player Input"
excerpt: "Input System - Player Input"
categories:
  - Unity
permalink: /develop/unity/165-input-system-player-input/
tags:
  - "Unity"
  - "Game Development"
  - "input-system"
  - "playerinput"
  - "unity"
toc: true
toc_sticky: true
date: 2025-04-11
last_modified_at: 2025-04-11
source_url: https://b-note.tistory.com/165
---

<h3>PlayerInput</h3>
<p>Input&nbsp;System은&nbsp;Input&nbsp;Actions와&nbsp;PlayerInput으로&nbsp;구성된다.&nbsp;Input&nbsp;Actions는&nbsp;입력과&nbsp;행동의&nbsp;연결을&nbsp;정의하는&nbsp;구조이고,&nbsp;PlayerInput은&nbsp;그&nbsp;정의를&nbsp;바탕으로&nbsp;실제&nbsp;입력을&nbsp;감지하고&nbsp;동작을&nbsp;실행하는&nbsp;컴포넌트다.</p>

<p>동작의 주체가 되는 Player 게임 오브젝트에 PlayerInput 컴포넌트를 추가하고, Actions 필드에 사용할 Input Actions 에셋을 지정하면 PlayerInput을 사용할 준비가 완료된다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="410" data-origin-height="255"><span data-alt="unity - PlayerInput"><img src="/assets/images/posts/2025/04/11/165-1.png" loading="lazy" width="410" height="255" data-origin-width="410" data-origin-height="255"/></span><figcaption>unity - PlayerInput</figcaption>
</figure>
</p>

<h4>Default Scheme</h4>
<p>어떤 입력 장치(키보드마우스, 게임패드 등)에 대한 입력을 처리할지 지정할 수 있는 설정이다.&nbsp;</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="242" data-origin-height="158"><span data-alt="Player Input - Scheme"><img src="/assets/images/posts/2025/04/11/165-2.png" loading="lazy" width="242" height="158" data-origin-width="242" data-origin-height="158"/></span><figcaption>Player Input - Scheme</figcaption>
</figure>
</p>

<p>기본값인 Any는 어떤 장치에서든 입력을 받을 수 있다. 특정 장치를 지정하더라도 Auto-Switch가 활성화되어 있다면, 다른 장치의 입력이 감지되었을 때 자동으로 해당 장치로 전환되어 입력을 처리한다. 반대로 Auto-Switch가 비활성화되어 있다면, 처음 감지된 장치만 계속 사용하게 된다.&nbsp;</p>

<p>예를 들어 Default Scheme을 Any로 설정하면 먼저 사용된 키보드마우스로 Control Scheme이 잡힌다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="393" data-origin-height="92"><span data-alt="PlayerInput - Keyboard&amp;amp;Mouse"><img src="/assets/images/posts/2025/04/11/165-3.png" loading="lazy" width="393" height="92" data-origin-width="393" data-origin-height="92"/></span><figcaption>PlayerInput - Keyboard&amp;Mouse</figcaption>
</figure>
</p>

<p>이 상태에서 게임패드를 연결하여 조작을 하면 Auto-Switch 덕분에 자동으로 게임패드로 입력이 감지되어 처리된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="405" data-origin-height="83"><span data-alt="PlayerInput - GamePad detection"><img src="/assets/images/posts/2025/04/11/165-4.png" loading="lazy" width="405" height="83" data-origin-width="405" data-origin-height="83"/></span><figcaption>PlayerInput - GamePad detection</figcaption>
</figure>
</p>

<h4>Default Map</h4>
<p>Default Map은 Input Action Maps 중에서 기본으로 사용할 Map을 지정하는 설정이다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="240" data-origin-height="114"><span data-alt="Input Actions - Default Map"><img src="/assets/images/posts/2025/04/11/165-5.png" loading="lazy" width="240" height="114" data-origin-width="240" data-origin-height="114"/></span><figcaption>Input Actions - Default Map</figcaption>
</figure>
</p>

<p>Input Action은 상황에 따라 다른 Map으로 전환할 수 있다.</p>
<p>예를 들어 캐릭터 조작 시에는 Player 맵을 사용하고, 메뉴를 열었을 때는 UI 맵으로 전환하여 입력을 UI 조작에만 반응하도록 만들 수 있다. 이러한 방식은 게임패드나 조이스틱처럼 여러 입력이 혼합되는 환경에서 특히 유용하다.</p>

<h4>UI Input Module</h4>
<p>UI와의 상호작용은 EventSystem에 연결된 Input System UI Input Module 컴포넌트를 통해 처리된다.</p>
<p>기본 Unity UI 시스템은 단일 입력만 처리하도록 설계되어 있지만 멀티플레이 게임(로컬)에서는 각 플레이어가 자신의 UI를 조작해야 하는 경우가 생기기 때문에 각 플레이어에게 UI 입력용 시스템도 별도로 연결해주어야 한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="412" data-origin-height="667"><span data-alt="Event System"><img src="/assets/images/posts/2025/04/11/165-6.png" loading="lazy" width="412" height="667" data-origin-width="412" data-origin-height="667"/></span><figcaption>Event System</figcaption>
</figure>
</p>

<p>PlayerInput 컴포넌트가 사용하는 Input Action Asset은 UI Input Module에도 동일하게 적용되어, 동일한 동작과 디바이스 설정으로 UI와 게임 조작을 일관되게 제어할 수 있다.</p>

<p>멀티플레이 환경에서는 MultiplayerEventSystem 컴포넌트를 사용하여 화면에 여러 UI 인스턴스를 동시에 표시하고 각 UI를 서로 다른 플레이어가 독립적으로 제어할 수 있게 만들 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="412" data-origin-height="700"><span data-alt="MultiPlayer Event System"><img src="/assets/images/posts/2025/04/11/165-7.png" loading="lazy" width="412" height="700" data-origin-width="412" data-origin-height="700"/></span><figcaption>MultiPlayer Event System</figcaption>
</figure>
</p>

<h4>Camera</h4>
<p>Camera 필드는 멀티 플레이어 상황에서, 플레이어 관리에 사용되는 PlayerInputManager 컴포넌트의 Split-Screen 기능이 활성화된 경우에 의미를 갖는다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="411" data-origin-height="431"><span data-alt="PlayerInputManager"><img src="/assets/images/posts/2025/04/11/165-8.png" loading="lazy" width="411" height="431" data-origin-width="411" data-origin-height="431"/></span><figcaption>PlayerInputManager</figcaption>
</figure>
</p>

<p>이 기능이 켜지면 각 플레이어는 자신만의 카메라를 통해 분할된 화면을 보게 되며, 이때 PlayerInput의 Camera 필드에 각 플레이어의 카메라를 연결해주어야 한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="799" data-origin-height="488"><span data-alt="Mario Kart 2P"><img src="/assets/images/posts/2025/04/11/165-9.png" loading="lazy" width="460" height="281" data-origin-width="799" data-origin-height="488"/></span><figcaption>Mario Kart 2P</figcaption>
</figure>
</p>

<p>이렇게 설정하면, UI의 입력 처리도 해당 카메라를 기준으로 이루어지므로 플레이어마다 올바른 UI 포커스 및 이벤트 처리가 가능해진다.</p>

<h4>Behavior</h4>
<p>이벤트가 발생했을 때 어떤 방식으로 처리할지 결정하는 옵션이다.</p>

<p><b>Send Messages</b></p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="385" data-origin-height="113"><span data-alt="PlayerInpt - Behavior"><img src="/assets/images/posts/2025/04/11/165-10.png" loading="lazy" width="385" height="113" data-origin-width="385" data-origin-height="113"/></span><figcaption>PlayerInpt - Behavior</figcaption>
</figure>
</p>

<p>Send Message는 Unity의 고전적인 메시지 전달 방식으로, SendMessage("함수명", 파라미터) 형태로 특정 메서드를 실행한다.</p>
<p>PlayerInput 컴포넌트는 Input Action이 발생했을 때, 해당 액션 이름을 기반으로 구성된 함수명을 자동으로 호출한다. 이 메서드는 GameObject에 연결된 MonoBehaviour 스크립트 내에 정확한 이름으로 존재해야 하며, 그렇지 않으면 호출되지 않고 무시된다.</p>
<p>예를 들어 Jump라는 액션이 정의되어 있다면, PlayerInput은 OnJump()라는 함수명을 찾아 호출한다.</p>

<p>이처럼 Input Action에서 정의된 Action 이름 앞에 On을 붙인 함수명이 호출 대상이 되며 위 이미지에서 텍스트로 사용가능한 함수명이 표시된다. 이 함수명 텍스트는 Input Actions 에셋에서 Action의 이름을 추가하거나 편집하고 Asset을 저장하면 자동으로 수정되어 보인다.</p>

<p>SendMessage 방식의 장점은 간단하고 빠르게 연결 가능하기 때문에 코드 구조가 가볍지만 메서드명이 정확히 일치해야 작동한다는 점과 동적 호출 방식이기 때문에 컴파일 타임에서 오류 체크가 불가능하며 함수의 파라미터가 InputValue만 전달되기 때문에 복합적인 처리나 Context 정보 전달, 다중 파라미터 기반 로직등의 처리가 어렵다.</p>

<pre class="csharp"><code>public void OnMove(InputValue value)
{
	moveInput = value.Get&lt;Vector2&gt;();
}</code></pre>


<p><b>Broadcast Message</b></p>
<p>Broadcast Message 방식도 Unity의 고전적인 메시지 전달 방식으로 Send Message와 동일한 형식을 따르지만, 차이점은 현재 GameObject 뿐만 아니라 모든 자식 오브젝트들에게도 메시지를 전파한다는 점이다.</p>

<p>예를 들어 계층 구조 내 여러 컴포넌트가 동일한 함수명을 가지고 있다면, 모두 호출되기 때문에 예상치 못한 중복 동작이 발생할 수 있다. 또한 자식 오브젝트가 많거나 계층이 깊을 경우, 성능 저하의 원인이 될 수 있어 주의가 필요하다.</p>

<p><b>Invoke Unity Events</b></p>
<p>이벤트 기반 정적 연결방식으로, 함수명을 신경 쓸 필요 없이 에디터에서 간편하게 메서드를 지정할 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="407" data-origin-height="177"><span data-alt="Behavior - Invoke Unity Events"><img src="/assets/images/posts/2025/04/11/165-11.png" loading="lazy" width="407" height="177" data-origin-width="407" data-origin-height="177"/></span><figcaption>Behavior - Invoke Unity Events</figcaption>
</figure>
</p>

<p>Input Actions에서 정의한 Action들은 PlayerInput 컴포넌트 내에서 자동으로 이벤트로 생성되며, 인스펙터 창에서 해당 이벤트에 호출할 메서드를 직접 할당할 수 있다. 이러한 이벤트 - 리스너 구조는 코드 간의 결합도를 낮추고, 동작을 시각적으로 구성할 수 있어 직관적이고 유지보수도 용이하다.</p>

<p><b>Invoke C Sharp Events</b></p>
<p>Invoke C# Events는 코드 기반으로 입력을 처리하는 방식으로, PlayerInput이 제공하는 onActionTriggered 이벤트에 리스너를 등록하여 모든 입력 액션을 하나의 이벤트에서 감지할 수 있다.</p>
<pre class="csharp"><code>void OnEnable()
{
    playerInput.onActionTriggered += OnActionTriggered;
}

void OnDisable()
{
    playerInput.onActionTriggered -= OnActionTriggered;
}

void OnActionTriggered(InputAction.CallbackContext context)
{
    if (context.action.name == "Jump")
    {
        Debug.Log("Jump triggered");
    }
}</code></pre>

<p>action.name을 기준으로 원하는 액션을 구분해서 처리할 수 있으며, Unity Events 방식은 인스펙터에서 함수명을 문자열로 참조하기 때문에 함수명이 바뀌면 참조가 끊길 수 있는 반면 Invoke C# Events는 코드에서 직접 리스너를 등록하기 때문에 함수명을 변경하더라도 안전하게 리팩토링이 가능하며, 유지보수에 강점을 가진다.</p>

<p><b>정리</b></p>
<p>각 Behavior 방식은 특징이 다르기 때문에 상황에 따라 적절히 선택해서 사용하는 것이 중요하며 다음과 같이 요약할 수 있다.</p>
<p>- Send Message : 간단한 구현이 필요할 때 유용</p>
<p>- Broadcast Message : 하위 오브젝트까지 포함하여 입력 처리를 해야 하는 특수한 경우에 사용</p>
<p>- Invoke Unity Events : 비프로그래머나 디자이너가 에디터에서 직관적으로 연결할 때 적합</p>
<p>- Invoke C Sharp Events : 복잡한 입력 로직을 처리할 때 사용</p>
