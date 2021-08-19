---
title:  "네임스페이스"
excerpt: "cpp, oop, namespace, using"

categories:
  - Cpp
tags:
  - [cpp, oop, namespace, using]

toc: true
toc_sticky: true
 
date: 2021-08-12
last_modified_at: 2021-08-12
---  

***

### 모듈(module)
프로그래밍에서 모듈이란 그 자체로 하나의 완성된 기능을 가지는 독립된 것으로 객체지향 프로그래밍이 알려지면서 클래스와 라이브러리가 발전하면서 생겨난 개념이다. 

본체에서 분리된 작은 부분으로 필요할 때 합류하여 그 기능을 수행하는 것으로 한가지 기능을 수행하는 코드의 모음을 모듈이라고 할 수 있다.  

모듈화는 소스 코드 덩어리를 기능 단위의 조각들로 나누는 것을 말한다.  

<br/>  

**모듈의 특징**
* 한가지 기능만 수행(unity)
* 간단 명료(smallness)
* 단순성(simplicity)
* 독립성(independency)

위 특징을 가지는 모듈은 수정과 재사용이 용이하며 유지관리가 쉽다는 장점을 가진다.

<br/>

### 네임스페이스(namespace)
객체지향 프로그래밍의 단점 중 하나는 코드의 양이 많아진다는 것이다. 프로젝트가 커질수록 사용되는 변수명이나 함수명이 늘어나게 되면서 중복으로 충돌하는 경우가 생길 수 있다. 이 때 중복으로 인한 오류를 피할 수 있는 방법이 네임스페이스를 사용하는 것이다.

```cpp
namespace printA
{
	int a = 3;

	void Print(int _a)
	{
		std::cout << "Value : " << _a << std::endl;
	}
}

namespace printB
{
	int a = 2;

	void Print(int* _a)
	{
		std::cout << "Adress : " << _a << std::endl;
	}
}

int main()
{
	int a = 10;
	int* pa = &a;

	printA::Print(a);
	printB::Print(pa);
	
	std::cout << printA::a << " : " << printB::a << std::endl;

	// 출력
	// Value : 10
	// Adress : 00EFFED0
	// 3 : 2

	return 0;
}
```
네임스페이스를 사용하는 방법은 범위지정 연산자 :: 를 사용해서 이름으로 접근한다. 동일한 이름의 함수와 변수가 네임스페이스로 구분되어서 동작하는걸 볼 수 있다. 

<br/>

### 명시적 사용 using
네임스페이스 내부에 접근하기 위해서는 범위지정 연산자를 써줘야한다. 만약 여러번 사용해야하는 경우라면 같은 문장을 반복해서 작성하는 번거러움이 생긴다.

출력과 줄 바꿈 처럼 자주 사용되는 함수의 경우에 using을 통한 선언으로 std:: 를 생략하여 표현할 수 있다.

```cpp
// 해당 네임스페이스 전체 명시
using namespace std;

// 네임스페이스에서 특정한 것만 명시
using std::cout;
using std::endl;
```

만약 printA와 printB 처럼 동일한 이름을 가지는 함수를 사용하는 경우라면 생략하여 사용할 수 없고 꼭 명시해 주어야한다.  

여러 라이브러리를 사용하다보면 중복된 변수, 함수명이 있을 수 있기 때문에 라이브러리에 대한 숙지가 부족하다면 전체적인 명시는 에러를 발생시킬 수 있다.

