---
title: "구글 계정 연동"
excerpt: "구글 계정 연동"
categories:
  - Unity
permalink: /develop/unity/150-post/
tags:
  - "Unity"
  - "Game Development"
  - "firebase-auth"
  - "google-signin"
  - "unity"
toc: true
toc_sticky: true
date: 2025-02-28
last_modified_at: 2025-02-28
source_url: https://b-note.tistory.com/150
---

<p>버전 : Unity 6</p>

<p>구글 계정에 연동과정</p>

<p>Google Sign In SDK에서 ID 토큰, 액세스 토큰을 받는다.</p>

<p>Firebase Authentication으로 Google ID 토큰을 Firebase로 전달하고 이를 인증한다.</p>

<p>Google Sign In SDK는 구글 계정으로 로그인할 수 있지만 이후 로그인한 사용자를 앱의 인증 시스템에서 관리할 방법이 없다.</p>

<p>또한 Google ID 토큰을 앱에서 직접 검증하는 것은 보안상 위험하기 때문에 파이어베이스를 통해서 토큰을 검증하고 관리하여 안전하게 관리할 수 있고 파이어베이스의 다양한 기능과 연계하여 사용할 수도 있다.</p>

<h2>1. 파이어베이스 인증 SDK 설치</h2>
<p><a href="https://firebase.google.com/docs/auth/unity/google-signin?hl=ko" target="_blank" rel="noopener">Firebase Authentication SDK</a></p>
<figure id="og_1738703317545" contenteditable="false" data-og-type="website" data-og-title="Google 로그인과 Unity를 사용하여 인증하기 &nbsp;|&nbsp; Firebase" data-og-description="의견 보내기 Google 로그인과 Unity를 사용하여 인증하기 컬렉션을 사용해 정리하기 내 환경설정을 기준으로 콘텐츠를 저장하고 분류하세요. Google 로그인을 앱에 통합하여 사용자가 Google 계정으로" data-og-host="firebase.google.com" data-og-source-url="https://firebase.google.com/docs/auth/unity/google-signin?hl=ko" data-og-url="https://firebase.google.com/docs/auth/unity/google-signin?hl=ko"><a href="https://firebase.google.com/docs/auth/unity/google-signin?hl=ko" target="_blank" rel="noopener" data-source-url="https://firebase.google.com/docs/auth/unity/google-signin?hl=ko">
<div class="og-image" style="background-image: url();">&nbsp;</div>
<div class="og-text">
<p class="og-title">Google 로그인과 Unity를 사용하여 인증하기 &nbsp;|&nbsp; Firebase</p>
<p class="og-desc">의견 보내기 Google 로그인과 Unity를 사용하여 인증하기 컬렉션을 사용해 정리하기 내 환경설정을 기준으로 콘텐츠를 저장하고 분류하세요. Google 로그인을 앱에 통합하여 사용자가 Google 계정으로</p>
<p class="og-host">firebase.google.com</p>
</div>
</a></figure>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1049" data-origin-height="422"><span data-alt="Firebase Authentication"><img src="/assets/images/posts/2025/02/28/150-1.png" loading="lazy" width="1049" height="422" data-origin-width="1049" data-origin-height="422"/></span><figcaption>Firebase Authentication</figcaption>
</figure>
</p>

<p>다운로드한 압축 파일에서 FirebaseAuth.unitypackage 패키지를 프로젝트에 임포트</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="744" data-origin-height="414"><span data-alt="FirebaseAuth"><img src="/assets/images/posts/2025/02/28/150-2.png" loading="lazy" width="555" height="309" data-origin-width="744" data-origin-height="414"/></span><figcaption>FirebaseAuth</figcaption>
</figure>
</p>

<h2>2. Google-Signin-Unity</h2>
<p><a href="https://github.com/googlesamples/google-signin-unity" target="_blank" rel="noopener">Google-SignIn-Unity</a></p>
<figure id="og_1738708104244" contenteditable="false" data-og-type="object" data-og-title="GitHub - googlesamples/google-signin-unity: Google Sign-In API plugin for Unity game engine.  Works with Android and iOS." data-og-description="Google Sign-In API plugin for Unity game engine. Works with Android and iOS. - googlesamples/google-signin-unity" data-og-host="github.com" data-og-source-url="https://github.com/googlesamples/google-signin-unity" data-og-url="https://github.com/googlesamples/google-signin-unity"><a href="https://github.com/googlesamples/google-signin-unity" target="_blank" rel="noopener" data-source-url="https://github.com/googlesamples/google-signin-unity">
<div class="og-image">&nbsp;</div>
<div class="og-text">
<p class="og-title">GitHub - googlesamples/google-signin-unity: Google Sign-In API plugin for Unity game engine. Works with Android and iOS.</p>
<p class="og-desc">Google Sign-In API plugin for Unity game engine. Works with Android and iOS. - googlesamples/google-signin-unity</p>
<p class="og-host">github.com</p>
</div>
</a></figure>

