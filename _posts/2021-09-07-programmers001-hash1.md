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
last_modified_at: 2023-06-04
---  

***

### 해시(hash)  
우리가 샵이라고 부르는 문자 #는 영어로 hash이며 인스타그램이나 블로그 등에서 해시태그로 많이 사용된다. 해시 태그를 통해 글의 전체 내용을 검색할 필요없이 특정 키워드만으로 원하는 글을 찾아 볼 수 있게 된다.

프로그래밍에서도 위와 비슷하게 저장된 데이터를 조회할 때 직접 그 데이터를 찾아보는게 아닌 대응되는 고정된 값을 정해두고 그 값을 통해서 데이터를 검색과 수정을 하는데 해시를 사용한다. 

이렇게 원래 데이터의 해시를 정해주는 것을 매핑(mapping)이라고 하며 매핑 전 원래 데이터의 값을 키(key), 매핑 후 데이터 의 값을 해시 값(hash value), 이 과정 자체를 해싱(hashing)이라고 하며 이렇게 해시 값들이 저장된 확보된 공간을 해시 테이블(hash table)이라고 한다.  

배열에서 인덱스가 메모리의 주소를 가리킨다면 해시는 해시 테이블의 주소를 나타내는 것으로 볼 수 있다.  

![hash](/assets/images/posting/20210907/hash_func.png)

<br/>

### 해시 함수(hash func)
다수의 키들을 중복되지 않고 해시를 정해주기 위해서 알고리즘을 사용한 해시 함수들이 있다.

* division method  
  해시 = 키 % 테이블 크기  
  key를 테이블의 크기로 나누고 그 나머지를 테이블 주소로 사용하는 방식으로 가장 간단한 알고리즘이다.

* multiplication method  
  곱셈을 사용한 방식으로 테이블의 크기 값은 중요하지 않으며 보통 2의 제곱수로 정해진다.  

* universal hasing  
  다수의 해시함수를 만들고 이 집합에서 무작위로 해시함수를 선택해 해시값을 만드는 방법이다.  

<br/>

### 해시 충돌(hash collision)
해시 함수를 사용해도 중복되는 경우가 생길 수 밖에 없고 이를 해결하기 위한 방법들이 있으며 대표적으로 chaining과 open addressing이 있다.

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