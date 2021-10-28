---
title:  "동적할당"
excerpt: "cpp, new, delete"

categories:
  - Cpp
tags:
  - [cpp, new, delete]

toc: true
toc_sticky: true
 
date: 2021-07-30
last_modified_at: 2021-07-30
---  

***

### C++ 동적할당(dynamic allocation)
c++에서 동적할당 방법은 malloc함수 또는 new연산자가 있다.

* malloc 함수는 바이트 단위의 사이즈를 인자로 받아서 사용 가능한 메모리 공간의 시작 주소를 반환한다. 할당과 동시에 초기화는 할수 없어 기본적으로 쓰레기 값을 가진 메모리 주소를 반환한다.  

* new 연산자는 사용하려는 자료형에 대한 초기값을 인자로 받고 new[] 연산자는 배열의 크기를 인자로 받으며 둘 다 선언과 동시에 초기화가 가능하다.


<br/>


### 할당, 해제
  * new는 자료형 뿐만 아니라 구조체나 클래스 등의 형태도 동적할당이 가능하다.

    ```cpp
    int* iName = new int;
    char* chName = new char;
    .
    .
    .
    struct StructName
    {

    };

    StructName* sName = new StructName;
    .
    .
    .
    class ClassName
    {
    public:
      ClassName(){};
      ~ClassName(){};
    };
    ClassName* cName = new ClassName;
    ```


  * 할당과 동시에 초기화가 가능하다.
    ```cpp
    int* iName = new int(1);
    char* chName = new char('a');
    ```

  * 배열 동적 할당 
    ```cpp
    int* iArray = new int[2];
    int* iArray = new int[2] {1, 2};
    ```

  * delete는 동적할당된 메모리를 해제해준다.
    ```cpp
    delete iName;
    // 배열의 경우 배열로 해제
    delete[] iArray;
    ```

  * 2차원 배열  
    이중포인터를 사용해서 우선 주소를 저장할 배열부터 할당한 다음 반복문을 사용해서 배열안에 동적할당을 해서 2차원 배열을 만든다.

    ```cpp
    int** iArray2D = new int* [2];

    for (int i = 0; i < 2; i++)
    {
      iArray2D[i] = new int[3];
    }

    for (int row = 0; row < 2; row++)
    {
      for (int col = 0; col < 3; col++)
      {
        iArray2D[row][col] = row + col;
        printf("%d, %p\n", iArray2D[row][col], &iArray2D[row][col]);
      }
    }

    for (int i = 0; i < 2; i++)
    {
      delete[] iArray2D[i];
    }

    delete[] iArray2D;
    ```

    해제는 할당의 역순으로 해주어야 이미 해제된 메모리를 찾아가는 에러가 발생하지 않는다.
    
    
    



    