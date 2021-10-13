---
title:  "[영리한 프로그래밍을 위한 알고리즘] #8 정렬 알고리즘"
excerpt: "algorithm, sort, inflearn, java"

categories:
  - Algorithm
tags:
  - [algorithm, sort, inflearn, java]

toc: true
toc_sticky: true
 
date: 2021-10-13 
last_modified_at: 2021-10-13
---  

***

### 정렬(sort)
성능에 많은 영향을 끼치는 알고리즘 중 하나로 다양한 정렬 알고리즘들이 사용되어진다.  

* 버블정렬(bubble sort)
* 삽입정렬(insertion sort)
* 선택정렬(selection sort)
* 빠른정렬(quick sort)
* 합병정렬(merge sort)
* 힙정렬(heap sort)
* 기수정렬(radix sort)

버블, 삽입, 선택 정렬의 경우 간단하게 구현이 가능하지만 성능이 느리다. 하지만 정렬알고리즘의 동작방식을 파악하는데 도움이 된다. 

빠른, 병합, 힙 정렬은 위 세가지 보다 비교적 빠른 성능을 보여주며 기수 정렬의 경우 다른 정렬들과는 근본적으로 다르다고 볼 수 있다.

<br/>

### 기본적인 정렬 알고리즘

**선택정렬(selection sort)**  
정렬하고자 하는 데이터 컨테이너에서 가장 큰 값 또는 가장 작은 값을 찾아서 맨앞이나 맨뒤로 위치를 교환한다. 바뀐 위치의 가장 큰 값은 고정시키고 나머지 데이터도 동작을 반복해 정렬한다.  

찾는 값이나 교환 위치는 원하는 정렬 방식에 따라 정하면된다. 가장 작은 값을 맨앞과 교환하는 방식은 오름차순이고 반대의 경우는 내림차순이 된다.

![selsort](/assets/images/20211013_Posting/1.png)

수도코드
```java
selection(A[], n)
{
  for last n down to 2 {
    A[1 ... last] 중 가장 큰 수 A[k]를 찾는다.
    A[k] -> A[last] --- A[k]와 A[last]의 값을 교환한다.
  }
}
```

선택정렬의 실행시간은 for의 n-1번까지의 반복과 가장 큰수를 찾기 위한 비교횟수 n-1, n-2, ... , 2, 1 그리고 위치를 교환하는 상수시간 작업으로 시간복잡도는 다음과 같다.

$$ T(n) = (n-1) + (n-2) + ... + 2 + 1 = \frac {n(n-1)}{2} 이며 $$

$$ O(n^2) 이다. $$


**버블정렬(bubble sort)**  
첫번째 값을 그 다음 값과 비교해서 더 크면 자리를 바꾸는 동작을 반복한다. 결과는 마지막에 가장 큰 값이 배치되고 그 값은 고정시킨후 다시 처음으로 돌아가서 이 동작을 반복하면 오름차순으로 정렬이된다.  

![bubsort](/assets/images/20211013_Posting/2.png)

수도코드  
```java
bubbleSort(A[], n)
{
  for last <- n down to 2 {
    for i <- 1 to last - 1
      if (A[i] > A[i+1]) then A[i] <-> A[i+1];
  }
}
```

수행시간은 O(n<sup>2</sup>) 이다.  


**삽입정렬(insertion sort)**  
두번째 값부터 시작해서 앞에 있는 값들과 비교한다. 기준 값이 더 작은 경우 큰 값을 뒤로 보내는 동작을 반복한다.  

기준 값은 임시변수에 저장하여 앞의 값이 뒤로 밀릴 때 지워지지 않게 한다. 

![insort](/assets/images/20211013_Posting/3.png)

수도코드  
```java
insertionSort(A[], n)
{
  for i <- 2 to n {
    A[1...i]의 적당한 자리에 A[i]를 삽입한다.
  }
}
```

삽입정렬의 경우 앞에 값들이 정렬된 상태라면 다음 값을 비교할 때 어떤 값이 오는지에 따라서 연산량이 달라진다. 만약 1 ~ 7까지 값들이 정렬된 상태에서 8을 삽입정렬하면 바로앞의 7과 비교 후 바로 작업이 끝나지만 더 작은 값인 0이 오면 앞의 모든 값들과 연산하는 최악의 경우가 생기게 된다.  

