---
title:  "Github 블로그 카테고리 생성"
excerpt: "Github, Jekyll, Blog, Category"

categories:
  - Blog
tags:
  - [Github, Jekyll, Blog, Category]

toc: true
toc_sticky: true
 
date: 2022-03-30
last_modified_at: 2022-03-30
---

***

### Gitblog 카테고리 추가하기

페이지의 카테고리를 추가한다.

크게 분류를 나누고 그 안에서 작은 소주제로 분류하는 방식으로 만들어 본다. Jekyll로 페이지를 생성했다면 동일하게 적용이 가능하다.

<br>

### 카테고리 생성

포스트 글의 categories 이 소주제에 해당하는 것들이다. 

해당 블로그를 저장한 폴더를 열고

_includes > _pages > _categories 폴더에 카테고리 파일을 생성한다. 파일은 마크다운 확장자로 기본 형식은 다음과 같다.

```md
\---
title: "C"  <!-- 카테고리 이름 -->
layout: archive   
permalink: /categories/c   <!-- 현재 파일의 이름 -->
author_profile: true   
sidebar_main: true  
\---

{% assign posts = site.categories.C %}  <!-- 포스트 글에서 categories 에 작성될 카테고리 -->
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}
```

여기서 수정해야할 부분은 title, permalink, assign posts 부분이다.

* title : 페이지에 표시될 카테고리 명에 해당한다.

* permalink : 현재 카테고리 파일의 파일명이다. 이 파일명을 통해서 카테고리를 목록에 표시한다.

* assign posts : site.categories.'' 마지막 부분에 포스트 글 작성시 categories 항목에 작성할 양식을 정한다. 

이 과정을 통해서 카테고리 페이지가 생성되었다. for ~ endfor 를 통해서 전체 포스트 글을 순회하면서 해당 카테고리의 글들을 가져와서 페이지에 표시하게 된다.

하지만 현재 이 카테고리 페이지는 접근할 방법이 블로그 페이지 상에는 존재하지 않기 때문에 블로그에 표시해주는 과정이 필요하다.

<br>

### 페이지에 카테고리 표시

페이지에 실제로 반영되기 위해서는 html 태그로 페이지를 불러오는 작업이 필요하다.

_includes > nav_list_main 파일을 열어본다.

```html
<nav class="nav__list">
    <input id="ac-toc" name="accordion-toc" type="checkbox" />
    <label for="ac-toc">{{ site.data.ui-text[site.locale].menu_label }}</label>
    <ul class="nav__items" id="category_tag_menu">
        <li>
          <!-- 카테고리 대분류 -->
          <ul>
            <!-- 카테고리 소분류 -->
            <li></li>
            <li></li>
            <li></li>
          <ul>
        </li>
    </ul>
</nav>
```

여기서 필요한 부분은 nav_items 클래스의 ul 태그 안에서 부터이다.

li 태그는 리스트를 만드는 기능을 하며 이 리스트를 한 묶음으로 만드는 태그가 ul 태그이다.

우선 li 태그로 대분류를 만들고 그 안에서 다시 소분류를 묶어주는 방식으로 만든다.

```html
<li>
  <!-- 대분류 제목을 지정한다. span 태그는 스타일을 적용시키기 위해 사용한다. -->
  <span class="nav__sub-title">C/C++</span>
  <ul>
    <!-- 반복문, 전체 카테고리를 순회하면서 해당 카테고리를 가져온다. -->
    {% for category in site.categories %}
    <!-- 카테고리명이 C 인경우 -->
    {% if category[0] == "C" %}
    <li>
      <!-- 해당 카테고리 페이지 링크를 걸고 카테고리 명을 표시한다. -->
      <a href="/categories/c" class="toc__menu">
        C ({{category[1].size}})
      </a>
    </li>
    {% endif %}
    {% endfor %}
  </ul>
</li>
```

이 코드에서는 categories 폴더를 순회하면서 내가 표시할 카테고리를 지정하고 어떤식으로 링크를 만들지 정하는 것이다.

a 태그로 작성한 C 라는 문자에 href로 링크를 걸어서 C를 클릭하면 C 카테고리에 해당하는 포스팅 글들이 나열된 페이지로 연결되도록 한다.

이렇게 하면 이제 블로그 페이지에 카테고리 영역에 내가 만든 C/C++ 대분류 속 C 카테고리가 생성된것을 확인할 수 있다. 주의할 점은 해당 카테고리의 글이 하나 이상 존재해야 표시된다.

<br>

정리하자면 우선 카테고리로 만들 페이지를 생성한 다음 이 페이지를 블로그에서 보이도록 만들어 주는게 전부인 간단한 작업이다.