<p>최신버전 1.0.4 사용</p>

<p>* 프로젝트에 임포트하면 Unity.Task 관련해서 충돌 에러가 발생하는데 Assets &gt; Parse&nbsp; 폴더를 지우면 해결 가능하다.</p>

<p>설치 후 패키지 문제 없는지 테스트 빌드를 진행</p>

<p>gradle 에러가 발생해서 빌드에 실패한다. 안드로이드 빌드 시 자주 발생하는 에러로 이런 경우 프로젝트 세팅의 최소 타겟&nbsp;API를 올리면 해결되는 경우가 많은데 먼저 이 부분을 확인해서 다시 빌드해 본다.</p>

<p>Minimum API Level 23 -&gt; 24로 변경 후 다시 빌드하니 해결되었다.</p>

<h2>3. Key Store 생성</h2>
<p>파이어베이스에서 인증 정보를 저장하고 관리할 프로젝트를 생성해야 하는데 이때 유니티 프로젝트의 SHA 키가 필요하다.</p>

<p>먼저 유니티에서 키스토어를 생성하고 SHA를 확인해 둔다.</p>

<p>1. 키스토어 생성</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1397" data-origin-height="482"><span><img src="/assets/images/posts/2025/02/28/150-3.png" loading="lazy" width="1397" height="482" data-origin-width="1397" data-origin-height="482"/></span></figure>
</p>

<p>2. SHA 확인</p>
<p>키스토어를 열어보기 위해서는 keytool을 사용해야 하는데 유니티 에디터를 설치하면 포함되어 있기 때문에 에디터 설치 경로에서&nbsp;</p>
<p>keytool.exe 파일이 위치한 경로에서 명령 프롬프터를 켜서 'keytool -list -keystore [키스토어 경로]' 를 실행한다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1088" data-origin-height="216"><span><img src="/assets/images/posts/2025/02/28/150-4.png" loading="lazy" width="1088" height="216" data-origin-width="1088" data-origin-height="216"/></span></figure>
</p>

<p style="color: #333333; text-align: start;"><br />* 구글 계정 인증에는 SHA-1 이 필요한데 Unity 6 버전의 keytool을 사용했더니 256만 뜨고 나머지 지문들은 생략된다.</p>
<p style="color: #333333; text-align: start;">&nbsp; &nbsp;다른 에디터 버전의 keytool을 사용해서 SHA-1을 확인하고 메모해 둔다.</p>

<p>해당 키는 잠시 메모해 둔다.</p>

<h2>4. 파이어베이스 프로젝트 세팅</h2>
<p><a href="https://firebase.google.com/?gad_source=1&amp;gclid=Cj0KCQiAkoe9BhDYARIsAH85cDNURCVWVna306XtsiH6wCwNjIARqXhjKPeEZK20hwwBzTLhwfnhRnoaAu87EALw_wcB&amp;gclsrc=aw.ds&amp;hl=ko" target="_blank" rel="noopener">Firebase</a></p>
<figure id="og_1738717592506" contenteditable="false" data-og-type="website" data-og-title="Firebase | Google's Mobile and Web App Development Platform" data-og-description="개발자가 사용자가 좋아할 만한 앱과 게임을 빌드하도록 지원하는 Google의 모바일 및 웹 앱 개발 플랫폼인 Firebase에 대해 알아보세요." data-og-host="firebase.google.com" data-og-source-url="https://firebase.google.com/?gad_source=1&amp;gclid=Cj0KCQiAkoe9BhDYARIsAH85cDNURCVWVna306XtsiH6wCwNjIARqXhjKPeEZK20hwwBzTLhwfnhRnoaAu87EALw_wcB&amp;gclsrc=aw.ds&amp;hl=ko" data-og-url="https://firebase.google.com/?hl=ko"><a href="https://firebase.google.com/?gad_source=1&amp;gclid=Cj0KCQiAkoe9BhDYARIsAH85cDNURCVWVna306XtsiH6wCwNjIARqXhjKPeEZK20hwwBzTLhwfnhRnoaAu87EALw_wcB&amp;gclsrc=aw.ds&amp;hl=ko" target="_blank" rel="noopener" data-source-url="https://firebase.google.com/?gad_source=1&amp;gclid=Cj0KCQiAkoe9BhDYARIsAH85cDNURCVWVna306XtsiH6wCwNjIARqXhjKPeEZK20hwwBzTLhwfnhRnoaAu87EALw_wcB&amp;gclsrc=aw.ds&amp;hl=ko">
<div class="og-image">&nbsp;</div>
<div class="og-text">
<p class="og-title">Firebase | Google's Mobile and Web App Development Platform</p>
<p class="og-desc">개발자가 사용자가 좋아할 만한 앱과 게임을 빌드하도록 지원하는 Google의 모바일 및 웹 앱 개발 플랫폼인 Firebase에 대해 알아보세요.</p>
<p class="og-host">firebase.google.com</p>
</div>
</a></figure>