따라서 삽입정렬의 수행시간은 최악의경우 O(n<sup>2</sup>) 이다.

<br/>

### 분할정복법
빠른정렬과 합병정렬에서 사용되는 알고리즘으로 해결하고자 하는 문제를 작은 크기의 동일한 문제들로 분할하고 각가의 작은 문제를 순환적으로 해결하는 정복과 작은 문제의 해를 합하여 원래 문제에 대한 해를 구하는 합병과정을 말한다.  

**합병정렬(merge sort)**  

![merge](/assets/images/20211013_Posting/4.png)  

* 데이터가 저장된 배열을 절반으로 나눈다. 
* 각각을 순환적으로 정렬한다.  
* 정렬된 두 개의 배열을 합치고 전체를 정렬한다.  

수도코드

```java
mergeSort(A[], p, r)  A[p ... r]을 정렬한다.  
{
  if (p < r) then {
    q <- (p+r) / 2;       p, r의 중간 지점 계산
    mergeSort(A, p, q);   전반부 정렬
    mergeSort(A, q+1, r); 후반부 정렬
    merge(A, p, q, r);    합병
  }
}

merge(A[], p, q, r)
{
  정렬되어 있는 두 배열 A[p...q]와 A[q+1...r]을 합하여 정렬된 하나의 배열 A[p....r]을 만든다. 
}
```
코드로 구현해 보면

```java
void merge( int datap[], int p, int q, int r) {
  int i = p; j = q+1; k = p;
  // 임시저장 변수
  int tmp[data.length()];
  while (i <= q && j <= r) {
    // 크기 비교해서 tmp에 저장
    if (data[i] <= data[j])
      tmp[k++] = data[i++];
    else
      tmp[k++] = data[j++]; 
  }
  // 나머지 데이터들 그대로 대입
  // 앞에 남은 데이터
  while (i <= q)
    tmp[k++] = data[i++];
  // while은 둘 중 하나만 실행된다.
  // 뒤에 남은 데이터
  while (j <= r)
    tmp[k++] = data[j++];
  for (int i = p; i <= r; i++)
    // 본래 데이터 변수에 저장
    data[i] = tmp[i];
}
```

병합정렬의 실행속도 T(n)은 n이 1일 때 0 이다. 그 이외의 경우는 
전체를 반으로 나눈 다음 정렬하는 T([n/2\]) + T([n/2\])과 다시 병합하는 n의 합이다.

![merge](/assets/images/20211013_Posting/5.png)

$$ T(n) = T([n/2]) + T([n/2]) + n = 2*T( \frac{n}{2} ) + n $$

으로 시간복잡도는  

$$ O(nlogn) 이 된다 $$ 

**빠른정렬(quick sort)**  
합병정렬과 마찬가지로 분할정복법으로 정렬되는데 데이터를 정렬하는 방식에서 차이가 있는데 임의의 값(pivot)을 기준으로 작은 값과 큰 값으로 컨테이너를 분할하게 된다.  

따라서 정복을 거치면 데이터는 정렬이 완료되므로 추가로 합병과정이 필요가 없다.

![quick](/assets/images/20211013_Posting/6.png)  

대략적인 코드의 흐름을 다음 처럼 잡는다.

```java
quickSort(A[], p, r)
{
  if (p<r) then {
    // q는 pivot의 위치
    q = partition(A, p, r);     분할
    quickSort(A, p, q-1);       왼쪽 부분배열 정렬
    quickSort(A, q+1, r);       오른쪽 부분배열 정렬
  }
}

// pivot의 자리를 반환하는 역할
partition(A[], p, r)
{
  배열 A[p...r]의 원소들을 A[r]을 기준으로 양쪽으로 재배치하고
  // A[r]은 pivot
  A[r]이 자리한 위치를 return 한다;
}
```

여기서 partition 함수의 역할이 가장 중요하다. 어떻게 기능을 만들지 자세히 살펴보면 

![quick](/assets/images/20211013_Posting/7.png)  

x는 pivot으로 pivot을 기준으로 데이터를 비교해서 pivot보다 작은 값과 큰 값으로 구분하고 그 지점을 i로 구분한다.

