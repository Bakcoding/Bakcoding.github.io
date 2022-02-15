---
title:  "null"
excerpt: "csharp, null"

categories:
  - CSharp
tags:
  - [csharp, \null]

toc: true
toc_sticky: true
 
date: 2022-02-15 
last_modified_at: 2022-02-15
---

### NULL

메모리 상에 어떤 데이터도 가지고 있지 않음을 나타내는 단어이다. C#에서는 소문자인 null 키워드를 사용한다.

null을 가질 수 있는 값은 reference type이고 value type은 가질 수 없다. C# 2.0 이후부터는 value type도 null을 가질 수 있게 만들 수 있는데 이를 Nullable Type이라고 한다.  

물음표(?)를 자료형 뒤에 붙이면 null을 가질 수 있는 Nullable Type이 된다. 

```cs
int? i = null;
i = 10;
```

이는 데이터베이스 처럼 null 값을 허용하는 INT 컬럼을 만들 때 C#에서 int?로 매핑할 수 있다.  
