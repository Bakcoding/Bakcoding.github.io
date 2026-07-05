---
title: "2D 애니메이션, 이펙트"
excerpt: "2D 애니메이션, 이펙트"
categories:
  - Unity
permalink: /develop/unity/149-2d/
tags:
  - "Unity"
  - "Game Development"
  - "effect"
  - "Particle"
  - "ui"
  - "unity"
toc: true
toc_sticky: true
date: 2024-12-03
last_modified_at: 2024-12-03
source_url: https://b-note.tistory.com/149
---

<p>최근에 UI 애니메이션을 작업하다 정리가 필요한 부분이 있어서 작성한다.</p>

<h2>2D Sprite</h2>
<p>2D 스프라이트의 애니메이션은 리소스와 Animator를 가지고 만들 수 있다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="sprite_renderer.gif" data-origin-width="600" data-origin-height="292"><span data-alt="Sprite Renderer Animation"><img src="/assets/images/posts/2024/12/03/149-1.gif" loading="lazy" width="600" height="292" data-filename="sprite_renderer.gif" data-origin-width="600" data-origin-height="292"/></span><figcaption>Sprite Renderer Animation</figcaption>
</figure>
</p>

<p>원하는 프레임마다 스프라이트를 변경하는 방식으로 애니메이션을 만들 수 있다.</p>

<h2>UI Animation</h2>
<p>UI 경우에도 애니메이션으로 컨트롤하는 경우에는 동일한 방식으로 처리된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="ui_anim.gif" data-origin-width="600" data-origin-height="353"><span data-alt="UI Animation"><img src="/assets/images/posts/2024/12/03/149-2.gif" loading="lazy" width="600" height="353" data-filename="ui_anim.gif" data-origin-width="600" data-origin-height="353"/></span><figcaption>UI Animation</figcaption>
</figure>
</p>

<h2>Effect</h2>
<p>Sprite Renderer를 사용하는 상황에서 뭔가 발산하는 이펙트를 사용한다면 어떻게 하는 게 좋을까 생각하면서 파티클 시스템과 오브젝트를 직접 제어하는 방법 두 가지를 사용해 보았다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="effect.gif" data-origin-width="600" data-origin-height="341"><span><img src="/assets/images/posts/2024/12/03/149-3.gif" loading="lazy" width="449" height="255" data-filename="effect.gif" data-origin-width="600" data-origin-height="341"/></span></figure>
</p>

<p>있는 리소소 가지고 대충 테스트만 하려고 만들다 보니 별로 이뻐 보이진 않는다.</p>

<p>이러한 상황에서는 오브젝트를 가지고 직접 제어하는 게 나은 방식인 거 같다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="effect_2.gif" data-origin-width="600" data-origin-height="339"><span><img src="/assets/images/posts/2024/12/03/149-4.gif" loading="lazy" width="600" height="339" data-filename="effect_2.gif" data-origin-width="600" data-origin-height="339"/></span></figure>
</p>

<p>실제로 사용한다면 풀링을 해서 쓰겠지만 그럼에도 상당히 많은 오브젝트를 뿜어낸다면 파티클을 쓰는 게 적합하다고 보인다.</p>

<p>상황에 맞게 잘 조율하는 게 필요하다.</p>

<p>위에서 사용한 코드</p>

<pre class="csharp"><code>using UnityEngine;

public class Coin : MonoBehaviour
{
    private const float power = 10f;
    private void OnEnable()
    {
        transform.position = Vector3.zero;
        ApplyForce();
    }

    private void ApplyForce()
    {
        var rb = GetComponent&lt;Rigidbody2D&gt;();
        float randomHorizontal = Random.Range(-1f, 1f); // -1 to 1 for left/right
        Vector2 direction = new Vector2(randomHorizontal, 1f).normalized;
        rb.AddForce(direction * power, ForceMode2D.Impulse);
    }
}

using UnityEngine;

public class Coin : MonoBehaviour
{
    private const float power = 10f;
    private void OnEnable()
    {
        transform.position = Vector3.zero;
        ApplyForce();
    }

    private void ApplyForce()
    {
        var rb = GetComponent&lt;Rigidbody2D&gt;();
        float randomHorizontal = Random.Range(-1f, 1f); // -1 to 1 for left/right
        Vector2 direction = new Vector2(randomHorizontal, 1f).normalized;
        rb.AddForce(direction * power, ForceMode2D.Impulse);
    }
}</code></pre>

