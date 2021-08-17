---
title:  "템플릿"
excerpt: "cpp, template, function, class, type"

categories:
  - Cpp
tags:
  - [cpp, template, function, class, type]

toc: true
toc_sticky: true
 
date: 2021-08-17
last_modified_at: 2021-08-17
---  

### 일반화 프로그래밍(generic programming)
c++ 언어가 가지는 특징 중 하나로 데이터를 중시하는 객체 지향과는 달리 알고리즘에 중점을 둔다.  
이런 일반화 프로그래밍을 지원하는 대표적인 기능 중 하나가 템플릿이다.

<br/>

### 템플릿(template)
매개변수의 타입에 따라 함수나 클래스를 생성하는 것을 말한다.  
타입마다 별도의 함수나 클래스를 만들지 않고 여러 타입에서 동작할 수 있는 하나의 함수나 클래스를 만들 수 있다.

* 함수 템플릿
	```cpp
	#include <iostream>
	using namespace std;

	template <typename T>
	T Sum(T a, T b)
	{
		return a + b;
	}

	int main()
	{
		int a = 1;
		int b = 2;
		float c = 1.2f;
		float d = 2.4f;
		string e = "Hello";
		string f = " World";

		int result1 = Sum(a, b);
		float result2 = Sum(c, d);
		string result3 = Sum(e, f);

		cout << "a + b = " << result1 << "\n";
		cout << "c + d = " << result2 << "\n";
		cout << "e + f = " << result3 << "\n";

		return 0;
	}

	// 출력
	// a + b = 3
	// c + d = 3.6
	// e + f = Hello World
	```
함수 템플릿을 통해 하나의 함수로 정수형과 실수형 모두 같은 동작을 하였다. 이렇게 정의된 템플릿에서 특정 타입에 대해서만 따로 정의를 두는 것도 가능하며 이를 명시적 특수화라고 한다.  

* 명시적 특수화(explicit specialization)
	```cpp
	template <> 
	double Sum<double>(double a, double b)
	{
		return a * b;
	}

	int main()
	{
	int a = 1;
	int b = 2;
	float c = 1.2f;
	float d = 2.4f;
	string e = "Hello";
	string f = " World";
	double g = 3.14;
	double h = 1.59;

	int result1 = Sum(a, b);
	float result2 = Sum(c, d);
	string result3 = Sum(e, f);
	double result4 = Sum(g, h);

	cout << "a + b = " << result1 << "\n";
	cout << "c + d = " << result2 << "\n";
	cout << "e + f = " << result3 << "\n";
	cout << "g * h = " << result4 << "\n";

	return 0;
	}

	// 출력
	// a + b = 3
	// c + d = 3.6
	// e + f = Hello World
	// g * h = 4.9926
	```

* 클래스 템플릿(class template)  
	클래스를 일반화해서 선언한다. 함수 템플릿과 동작은 같으며 대상만 다르다. 타입에 따라 다르게 동작하는 클래스 집합을 만들어 전달인자에 따라 별도의 클래스를 만들 수 있게 된다.

	```cpp
	#include <iostream>
	using namespace std;

	template <class T>
	class ClassTemplate
	{
		T data;
	public:
		ClassTemplate(T _data)
		{
			data = _data;
		}
		T GetData()
		{
			return data;
		}
	};

	int main()
	{
		ClassTemplate<string> str_data("Bakcoding");
		ClassTemplate<int> int_data(1234);

		cout << str_data.GetData() << "\n";
		cout << int_data.GetData() << "\n";

		return 0;
	}
	```
	함수 템플릿은 컴파일러가 전달된 매개변수의 타입으로 함수를 생성해주었다면 클래스 템플릿은 인스턴스를 만들 때 사용자가 타입을 명시해야한다.  

	
	
* 명시적 특수화(explicit specialization)  
클래스 템플릿도 명시적 특수화가 가능하다.  

	```cpp
	template <>
	class CT<double>
	{
		...
	};

* 부분 특수화(partial specialization)  
템플릿 인수가 두 개 이상이고 그 중 일부에 대해서만 특수화가 필요한 경우 부분 특수화가 가능하다.

	```cpp
	//template <typename T1, typename T2>를 double에 대한 부분 특수화 시키면
	template <typename T1> 
	class CT<T1, double>
	{
		...
	};
	```

<br/>

템플릿은 중복되는 코드를 줄일 수 있고 활용성도 다양하다. 하지만 선언하는 순간 정의가 같이 메모리에 올라가서 컴파일 타임이 비교적 느려지게 되고 코드의 선언과 정의를 파일로 분할해서 관리할 수 없기 때문에 가독성이 떨어지기도 한다. 장점과 단점이 명확하기 때문에 많은 숙련도를 요구하는 기능이라고 생각이 된다.