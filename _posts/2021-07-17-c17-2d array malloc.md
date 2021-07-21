---
title:  "동적할당으로 2차원 배열"
excerpt: "C, malloc, NULL, 2D, array"

categories:
  - C
tags:
  - [C, malloc, NULL, 2D, array]

toc: true
toc_sticky: true
 
date: 2021-07-17
last_modified_at: 2021-07-17
---  

**이중 포인터 동적 메모리 할당**  
동적할당의 배열같은 특성을 이용하면 2차원 배열처럼 사용이 가능하다.  
배열의 행으로 사용할 메모리 공간을 동적할당하고 그 공간안에 또 동적할당을 해준다. 주소를 저장한 변수의 주소를 저장하기 위해서 이중 포인터를 사용한다.

<br/>

### 1. 이중 포인터
  * 포인터 변수의 메모리 주소를 저장한다.  
    ```c
    int a = 1;
    int* pa = &a;
    int** ppa = &pa;

    // a의 주소
    printf("%p", &a);
    printf("%p", pa);

    // pa의 주소
    printf("%p", &pa);
    printf("%p", ppa);

    // 값 출력
    printf("%d", a);
    printf("%d", *pa);
    printf("%d", **ppa);
    ```  

    변수들은 다음과 같이 값을 저장하고 접근한다.  

    ![doubleP](/assets/images/20210720_Posting/1.png)  

<br/>

### 2. 2차원 배열 구조 동적할당
  * 배열안에 배열을 요소로 받는 2차원 배열처럼 동적할당도 이와 같은 구조로 만들 수 있다.  

    ```c
    int** ppArr2D = (int**)malloc(sizeof(int*) * 2);
    *(ppArr2D + 0) = (int*)malloc(sizeof(int) * 3);
    *(ppArr2D + 1) = (int*)malloc(sizeof(int) * 3);

    *(*(ppArr2D + 0) + 0) = 1;
    *(*(ppArr2D + 0) + 1) = 2;
    *(*(ppArr2D + 0) + 2) = 3;
    *(*(ppArr2D + 1) + 0) = 4;
    *(*(ppArr2D + 1) + 1) = 5;
    *(*(ppArr2D + 1) + 2) = 6;

    /*
    위와 동일함
    *(ppArr2D[0] + 0) = 1;
    *(ppArr2D[0] + 1) = 2;
    *(ppArr2D[0] + 2) = 3;
    *(ppArr2D[1] + 0) = 4;
    *(ppArr2D[1] + 1) = 5;
    *(ppArr2D[1] + 2) = 6;
    */

    for (int row = 0; row < 2; row++)
    {
      for (int col = 0; col < 3; col++)
      {
         printf("%d (%p)\n", *(*(ppArr2D + row) + col), &(*(*(ppArr2D + row) + col)));
      }
    }

    if (*(ppArr2D + 1) != NULL)
    {
        free(*(ppArr2D + 1));
        *(ppArr2D + 1) = NULL;
    }

    if (ppArr2D[0] != NULL)
    {
        free(ppArr2D[0]);
        ppArr2D[0] = NULL;
    }

    if (ppArr2D != NULL)
    {
        free(ppArr2D);
        ppArr2D = NULL;
    }
    ```  
  * 선언  
    먼저 배열의 행에 해당하는 공간을 할당한 다음 그 공간안에 또 여러개의 공간을 할당하는 방식이다.  

    사용하는 방식과 구조는 동일하지만 각 메모리 주소를 출력해보면 차이가 있다.  

    ![doubleP](/assets/images/20210720_Posting/2.png)

    ```c
    *(ppArr2D + 0) = (int*)malloc(sizeof(int) * 3);
    *(ppArr2D + 1) = (int*)malloc(sizeof(int) * 3);
    ```
    
    메모리 주소를 할당할 때 개별적으로 선언하기 때문에 행끼리 주소가 연속되지가 않는다. 그래서 2차원 배열을 1차원 형식으로 접근할시 동적할당 배열은 제대로 동작하지 않게된다.  
  
  
    ![doubleP](/assets/images/20210720_Posting/3.png)

  * 해제    
    해제는 할당한 메모리 모두 각 각 해주어야한다. 이 때 해제는 할당의 역순으로 해주어야지 사용중인 공간이 해제되어서 에러가 발생하는 일이 생기지 않는다.  
    
