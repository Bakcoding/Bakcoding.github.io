---
title:  "메타데이터"
excerpt: "csharp, identifier"

categories:
  - CSharp
tags:
  - [csharp, identifier]

toc: true
toc_sticky: true
 
date: 2022-02-15 
last_modified_at: 2022-02-15
---

### 데이터와 메타데이터

메타데이터란 데이터에 대한 설명을 위한 데이터이다. 

<br>

![file-data](/assets/images/20220219_Posting/data-metadata.jpg)

<br>

이미지 파일을 예로 들어서 이미지 자체의 데이터를 설명하기 위한 파일 크기, 너비, 높이 등의 정보들이 메타데이터이다.

<br>

#### 프로그래밍에선?

개발자가 구현한 코드가 데이터라고 한다면 그 코드가 어떤 클래스와 메서드로 구성되어있는지 코드의 성격에 대한 설명이 메타데이터가 된다.

![code-data](/assets/images/20220219_Posting/codedata.jpg)

<br>

#### 닷넷호환언어

CLR에서 동작하는 실행 파일은 자기 서술적인(self descriptive) 메타데이터를 제공한다.  

외부에서는 이런 정보를 리플렉션(reflection)이라는 기술을 통해 사용할 수 있다. 

따라서 닷넷 호환 언어를 직접 개발할 때는 중간 언어 코드와 함께 그에 대한 메타데어터도 생성되도록 만들어야한다.  

<br>

C#에서도 마찬가지로 컴파일된 EXE/DLL 파일에는 메타데이터가 담겨 있으며 다른 사람이 만든 파일에서 어떤 클래스와 메서드가 제공되는지 메타데이터를 통해 확인할 수 있다.

