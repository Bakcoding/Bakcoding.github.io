---
title:  "다차원 배열"
excerpt: "csharp, array, multi-dimentional"

categories:
  - CSharp
tags:
  - [csharp, array, multi-dimentional]

toc: true
toc_sticky: true
 
date: 2022-02-20 
last_modified_at: 2022-02-20
---

### 다차원 배열

multi dimentional

차수가 2 이상인 배열을 말한다.

<br>


#### 선언

배열을 선언할 때 콤바를 사용한다. 

```cs
// 2차원 
int [,] array = new int [5, 3];
// 3차원
int [,,] array = new int [5, 3, 2];
```

<br>

#### 메모리 크기

개별 차원의 수를 곱한 만큼 계산되고 그 수만큼 메모리가 할당된다.  

**2차원**

첫번째 숫자가 행, 두번째 숫자가 열의 수를 나타낸다. 

![2darray](/assets/images/20220220_Posting/2darray.jpg)

<br>

하나에 4byte인 공간이 5개가 행으로 만들어지고 그 크기만큼 3개의 열이 만들어진다. 

총 4 * 5 * 3 = 60byte 크기만큼 메모리 공간이 할당된다. 

<br>

**3차원**

![3darray](/assets/images/20220220_Posting/3darray.jpg)

마지막 숫자가 행, 두번째 숫자가 열의 수를 나타내고 그렇게 만들어진 2차원 배열이 첫번째 수 만큼 만들어진다. 따라서 이미지상 입체적인 구조처럼 보이게 된다. 


이렇게 행열로 표현되는 다차원 배열은 사람이 쉽게 알아보고 사용하기 위해서 나타내는 방식이므로 실제 메모리에서 그림처럼 구조를 가지지 않으며 연속되는 주소를 통해서 할당된다. 

<br>

일반적으로 1차원 배열이 주로 사용되며 수학의 행렬을 자주 다루는 게임 프로그래밍에서 2차원 배열 정도를 다룬다. 그 이상의 다차원 배열의 경우 사용 빈도가 극히 낮은 편에 속한다.