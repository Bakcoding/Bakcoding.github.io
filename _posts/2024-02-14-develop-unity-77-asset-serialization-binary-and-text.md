---
title: "Asset Serialization, Binary and Text"
excerpt: "Asset Serialization, Binary and Text"
categories:
  - Unity
permalink: /develop/unity/77-asset-serialization-binary-and-text/
tags:
  - "Unity"
  - "Game Development"
  - "asset serialization"
  - "Binary"
  - "text"
  - "unity"
toc: true
toc_sticky: true
date: 2024-02-14
last_modified_at: 2024-02-14
source_url: https://b-note.tistory.com/77
---

<h2>바이너리와 텍스트(YAML) 비교</h2>
<p>비주얼 스튜디오에서 바이너리를 볼 수 있는 확장 툴을 설치해서 해당 파일을 분석해 본다.</p>

<p>프로젝트 설정 중에서 에셋 데이터를 관리하는 방식인 바이너리와 텍스트 두 가지에 대해서 몇 가지 테스트를 해볼 것이다.</p>
<p>두 방식을 비교해 보기 위해서 프로젝트에서 모든 컴포넌트의 데이터가 동일한 오브젝트를 생성해 보고 차이점을 비교한다.&nbsp;</p>

<p>하이어라키에서 큐브를 생성하고 프리팹으로 만들어 파일을 확인해 본다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="625" data-origin-height="90"><span data-alt=".prefab Text"><img src="/assets/images/posts/2024/02/14/77-1.png" loading="lazy" width="556" height="90" data-origin-width="625" data-origin-height="90"/></span><figcaption>.prefab Text</figcaption>
</figure>
</p>
<p>파일의 크기는 3kb이며 파일 내용은 YAML 형식으로 오브젝트의 모든 컴포넌트의 정보가 저장되어 있다.</p>
<p>길이는 100줄 정도 된다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="498" data-origin-height="612"><span data-alt=".prefab Text view"><img src="/assets/images/posts/2024/02/14/77-2.png" loading="lazy" width="498" height="612" data-origin-width="498" data-origin-height="612"/></span><figcaption>.prefab Text view</figcaption>
</figure>
</p>

<p>데이터 내용을 그대로 보아도 어떤 정보를 담고 있는지 파악하기 쉽다.</p>

<p>그대로 프로젝트 세팅에서 Asset Seriailization 모드를 Force Binary로 변경한다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="619" data-origin-height="68"><span data-alt=".prefab Binary"><img src="/assets/images/posts/2024/02/14/77-3.png" loading="lazy" width="546" height="60" data-origin-width="619" data-origin-height="68"/></span><figcaption>.prefab Binary</figcaption>
</figure>
</p>

<p>용량이 더 줄어들었을 거라고 예상했지만 반대로 증가했다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="543" data-origin-height="200"><span data-alt=".prefab Binary view"><img src="/assets/images/posts/2024/02/14/77-4.png" loading="lazy" width="543" height="200" data-origin-width="543" data-origin-height="200"/></span><figcaption>.prefab Binary view</figcaption>
</figure>
</p>

<p>파일의 마지막은 다음과 같이 정보를 보여준다.</p>
<p>좌측의 메모리주소와 우측의 아스키코드에 대응하는 문자는 편집기의 기능으로 데이터에 포함되지 않는 정보일 것이다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="597" data-origin-height="103"><span data-alt="Binary"><img src="/assets/images/posts/2024/02/14/77-5.png" loading="lazy" width="568" height="103" data-origin-width="597" data-origin-height="103"/></span><figcaption>Binary</figcaption>
</figure>
</p>

<p>맨 앞의 8자리 숫자+알파벳의 조합은 16진수로 보인다.</p>
<p>이 주소가 16 단위로 증가하고 뒤에 오는 정보는 8 + 8 총 16으로 정보의 개수를 의미하는 것 같다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="192" data-origin-height="54"><span data-alt="ASCII"><img src="/assets/images/posts/2024/02/14/77-6.png" loading="lazy" width="192" height="54" data-origin-width="192" data-origin-height="54"/></span><figcaption>ASCII</figcaption>
</figure>
</p>
<p>메모리 주소 뒤에 오는 행렬 형태의 정보는 아스키코드로 보이는데 아스키 테이블에서 20은 공백, 3C는 &lt; 로 확인할 수 있다. 따라서 맨 우측에는 테이블에 대응하는 문자를 확인된다.</p>

<p>마지막 주소가 2030으로 10진법으로 변환 시 8240이다. 즉 총 8240개의 데이터가 담겨있으며 파일의 크기가 9kb인 것으로 생각해 볼 때 하나에 1byte로 떨어지고 각 데이터가 아스키코드이므로 1byte라고 생각하면 얼추 맞아떨어지는 거 같다.</p>

<p>파일크기는 9kb로 나오는데 해당 파일을 속성을 열어서 자세히 보면</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="283" data-origin-height="27"><span data-alt=".prefab size"><img src="/assets/images/posts/2024/02/14/77-7.png" loading="lazy" width="283" height="27" data-origin-width="283" data-origin-height="27"/></span><figcaption>.prefab size</figcaption>
</figure>
</p>
<p>더 근접한 크기임을 알 수 있다.&nbsp;</p>

<p>좀 더 정밀하게 계산하면 마지막 줄에는 데이터 4개가 빠져있어서 8236이다. 즉 최종적으로 16byte가 모자라다.</p>
<p>만약 마지막 메모리가 온전히 16을 차지한다고 해도 8240이 최대일 텐데 그래도 12byte가 채워지지 않는다.</p>

<p>어디서 계산이 잘못된 건지 이 부분은 다시 확인해 볼 필요가 있다.</p>

