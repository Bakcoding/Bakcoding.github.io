---
title:  "복사 생성자"
excerpt: "cpp, constructor, copy, shallow, deep"

categories:
  - Cpp
tags:
  - [cpp, constructor, copy, shallow, deep]

toc: true
toc_sticky: true
 
date: 2021-08-16
last_modified_at: 2021-08-16
---  

### 복사 생성자(copy constructor)
선언되는 객체와 같은 자료형의 객체를 인수로 전달하는 생성자이다. 인수는 참조자로 전달되며 복사 생성자 정의를 생략할시 디폴트 복사 생성자가 자동으로 만들어진다.

```cpp
#include <iostream>
using namespace std;

class CopyConstructor
{
public:
	CopyConstructor()
	{
		cout << "Constructor Call\n";
	}

	CopyConstructor(int i)
	{
		cout << "Constructor int i Call\n";
	}

	// 복사생성자
	CopyConstructor(const CopyConstructor& _i)
	{
		cout << "CopyyConstructor& _i Call\n";
	}

	~CopyConstructor() {}
};

int main()
{
	CopyConstructor c1;
	CopyConstructor c2(10);
	CopyConstructor c3(c2);

	return 0;
}
```

### 기본 복사 생성자(default copy constructor)
```cpp
#include<iostream>
using namespace std;

class DefalutConstructor
{
	int a, b;
public:
	DefalutConstructor(int _a, int _b) {
		a = _a;
		b = _b;
	}
	void PrintResult() 
	{
		cout << a << ' ' << b << endl;
	}
};
int main(void)
{
	DefalutConstructor p1(10, 20);
	DefalutConstructor p2(p1); // 기본 복사생성자 호출
	p1.PrintResult();
	p2.PrintResult();

	return 0;
}
```

<br/>

**기본 복사 생성자의 문제점**  
얕은 복사로 인한 문제

```cpp
#include <iostream>
using namespace std;

class ShallowCopy
{
	char* name;
	char* id;

public:
	ShallowCopy(const char* _name, const char* _id)
	{
		cout << "Constructor Call\n";

		int nameLength = strlen(_name) + 1;
		this->name = new char[nameLength];
		strcpy_s(name, nameLength * sizeof(char), _name);

		int idLength = strlen(_id) + 1;
		id = new char[idLength];
		strcpy_s(id, idLength * sizeof(char), _id);
	}

	/* 기본 복사 생성자 형태
	ShallowCopy(const ShallowCopy& c)
	{
		name = p.name;
		id = p.id;
	}
	*/

	~ShallowCopy()
	{
		cout << "Desturcotr Call\n";
		delete []name;
		delete []id;
	}

	void PrintResult()
	{
		cout << "Name : " << this->name << "\n" << "ID : "<< this->id << "\n";
	}
};

int main()
{
	ShallowCopy c1("Bak" , "BKDBLOG");
	// 기본 복사 생성자 호출(얕은 복사)
	ShallowCopy c2(c1);

	c1.PrintResult();
	c2.PrintResult();

	return 0;
}
```
* strcpy를 사용할 경우 컴파일러 버전에 따라 strcpy_s의 사용을 권장하며 에러가 발생한다. 해결은 _CRT_SECURE_NO_WARNINGS 나 #pragma warning(disable:4996) 를 사용해서 에러를 무시하거나 strcpy_s를 사용하는 방법이 있다.

* _s는 대부분 버퍼의 공간 초과로 인한 에러를 방지하여 안정성을 추가한 것으로 strcpy_s의 경우도 매개변수로 복사하려는 자료의 크기가 추가로 필요하다.


c2(c1) 작업에서 메모리 할당없이 포인터만 복사하는 얕은 복사가 이루어지고 동일한 주소를 가지게 된다. main함수가 종료될 때 인스턴스들은 소멸자를 호출하고 동적할당한 메모리를 delete하면서 이미 지워진 주소를 한번 더 찾아가기 때문에 에러가 발생한다.  

이 문제를 해결하기 위해서는 메모리를 할당해주는 깊은 복사가 필요하다.

<br/>

### 깊은 복사 생성자
```cpp
DeepCopy(const DeepCopy& c)
{
	int nameLength = strlen(c.name) + 1;
	name = new char[nameLength];
	strcpy_s(name, nameLength, c.name);

	int idLength = strlen(c.id) + 1;
	id = new char[idLength];
	strcpy_s(id, idLength, c.id);
}
```

객체를 인자로 받아서 객체를 생성할 때 메모리를 따로 할당받아 생성되는 깊은 복사가 되도록 하는 복사 생성자이다. 

<br/>

### 복사 생성자 호출 시점
복사 생성자는 기존에 생성된 객체를 인자로 새로운 객체를 초기화 할 때, 함수의 호출로 값에 의해 전달될 때, 함수 내에서 객체를 리턴할 때이다.

* 생성된 객체를 인자로 새로운 객체 초기화
	```cpp
	CopyConstructor c1(10);
	// 복사 생성자 호출
	CopyConstructor c2(c1);
	```

* 함수 호출 시 객체가 인자로 전달될 때
	```cpp
	class ConstructorCall
	{
		int val;
	public:
		ConstructorCall (int _val)
		{
			val = _val;
		}
		ConstructorCall(const ConstructorCall& c)
		{
			cout << "Copy Constructor Call\n";
			val = c.val;
		}
		void PrintResult()
		{
			cout << "value : " << val << "\n";
		}
	}

	void Function(ConstructorCall c)
	{
		c.PrintResult();
	}

	int main()
	{
		ConstructorCall c(10);
		// 객체 c를 인수로 함수에 전달, 복사 생성자 호출
		Function(c);

		return 0;
	}
	```

	객체가 인수로 전달 되는 경우 매개변수에 복사되어 전달하기 때문에 복사 생성자가 호출되며 함수가 종료될 때 매개변수로 복사된 객체가 소멸하면서 소멸자가 호출된다. 따라서 얕은 복사로 인한 에러가 발생할 상황이 생기게 된다.  
	이런 경우 함수의 인자를 참조자로 받게 되면 복사 생성자와 소멸자로 따로 호출하지 않기 때문에 중복 해제로 인한 에러가 발생하지 않는다. 

	```cpp
	void Function(ConstructCall &c)
	{ ~ }
	```

* 함수 내에서 객체를 리턴할 때

	```cpp
	class ConstructorCall
	{
		int val;
	public:
		ConstructorCall (int _val)
		{
			val = _val;
		}
		ConstructorCall(const ConstructorCall& c)
		{
			cout << "Copy Constructor Call\n";
			val = c.val;
		}
		void PrintResult()
		{
			cout << "value : " << val << "\n";
		}
	}
	
	ConstructorCall Function()
	{
		ConstructorCall c(10);
		return c;
	}

	int main()
	{
		Function();

		return 0;
	}
	```

	객체를 반환하는 함수 내에서 객체를 생성한 다음 리턴할 때  생성한 객체를 복사하여 전달한 다음 함수가 종료하면 생성한 객체가 소멸자를 호출한다. 객체의 크기가 큰 경우라면 연산량이 너무 늘어나는 작업인거같다. 