---
title: "파이썬의 철학"
excerpt: "파이썬의 철학"
categories:
  - Python
permalink: /programming/python/71-post/
tags:
  - "Python"
  - "파이썬의 선"
toc: true
toc_sticky: true
date: 2023-08-25
last_modified_at: 2023-08-25
source_url: https://b-note.tistory.com/71
---

<p>프로그래머들은 각자의 개발 철학을 가지고 있다.</p>
<p>프로그래밍 언어들의 다양한 특징들은 개발자들의 철학을 배경으로 만들어지게 된다.</p>

<p>파이썬 또한 개발자의 철학이 담겨 있는 프로그래밍 언어이다. 그 철학은 pep-20으로 알려진 문서에 담겨있다.</p>

<p><a href="https://peps.python.org/pep-0020/" target="_blank" rel="noopener">PEP&nbsp;20&nbsp;&ndash;&nbsp;The&nbsp;Zen&nbsp;of&nbsp;Python</a></p>
<p>문서의 제목을 번역하면 파이썬의 선이다.</p>
<p>여기서 선은 불교용어 선(禪)이다. 서구권에 선이라는 개념을 정착시킨게 일본 불교학자이다 보니 일본식 발음인 젠(zen)이 고유명사가 되었는데 문서에서 사용된 뜻이 불교의 선과 동일한 의미를 가지기 보다는 파이썬의 개발 철학이나 가치와 원칙 등 방향성을 나타내는 의미로 쓰인거같다. 제목도 일반적인 문서스럽지 않은데 이는 파이썬의 공식 문서 대부분이 비슷한 느낌을 준다.</p>

<p>문서의 저자를 보고 Tim Peters가 파이썬을 만든사람인줄 알았지만 알고보니&nbsp;파이썬의 초기 개발자는 Guido van Rossum(귀도 반 로섬)이라는 네덜란드 개발자였다.</p>

<p><a href="https://www.python.org/doc/essays/foreword/" target="_blank" rel="noopener">Foreword&nbsp;for&nbsp;"Programming&nbsp;Python"<span style="background-color: #ffffff; color: #202122; text-align: start;"></span></a></p>

<p>파이썬의 서문에서는 탄생 배경에 대한 인터뷰 내용이 있다. 심심했던 그는 ABC 언어에 영감을 받고 취미로 만들기 시작했다고 하는데 그렇게 만들어진 언어가 지금까지도 많은 사람들에게 사용된다는게 그의 천재적인 면모가 보인다.</p>

<p>다시 파이썬의 선으로 돌아가서 저자인 Tim Peters는 파이썬 초기 설계부터 현재까지 개발과 커뮤니티에 많은 영향을 준 인물이다. 해당 문서는 커뮤니티에 파이썬의 가치와 철학을 공유하고 강조하기 위해서 작성되었으며 커뮤니티 안에서 협업할 때 지켜야할 원칙을 정리하고 제시하는 목적을 가지고 있다.</p>
<p>작성 배경이 그렇다보니 문서의 내용이 다소 가볍고 사용되는 표현들도 유머러스함이 보인다.&nbsp;</p>

<blockquote>Beautiful is better than ugly. (아름다운 것이 추한 것보다 낫다.)<br />Explicit is better than implicit. (명시적인 것이 암시적인 것보다 낫다.)<br />Simple is better than complex. (간결한 것이 복합적인 것보다 낫다.)<br />Complex is better than complicated. (복합적인 것이 복잡한 것보다 낫다.)<br />Flat is better than nested. (수평적인 것이 내포된 것보다 낫다.)<br />Sparse is better than dense. (여유로운 것이 밀집된 것보다 낫다.)<br />Readability counts. (가독성은 중요하다.)<br />Special cases aren't special enough to break the rules.<br />(특별한 경우들은 규칙을 어길 정도로 특별하지 않다.)<br />Although practicality beats purity. (실용성은 순수성을 이긴다.)<br />Errors should never pass silently. (에러는 절대로 조용히 지나가지 않는다.)<br />Unless explicitly silenced. In the face of ambiguity, refuse the temptation to guess.<br />(명시적으로 오류를 감추려는 의도가 아니라면 모호함을 대할 때, 이를 추측하려는 유혹을 거부하라.)<br />There should be one-- and preferably only one --obvious way to do it.<br />(명확하고 가급적이면 유일한 하나의 방법은 항상 존재한다.)<br />Although that way may not be obvious at first unless you're Dutch.<br />(네덜란드인이 아니면 비록 그 방법이 처음에는 명확해 보이지 않더라도. (네덜란드인은&nbsp;<br />귀도 반 로섬을 의미하는것 같다.))<br />Now is better than never. (지금 행동에 옮기는 것이 아예 안 하는 것보다는 낫다.)<br />Although never is often better than *right* now. <br />(비록 아예 안 하는 것이 지금 *당장* 하는 것보다 나을 때도 많지만.)<br />If the implementation is hard to explain, it's a bad idea. (구현 결과를 설명하기 쉽지 않다면, 그것은 나쁜 아이디어이다.)<br />If the implementation is easy to explain, it may be a good idea.<br />(구현 결과를 설명하기 쉽다면, 그것은 좋은 아이디어일지도 모른다.)<br />Namespaces are one honking great idea -- let's do more of those!<br />(네임스페이스는 정말 훌륭한 아이디어다 -- 더 많이 사용하자!)</blockquote>

<p>문서에서 반복해서 명확성, 간결성, 가독성을 강조한다. 이러한 철학으로 인해서 문법면에서는 엄격하며 이를 위한 스타일 가이드도 있다. (<a href="https://peps.python.org/pep-0008/" target="_blank" rel="noopener">PEP 8</a>)&nbsp; 이러한 코드 스타일들은 대부분 기술적인 제한 보다는 프로그래머들간에 지켜야할 관례이다.</p>

<p>예를 들어서 상수의 경우 모두 대문자로 표기하는 것을 규칙으로 한다.</p>
<p>하지만 일반 변수를 모두 대문자로 표기하고 그 값을 마음대로 바꾸어 사용한다고해서 실행이 안되거나 하지 않지만 다른 프로그래머들에게는 상수의 값이 변경되는 예상하지 못한 동작이 될 수 있고 이는 파이썬의 철학과 반대되는 행동이라 볼 수 있다.</p>