<p>로그인 인증을 처리할 프로젝트를 생성한다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1017" data-origin-height="252"><span><img src="/assets/images/posts/2025/02/28/150-5.png" loading="lazy" width="1017" height="252" data-origin-width="1017" data-origin-height="252"/></span></figure>
</p>

<p>유니티 플랫폼을 선택해서 앱을 추가한다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="938" data-origin-height="638"><span><img src="/assets/images/posts/2025/02/28/150-6.png" loading="lazy" width="938" height="638" data-origin-width="938" data-origin-height="638"/></span></figure>
</p>

<p>여기서 디지털 지문 추가에서 키스토어의 SHA 키를 입력한다.</p>

<p>Authentication 항목으로 들어가서 로그인 제공업체를 추가한다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1469" data-origin-height="457"><span><img src="/assets/images/posts/2025/02/28/150-7.png" loading="lazy" width="1469" height="457" data-origin-width="1469" data-origin-height="457"/></span></figure>
</p>

<p>Google을 선택하고 사용설정을 해준다.</p>

<h2>5. 클라이언트 ID 확인</h2>
<p><a href="https://console.cloud.google.com/welcome?authuser=0&amp;hl=ko&amp;inv=1&amp;invt=Abotyg&amp;project=testsample-e25bc" target="_blank" rel="noopener">Google Cloud</a></p>
<figure id="og_1738718524089" contenteditable="false" data-og-type="website" data-og-title="Google 클라우드 플랫폼" data-og-description="로그인 Google 클라우드 플랫폼으로 이동" data-og-host="accounts.google.com" data-og-source-url="https://console.cloud.google.com/welcome?authuser=0&amp;hl=ko&amp;inv=1&amp;invt=Abotyg&amp;project=testsample-e25bc" data-og-url="https://accounts.google.com/v3/signin/identifier?continue=https%3A%2F%2Fconsole.cloud.google.com%2Fwelcome%3Fauthuser%3D0%26hl%3Dko%26inv%3D1%26invt%3DAbotyg%26project%3Dtestsample-e25bc&amp;followup=https%3A%2F%2Fconsole.cloud.google.com%2Fwelcome%3Fauthuser%3D0%26hl%3Dko%26inv%3D1%26invt%3DAbotyg%26project%3Dtestsample-e25bc&amp;hl=ko&amp;ifkv=AVdkyDmdBXipijDw-COPhj1iyPxksN96kF51kgQaxEvgkoyD8CvOpjAc7C82sQj5A_sriGJ5gqkK&amp;osid=1&amp;passive=1209600&amp;service=cloudconsole&amp;flowName=WebLiteSignIn&amp;flowEntry=ServiceLogin&amp;dsh=S1879872994%3A1738718522189988"><a href="https://console.cloud.google.com/welcome?authuser=0&amp;hl=ko&amp;inv=1&amp;invt=Abotyg&amp;project=testsample-e25bc" target="_blank" rel="noopener" data-source-url="https://console.cloud.google.com/welcome?authuser=0&amp;hl=ko&amp;inv=1&amp;invt=Abotyg&amp;project=testsample-e25bc">
<div class="og-image" style="background-image: url();">&nbsp;</div>
<div class="og-text">
<p class="og-title">Google 클라우드 플랫폼</p>
<p class="og-desc">로그인 Google 클라우드 플랫폼으로 이동</p>
<p class="og-host">accounts.google.com</p>
</div>
</a></figure>

<p>구글 클라우드에 접속하면 파이어베이스에서 생성했던 프로젝트와 동일한 정보로 프로젝트가 생성되어 있다.</p>

<p>이 중에서 사용자 인증 정보 항목에서 OAuth 2.0 클라이언트 ID를 사용해서 유니티에서 접속을 시도한다.</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="1627" data-origin-height="105"><span><img src="/assets/images/posts/2025/02/28/150-8.png" loading="lazy" width="1627" height="105" data-origin-width="1627" data-origin-height="105"/></span></figure>
</p>


