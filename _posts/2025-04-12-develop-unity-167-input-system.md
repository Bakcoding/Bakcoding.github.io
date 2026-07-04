---
title: "Input System 으로 플레이어 만들기"
excerpt: "Input System 으로 플레이어 만들기"
categories:
  - Unity
permalink: /develop/unity/167-input-system/
tags:
  - "Unity"
  - "Game Development"
  - "input system"
  - "Move"
  - "Player"
  - "sprint"
toc: true
toc_sticky: true
date: 2025-04-12
last_modified_at: 2025-04-12
source_url: https://b-note.tistory.com/167
---

<h3>Player</h3>
<p>Input System을 활용해서 간단한 플레이어를 만들어 본다.</p>

<p>구현할 기능은 Move, Sprint</p>

<p>디바이스는 키보드, Invoke C Sharp Events로 작업한다.</p>

<h4>Move</h4>
<p>Input Action에서 WASD의 입력을 받아서 플레이어 이동으로 처리한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="523" data-origin-height="143"><span data-alt="Input Action - Move"><img src="/assets/images/posts/2025/04/12/167-1.png" loading="lazy" width="523" height="143" data-origin-width="523" data-origin-height="143"/></span><figcaption>Input Action - Move</figcaption>
</figure>
</p>

<p>Input Action에서 WASD키를 조합하여 Move 액션을 만든다.</p>

<p>스크립트에서 PlayerInput의 onActionTriggered 이벤트에 OnActionTriggered 함수를 리스너로 등록하고, OnActionTriggered 함수 안에서 각 액션에 대한 처리를 한다.</p>

<pre class="csharp"><code>private PlayerInput playerInput;
private Vector2 moveInput;

private void Awake()
{
	...
    playerInput = GetComponent&lt;PlayerInput&gt;();
    playerInput.onActionTriggered += OnActionTriggered;
    ...
}

...


private void OnActionTriggered(InputAction.CallbackContext context)
{
    if (context.action.name == "Move" &amp;&amp; context.performed)
    {
        OnMove(context);
    }
}

...

public void OnMove(InputAction.CallbackContext context)
{
    moveInput = context.ReadValue&lt;Vector2&gt;();
}</code></pre>

<p>WASD 키 입력에 따라서 moveInput의 값이 수시로 업데이트되고 플레이어의 움직임을 관리하는 함수에서 moveInput 값을 사용해서 처리한다.</p>

<p>확실한 입력이 있을 때 만 처리하기 위해서 performed 인 경우를 체크한다.</p>

<h4>Sprint</h4>
<p>달리기를 위한 기능으로 눌린 상태에서 더 빠르게 움직이도록 한다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="757" data-origin-height="306"><span data-alt="Input Action - Sprint"><img src="/assets/images/posts/2025/04/12/167-2.png" loading="lazy" width="757" height="306" data-origin-width="757" data-origin-height="306"/></span><figcaption>Input Action - Sprint</figcaption>
</figure>
</p>

<p>Left Shift 키와 바인딩하여 누르고 있을 때 달리고 떼면 다시 걷도록 한다. 이 입력을 위해서 Press And Release로 키 입력을 받는다.</p>

<pre class="csharp"><code>private void OnActionTriggered(InputAction.CallbackContext context)
{
	...
    
    if (context.action.name == "Sprint" &amp;&amp; context.performed)
    {
        OnSprint(context);
    }

    ...
}

public void OnSprint(InputAction.CallbackContext context)
{
    isSprint = context.ReadValue&lt;float&gt;() == 1;
    currentSpeed = isSprint ? moveSpeed * 2f : moveSpeed;
    Debug.Log("On Sprint");
}</code></pre>

<p>눌림 상태는 float 값으로 들어오며 눌리면 1 떼면 0으로 콜백이 들어온다.</p>

<p>이 값을 달리는 상태를 변경하는 플래그로 사용해서 처리한다.</p>

<p>간단하게 조작 로직을 구현해서 본다.</p>

> 용량 문제로 `Player - Move&Sprint` 애니메이션 이미지는 [원문](https://b-note.tistory.com/167)에서 확인한다.
</figure>
</p>