<p>대충 동전이 뿜어지는 듯한 모습을 중점으로 만들었다.</p>

<p>Coin 간에는 충돌처리하면 초기 한 위치에 모여있을 때 서로 부딪혀서 Physics2D &gt; Layer Collision Matrix를 꺼두었다.</p>

<p>바닥에 충돌 후 튕기는 것과 미끄러지는 정도는 Phsics Material로 조절한다 (Friction 마찰력, Bounciness 탄성력)</p>

<h2>UI Effect</h2>
<p>위 내용들은 겸사겸사로 같이 정리한 내용이고 이 글을 쓰기 시작한 이유는 이 부분 때문이었다.</p>

<p>상황은 대충 이렇다.</p>

<p>간단한 퍼즐 게임을 만드는 중에 스프라이트 렌더러를 쓰기에는 귀찮은 부분들이 있어서 간단하게 만들려고 UI를 베이스로 해서 게임 로직들을 만들었고 그렇게 진행하다 보니 효과를 추가하는 과정에서 물리적인 부분을 사용할 수 없어 직접 위치를 이동시켜서 유사하게 재현할 수밖에 없었다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-filename="2024-12-03003428-ezgif.com-video-to-gif-converter.gif" data-origin-width="600" data-origin-height="341"><span data-alt="UI Animation"><img src="/assets/images/posts/2024/12/03/149-5.gif" loading="lazy" width="600" height="341" data-filename="2024-12-03003428-ezgif.com-video-to-gif-converter.gif" data-origin-width="600" data-origin-height="341"/></span><figcaption>UI Animation</figcaption>
</figure>
</p>

<pre class="csharp"><code>using UnityEngine;

public class UICoinMaster : MonoBehaviour
{
    [SerializeField] UICoin[] uiCoins;

    bool isOn = false;
    public void OnClick_UICoinMaster()
    {
        if (isOn)
        {
            foreach( var coin in uiCoins)
            {
                coin.gameObject.SetActive(false);
            }
            isOn = false;
        }
        else
        {
            foreach (var coin in uiCoins)
            {
                coin.gameObject.SetActive(true);
            }
            isOn = true;
        }
    }
}


using UnityEngine;

public class UICoin : MonoBehaviour
{
    [SerializeField] private float initialForce = 10f;
    [SerializeField] private float gravity = 9.8f;
    [SerializeField] private float bounceForce = 0.5f;
    [SerializeField] private bool isMoving = false;

    private RectTransform rect;
    private Vector2 velocity;
    private Vector2 originPos;
    private void Awake()
    {
        rect = GetComponent&lt;RectTransform&gt;();
        originPos = rect.position;
    }

    private void OnEnable()
    {
        ApplyPower();
    }

    private void OnDisable()
    {
        rect.position = originPos;
    }

    private void ApplyPower()
    {
        float randomX = Random.Range(-1f, 1f);
        velocity = new Vector2(randomX, 1f).normalized * initialForce;
        isMoving = true;
    }

    private void Update()
    {
        if (!isMoving) return;

        velocity.y -= gravity * Time.deltaTime;

        rect.anchoredPosition += velocity * Time.deltaTime;

        if (rect.anchoredPosition.y &lt; 0)
        {
            rect.anchoredPosition = new Vector2(rect.anchoredPosition.x, 0);
            velocity.y = -velocity.y * bounceForce;
            velocity.x *= 0.8f;
            
            if (Mathf.Abs(velocity.y) &lt; 0.1f)
            {
                isMoving = false;
            }
        }
    }
}</code></pre>

<p>UI 크기에 맞춰서 값들을 적절하게 세팅하면 그럴듯해 보인다. 구현하는 데는 크게 무리가 없지만 UI 가지고 이래도 되나 싶은 생각이 들기도 한다.</p>

<p>개인적으로는 필요한 기능만 직접 구현해서 쓰는 걸 선호하는 편이라 잘 쓰진 않지만 위처럼 UI를 제어하는 데는 DoTween을 사용하는 게 더 간단하고 다양한 동작들도 처리할 수 있을 것이다.</p>

<h2>UI Particle System</h2>
<p>한 번쯤은 'UI위에 파티클 뿌리기'에 대해서 많은 고민과 탐구를 해보았을 것이다. 이 경우 나는 주로 카메라의 렌더링 모드를 Screen Space - Camera로 세팅해서 파티클을 보이게 하는 방법을 사용했다. 그런데 이 방법은<span style="text-align: start"><span> 원하는&nbsp;</span>파티클을 사용할 때나</span> 좌표계를 다룰 때 은근히 귀찮고 까로운면이 있었다.</p>