<h2>6. 로그인 스크립트</h2>
<p>유니티로 돌아가서 로그인 스크립트를 구현한다.</p>

<p>* 에러</p>
<p>SignIn 함수 호출 시 계정 선택 UI 팝업이 뜬 후 계정을 선택하고 나서 반응이 없는 현상이 있었는데 결과를 받아서 처리하는 콜백에서 에러가 발생했었다.</p>

<p>이때 메인스레드에서 처리되도록 Dispatcher 함수를&nbsp; 구현해서 처리하니 문제가 해결되긴 했는데 정확한 원인은 확인을 못한 부분이다.</p>

<pre class="csharp"><code>using System.Collections.Generic;
using UnityEngine;

public class MainThreadDispatcher : MonoBehaviour
{
    private static MainThreadDispatcher instance;
    private readonly Queue&lt;System.Action&gt; executionQueue = new Queue&lt;System.Action&gt;();

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    private void Update()
    {
        lock (executionQueue)
        {
            while (executionQueue.Count &gt; 0)
            {
                executionQueue.Dequeue()?.Invoke();
            }
        }
    }

    public static void RunOnMainThread(System.Action action)
    {
        if (instance != null)
        {
            lock (instance.executionQueue)
            {
                instance.executionQueue.Enqueue(action);
            }
        }
    }
}</code></pre>


<p>디스패처를 사용해 SignIn 함수 결과를 처리한다.</p>

<pre class="csharp"><code>using Google;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;

public class GoogleLogin : MonoBehaviour
{
    private string web_client_id = "구글 클라우드의 클라이언트 ID";

    private void Awake()
    {
        Init();
    }

    private void Init()
    {
        GoogleSignIn.Configuration = new GoogleSignInConfiguration
        {
            WebClientId = web_client_id,
            UseGameSignIn = false,
            RequestEmail = true,
            RequestIdToken = true
        };
    }

    public void SignIn()
    {
        DebugMessage.Instance.ShowMessage("Calling SignIn");
        Debug.Log("Calling SignIn");
        GoogleSignIn.DefaultInstance.SignIn().ContinueWith(
          OnAuthenticationFinished);
    }

    internal void OnAuthenticationFinished(Task&lt;GoogleSignInUser&gt; task)
    {
        Debug.Log("Authentication finished, processing on main thread");
        MainThreadDispatcher.RunOnMainThread(() =&gt; ProcessAuthResult(task));
    }

    private void ProcessAuthResult(Task&lt;GoogleSignInUser&gt; task)
    {
        Debug.Log("Auth Result");
        if (task.IsFaulted)
        {
            using (IEnumerator&lt;System.Exception&gt; enumerator = task.Exception.InnerExceptions.GetEnumerator())
            {
                if (enumerator.MoveNext())
                {
                    GoogleSignIn.SignInException error = (GoogleSignIn.SignInException)enumerator.Current;
                    DebugMessage.Instance.ShowMessage("Got Error: " + error.Status + " " + error.Message);
                    Debug.Log("Got Error: " + error.Status + " " + error.Message);
                }
                else
                {
                    DebugMessage.Instance.ShowMessage("Got Unexpected Exception?!?" + task.Exception);
                    Debug.Log("Got Unexpected Exception?!?" + task.Exception);
                }
            }
        }
        else if (task.IsCanceled)
        {
            DebugMessage.Instance.ShowMessage("Canceled");
            Debug.Log("Canceled");
        }
        else
        {
            DebugMessage.Instance.ShowMessage("Welcome: " + task.Result.DisplayName + "!");
            DebugMessage.Instance.ShowMessage(task.Result.Email + "!");
            DebugMessage.Instance.ShowMessage(task.Result.IdToken + "!");

            Debug.Log("Welcome: " + task.Result.DisplayName + "!");
            Debug.Log(task.Result.Email + "!");
            Debug.Log(task.Result.IdToken + "!");
        }
    }
}</code></pre>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="546" data-origin-height="965"><span><img src="/assets/images/posts/2025/02/28/150-9.png" loading="lazy" width="407" height="965" data-origin-width="546" data-origin-height="965"/></span></figure>
</p>

<p>폰트에 한글이 지원되지 않아서 깨진 것 빼고는 로그인 성공 후 들어오는 리턴 정보를 로그로 찍은 값들이 잘 출력되는 게 확인된다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="541" data-origin-height="694"><span><img src="/assets/images/posts/2025/02/28/150-10.png" loading="lazy" width="407" height="522" data-origin-width="541" data-origin-height="694"/></span></figure>
</p>
