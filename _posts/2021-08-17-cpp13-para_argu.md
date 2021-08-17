---
title:  "매개변수, 전달인자"
excerpt: "cpp, parameter, argument"

categories:
  - Cpp
tags:
  - [cpp, parameter, argument]

toc: true
toc_sticky: true
 
date: 2021-08-17
last_modified_at: 2021-08-17
---  


프로그래밍 용어들은 어디서 본 듯 한 단어들인데 막상 알고나면 전혀 다른 의미를 가지는 경우도 있고 하나의 용어가 불려지는 방식이 사람마다 다르기도 하다. 검색하다보면 이런 용어들과 관련한 토론들이 많이 보이는데 이건 이거다 라고 확정짓기 힘든 부분들이 보인다. 그냥 영어단어 자체를 받아들이고 이해할 수 있는게 가장 좋은거같다.


### 매개변수(parameter)
파라미터, 매개변수, 가인수 등으로 불린다. 위키에서는 [매개변수](https://ko.wikipedia.org/wiki/%EB%A7%A4%EA%B0%9C%EB%B3%80%EC%88%98_(%EC%BB%B4%ED%93%A8%ED%84%B0_%ED%94%84%EB%A1%9C%EA%B7%B8%EB%9E%98%EB%B0%8D)#%EB%A7%A4%EA%B0%9C%EB%B3%80%EC%88%98%EC%99%80_%EC%A0%84%EB%8B%AC%EC%9D%B8%EC%9E%90)로 표현하는데 내가 생각했을 때도 매개변수가 적당한 명칭인거같다.

매개변수는 변수의 한 종류로서 함수 내부에서 사용할 변수와 외부에서 전달받은 값 둘 사이를 이어준다. 즉 외부와 함수 내부로 매개해주는 역할을 하기 때문에 매개변수라고 부르는거 같다. 변수이기 때문에 사용자 정의 자료형을 포함한 다양한 자료형들이 올 수 있다.  

```cpp
void Parameter(int _a) {}	// 매개변수 int _a
```


<br/>

### 전달인자(argument)
아규먼트, 전달인자, 실인수, 인수/인자 등으로 불린다.  위키에서는 전달인자로 표현하는데 의미가 가장 잘맞는거같다. 전달인자는 매개변수를 가지는 함수에 전달하는 값을 말하며 전달인자와 매개변수는 동일한 자료형을 가져야한다.  

```cpp
void Parameter(int _a) {}
int main()
{
	Parameter(10);	// 전달인자 10
	int a = 0;
	Parameter(a);	// 전달인자 a

	return 0;
}
```

매개변수 형태에 따라서 값이나 주소를 복사하는지 변수를 참조하는지 정할 수 있다.

### 기본 매개변수(default parameter)
매개변수에 기본 값을 지정하면 전달인자를 받지 않을 경우 기본 값이 함수에 제공된다.

```cpp
void Function(int _a = 0, int _b = 0)
{
	_a *= 10;
	_b *= 10;

	cout << _a << "," << _b << "\n";
}
// void Function(int _a, int _b = 0) 하나만 선언할 수 도 있음

int main()
{
	Function(1, 2);  // 10, 20
	Function(1);	 // 10, 0
	Function(0);	 // 0, 0

	return 0;
}
```

기본 매개변수를 선언할 때는 마지막부터 선언되어야 한다. 

```cpp
// 이런 형태는 불가능하다.
void Function(int _a = 0, int _b) 
```

함수 오버로딩이 문제가 생길 수 있다.
```cpp
void Function(int _a)
void Function(int _a, int _b = 0)

int main()
{
	Function(10);	//	error
}
==================================

void Function(int _a = 0)
void Function(char _a = 'a')

int main()
{
	Function();	// error

	return 0;
}
```

어떤 함수를 사용할지 구분할 수 있는 근거가 부족하다.
