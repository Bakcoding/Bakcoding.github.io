---
title: "Input System 사용시 UI 상호작용 안될때"
excerpt: "Input System 사용시 UI 상호작용 안될때"
categories:
  - Unity
permalink: /develop/unity/148-input-system-ui/
tags:
  - "Unity"
  - "Game Development"
  - "유니티"
  - "인풋 시스템"
toc: true
toc_sticky: true
date: 2024-11-18
last_modified_at: 2024-11-18
source_url: https://b-note.tistory.com/148
---

<p>Player 세팅에서 Input System Package만 사용하는 상태</p>

<p>게임 뷰 창에서 버튼이 클릭되지 않는 문제가 발생했다.</p>

<p>하지만 시뮬레이터 창, 빌드 후에는 정상적으로 동작이 되는 문제가 있었다.</p>

<p>이런저런 방법을 시도해 보다가 혹시나 해서 시뮬레이터 창을 닫고 다시 플레이해 보니</p>

<p>정상적으로 동작이 되었다.</p>

<p>두 창이 모두 활성화된 상태에서 플레이될 때 에디터루프에서 인풋시스템이 초기화하면서 문제가 생긴 건지 별거 아닌 문제 때문에 꽤 시간을 빼앗긴 일이 생겨서 메모해 둔다.</p>
