---
title:  "[영리한 프로그래밍을 위한 알고리즘] #6 순환_멱집합"
excerpt: "algorithm, recursion, inflearn, java"

categories:
  - Algorithm
tags:
  - [algorithm, recursion, inflearn, java]

toc: true
toc_sticky: true
 
date: 2021-10-09 
last_modified_at: 2021-10-09
---  

***

### 멱집합(powerset)
부분집합을 원소로 하는 집합을 멱집합이라고 한다.  

예)  
임의의 집합 data = {a, b, c, d}가 있을 때  
data의 멱집합 P(data) =  
{ 
  {∅}, {a}, {b}, {c}, {d}, 
  {a, b}, {a, c}, {a, d}, {b, c}, {b, d}, {c, d},
  {a, b, c}, {a, b, d}, {a, c, d}, {b, c, d},
  {a, b, c, d}
}

멱집합의 개수를 구하는 공식은 각 원소들이 포함될 경우와 포함되지 않을 경우 2가지이므로 모든 원소의 개수가 n일 때 2<sup>n</sup>으로 멱집합의 개수를 구할 수 있다.  

<br/>

### recursion thinking
{a, b, c, d, e, f} 모든 부분집합을 나열하려면 a를 제외한 {b, c, d, e, f}의 모든 부분집합들을 나열하고, {b, c, d, e, f}의 모든 부분집합에 {a}를 추가한 집합들을 나열한다.   

* a를 포함하지 않는 경우 {b, c, d, e, f} 5개 원소, 2<sup>5</sup>  
* 위의 경우의 수에서 a가 포함되는 경우를 추가, 2<sup>5</sup>  

따라서 2<sup>5</sup> + 2<sup>5</sup> = 2<sup>6</sup>의 결과와 같다.

즉 어떤 집합의 모든 부분집합을 구하기 위해서는 그 집합에서 원소하나를 제외한 나머지의 모든 부분집합을 구할 수 있으면 원래 집합에 대한 모든 부분집합도 구할 수 있다.  

* {b, c, d, e, f}의 모든 부분집합에 {a}를 추가한 집합들을 나열하려면  

* {c, d, e, f}의 모든 부분집합들에 {a}를 추가한 집합들을 나열하고, {c, d, e, f}의 모든 부분집합에 {a, b}를 추가한 집합들을 나열한다.  

이 규칙으로 recursion 표현이 가능하다.  

<br/>

### 알고리즘

```java
powerSet(S)
if S is an empty set
  print nothing;
else
  let t be the first element of S;
  find all subsets of S-{t} by calling powerSet(S-{t});
  return all of them; 
```

2<sup>n</sup> 개의 집합을 반환하기 때문에 메모리 문제가 발생할 위험이 있다. 그렇다고 반환 없이 출력만 실행시키기에는 집합에 다른 집합을 추가할 수 가 없게 된다.  

그렇기 때문에 집합을 저장하기 위한 변수를 만들어 준다.  


```java
powerSet(P, S)
if S is an empty set
  print P;
else
  let t be the first element of S;
  powerSet(P, S-{t});
  powerSet(P ∪ {t}, S - {t});
```

S의 멱집합을 구한 후 각각에 집합 P를 합집합한 뒤 출력한다.  
recursion 함수가 두 개의 집합을 매개변수로 받도록 설계해야 한다는 의미로 두 번째 집합의 모든 부분집합들에 첫번째 집합을 합집합하여 출력한다.  


코드로 적용시킨다.  

```java
private static char data[] = {'a', 'b', 'c', 'd', 'e', 'f'};
private static int n=data.length;
private static boolean [] include = new boolean [n];

public static void powerSet(int k) {
  if (k == n) {
    for (int i = 0; i < n; i++)
      if (include[i]) System.out.print(data[i] + " ");
    System.out.printIn();
    return;
  }
  include[k]=false;
  powerSet(k+1);
  include[k] = true;
  powerSet(k+1);
}
```

data[k\], ... , data[n-1\]의 멱집합을 구한 후 각각에 include[i\] = true, i = 0, ... , k-1 인 원소를 추가하여 출력한다.  

처음 이 함수를 호출할 때는 powerSet(0)로 호출하며 P는 공집합이고 S는 전체집합이 된다.  


**상태공간트리**  
이 문제도 상태공간트리를 사용해서 모든 경우의 수를 구조화 시킨 다음 탐색을 통하여 답을 구하는 방법이 가능하다.  

![tree](/assets/images/20211009_Posting/1.png)

```java
private static char data[] = {'a', 'b', 'c', 'd', 'e',};
private static int n = data.length;
//트리상에서 현재 나의 위치를 표현한다.
private static boolean [] include = new boolean [n];

public static void powerSet(int k) {
  // 만약 내 위치가 리프 노드라면 동작수행
  if (k == n) {
    for (int i = 0; i < n; i++)
      if (include[i]) System.out.print(data[i] + " ");
    System.out.printIn();
    return;
  }
  include[k] = false;
  // 왼쪽 노드 확인
  powerSet(k+1);
  include[k] = true;
  // 오른쪽 노드 확인
  powerSet(k+1);
}
```