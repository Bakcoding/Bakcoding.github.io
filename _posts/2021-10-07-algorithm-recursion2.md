---
title:  "[영리한 프로그래밍을 위한 알고리즘 강좌] #2 순환 2"
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

### 순환적 사고
순환함수는 수학적인 문제를 해결하는데 이외에도 사용이 가능한데 일반적인 문제에 대입하기 위해서는 연습이 필요하다.  

<br/>

### 문자열 길이 계산  
문자열의 길이를 계산하려면 각 문자를 하나씩 세면 되는데 가장 쉬운 방법은 반복문을 사용하는 것이지만 더 넓은 사고를 위해서 다른 방법을 생각해 본다.  

**규칙 찾기**  
문자열의 총 길이는 첫 번째 문자열을 제외한 나머지 문자열에 +1 한 것과 같다.  

![string](/assets/images/20211007_Posting/1.png)

이 규칙은 문자열을 하나씩 줄여가면서 0이 될 때 까지 반복해서 적용이 가능하다.  

이를 코드로 표현한다.  

```java
public static int length(String str) {
  // 빈문자열일 때, 문자열이 끝나면 함수종료
  if (str.equals(""))
    return 0;
  // 규칙을 코드로 표현
  else
    return 1 + length(str.substring(1));
}
```

응용  

* 문자열의 출력

  ```java
  public static void printChars(String str) {
    if (str.length() == 0)
      return;
    else {
      // 첫번째 문자만 출력
      System.out.print(str.charAt(0));
      // 다음 문자열 첫번째 출력
      printChars(str.substring(1));
    }
  }
  ```

* 문자열 뒤에서부터 출력  

  ```java
  public static void printCharsReverse(String str) {
    if (str.length() == 0)
      return;
    else {
      printCharsReverse(str.substring(1));
    System.out.print(str.charAt(0));
    }
  }
  ```

  첫 문자를 제외한 나머지 문자열을 출력 후 마지막 문자 출력

<br/>

### 2진수로 변환  

2진수의 특징 마지막 비트는 홀수와 짝수를 표현하는데 홀일 때 1, 짝일 때 0이다.  

**규칙 찾기**  

10진수를 2진수로 변환하려면 몫이 1이 될 때까지 2로 나누어준 후 나머지를 써주면 된다.  

![binary](/assets/images/20211007_Posting/2.png)  

이를 코드로 표현한다.  

```java
public void printInBinary(int n) {
  // 몫이 1이되면 몫을 출력하고 종료
  if (n < 2)
    System.out.print(n);
  else {
    // 입력값의 몫을 한번 더 함수 실행
    printInBinary(n / 2);
    // 나머지 출력
    System.out.print(n % 2);
  }
}
```

<br/>

### 배열의 합 구하기
배열안의 각 요소들의 합을 구한다.  

```java
// data 배열의 n개의 요소 합구하는 함수
public static int sum(int n, int [] data) {
  // 더할게 없는 경우
  if (n <= 0)
    return 0;
  else
    // n개의 합을 구할 때 맨 뒤인 인덱스는 n - 1에 해당한다. (인덱스는 0부터)
    // n - 1부터 0번 인덱스가 될 때까지 요소를 합한다.
    return sum(n-1, data) + data[n-1];
}
```

<br/>

### 데이터 파일로부터 n개의 정수 읽어오기

저장된 데이터에서 원하는 만큼의 데이터를 가져온다.  

Scanner는 java의 라이브러리 중 하나로 값을 입력받기 위해 사용하는 클래스이다.  

정수를 입력받아 저장할것이기 때문에 nextInt() 함수를 사용한다.

```java
public void readFrom(int n, int [] data, Scanner in) {
  if (n == 0)
    return;
  else {
    // n번 입력을 받아 data 변수에 저장한다.  
    readFrom(n-1, data, in);
    data[n-1] = in.nextInt();
  }
}
```  

<br/>

### 순환함수와 반복문

* 모든 순환함수는 반복문으로 변경 가능하며 그 반대도 가능하다.  

* 순환함수는 복잡한 알고리즘을 단순하고 알기쉽게 표현할 수 있지만 함수 호출에 따른 성능 문제가 있다.  

