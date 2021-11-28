---
title: "노트"  
layout: archive   
permalink: /categories/note   
author_profile: true   
sidebar_main: true  
---

{% assign posts = site.categories.Note %}
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}