---
title:  "두 점 사이의 거리"
excerpt: "c, math.h, distance, sqrt"

categories:
  - C
tags:
  - [c, math.h, distance, sqrt]

toc: true
toc_sticky: true
 
date: 2021-08-14
last_modified_at: 2021-08-14
---  

***
<br/>

### 피타고라스 정리
직각 삼각형에서 빗변의 제곱은 수직하는 두 변의 제곱의 합과 같다.

![pytha](/assets/images/20210814_Posting/pyth.png)

이 공식은 2차원 평면좌표에서 서로 다른 위치에 찍힌 두 점 사이의 거리를 구하는데 사용할 수 있다.  

c에서 지원되는 math.h 헤더파일은 수학과 관련된 공식들이 모여있다. 이 중에서 제곱을 반환하는 함수 pow와 제곱근을 반환하는 함수 sqrt를 사용해서 두 점 사이의 거리를 구할 수 있다.

<br/>

### pow(double, double)
제곱을 뜻하는 power의 줄임말이다. 인자로 받은 첫 번재 인자로 제곱할 수를 받고 두 번째 인자로 제곱할 수 즉, 지수를 받는다.  
```cpp
double result = pow(2.0, 2.0);
printf("result : %lf", result);

// 출력 
// result : 4.000000
```

### sqrt(double)
제곱근 square root의 줄임말로 인자로 받은 값의 제곱근을 반환하는 함수이다.  

```cpp
double result = pow(2.0, 2.0);
double result2 = sqrt(result);
printf("square root : %lf", result2);

// 출력
// result2 : 2.000000
```

### 두 점 사이의 거리
두 점을 입력 받고 사이의 거리를 출력한다.  

```cpp
#include <stdio.h>
#include <math.h>

double GetDistance(double _x1, double _y1, double _x2, double _y2);

int main()
{
	double x1, x2, y1, y2;
	printf("첫 번째 점의 x, y 좌표 : \n");
	scanf_s("%lf %lf", &x1, &y1);
	printf("두 번째 점의 x, y 좌표 : \n");
	scanf_s("%lf %lf", &x2, &y2);

	double distance = GetDistance(x1, y1, x2, y2);

	printf("거리 : %lf\n", distance);

	return 0;
}

double GetDistance(double _x1, double _y1, double _x2, double _y2)
{
	return sqrt(pow(_x2 - _x1, 2.0) + pow(_y2 - _y1, 2.0));
}
```

![dist](/assets/images/20210814_Posting/dist.png)



