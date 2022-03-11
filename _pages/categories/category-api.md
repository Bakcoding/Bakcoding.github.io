---
title: "API"  
layout: archive   
permalink: /categories/api  
author_profile: true   
sidebar_main: true  
---

{% assign posts = site.categories.API %}
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}