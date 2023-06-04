---
title:  "Serialization"
excerpt: "Serialization, Deserialization"

categories:
  - Note
tags:
  - [Serialization, Deserialization]

toc: true
toc_sticky: true
 
date: 2022-03-16
last_modified_at: 2023-06-05
---  

***

<br>

### Serialization

직렬화는 데이터 오브젝트를 일련의 바이트로 변환하여 전송이 용이한 형태로 객체 상태를 변환시켜 저장하는 프로세스이다.

여기서 데이터 오브젝트는 데이터 스토리지 영역 내에서 표현되는 코드와 데이터의 조합을 말한다.

![serialization](/assets/images/posting/20220316/serialization.png) <br>


> 데이터 직렬화는 오브젝트를 바이트 스트림으로 변환하여 저장 또는 전송하기 쉽게하는 프로세스이다.

데이터를 사용하기 위해서는 바이트에서 다시 오브젝트로 구성하는 작업도 필요하다.

<br>


역직렬화는 바이트 형태의 데이터를 오브젝트로 변환하는 역프로세스이다.

오브젝트를 재작성하여 데이터를 프로그래밍 언어의 네이티브 구조로 읽고 수정하기 쉽게 한다.

![serialization](/assets/images/posting/20220316/deserialization.png) <br>


> 직렬화, 역직렬화 프로세스는 함께 동작하여 데이터 오브젝트를 편리한 형태로 변환/재호출한다.

<br>


즉 직렬화는 개체의 저장과 데이터 변환을 모두 포함하는 것이다.
오브젝트는 여러 컴포넌트로 구성되어 있기 때문에 모든 구성요소를 저장하거나 전달하려면 일반적으로 상당한 코딩 작업이 필요하며 그 작업을 간단하게 해주는 직렬화를 사용해서 오브젝트를 공유 가능한 형식으로 변환하여 오브젝트를 저장, 전송한다.

<a href="https://hazelcast.com/glossary/serialization/">참고</a>
