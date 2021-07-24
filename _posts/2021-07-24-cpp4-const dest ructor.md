---
title:  "생성자와 소멸자"
excerpt: "cpp, constructor, destructor"

categories:
  - Cpp
tags:
  - [cpp, constructor, destructor]

toc: true
toc_sticky: true
 
date: 2021-07-24
last_modified_at: 2021-07-24
---  

### 1. 생성자(constructor)
```cpp
class Student
{
private:
  int i_mA;
  int i_mB;
  int i_mC;

public:
  Student() {};
}
```
* Student();  
생성자는 클래스 내에서 만들어 주며 클래스의 이름과 동일하게 만들어야 한다.  

* 반환형   
반환형은 따로 갖지 않지만 실제로는 생성된 객체의 참조값을 반환한다. 따라서 객체를 생성하려면 생성자가 무조건 호출되어야 하는 이유가 된다.

* 기본 생성자  
매개 변수를 갖지 않거나 모두 기본값으로 설정된 매개 변수를 가지고 있는 생성자를 말한다. 인스턴스를 만들 때 초기화를 하지않으면 기본 생성자가 호출 된다. 

<br/>

### 2. 오버로딩(overloading)
생성자 또한 함수이기 때문에 오버로딩이 가능하다.  
오버로딩을 사용해서 다양하게 생성자를 만들 수 있어 원하는 값으로 초기화할 수 있다.

```cpp
CConstructor() { printf("기본생성자 호출\n"); };
CConstructor(int _a, int _b, int _c)
{
   printf("매개변수 3개 생성자 호출\n");
    i_mA = _a;
    i_mB = _b;
    i_mC = _c;
}
CConstructor(int _a)
{
    printf("매개변수 1개 생성자 호출\n");
    i_mA = _a;
}

void PrintFunc()
{
    std::cout << i_mA << " " << i_mB << " " << i_mC << " " << std::endl;
}

int main()
{
    CConstructor a;
    CConstructor b(4, 5, 6);
    CConstructor c(9);

    a.PrintFunc();
    b.PrintFunc();
    c.PrintFunc();

	return 0;
}
```

![instance](/assets/images/20210724_Posting/1.png)  


각 생성자에 출력을 만들어 놓고 인스턴시 어떻게 호출되는지 확인해본다.  
인스턴스 순서대로 생성자가 호출되고 메인 함수가 실행되는걸 볼 수 있다.  

### 3. 암시적 생성자
클래스에 따로 생성자를 만들지 않았다면 c++에서는 컴파일러가 자동으로 기본 생성자를 생성한다. 이 생성자를 암시적 생성자라고 하며 객체를 만들 수 있지만 멤버 변수를 초기화하지는 않기 때문에 항상 하나 이상의 생성자를 정의하는게 좋다.  


<br/>

### 4. 소멸자(destructor)
인스턴스가 생성될 때 생성자를 호출했다면 소멸되는 시점에서 소멸자를 호출한다. 

```cpp
class CTest
{
  CTest() {};
  ~CTest() {};
}
```

소멸자도 생성자 처럼 반환형은 쓰지 않으며 클래스 이름과 똑같이 만들고 앞에 ~를 붙여준다.  
소멸자의 호출 시점을 출력을 사용해서 확인해 본다.

![instance](/assets/images/20210724_Posting/2.png)  

각 인스턴스가 소멸될 때 마다 소멸자가 호출되는걸 볼 수 있다.


<br/>

이렇게 생성자와 소멸자를 사용하면 다른 작업이 필요없이 클래스는 스스로 초기화하고 정리되면서 사용을 편리하게 해준다.