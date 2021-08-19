---
title:  "클래스 인스턴스화"
excerpt: "cpp, class, instance"

categories:
  - Cpp
tags:
  - [cpp, class, instance]

toc: true
toc_sticky: true
 
date: 2021-07-22
last_modified_at: 2021-07-22
---  

***
<br/>

### 객체와 인스턴스  
객체는 멤버 변수, 메서드 등 속성이나 기능을 가지고 있는 것들을 말한다.  
클래스는 연관된 객체들 끼리 묶어주는 틀의 역할을 한다. 클래스로 부터 만들어낸 객체를 인스턴스라고 하며 이 과정을 인스턴스화라고 한다.  

* 함수와 메서드  
  함수는 특정 톡립된 작업을 수행하는 코드를 말한다. 메서드는 함수에 포함되는 개념으로 클래스, 구조체 열거형에 포함되어있는 함수를 뜻하며 클래스 함수라고도 한다.

<br/>

클래스를 만들고 인스턴스 생성하기 

```cpp
#include <iostream>

class CStudent
{
private:
    char c_mName[20];
    int i_mAge = 0;
    int i_mNumber = 0;

public:
    void SetInformation( const char * _name, int _age, int _number)
    {
        strcpy_s(c_mName, _name);
        i_mAge = _age;
        i_mNumber = _number;
    }

    void PrintInformation()
    {
        std::cout << "NAME : " << c_mName << std::endl 
            << "AGE : " << i_mAge << std::endl 
            << "NUMBER : " << i_mNumber << std::endl;
    }
};


int main()
{
    CStudent student;
    student.SetInformation( "Bak", 17, 12345 );
    student.PrintInformation();

    return 0;
}
```

Student 클래스는 학생의 정보를 저장한다.   
클래스 멤버 변수는 직접적인 접근을 제한하기위해서 private로 선언했다.
private로 선언한 변수는 클래스 외부에서 접근할 수 없기 때문에 메인 함수에서 사용하기 위해서 값을 넣는 함수와 출력하는 함수를 만들고 외부에서는 이 함수를 통해 접근한다.  

<br/>

### 인스턴스화
  * 메인함수에서 클래스 인스턴스를 생성한다.  

    ```cpp
    CStudent student;
    ```
    
    이렇게 생성된 인스턴스는 public으로 지정된 멤버 변수와 메서드에 접근이 가능해진다.  

    ```cpp
    student.SetInformation( "Bak", 17, 12345 );
    student.PrintInformation();
    ```

    값을 초기화 해주는 함수와 출력해 주는 함수를 통해 멤버 변수에 값을 저장하고 출력할 수 가 있다.  

    ![instance](/assets/images/20210723_Posting/1.png) 