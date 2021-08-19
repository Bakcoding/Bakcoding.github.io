---
title:  "헤더 가드"
excerpt: "cpp, header, file, ifdef, endif, define"

categories:
  - Cpp
tags:
  - [cpp, header, file, ifdef, endif, define]

toc: true
toc_sticky: true
 
date: 2021-07-29
last_modified_at: 2021-07-29
---  

***

### 파일 분할
하나의 파일에 코드를 작성해도 실행에는 문제가 없다. 하지만 내용이 많아질 수 록 코드의 가독성이 떨어지면서 수정과 삭제가 힘들어지고 코드의 재사용 효율도 떨어지게 된다. 따라서 코드를 더 효율적으로 관리하기 위해서 파일을 분할해서 작성해주는 것이 좋다.  


<br/>

클래스는 파일을 나눌 때에도 활용성이 좋다. 클래스 단위로 파일들을 분할하면 코드의 직관성과 가독성을 높일 수 있다.

```cpp
// main.cpp
#include <ionstream>
#include "CWeapon.h"

int main()
{
  

  return 0;

}

// CWeapon.h
#include <iostream>

class CWeapon
{
private:
  float m_fDamage;
  int m_iRank;

public:
  CWeapon();
  ~CWeapon();

  float Attack();
}

// CWeapon.cpp
#include "CWeapon.h"

CWeapon::CWeapon()
{
  m_fDamage = 3.14;
  m_iRank = 1;
}

float CWeapon::Attack()
{
  return m_fDamage * m_iRank;
}
```

CWeapon 클래스는 무기의 공격력과 등급을 관리하고 공격함수를 가지고 있다. 이 클래스는 또 .h와 .cpp로 분할해서 작성했다. 

<br/>

### 1. "CWeapon.h" 헤더파일 포함  
헤더 파일을 inlcude 하는 방법은 두 가지가 있다.  

  * 디렉터리에 저장되어있는 표준 헤더파일들은 꺽쇠<>를 사용한다.  
    ex) \<stdio\.h\>,  \<stdlib\.h\>, \<string\.h\>

  * 사용자가 정의한 헤더파일들은 큰 따옴표 "" 를 사용한다.  
    ex) "Mystring.h", "CWeapon.h"
  
<br/>

### 2. 중복 컴파일
CWeapon을 다른 클래스에서 포함해서 사용하는 경우  
```cpp
//Player.h
#include <iostream>
#inlcude "CWeapon.h"

class Player
{
  ~~
};
```

컴파일시 에러가 발생한다. main.cpp에서 CWeapon.h를 포함시켰는데 Player.h에서 다시한번 포함시키기 때문에 중복 컴파일 문제가 발생하게 된다. 


이 에러를 방지하기 위해서 헤더 가드(header guard)를 사용한다.

```cpp
#ifdef _CWEAPON_H_
#define _CWEAPON_H_

  ~~ source code ~~

#endif
``` 

 * #ifdef \_CWEAPON_H_ ~ #endif  
 ifdef는 if define의 약자이다. 
 ifdef와 endif 사이를 컴파일하면서 \_CWEAPON_H_가 정의되어있는지를 확인하여 컴파일 여부를 정하게 된다.  

 * define \_CWEAPON_H_  
  _CWEAPON_H_를 정의한다. 

* 정의가 되어있는지를 확인하고 다음에 바로 정의를 하여서 한 번만 컴파일 되도록 만든다.

이 방식을 예전부터 많이 썼지만 현재는 컴파일러에서 해당 기능을 지원하면서 그 기능이 보편화 되었다.  

```cpp
#pragam once
```

이 한 줄이 위 헤더 가드와 동일한 기능을 한다. 하지만 이 방식이 대부분의 컴파일러에서 지원한다 해도 모든 곳에 적용되어 있는것은 아니기 때문에 헤더 가드가 더 안정적인 호환성을 가진다. 

<br/>

### 3. \_CLASS_NAME_
코드 작성에서 표기법은 개인마다 다양하다. 하지만 직관성과 가독성을 만족시키는 표기법은 유행처럼 사용되면서 보편적인 규칙으로 자리잡기도 한다.

\_CLASS_NAME_ 도 마찬가지로 어떻게 써도 상관은 없다. 하지만 직관성과 가독성을 생각해서 간단하면서 무엇을 나타내는지 단 번에 알아 볼 수 있는게 좋다.
