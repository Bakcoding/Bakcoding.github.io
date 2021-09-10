---
title:  "set / map"
excerpt: "coding, test, programmers, set, map"

categories: 
  - Programmers
tags:
  - [coding, test, programmers, set, map]

toc: true
toc_sticky: true
 
date: 2021-09-07 
last_modified_at: 2021-09-07
---  

***

### set/map
c++ 에서는 데이터를 매핑하여 관리하는데 용이한 클래스를 지원한다.  

* set
* map
* unordered_set
* unordered_map  

**set/map 차이**  
key와 그에 대응하는 value가 있다고 할 때  
set은 key가 헤시 테이블에 존재하는지 판단하는 기능을 한다.  
map은 특정 key에 대응되는 값이 무엇인지 까지 알 수 있다.

<br/>

### set

```cpp
#include <set>

int main()
{
  // 선언
  set::set<int> i;
  // 원소 추가하기
  i.insert(1);
  i.insert(3);
  i.insert(2);
  i.insert(1);

  std::set<int>::iterator iter;

  for (iter = i.begin(); iter != i.end(); iter++)
  {
    cout << *iter << endl;
  }
}
```

set에 저장된 원소들에 접근하기 위한 반복자를 제공한다. 이 반복자는 임의의 위치에 있는 원소에 접근할 수 없고 순차적으로 하나 씩 접근할 수 밖에 없다.  

위에서 set에 데이터를 넣을 때 1, 3, 2, 1 순서로 넣어지만 출력해보면 1, 2, 3 순서로 나온다. 즉 원소를 추가할 때 정렬된 상태로 추가된다.  

그리고 1을 두 번 넣었음에도 하나만 출력이된다. set은 자체적으로 중복되는 원소는 추가하지 않기 때문에 마지막 1을 넣는 작업은 수행되지 않은 것이다. 

이렇게 중복되는 원소를 허용하고 싶을 때는 multiset을 사용하면된다.


<br/>

### map
set의 기능에 추가해 key에 대응되는 값까지도 같이 보관한다.

```cpp
#include <map>
using namespace std;
int main()
{
  map<string, int> mapList;

  // map의 insert 함수는 pair 객체를 전달인자로 한다.
  // pair : fist, second 두 객체를 가진다.
  mapList.insert(pair<string, int>("abc", 123));

  // make_pair 함수
  // 타입 지정없이 바로 객체 만들 수 있다.
  mapList.insert(make_pair("ABC", 321));

  // insert 없이 값 추가
  mapList["AAA"] = 111;
}
```

map도 set과 마찬가지로 원소들을 탐색하기 위해서는 반복자를 사용해야한다. set의 반복자의 포인터가 원소를 가리켰다면 map의 반복자는 저장된 pair객체를 가리킨다.  
iter->first와 iter->second로 원소에 접근한다.  

key로 저장된 값을 검색하는 방법

```cpp
// 해당 키에 대응되는 값 반환
int num = mapList["abc"]
```

이 방법을 사용할 때 중요한 점은 존재하지 않는 key를 입력해도 자동으로 디폴트 생성자를 호출해서 원소를 추가하기 때문에 에러가 발생하지 않고 0을 출력한다. 따라서 되도록 find를 통해 key의 존재를 확인 한 다음 값을 참조하는게 안전하다.  

```cpp
string key = "CCC"
auto iter = i.find(key);
if (iter != i.end()) { ~ }
```
find 함수는 map에서 해당 key를 찾아서 이를 가리키는 반복자를 리턴하는데 이 때 키가 존재하지 않으면 end()를 리턴하기 때문에 조건문에서 실행 여부를 end()인지 아닌지로 판단한다.  

map도 마찬가지로 중복을 허용하려면 multimap을 사용해준다.  

<br/>

### multiset / multimap  
중복을 허용하는 set과 map이다.  
그렇기 때문에 set과 map에서 key의 value를 가져올 때 []를 사용했던 방식이 적용되지 않는다.  

```cpp
i.insert(make_pair("ABC", 123));
i.insert(make_pair("ABC", 321));

// 사용불가
i["ABC"];
```

[]를 사용했을 때 중복되는 키들 중 어떤걸 가리키는지 알 수 없기 때문에 multiset/map에서는 []연산자를 제공하지 않는다.  

중복되는 key들의 값을 알아내는 법  

```cpp
auto range = i.equal_range("ABC");
```
equal_range 함수는 전달인자로 받은 key와 대응되는 원소들의 반복자들 중에서 시작과 끝 바로 다음을 가리키는 반복자를 pair 객체로 만들어서 리턴한다.

```cpp
for (iter = range.first; iter != range.second; iter++) { ~ } 
```
range.first와 range.second로 중복되는 key들의 범위를 정할 수 있다.

<br/>

### unordered_set / unordered_map
set과 map은 원소를 삽입할 때 정렬을 한 상태에서 추가하였다. unoredered는 뜻 그대로 순서가 없이 무작위로 삽입이 된다.  

원소를 삽입하거나 검색할 때 우선 해시함수를 사용해서 key에 대응되는 hash를 만든다. 해시함수는 1부터 해시 테이블의 사이즈 값을 반환하고 그 해시값을 원소를 저장할 주소의 인덱스로 삼게 된다.  

해시 함수의 가장 중요한 성질은 같은 원소를 해시 함수에 전달하면 같은 해시값을 리턴하는데 이 점이 원소의 탐색을 빠르게 수행할 수 있게 한다. 하지만 다른 원소일 때도 같은 해시값을 갖는 해시 충돌이 생길 수 있기 때문에 효율성이 높으면서 그만큼 설계를 잘 해서 사용해야한다.  

```cpp
#include <unordered_set>
#include <unordered_map>

int main()
{
  unordered_set<string> set;
  unordered_map<string> map;

  set.insert("hello");
  map.insert("world");

  auto iter = set.find("hello");
  auto iter = map.find("world");
}
```

set / map 과 동일하게 insert로 추가하고 find로 검색이 가능하다.