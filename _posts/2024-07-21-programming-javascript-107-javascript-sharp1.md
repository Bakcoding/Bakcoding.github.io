---
title: "JavaScript #1 개요"
excerpt: "JavaScript #1 개요"
categories:
  - Javascript
permalink: /programming/javascript/107-javascript-sharp1/
tags:
  - "JavaScript"
  - "Web"
  - "Index"
  - "개요"
  - "자바스크립트"
toc: true
toc_sticky: true
date: 2024-07-21
last_modified_at: 2024-07-21
source_url: https://b-note.tistory.com/107
---

<h2>JavaScript</h2>
<p>자바스크립트는 현재까지도 웹 개발에서는 빼놓을 수 없는 필수적인 기술이다. 더 나아가 이제는 웹뿐만 아니라 서버 개발에서도 사용할 정도로 높은 유연성과 확장성을 가진 언어로 평가된다.</p>

<h2>탄생</h2>
<p>1995년, 웹은 주로 정적인 페이지로 구성되어 있었고 이러한 페이지는 사용자가 상호작용할 수 있는 기능이 매우 제한적이었으며 또한 모든 상호작용은 서버와의 통신을 통해 이루어졌기 때문에 느리고 비효율적인 방식이었다.</p>

<p>당시 웹 브라우저 시장을 주도했던 미국의 소프트웨어 회사인 넷스케이프(Netscape Communications Corporation)는 이러한 문제점을 해결하고 사용자와 웹 페이지의 상호작용을 개선하기 위해서 클라이언트 측에서 실행될 수 있는 스크립팅 언어가 필요하다고 판단하였다.&nbsp;</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="800" data-origin-height="800"><span data-alt="넷스케이프"><img src="/assets/images/posts/2024/07/21/107-1.png" loading="lazy" width="206" height="206" data-origin-width="800" data-origin-height="800"/></span><figcaption>넷스케이프</figcaption>
</figure>
</p>

<p>넷스케이프의 CTO였던 마크 앤드리슨(Marc Andreessen)은 프로그래밍 언어 설계와 컴파일러 개발에 경험이 있던 브렌던 아이크(Brendan Eich)를 고용했으며 그의 풍부한 경험을 바탕으로 아주 짧은 기간인 10일 만에 넷스케이프의 요구를 충족하는 스크립팅 언어를 개발했고 그 초기 버전은 '모카(Mocha)'라는 이름이었다.</p>

<p><figure class="imagegridblock">
  <div class="image-container"><span data-origin-width="347" data-origin-height="256" data-is-animation="false" style="width: 56.9263%; margin-right: 10px;" data-widthpercent="57.6"><img src="/assets/images/posts/2024/07/21/107-2.png" loading="lazy" width="347" height="256"/></span><span data-origin-width="484" data-origin-height="485" data-is-animation="false" data-widthpercent="42.4" style="width: 41.9109%;"><img src="/assets/images/posts/2024/07/21/107-3.png" loading="lazy" width="484" height="485"/></span></div>
  <figcaption>좌) 마크 앤드리슨 우) 브렌던 아이크</figcaption>
</figure>
</p>

<p>모카는 이후 개발과 사업적인 과정을 거치면서 '라이브스크립트(LiveScript)'로 바뀌었고 최종적으로는 자바스크립트(JavaScript)로 알려지게 되었다.</p>

<p>당시 넷스케이프와 경쟁 관계였던 마이크로소프트(Microsoft)는 자바스크립트와의 경쟁을 위해 자사의 브라우저인 인터넷 익스플로러 3.0에 자바스크립트의 변형인 JScript를 도입하면서 두 웹 브라우저 간의 경쟁이 치열해졌다. 그 밖에도 여러 브라우저들이 있었으며 하나의 브라우저에 맞춰서 작업을 하면 다른 브라우저에서는 제대로 동작하지 않는&nbsp;경우가 빈번하게 발생하였고 이는 웹 개발자들에게 큰 불편을 초래하여 웹의 발전을 저해하는 요인이 되었다.</p>

<h3>자바스크립트 표준화</h3>
<p>이러한 호환성 문제를 해결하기 위해서 자바스크립트를 표준화하려는 노력이 시작되었다.</p>
<p>1996년 넷스케이프는 유럽 컴퓨터 제조업체 협회(ECMA)에 자바스크립트의 표준화를 제안하였고 ECMA는 자바스크립트를 표준화하기 위한 기술 위원회를 구성하였다.&nbsp;</p>

<p>그리고 1997년 자바스크립트의 표준 사양인 ECMA-262를 발표했다. ECMAAScript로 알려진 이 표준은 자바스크립트와 JScript 간의 차이를 최소화하고, 두 브라우저 간의 호환성을 개선하는데 목적이 있었다. 이후에도 표준화 작업은 지속적으로 이루어져 자바스크립트의 공식 표준으로 웹 개발의 핵심을 이루었으며 최신버전인 2015년 ES6까지 이어지고 있다.</p>

<h3>발전</h3>
<p>자바스크립트는 동적 언어의 패러다임을 가지고 있으며 발전 과정에서도 그 틀은 바뀌지 않았다. 웹 페이지는 발전할 수 록 더 복잡해져 갔고 여기서 발생되는 가장 큰 불편은 데이터를 갱신할 때마다 서버로부터 새로 데이터를 가져오면서 발생하는 새로고침으로 웹 페이지의 데이터가 많을수록 점점 더 느려져갔다.</p>

<p>1999년 마이크로소프는 인터넷 익스플로러 5.0에서 XMLHttpRequest 객체를 도입하기 시작했다. 이 객체는 자바스크립트를 사용하여 서버와 비동기적으로 통신할 수 있게 해 주었다.</p>

