---
title:  "[영리한 프로그래밍을 위한 알고리즘 강좌] #1 순환 1"
excerpt: "algorithm, recursion, inflearn, java"

categories:
  - Algorithm
tags:
  - [algorithm, recursion, inflearn, java]

toc: true
toc_sticky: true
 
date: 2021-10-07 
last_modified_at: 2021-10-07
---  

***

### 순환(recursion)
자기 자신을 호출하는 함수로 재귀함수라고 한다.  

```
void finc(...)
{
  ...
  func(...);
  ...
}
```

예시1)

```java
public class Code01 {
  public static void main(String [] args) {
    func();
  }

  public static void func() {
    System.out.println("Hello...");
    func();
  }
}
```

Hello...를 출력후 다시 그 함수를 호출한다. 즉 계속해서 func()를 호출하고 출력 후 다시 func()를 출력하기 때문에 무한루프에 빠지는 결과가 발생한다.  

따라서 recursion을 사용할 때는 함수를 종료시킬 조건이 반드시 필요하다.

```java
public class Code2 {
  public static void main(String [] args) {
    int n = 4;
    func(n);
  }

  public static void func(int k) {
    if (k <= 0)
      return;
    else {
      System.out.println("Hello...");
      func(k-1);
    }
  } 
}
```

메인함수에서 호출한 func(n)은 func( k - 1)로 진행된다. 즉 매번 호출할 때마다 4부터 1씩 감소하게 되고 k - 1이 0이 되는 5번째 호출에서 조건을 만족하고 함수는 종료된다.  

조건과 매개변수를 통해서 무한루프에 빠지지않는 recursion 함수를 구현하였다.  

recursion 함수의 일반적인 형태는 다음과 같다.  

* base case  
적어도 하나의 recursion에 빠지지 않는 경우가 존재해야한다.  

  ```java
  if (k <= 0 )
    return;
  ```

* recursive case  
recursion을 반복하다보면 결국 base case로 수렴해야 한다.  

  ```java
  func (k-1);
  ```

예시2)  

```java
public class Code01 {
  public static void main (String [] args) {
    int result = func(4);
    System.out.print(result);
  }

  public static int func (int n) {
    if (n <= 0);
      return 0;
    else {
      return n + func (n - 1);
    }
  }
}
```

func(4)의 결과는 10을 반환한다.  
이 함수는 1 에서 n 까지 수의 합을 반환하는 동작을 하며 n <= 0 조건이 될 때까지 else 동작을 반복하며 마지막에 총 계산 결과인 10이 반환된다.  

<br/>

### 수학적 귀납법
어떤 명제가 참임을 증명하기 위해서 과정으로 추론하는 방법으로 이미 알고 있는 판단을 근거로 새로운 판단을 유도하는 추론으로 연역적 추론이라고 한다.  

재귀함수를 만들 때에도 수학적 귀납법과 같다. 사용하기 위해서는 위 증명과정을 거쳐야 하는게 아니라 함수를 만드는 입장에서 내가 만든게 모든 조건에서 충족하는가를 생각할 때 필요한 개념이기 때문이다.  

만약,  
0 부터 n 까지의 합을 반환하는 예시2)의 함수 func(int n) 이 모든 양의 정수 n에서 올바르게 동작하는지 확인하기 위한 방법은

1\. n = 0일 때 함수는 0을 반환한다. (참)

2\. 임의의 양의 정수 k가 있을 때, n = k 일 때 참이라고 가정하면,  

3\. 2번에 의해서 n = k일 때 함수는 0부터 k 까지의 합을 반환하는 것도 참이게 되며, k + 1도 참이게 된다.  

따라서 func(int n)은 모든 양의 정수에서 참인 함수이다.  


정리하자면 함수를 만드는 입장에서 내가 만든 함수가 의도한대로 동작하도록 만들기 위해서 반드시 귀납법의 사고방식을 알고가야하는건 아니지만 도움은 된다고 생각한다.  

<br/>

### recursion 활용 예시  

**팩토리얼 (factorial)** 


```java
public static int factorial(int n)
{
  if (n == 0)
  {
    return 1;
  }
  else if (n < 0)
  {
    System.out.print("factorial must n >= 0");
    break;
  }
  else
  {
    return n * factorial(n - 1);
  }
}
```

**승수(power)**

```java
public static double power(double x, int n) {
  if (n == 0)
    return 1;
  else
    return x * power(x, n - 1);
}
```

**피보나치 수(fibonachi number)**

```java
public static int fibo(int n) {
  if (n == 0)
    return n;
  else if (n == 1)
    return n;
  else if (n < 0)
    System.out.print("fivonach must n >= 0");
    break;
  else {
    return fibo(n - 1) + fibo(n - 2);
  }
}
```

**최대 공약수(euclid method)**

```java
public static double gcd(int m, int n) {
  // 큰 수가 기준 m이 항상 크도록 자리교환
  if (m < n) {
    int tmp = m;
    m = n;
    n = tmp;
  }

  // m이 n으로 나누어 떨어진다.
  // n이 최대 공약수
  if (m % n == 0)
    return n;

  // 그 외 나머지가 존재하는 경우
  // 나머지가 존재하지 않을 때 까지 반복
  else
    return gcd(n, m % n);
}
```

단순화 시키면

```java
public static int gcd(int p, int q) {
  if (q == 0)
    return p;
  else
    return gcd(q, p % q);
}
```