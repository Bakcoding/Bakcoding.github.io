---
title: "테스트 환경"
excerpt: "테스트 환경"
categories:
  - CSharp
permalink: /programming/csharp/9-post/
tags:
  - "CSharp"
  - ".NET"
  - "C#"
  - "console"
  - "Debug"
  - "Hello World"
  - "VisualStudio2022"
toc: true
toc_sticky: true
date: 2023-01-17
last_modified_at: 2023-01-17
source_url: https://b-note.tistory.com/9
---

<p>C# 예제를 작성하고 테스트를 하기위한 IDE는 Visual Studio를 사용한다.</p>

<p>사용하는 버전은 Visual Studio 2022이며 프로젝트 템플릿은 .Net 환경의 Console App 을 사용한다,</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="1010" data-origin-height="673"><span><img src="/assets/images/posts/2023/01/17/9-1.png" loading="lazy" width="639" height="673" data-origin-width="1010" data-origin-height="673"/></span></figure>
</p>

<p>프로젝트가 열리면 기본으로 Program.cs 스크립트가 만들어져있고 Hello World!를 출력하는 코드가 작성되어있다.</p>
<p>F5를 눌러서 콘솔창을 띄워서 해당코드를 실행시켜 볼 수 있다.</p>

<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="605" data-origin-height="224"><span><img src="/assets/images/posts/2023/01/17/9-2.png" loading="lazy" width="605" height="224" data-origin-width="605" data-origin-height="224"/></span></figure>
</p>

<p>그런데 템플릿에 작성된 코드를 보면 뭔가 빠져있다는것을 알 수 있다.</p>
<p>원래 C# 에서는 코드가 실행되기 위해서 반드시 메인 함수가 있어야하고 이 함수 내부에서 호출이 되어야 실행이된다.</p>

<p>코드의 첫번째 라인에 있는 링크를 들어가보면 이러한 변경사항에 대한 공시 문서의 설명이 나온다.</p>
<p>.Net 6 부터 C# Console App 프로젝트 템플릿은 Program.cs 파일에 위처럼 코드를 생성하게 되며 이전 버전의 경우는 그대로 전체 코드를 생성한다.&nbsp;</p>

<p>이전의 방식을 사용하고 싶은 경우 프로젝트 생성시 해당 옵션을 체크해준다.</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="458" data-origin-height="237"><span><img src="/assets/images/posts/2023/01/17/9-3.png" loading="lazy" width="365" height="189" data-origin-width="458" data-origin-height="237"/></span></figure>
<figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="484" data-origin-height="258"><span><img src="/assets/images/posts/2023/01/17/9-4.png" loading="lazy" width="484" height="258" data-origin-width="484" data-origin-height="258"/></span></figure>
</p>

<p>최신 템플릿을 사용하지 않고 기존의 방식으로 코드가 뜨는걸 확인할 수 있다.</p>
<p><a href="https://aka.ms/new-console-template" target="_blank" rel="noopener">https://aka.ms/new-console-template</a></p>

<p>위 링크를 들어가보면 다른 방법으로도 템플릿을 설정할 수 있으며 암시적으로 사용중인 using의 경우도 수정할 수 있다.</p>

<p>공부가 목적이기 때문에 우선 생략된 코드가 없는 방식을 사용하기로 한다.</p>