<p>이 객체의 도입으로 사용자의 요청마다 전체 페이지를 새로 고침 해야 하는 페이지 리로드 문제, 새로 고침으로 인해 서버 응답 시간과 페이지 렌더링으로 인해 시간이 필요한 느린 반응 속도 문제 그리고 매번 전체 페이지를 새로 고침 하면서 서버에 불필요한 요청을 증가시켜 서버 부하를 높이던 문제를 해결할 수 있게 되었다.</p>

<p>또한 이제 동적으로 콘텐츠를 업데이트하는 것이 가능해졌기 때문에 XMLHttpRequest의 등장 이후로 사용자의 경험은 크게 향상되었다. <span style="letter-spacing: 0px;">초기에는 이 기능이 주로 마이크로소프트의 ActiveX 기술을 통해 제공되었지만, 이후 다른 브라우저에서도 이 기능을 채택하게 되었다.</span></p>

<p>더 나아가서 비동기적 웹 기술의 발전은 2005년 제시 제임스 가렛(Jesse James Garrett)에 의해서 AJAX(Asynchronous JavaScript and XML), 자바스크립트를 사용하여 서버와 비동기적으로 통신하는 기술에 대한 개념을 정립하였다.</p>
<p><figure class="imageblock alignCenter" data-ke-mobileStyle="widthOrigin" data-origin-width="511" data-origin-height="651"><span data-alt="제시 제임스 가렛"><img src="/assets/images/posts/2024/07/21/107-4.png" loading="lazy" width="511" height="651" data-origin-width="511" data-origin-height="651"/></span><figcaption>제시 제임스 가렛</figcaption>
</figure>
</p>

<p><span style="color: #333333; text-align: start;"><span>이후로&nbsp;</span>더 상호적이고 반응성이 뛰어난 웹 애플리케이션들이 만들어지게 되었고 현재까지도 </span>이 기술은 일반적으로 사용되는 개념이 되었다.</p>

<h3>용도와 중요성</h3>
<p>자바스크립트는 기본적으로 웹 페이지에 동적인 기능을 추가하는 역할을 한다. 따라서 웹 개발에서는 필수적으로 요구된 되는 기술로 반드시 학습하는 것이 좋다.</p>

<p>현재는 웹뿐만 아니라 기술이 확장되어서 Node.js와 같은 런타임 환경을 통해서 서버 측 개발에서도 널리 사용되고 있다. 이를 통해 백엔드 로직을 작성하고 데이터베이스와 상호작용하는 것도 가능하다.</p>

<p>또한 React Native와 같은 프레임워크를 통해 네이티브 모바일 애플리케이션을 개발하거나 Phaser와 같은 라이브러리로 2D 나 3D 게임까지도 만들 수 있다.</p>

<h2>특징</h2>
<p>자바스크립트의 가장 큰 언어는 동적언어라는 점이다.</p>

<p>동적언어란, 런타임 시에 다양한 동작을 수행할 수 있는 프로그래밍 언어를 말한다. 이러한 자바스크립트의 특징은 사용자와 실시간으로 다양한 상호작용을 주고받을 필요가 있는 웹 페이지에 적합하다.</p>

<h3>동적 언어의 특징</h3>
<p><b>동적 타입 바인딩</b></p>
<p>변수의 타입이 런타임에 결정된다. 즉, 변수를 선언할 때 특정 타입을 지정할 필요가 없으며, 실행 중에 할당된 값에 따라 타입이 변경될 수 있다.</p>

<p>만약 C, C++, Java 같은 정적 언어인 경우</p>
<pre class="cpp"><code>int num = 1;
string name = "bak";</code></pre>
<p>컴파일 타임에 타입을 확인하기 때문에 타입으로 인한 런타임 오류를 방지할 수 있으며 명시적으로 지정했기 때문에 코드의 가독성이 좋지만 그만큼 매번 타입을 지정해야 하는 번거로움이 있다는 특징이 있다.</p>

<p>반대로 동적언어인 JavaScript, Ruby, Python의 경우</p>
<pre class="javascript"><code>var num = 1;
num = true;
num = "Hello";</code></pre>
<p>런타임에서 타입이 결정될 수 있다. 따라서 매번 타입을 변경할 필요가 없기 때문에 var 변수를 사용해 모든 변수 선언이 가능하다. 이미 선언된 변수도 이후에 다른 타입을 값을 저장하는 것 또한 문제가 발생하지 않는다.&nbsp;</p>

<p>동적언어와 비교했을 때 상대적으로 타입과 관련한 코드와 규칙이 적기 때문에 코드가 짧고 배우기가 쉽지만 실행 중 타입에러가 발생할 수 있는 문제도 존재한다.<br></p>
<p>추가적으로 C++의 auto 타입이 var와 비슷하기 때문에 동적인 특징이 있어 보이지만 auto 타입은 컴파일 단계에서 타입이 추론되기 때문에 런타임에서는 이미 타입이 확정된 상태이다.</p>

<p><b>인터프리터</b></p>
<p>자바스크립트는 기본적으로 인터프리터로 방식으로 실행된다. 현대에 들어서는 JIT(Just In Time) 컴파일을 활용하여 성능을 향상시기키도 했다.&nbsp;</p>

<p>인터프리터 방식이란 코드를 한 줄씩 읽고 실행하는 방식으로 개발 중 빠른 피드백을 제공하고 동적 특성을 잘 처리할 수 있지만 성능 면에서 제한이 있었다. 이러한 문제점을 JIT 컴파일을 통해서 보완하여 사용 중이다.</p>
