---
title: "C#"  
layout: archive   
permalink: /categories/programming-language-csharp 
author_profile: true   
sidebar_main: true  
---

{% assign posts = site.categories.CSharp %}
{% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}