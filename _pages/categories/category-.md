---
title: "Stream Of Consciousness"  
layout: archive   
permalink: /categories/soc 
author_profile: true   
sidebar_main: true  
---

{% assign posts = site.categories.SOC %}
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}