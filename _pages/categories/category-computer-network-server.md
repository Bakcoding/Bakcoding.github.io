---
title: "Server"  
layout: archive   
permalink: /categories/computer-network-server 
author_profile: true   
sidebar_main: true  
---

{% assign posts = site.categories.Server %}
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}