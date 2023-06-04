---
title:  "동적할당"
excerpt: "C, malloc, NULL"

categories:
  - C
tags:
  - [C, malloc, NULL]

toc: true
toc_sticky: true
 
date: 2021-07-16
last_modified_at: 2023-06-04
---  

***

### 동적할당  
동적할당은 프로그램이 실행되는 동안 사용할 메모리 공간을 임의로 할당하는 것을 말한다.  
동적으로 할당된 메모리는 사용이 끝나면 다시 컴퓨터에게 반납을 해야하는데 이 방식이 언어마다 다르며 C/C++의 경우 사용자가 직접 해제해야 하기 때문에 사용하기 더 까다롭지만 반납 시점을 임의로 정할 수 있어 메모리 관리에 유리하다는 큰 장점을 가지기도 한다.  

<br/>

### 1. 정적할당과 동적할당
  * 정적할당  
    * 정적할당은 일반적인 변수 선언방식을 통해 메모리를 할당하는 방식을 말한다.  
    * 프로그램이 시작되기 전에 미리 정해진 크기의 메모리를 할당하게 된다.
    * 크기가 고정되어 있기 때문에 더 큰 입력이 들어오면 처리하지 못하고 더 작은 입력이 들어오면 메모리가 낭비된다.  
    * 컴퓨터가 알아서 지워주기 때문에 해제로 인한 문제가 발생하지 않는다.  

  * 동적할당  
    * 프로그램이 실행 중에 동적으로 메모리가 할당된다.  
    * 할당 메모리 크기를 사용자 임의로 설정이 가능하다.  
    * 사용이 끝난 메모리는 반드시 해제가 필요하다.

    <br/>

### 2. 동적할당과 해제
   ```c
  #include <stdio.h>
  #include <malloc.h>

  int main()
  {
    int* ipVal = (int*)malloc(sizeof(int) * 2);
    
    *ipVal = 1;
    *(ipVal + 1) = 2;

    for (int i = 0; i < 2; i++)
    {
        printf("%d, %p\n", *(ipVal + i), (ipVal + i));
    }

    free(ipVal);

    return 0;
  }
  ```
  
  **void\* malloc\(size_t size \* n\)**

  * (int*)    
    void*는 어떠한 타입으로도 바뀔 수 있기 때문에 형변환을 사용해 원하는 타입을 지정할 수 있다. 

  * malloc  
      동적할당 함수 malloc을 사용하기 위해서 \<malloch>또는 \<stdlib.h> 헤더 파일이 필요하다.

  * (size_t size * n)  
     동적할당할 메모리의 크기와 수를 결정한다. 여러개를 할당하면 배열처럼 사용이 가능하다.  


    ![dynamic_allocate](/assets/images/posting/20210716/dynamic_allocate.png)  

    배열처럼 접근이 가능하며 메모리 주소도 연속한다. 

  * free(ipVal);  
    할당한 메모리 사용이 끝나면 해제를 해준다. 동적할당에서 가장 중요한 부분이며 해제되지 않은 메모리는 계속해서 남아있어 메모리 누수 현상(Memory Leak)를 일으킨다.

    메모리 해제의 경우 중복해서 해제를 시도하여 에러를 발생시키도 한다. 따라서 예외처리를 통해 에러를 줄일 수 있다.

    ```c
    if (ipVal != NULL)
    {
      free(ipVal);
      ipVal = NULL;
    }
    ```

    free는 메모리 내용을 지우면서 할당된 공간을 해제한다. 하지만 포인터에 그 주소는 남기 때문에 중복해제시 다시 그 주소를 찾아가려고 시도하기 때문에 오류가 발생한다. 

    이런 문제를 예방하기 위해서 해제시 NULL을 대입해 아무것도 남는것이 없도록 만든다.  

    동적할당은 자주 사용되기 때문에 매번 해제 코드를 쓰는것은 번거로운 일이다. 그래서 일반적으로 해제는 매크로를 작성해서 편의성을 높인다.

    ```c
    #define SAFE_FREE(p) if((p) != NULL){free((p)); (p) = NULL;}

    int main()
    {
      int* ipVal = (int*)malloc(sizeof(int));

      SAFE_FREE(ipVal);
    }
    ```

    하지만 이 방식은 에러를 발생시킬 여지가 있다.

    ```c
    if (*ipVal > 5)
      SAFE_FREE(ipVal);
    else
      return -1;
    ```
    위 코드처럼 조건문에 중괄호를 생략하여 사용할 경우 이상없이 동작하는거처럼 보이지만 매크로를 풀어서 써보면

    ```c
    if (*ipVal > 5)
      if (ipVal != NULL)
      {
          free(ipVal);
          ipVal = NULL;
      }
      else
        return -1;
    ```

    이 처럼 else 부분이 매크로의 나머지 경우를 처리하는 에러가 발생한다.

    자주 발생하는 문제는 아니지만 혹시나 발생하면 큰 문제로 이어지기 때문에 더 안전한 방식이 만들어 졌다.

    ```c 
    #define SAFE_FREE(p) do {if((p) != NULL){free((p)); (p) = NULL;}} while (0);
    
    // 보기쉽게
    do 
    { 
      if ((p) != NULL)
      {
        free((p));
        (p) = NULL;
      }
    } while (0);

    ```

    한 번만 동작하는 do while 반복문을 통해서 전보다 더 일관적인 작동을 하도록 만들어졌다.