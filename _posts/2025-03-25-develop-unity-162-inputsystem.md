---
title: "InputSystem 기본 사용법"
excerpt: "InputSystem 기본 사용법"
categories:
  - Unity
permalink: /develop/unity/162-inputsystem/
tags:
  - "Unity"
  - "Game Development"
  - "InputSystem"
  - "unity"
toc: true
toc_sticky: true
date: 2025-03-25
last_modified_at: 2025-03-25
source_url: https://b-note.tistory.com/162
---

<h3>PlayerInput Component</h3>
<p>빌트인 컴포넌트인 PlayerInput을 플레이어 오브젝트에 추가해서 키입력을 바로 받을 수 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="410" data-origin-height="255"><span data-alt="unity - PlayerInput"><img src="/assets/images/posts/2025/03/25/162-1.png" loading="lazy" width="410" height="255" data-origin-width="410" data-origin-height="255"/></span><figcaption>unity - PlayerInput</figcaption>
</figure>
</p>

<p>Actions에 등록된 InputSystem_Actions를 열어볼 수 있는데 일반적으로 사용되는 키로 바인딩되어 있는 걸 확인할 수 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="947" data-origin-height="377"><span data-alt="unity - input action"><img src="/assets/images/posts/2025/03/25/162-2.png" loading="lazy" width="649" height="258" data-origin-width="947" data-origin-height="377"/></span><figcaption>unity - input action</figcaption>
</figure>
</p>

<p>이 파일을 수정해서 바인딩 키나 값을 변경하여 처리할 수 있다.</p>

<p>플레이어 조작 스크립트에서 이 입력을 가져다 쓰는 방법은 다음과 같다.</p>

<pre class="csharp"><code>private void Awake()
{
    rb = GetComponent&lt;Rigidbody&gt;();
}

private void FixedUpdate()
{
    if (currentInput != Vector2.zero)
    {
        // 방향 설정
        body.forward = new Vector3(currentInput.x, 0, currentInput.y).normalized;

        // 속도 계산
        float currentSpeed = walkSpeed;
        Vector3 moveVelocity = new Vector3(currentInput.x, 0, currentInput.y) * currentSpeed;

        // 물리 이동
        rb.linearVelocity = moveVelocity;

        // 애니메이션
        animator.SetFloat("Move", currentInput.magnitude);
    }
    else
    {
        // 정지 상태
        animator.SetFloat("Move", 0);
        rb.linearVelocity = Vector3.zero;
    }
}

public void OnMove(InputValue value)
{
	moveInput = value.Get&lt;Vector2&gt;();
}</code></pre>

<p>업데이트 안에서 이동키 입력으로 변경되는 moveInput 값을 갱신해서 플레이어를 움직인다.</p>> 용량 문제로 `unity - player move` 애니메이션 이미지는 [원문](/develop/unity/162-inputsystem/)에서 확인한다.
</figure>
</p>

<p>Action Properties 설정을 통해서 필요에 맞춰 수정해서 쓸 수 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="656" data-origin-height="485"><span data-alt="unity - sprint properties"><img src="/assets/images/posts/2025/03/25/162-4.png" loading="lazy" width="656" height="485" data-origin-width="656" data-origin-height="485"/></span><figcaption>unity - sprint properties</figcaption>
</figure>
</p>

<p>쉬프트를 누르면 달리고, 떼면 걷도록 상태를 변경하는 기능을 추가해본다.&nbsp;</p>

<p>기본 Action은 눌렀을 때만 처리하고 있는데 이 부분을 PressAndRelease로 변경한다.&nbsp;</p>

<p>그리고 Initial State Check를 활성화 해준다.</p>

<pre class="csharp"><code>

private void FixedUpdate()
{
    currentInput = Vector2.SmoothDamp(
        currentInput,
        moveInput * (isSprint ? 1f : 0.5f),
        ref smoothVelocity,
        smoothTime
    );

    if (currentInput != Vector2.zero)
    {
        // 방향 설정
        body.forward = new Vector3(currentInput.x, 0, currentInput.y).normalized;

        // 속도 계산
        float currentSpeed = isSprint ? sprintSpeed : walkSpeed;
        Vector3 moveVelocity = new Vector3(currentInput.x, 0, currentInput.y) * currentSpeed;

        // 물리 이동
        rb.linearVelocity = moveVelocity;

        // 애니메이션
        animator.SetFloat("Move", currentInput.magnitude);
    }
    else
    {
        // 정지 상태
        animator.SetFloat("Move", 0);
        rb.linearVelocity = Vector3.zero;
    }
}

private void PlayerAnimation(float moveAmount)
{
    animator.SetFloat("Move", moveAmount);
}

public void OnMove(InputValue value)
{
    moveInput = value.Get&lt;Vector2&gt;();
}

public void OnSprint(InputValue value)
{
    isSprint = value.isPressed;
}</code></pre>

<p>InputManager의 GetAxis처럼 입력이 서서히 -1 0 1 사이에서 움직이는 선택 없이 GetAxisRaw처럼 고정된 숫자로 값이 반환되는데 이 부분이 InputSystem에서 설정으로 제어 가능한 부분이 아닌 것으로 현재 판단되어서 일단 damp를 사용해서 임의로 값을 증가, 증감시켜 범위 내 변하는 값으로 움직임을 처리한다.</p>

<p>이 값이 필요한 이유는 애니메이션을 블렌딩으로 처리하기 때문에 자연스러운 애니메이션을 표현하기 위해서 시작-도착 값까지의 변화하는 값이 필요하다.</p>> 용량 문제로 `unity - move` 애니메이션 이미지는 [원문](/develop/unity/162-inputsystem/)에서 확인한다.
</figure>
</p>