<p>다시 본래의 목적으로 돌아가서 YAML 형식이 바이너리보다 용량이 적은 것은 의문이 들어서 프리팹의 크기를 키워보기로 한다. 기존의 큐브 프리팹에 자식으로 큐브를 추가해서 수정해 결과를 확인해 본다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="284" data-origin-height="38"><span data-alt="+1 cube biary"><img src="/assets/images/posts/2024/02/14/77-8.png" loading="lazy" width="284" height="38" data-origin-width="284" data-origin-height="38"/></span><figcaption>+1 cube biary</figcaption>
</figure>
</p>

<p>바이너리의 경우 768 byte 가 추가되었다.</p>

<p>모드를 변경해서 Text의 크기를 확인해 보니 6kb로 처음 경우에서 2배로 사이즈가 커졌다. 증가량만 따졌을 때는 엄청난 크기 차이가 있다.</p>

<p>몇 번 더 큐브를 추가해 보면서 살펴본다.</p>
<table style="border-collapse: collapse; width: 100%; height: 123px" border="1">
<tbody>
<tr style="height: 20px">
<td style="width: 33.3333%; height: 20px">큐브 개수 / 파일 사이즈(kb)</td>
<td style="width: 33.3333%; height: 20px">&nbsp;Binary</td>
<td style="width: 33.3333%; height: 20px">Text</td>
</tr>
<tr style="height: 17px">
<td style="width: 33.3333%; height: 17px">1</td>
<td style="width: 33.3333%; height: 17px">9</td>
<td style="width: 33.3333%; height: 17px">3</td>
</tr>
<tr style="height: 17px">
<td style="width: 33.3333%; height: 17px">2</td>
<td style="width: 33.3333%; height: 17px">9</td>
<td style="width: 33.3333%; height: 17px">6</td>
</tr>
<tr style="height: 18px">
<td style="width: 33.3333%; height: 18px">3</td>
<td style="width: 33.3333%; height: 18px">10</td>
<td style="width: 33.3333%; height: 18px">9</td>
</tr>
<tr style="height: 15px">
<td style="width: 33.3333%; height: 15px">4</td>
<td style="width: 33.3333%; height: 15px">11</td>
<td style="width: 33.3333%; height: 15px">12</td>
</tr>
<tr style="height: 19px">
<td style="width: 33.3333%; height: 19px">20</td>
<td style="width: 33.3333%; height: 19px">23</td>
<td style="width: 33.3333%; height: 19px">56</td>
</tr>
<tr style="height: 17px">
<td style="width: 33.3333%; height: 17px">100</td>
<td style="width: 33.3333%; height: 17px">82</td>
<td style="width: 33.3333%; height: 17px">276</td>
</tr>
</tbody>
</table>

<p>프리팹에 오브젝트가 많이 포함되어 있을수록 파일의 사이즈는 확연히 차이가 난다.</p>
<p>게임을 만들다 보면 프리팹 하나에 여러 오브젝트들이 붙어있게 되는 경우는 많기 때문에 거의 일반적으로 Text 모드가 용량이 크다고 보인다.</p>

<h2>비교</h2>
<p>테스트 결과로 비교해 보면 바이너리를 사용하는 것이 데이터의 크기를 줄여주기 때문에 프로젝트를 열고 데이터를 저장하는 과정에서 시간이 단축될 수 있다.</p>

<p>하지만 유니티를 사용한 프로젝트를 협업할 때에는 바이너리보다는 Text 가 권장된다. Github에서는 공식문서에서 해당 부분에 대하여 Force Text로 설정해야 한다고 명시해 두었다.</p>

<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="925" data-origin-height="235"><span data-alt="Github unity Asset Serialization"><img src="/assets/images/posts/2024/02/14/77-9.png" loading="lazy" width="741" height="188" data-origin-width="925" data-origin-height="235"/></span><figcaption>Github unity Asset Serialization</figcaption>
</figure>
</p>

<p><a title="Github - Git and Unity" href="https://gist.github.com/Ikalou/197c414d62f45a1193fd?permalink_comment_id=2645264" target="_blank" rel="noopener">Github - Git and Unity</a></p>
<figure id="og_1707914442290" contenteditable="false" data-og-type="article" data-og-title="Git and Unity" data-og-description="Git and Unity. GitHub Gist: instantly share code, notes, and snippets." data-og-host="gist.github.com" data-og-source-url="https://gist.github.com/Ikalou/197c414d62f45a1193fd?permalink_comment_id=2645264" data-og-url="https://gist.github.com/Ikalou/197c414d62f45a1193fd"><a title="Github - Git and Unity" href="https://gist.github.com/Ikalou/197c414d62f45a1193fd?permalink_comment_id=2645264" target="_blank" rel="noopener" data-source-url="https://gist.github.com/Ikalou/197c414d62f45a1193fd?permalink_comment_id=2645264">
<div class="og-image">&nbsp;</div>
<div class="og-text">
<p class="og-title">Git and Unity</p>
<p class="og-desc">Git and Unity. GitHub Gist: instantly share code, notes, and snippets.</p>
<p class="og-host">gist.github.com</p>
</div>
</a></figure>

<p>유니티에서도 기본값은 Force Text이며 이렇게 Force Text를 권장하는 이유는 바이너리 형식으로는 파일을 수정하고 병합하는 것이 불가능하다. 따라서 변경된 사항을 파악하는 것이 불가능한데 협업뿐만 아니라 개인 프로젝트 또한 버전 컨트롤을 사용하는 것이 일반적인데 해당 기능을 사용하지 못하는 Mixed 또는 Binary 모드는 더 이상은 사용되지 않는 기능으로 생각된다.</p>
