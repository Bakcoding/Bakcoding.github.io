---
title: "My Project : ThreeBullets"  
layout: archive   
permalink: /categories/develop-threebullets   
author_profile: true   
sidebar_main: true  
---

{% assign posts = site.categories.ThreeBullets %}
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}