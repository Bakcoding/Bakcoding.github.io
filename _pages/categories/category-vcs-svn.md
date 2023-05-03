---
title: "SVN"  
layout: archive   
permalink: /categories/vcs-svn   
author_profile: true   
sidebar_main: true  
---

{% assign posts = site.categories.VCS-SVN %}
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}