---
title: "JavaScript #13 DOM(Document Object Model)"
excerpt: "JavaScript #13 DOM(Document Object Model)"
categories:
  - Javascript
permalink: /programming/javascript/119-javascript-sharp13-dom-document-object-model/
tags:
  - "JavaScript"
  - "Web"
  - "DOM"
  - "자바스크립트"
toc: true
toc_sticky: true
date: 2024-07-23
last_modified_at: 2024-07-23
source_url: https://b-note.tistory.com/119
---

<h2>DOM</h2>
<p>DOM은 HTML 문서의 구조화된 표현이다. 웹 페이지의 각 요소는 객체로 표현되며, 이 객체들은 트리 구조를 형성한다. DOM을 통해 자바스크립트는 문서의 구조, 스타일, 콘텐츠를 동적으로 변경할 수 있다.</p>

<h2>요소 선택</h2>
<p>DOM 요소를 조작하기 위해서는 먼저 해당 요소를 선택해야 한다.</p>
<p>자주 사용되는 두 가지 방법으로 getElementById와 querySelector가 있다.</p>

<h3>getElementById</h3>
<p>getElementById 메서드는 문서에서 특정 ID를 가진 요소를 선택한다. ID는 문서 내에서 고유해야 한다.</p>

<pre class="javascript"><code>const element = document.getElementById('myElement');
console.log(element); // 해당 ID를 가진 요소를 출력</code></pre>

<h3>querySelector</h3>
<p>querySelector 메서드는 제공된 CSS 선택자에 매칭되는 첫 번째 요소를 반환하며 더 유연하게 요소를 선택할 수 있다.</p>
<pre class="javascript"><code>const element = document.querySelector('.myClass');
console.log(element); // 해당 클래스를 가진 첫 번째 요소를 출력

const anotherElement = document.querySelector('#myElement');
console.log(anotherElement); // 해당 ID를 가진 요소를 출력</code></pre>

<h2>요소 조작</h2>
<p>선택한 요소의 콘텐츠와 스타일을 변경할 수 있다.&nbsp;</p>
<p>getElementById나 querySelector는 요소를 선택하는 방법에만 차이가 있을 뿐 선택한 요소는 동일한 프로퍼티를 통해 조작할 수 있다.</p>

<h3>innerHTML&nbsp;</h3>
<p>innerHTML 프로퍼티는 요소의 HTML 콘텐츠를 설정하거나 가져온다. 요소 내부의 HTML 구조를 동적으로 변경할 수 있다.</p>
<pre class="javascript"><code>const element = document.getElementById('myElement');
element.innerHTML = '&lt;p&gt;새로운 콘텐츠&lt;/p&gt;';</code></pre>

<h3>style</h3>
<p>style 프로퍼티는 인라인 스타일을 설정한다. 특정 요소의 CSS 스타일을 직접 변경할 때 유용하다.</p>
<pre class="javascript"><code>const element = document.getElementById('myElement');
element.innerHTML = '&lt;p&gt;새로운 콘텐츠&lt;/p&gt;';</code></pre>

<h3>classList</h3>
<p>classList 프로퍼티는 요소의 클래스 목록을 조작하는 메서드를 제공한다. 이를 통해 클래스를 추가, 제거, 토글 할 수 있다.</p>
<pre class="javascript"><code>const element = document.getElementById('myElement');
element.classList.add('newClass');
element.classList.remove('oldClass');
element.classList.toggle('activeClass');</code></pre>

<h3>이벤트 처리</h3>
<p>DOM 요소에 이벤트를 처리하기 위해서는 addEventListener 메서드를 사용한다.&nbsp;</p>
<pre class="javascript"><code>const button = document.getElementById('myButton');
button.addEventListener('click', function() {
    alert('버튼이 클릭되었습니다!');
});</code></pre>

<h2>HTML 예제</h2>
<p>간단한 HTML을 작성하고 요소를 가져와서 조작해 본다.</p>

<p>index.html</p>
<pre class="javascript"><code>&lt;!DOCTYPE html&gt;
&lt;html lang="en"&gt;
&lt;head&gt;
    &lt;meta charset="UTF-8"&gt;
    &lt;meta name="viewport" content="width=device-width, initial-scale=1.0"&gt;
    &lt;title&gt;Element Selection Example&lt;/title&gt;
    &lt;style&gt;
        .highlight {
            background-color: yellow;
            color: red;
            font-weight: bold;
        }
    &lt;/style&gt;
&lt;/head&gt;
&lt;body&gt;
    &lt;div id="content"&gt;
        &lt;h1 id="header"&gt;Hello!&lt;/h1&gt;
        &lt;p class="paragraph"&gt;This is a paragraph.&lt;/p&gt;
    &lt;/div&gt;
    &lt;button id="changeContent"&gt;Change Content&lt;/button&gt;
    &lt;button id="changeStyle"&gt;Change Style&lt;/button&gt;
    &lt;button id="toggleClass"&gt;Toggle Class&lt;/button&gt;
    &lt;script src="script.js"&gt;&lt;/script&gt;
&lt;/body&gt;
&lt;/html&gt;</code></pre>

<p>script.js</p>
<pre class="javascript"><code>// 요소 선택
const header = document.getElementById('header');
const paragraph = document.querySelector('.paragraph'); // 클래스 선택자를 사용
const changeContentButton = document.getElementById('changeContent');
const changeStyleButton = document.getElementById('changeStyle');
const toggleClassButton = document.getElementById('toggleClass');

// 콘텐츠 변경
changeContentButton.addEventListener('click', function() {
    header.innerHTML = 'Content has been changed!';
    paragraph.innerHTML = 'The paragraph content has been changed!';
});

// 스타일 변경
changeStyleButton.addEventListener('click', function() {
    header.style.color = 'blue';
    paragraph.style.backgroundColor = 'lightgray';
    paragraph.style.padding = '10px';
});

// 클래스 토글
toggleClassButton.addEventListener('click', function() {
    paragraph.classList.toggle('highlight');
});</code></pre>

<p>페이지 상태</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="362" data-origin-height="159"><span data-alt="HTML"><img src="/assets/images/posts/2024/07/23/119-1.png" loading="lazy" width="362" height="159" data-origin-width="362" data-origin-height="159"/></span><figcaption>HTML</figcaption>
</figure>
</p>


<p>Change Content 버튼을 클릭 시</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="421" data-origin-height="165"><span data-alt="OnClick Change Content Button"><img src="/assets/images/posts/2024/07/23/119-2.png" loading="lazy" width="421" height="165" data-origin-width="421" data-origin-height="165"/></span><figcaption>OnClick Change Content Button</figcaption>
</figure>
</p>

<p>Change Style 버튼 클릭 시</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="407" data-origin-height="197"><span data-alt="OnClick Change Style"><img src="/assets/images/posts/2024/07/23/119-3.png" loading="lazy" width="407" height="197" data-origin-width="407" data-origin-height="197"/></span><figcaption>OnClick Change Style</figcaption>
</figure>
</p>

<p>Toggle Class 버튼 클릭 시</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="417" data-origin-height="195"><span data-alt="Onclick Toggle Class"><img src="/assets/images/posts/2024/07/23/119-4.png" loading="lazy" width="417" height="195" data-origin-width="417" data-origin-height="195"/></span><figcaption>Onclick Toggle Class</figcaption>
</figure>
</p>
