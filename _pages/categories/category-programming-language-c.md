---
title: "C"  
layout: archive   
permalink: /categories/programming-language-c   
author_profile: true   
sidebar_main: true  
---

{% assign posts = site.categories.C %}
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}