<p>그래서 이번에 좀 더 찾다 보니 좋은 방법을 알게 되었다.</p>

<p><a href="https://github.com/Unity-UI-Extensions/com.unity.uiextensions.git" target="_blank" rel="noopener&nbsp;noreferrer">https://github.com/Unity-UI-Extensions/com.unity.uiextensions.git</a></p>
<figure id="og_1733159007900" contenteditable="false" data-og-type="object" data-og-title="GitHub - Unity-UI-Extensions/com.unity.uiextensions" data-og-description="Contribute to Unity-UI-Extensions/com.unity.uiextensions development by creating an account on GitHub." data-og-host="github.com" data-og-source-url="https://github.com/Unity-UI-Extensions/com.unity.uiextensions.git" data-og-url="https://github.com/Unity-UI-Extensions/com.unity.uiextensions"><a href="https://github.com/Unity-UI-Extensions/com.unity.uiextensions.git" target="_blank" rel="noopener" data-source-url="https://github.com/Unity-UI-Extensions/com.unity.uiextensions.git">
<div class="og-image">&nbsp;</div>
<div class="og-text">
<p class="og-title">GitHub - Unity-UI-Extensions/com.unity.uiextensions</p>
<p class="og-desc">Contribute to Unity-UI-Extensions/com.unity.uiextensions development by creating an account on GitHub.</p>
<p class="og-host">github.com</p>
</div>
</a></figure>


<p>UI Extensions 라이브러리로 여기에서 UIParticle System을 사용하면 파티클을 UI 위에 렌더링 할 수 있는 상태로 만들 수 있다.</p>

<p>해당 라이브러리에 대해서는 알고는 있었는데 파티클 관련 기능이 있었다는 건 이번에 알게 되었다.</p>

<p>이와 관련해서 UIParticle System 사용방법과 파티클의 기본 사용방법을 배우기 좋은 영상을 메모해 둔다.</p>

<p><a href="https://www.youtube.com/watch?v=hiRdux33UCs" target="_blank" rel="noopener&nbsp;noreferrer">https://www.youtube.com/watch?v=hiRdux33UCs</a></p>
<figure data-video-host="youtube" data-video-url="https://www.youtube.com/watch?v=hiRdux33UCs" data-video-width="860" data-video-height="484" data-video-origin-width="860" data-video-origin-height="484" data-video-title="Unity 2018 - Game VFX - UI / User Interface Effects" data-original-url=""><iframe src="https://www.youtube.com/embed/hiRdux33UCs" width="860" height="484" frameborder="" allowfullscreen="true"></iframe>
<figcaption style="display: none"></figcaption>
</figure>

<p>파티클을 조금 참고해서 만들어 적용시켜 본다.</p>
<p><figure class="imageblock alignLeft"><span data-alt="Sprite Renderer Animation"><img src="/assets/images/posts/2024/12/03/149-6.gif" loading="lazy" width="600" height="292"/></span><figcaption>Sprite Renderer Animation</figcaption></figure></p>

<p>효과를 주고 싶은 UI의 자식에 파티클을 할당하면 UI와 동일한 렌더링 우선순위로 처리가 된다는 점에서 원하는 기능 그 자체였다.</p>


<h2>Performance</h2>
<p>겸사겸사로 추가된 내용들이 많지만 결국 UI로 동작들을 구현해 버리면 성능상에 좋지 않은 건 사실이고 권장되는 방식도 아니다.</p>
<p>가장 큰 이유는 UI는 변경될 때마다 캔버스가 리빌드를 돌리기 때문에 이러한 동작이 과도하게 발생되며 이 연산은 CPU에서 처리하기 때문에 신경이 안 쓰일 수 없지만 어느 정도 타협해서 사용한다면 괜찮지 않을까 생각도 든다.</p>

<p>UI로 만들어봤자 엄청나게 복잡한 게임도 아닐 것이고 퍼즐 게임 정도면 성능상에 이슈를 발생시킬 만큼은 아닐 것이라고 감히 예상한다.</p>

<p>정말 괜찮은지는 프로파일링을 해봐야겠지만 궁금하기도 하니 나중에 시간 날 때 게임 오브젝트와 UI로 구현한 것을 각각 최대한 비슷하게 만들어 놓고 성능을 한 번 비교해 보는 것이 괜찮을 것 같다.</p>