```java
// pivot보다 값이 크면 다음 j로 넘어가서 비교
if A[j] >= x
  j <- j+1;
// pivot보다 값이 작다면 이미 분류된 값 중에서 큰 값의 가장 앞에 있는 값과 자리를 바꾸면 간단하다.  
else
  // 즉 i를 증가시켜주고 j값과 바꾸어 준다. 
  i <- i+1;
  exchange A[i] and A[j];
  j <- j+1;
```

pivot을 매번 움직이는것은 비효율적이기 때문에 우선 고정시킨 다음 나머지 데이터를 pivot과 비교하여 정렬 시킨다.  

그리고 pivot의 위치를 pivot보다 작은 값의 마지막 pivot 보다 큰 값의 첫번째로 옮겨준다.

![quick](/assets/images/20211013_Posting/8.png)  
![quick](/assets/images/20211013_Posting/9.png)  

수도코드

```java
Partition(A, p, r)
{
  // pivot, r은 마지막값
  x <- A[r];
  i <- p-1;
  for j <- p to r-1 {
    if A[j] <= x then
      i <- i + 1;
      exchange A[i] and A[j];
  }
  exchange A[i+1] and A[r];
  return i+1;
}
```

빠른 정렬의 최악의 경우를 상성해 본다.  

* 항상 한 쪽은 0개, 다른 쪽은 n-1 개로 분할되는 경우

  $$ T(n) = T(0) + T(n-1) + n-1 $$

  0인 곳을 정렬하는 T(0)과 n-1개를 정렬하는 T(n-1) 그리고 분할이 몇개로 나누어지든 상관없이 pivot과의 비교 n-1번의 합이 실행속도이다.  

  위 식을 정리하면  

  $$ 
  T(n) 
  = T(n-2) + T(0) + ... n - 1 + n - 2 \\ 
          = n - 1 + n - 2 + ... + 1\\
          = \frac {n(n-1)}{2}\\
  $$

  이다.

  따라서 최악의 경우 O(n<sup>2</sup>)의 시간복잡도를 가진다.

* 이미 정렬된 입력 데이터를 마지막 원소를 pivot으로 빠른정렬을 할 때도 최악의 경우가 된다.  

반대로 최선의 경우도 있다.  

* 항상 절반으로 분할되는 경우  
    $$ 
  T(n) 
  = 2*T(n/2) + O(n) \\
  = O(nlogn)
  $$

  처음 절반으로 나눈 결과인 n/2를 각각 절반으로 나누면 4개의 n/4가 된다. 이 나누어지는데 속도는 n으로 일정하며 이 동작이 반복해 전부 하나짜리로 분할될 때 까지 총 분할의 횟수는 모두 항상 절반일 때 logn의 값을 가진다.

  따라서 각각 분할하는데 걸리는 n 과 총 횟수 logn을 곱한값이 시간복잡도가 된다.

pivot의 선택은 성능에 영향을 미치는 요소이다.  

* 첫번째 값이나 마지막 값을 pivot으로 선택  
  이미 정렬된 데이터 혹은 정렬된 데이터가 최악의 경우라면 현실의 데이터는 랜덤하지 않으므로 반대로 정렬된 데이터가 입력으로 들어 올 가능성은 매우 높기 때문에 이 pivot의 선택은 좋은 방법이 아니다.  

* "median of three"  
  첫번째 값과 마지막 값, 그리고 가운데 값 중에서 중간값(median)을 pivot으로 선택한다. pivot으로 선택한 값이 극단적인 상황일 확률을 줄이기 위한 방법이다. 하지만 최악의 경우의시간복잡도가 달리지지 않는다.  

* randomized quicksort  
  pivot을 랜덤하게 선택한다.  
  'no worst case instance, but worst case execution'
  최악의 경우가 존재 하지 않지만 최악의 실행이 있을수는 있다.  
  즉 최악의 경우는 입력값이 있어야 존재하므로 무작위로 선택하게 되면 최악의 경우라는게 발생하지는 않지만 무작위로 선택한게 최악의 실행을 발생시킬 수는 있게 된다.  

  이 경우 평균 시간복잡도는 O(nlogn)이 된다.  