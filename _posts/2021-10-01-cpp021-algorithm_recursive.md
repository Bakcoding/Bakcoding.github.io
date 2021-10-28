---
title:  "[자료구조]트리 구조"
excerpt: "cpp, structure, non-linear, tree"

categories:
  - Cpp
tags:
  - [cpp, structure, non-linear, tree]

toc: true
toc_sticky: true
 
date: 2021-09-30
last_modified_at: 2021-09-30
---  

***

### 재귀함수(recursive)
함수안에서 스스로를 다시 호출하는 함수이다.  
복잡한 문제를 간단하고 논리적으로 표현할 수 있으며 변수의 사용을 줄일 수 있지만 함수의 호출이 반복되는 점에서 stack의 메모리를 많이 사용하기 때문에 stack overflow의 위험이 있다.  

<br/>

### 예제

1. 카운트 다운 재귀함수  

	```cpp
	#include <iostream>

	using namespace std;

	void countDown(int _num)
	{
		if (_num == 1)
		{
			printf("Num : %d\n", _num);

			return;
		}
		else
		{
			printf("Num : %d\n", _num);
			countDonw(_num--);
		}
	}
	```

	이 함수는 입력한 정수값부터 시작해서 1부터 감소하면서 출력한다. 마지막에 1이되면 출력을하고 함수를 종료하게 된다.  

	재귀함수의 특징은 함수가 모두 종료된 다음에 출력이 진행된다는 점이다.  

	지금처럼 재귀호출보다 출력이 먼저오는 경우 순서대로 입력값부터 차례대로 1씩 감소하면서 출력되지만 재귀호출 뒤에 출력이 오게되면 출력되는 숫자는 역순으로 나오게 된다.  

	재귀함수는 재귀호출 되는 지점에서 재귀가 끝날 때 까지 진행된 후 다음 함수로 넘어가게 되는데 만약 _num값을 5로 넣었다면 5 > 4 재귀호출 > 3 재귀 > 2 재귀 > 1 출력 재귀 종료 > 대기 중이던 출력 진행 2 > 3 > 4 > 5 순서로 진행된다.  

	이런 순서로 동작되는 이유는 일반적인 함수의 저장은 스택영역에서 이루어지기 때문이다. 먼저들어온 동작이 저장되면서 뒤로 미루어지고 스택의 후입선출 특징에 따라서 가장 마지막 작업부터 출력이 되면서 처음 입력값인 5가 마지막에 출력이 된다.      

2. 팩토리얼  
	임의로 정한 정수부터 1이 될 때까지 1씩 감소시키면서 곱하는걸 말한다.

	```cpp
	#include<iostream>

	using namespace std;

	int factorial(int _num) 
	{
		int result = 1;

		for (int i = 1; i <= _num; ++i) 
		{
			result = result * i;
		}
		return result;
	}
	```  

	단순히 반복문으로 구현하자면 1부터 값을 증가시키면서 입력한 숫자까지 반복해서 곱해주면된다.  

	이를 재귀함수로 표현하면

	```cpp
	int factorial(int _num)
	{
		if (_num == 0)
		{
			return 1;
		}

		else
		{
			return _num * factorial(_num - 1);
		}
	}
	```

	입력 값부터 값을 줄여가면서 곱하는 것이기 때문에 더 팩토리얼같다고 할 수 있다.
	
	
3. 피보나치 수열

	피보나치 수열은 0부터 시작해서 그 다음 수 1이 올 때 그 다음의 수는 이전의 수의 합이 된다. 

	![fibonacci](/assets/images/20211001_Posting/1.png)


	```cpp
	int fibonacciSeq(int _num)
	{
		if (_num == 1)
		{
			return 0;
		}
		else if (n == 2)
		{
			return 1;
		}
		else 
		{
			return fibonacciSeq(_num - 1) + fibonacciSeq(_num - 2);
		}
	}
	```

	 이렇게 재귀함수로 표현하는게 자연스러운 경우라면 간단하게 표현할 수 있어 가독성이 좋기 때문에 사용할 수 있겠지만 단순한 반복동작이라면 성능적으로 반복문을 사용하는게 낫기 때문에 일반적으로 쓰이는 편은 아니다.  


<br/>

### 꼬리 재귀함수(tail recursion)
재귀함수의 단점은 연속적인 함수의 호출로 함수가 끝나지 않고 계속해서 스택에 저장되면서 발생하는 스택 오버 플로우의 위험과 잦은 점프의 반복으로 인한 성능의 저하이다.  

꼬리 재귀함수는 이런 단점을 보완해서 재귀함수의 코드를 최적화하는것으로 볼 수 있다.  

꼬래 재귀의 중점은 재귀 호출이 끝난 뒤 추가 연산을 요구하지 않도록 스택이 깊어지는 문제를 선형으로 처리 하도록 알고리즘을 바꿔 스택을 재사용하게 만드는 것이다.  

```cpp
int sum(const int _num)
{
	if (_num == 100)
	{
		return 100;
	}
	else
	{
		return _num + sum(_num + 1);
	}
}
```

입력값부터 100까지 합을 구하는 코드이다. 이 코드의 경우 함수가 연속호출되는 동안 반환값을 계산하기 위해서 _num의 값은 계속해서 유지가 되며 스택에 저장되게 된다.  

이를 피하기 위해서 함수에 인자를 하나 더 추가해준다. 보통 accumultor라고 부르는 인자 acc를 사용해 코드를 재구성하면

```cpp
int sum(const int _num, const int _acc)
{
	if (_num > 100)
	{
 		return _acc;
	}
	else
	{
		return sum(_num + 1, _num + _acc);
	}
}
```

차이점은 꼬리 재귀에서는 반환값에서 추가적인 연산이 필요하지 않는다는 점이다. 따라서 함수가 호출될 때 마다 추가적인 연산을 위해 스택에 저장할 필요가 없어지게 되어 재귀함수의 단점이 보완된 것이다.  