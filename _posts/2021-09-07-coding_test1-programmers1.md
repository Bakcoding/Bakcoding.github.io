---
title:  "해시 함수"
excerpt: "coding, test, programmers, hash"

categories: 
  - Programmers
tags:
  - [coding, test, programmers, hash]

toc: true
toc_sticky: true
 
date: 2021-09-07 
last_modified_at: 2021-09-07
---  

***

### 해시(hash)  
우리가 샵이라고 부르는 문자 #는 영어로 hash이며 인스타그램이나 블로그 등에서 해시태그로 많이 사용되는데 해시태그로 키워드를 설정하면 키워드를 포함하는 글들을 모두 보여주는 방식이다.  

프로그래밍에서 해시는 데이터를 다루는 기법 중 하나로 데이터를 검색할 때 사용할 key와 실제 데이터의 value 한 쌍으로 만들어 key값이 검색될 때 변환된 데이터 value로 변환되기 때문에 검색과 저장이 아주 빠르다는 장점이 있다.  

<br/>

### key, value

* 구조체  

  ```cpp
  struct sHash{
    int key;
    string value;
  }

  vector <sHash> vHash;
  ```

  컨테이너에 구조체로 데이터를 저장하면 정수 값에 대응하는 문자열 값을 얻을 수 있다. key값이 중복되지 않는다면 같은 문자열이라도 이 정수값에 따라 구분하여 관리할 수 있게 된다.  

  이렇게 하나의 값에 다른 값을 대응 시키는 것을 매핑(mapping)이라고 한다.  

* unordered_map  

  c++에서는 이런 기능을 지원하는 unordered_map 클래스가 있다.  

  ```cpp
  template <class Key,
    class Ty,
    class Hash = std::hash<Key>,
    class Pred = std::equal_to<Key>,
    class Alloc = std::allocator<std::pair<const Key, Ty>>>
  class unordered_map;
  ```

  키와 값을 지정하여 묶어서 관리할 수 있으며 비교나 할당하는 등의 다양한 기능들도 함수로 가지고 있는 클래스이다.

  [unordered_map](https://docs.microsoft.com/ko-kr/cpp/standard-library/unordered-map-class?view=msvc-160)


<br/>

### 해시함수(hash func)
key 와 대응하는 value로 데이터를 저장하는 자료구조를 해시테이블(hashtable)이라고 하며 이 때 데이터가 저장되는 곳을 버킷(bucket) 또는 슬롯(slot)이라고 한다.  

key는 중복되지 않는 고유한 값이 되어야하는게 핵심으로 이 값을 설정하는 방법을 해시함수라고 한다.

  * division method  
    나눗셈을 이용한다. 숫자로 된 키를 해시테이블의 크기로 나눈 나머지를 해시 값으로 반환한다. 해시 테이블의 크기 값은 소수를 쓰며 2의 제곱수와 거리가 먼 소수를 사용한다. 

  * multiplication method  
    곱셈을 사용한 방식으로 테이블의 크기 값은 중요하지 않으며 보통 2의 제곱수로 정해진다.  

  * universal hasing  
    다수의 해시함수를 만들고 이 집합에서 무작위로 해시함수를 선택해 해시값을 만드는 방법이다.  


하지만 이런 방식들을 사용해도 중복된 키 값이 생성되어 해시 충돌 문제가 발생할 수 있는데 이런 충돌 문제를 해결하는 여러 방법들이 있다.  

  * chaining  
  버킷 내에 연결 리스트를 할당하여 버킷에 데이터를 삽입하다가 해시 충돌이 발생하면 연결 리스트로 데이터들을 연결하는 방식이다.  

  * open addressing
    해시 충돌이 일어나면 다른 버킷에 데이터를 삽입하는 방식으로 대표적으로 3가지로 나뉜다.  

    * linear probing  
      해시 충돌 시 다음 버킷 혹은 몇 개를 건너뛰어 데이터를 삽입한다.  
    
    * quadratic probing  
      해시 충돌 시 제곱만큼 건너뛴 버킷에 데이터를 삽입한다.  

    * double hashing  
      해시 충돌 시 다른 해시 함수를 한 번 더 적용한 결과를 이용한다.   
