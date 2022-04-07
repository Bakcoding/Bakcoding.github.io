---
title:  "C# XML 주석"
excerpt: "csharp, xml, tags, summary"

categories:
  - CSharp
tags:
  - [csharp, xml, tags, summary]

toc: true
toc_sticky: true
 
date: 2022-04-07 
last_modified_at: 2022-04-07
---

***

<br>

### XML 주석

컴파일러의 인텔리전스를 통해서 설명을 덧붙일 수 있다.

일반적인 주석은 두 개의 슬래시로 작성되지만 XML 주석은 세 개의 주석으로 표현된다.

<br>

### 자주 사용되는 태그

* summary

  다음에 올 클래스, 변수, 메서드 등에 대한 설명을 추가한다.

  이름 위에 커서를 올리면 설명이 뜨게 된다. 

  ```cpp
  /// <summary>
	/// 이 변수는 나이를 저장
	/// </summary>
	int age = 0;
	/// <summary>
	/// 이 변수는 이름을 저장
	/// </summary>
	string name = "";
  ```

  ![summary](/assets/images/20220407_Posting/summary.png)
  <br>

* prama

  메서드의 매개변수에 대한 설명을 추가한다.

  ```cpp
  /// <summary>
	/// Test 메서드
	/// </summary>
	/// <param name="age"> 이 값은 나이를 변경 </param>
	/// <param name="name"> 이 값은 이름을 변경 </param>
	void TestMethod(int _age, string _name)
	{
		age = _age;
		name = _name;
	}
  ```

  ![param](/assets/images/20220407_Posting/param.png)
  <br>

* remarks

* returns

  값을 반환하는 메서드에서 반환값에 대한 설명을 추가한다.

  ```cpp
  /// <summary>
	/// 키를 반환하는 메서드
	/// </summary>
	/// <returns>반환 값에 대한 설명을 추가하는 태그</returns>
	int GetHeight()
	{
		return height;
	}
  ```

  ![returns](/assets/images/20220407_Posting/returns.png)
  <br>


<a href="https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/xmldoc/recommended-tags#remarks">태그 더 보기</a>
