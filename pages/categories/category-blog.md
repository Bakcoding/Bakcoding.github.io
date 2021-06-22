---
title: "Github 블로그"  <!-- 카테고리 페이지 이름 -->
layout: archive <!-- 카테고리 레이아웃 방식 -->
permalink: categories/blog <!-- 이 페이지의 링크 -->
author_profile: true <!-- 이 페이지에 프로필 보이는지 유무 -->
sidebar_main: true 
---

{% assign posts = site.categories.Blog %}
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}