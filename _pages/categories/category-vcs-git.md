---
title: "Git"  
layout: archive   
permalink: /categories/vcs-git   
author_profile: true   
sidebar_main: true  
---

{% assign posts = site.categories.VCS-Git %}
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}