---
title: "VR"  
layout: archive   
permalink: /categories/vr 
author_profile: true   
sidebar_main: true  
---

{% assign posts = site.categories.VR %}
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}