---
title: "Web"
layout: archive
permalink: categories/web
author_profile: true
sidebar_main: true
---


{% assign posts = site.categories.WEB %}
{% for post in posts %} {% include archive-single.html type=page.entries_layout %} {% endfor %}