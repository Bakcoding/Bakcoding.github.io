---
title:  "상속"
excerpt: "cpp, class, overriding"

categories:
  - Cpp
tags:
  - [cpp, class, overriding]

toc: true
toc_sticky: true
 
date: 2021-07-30
last_modified_at: 2023-06-04
---  

***

### 추상화(abstraction)
추상적이다는 말의 뜻은 흐릿하거나 분명하지 않고 막연한것들을 뜻한다. 추상화는 어떤것을 분명하지 않게 만든다는 것으로 즉 뭉뚱그려서 표현하는걸 뜻한다.  

프로그래밍에서 추상화는 전체적인 프로그램 설계의 큰 그림을 그리는 것으로 뭉뚱그려서 묶을 수 있는 공통적인 특징을 묶은 다음 점 점 구체적으로 만들어 가는 것을 말한다.  


<br/>

### 상속
상속은 중복되는 작업을 피하기 위해서 공통되는 부분은 하나로 정의하고 다른 부분들은 각각에서 구현하는 방식이다.

자식과 부모 클래스는 공통점을 공유하지만 자식간에는 차이가 있는 경우 각자에 맞춰 정의하여 사용한다.

여기서 추상화의 개념이 부모의 클래스를 정의하는데 필요한 개념이다.

![inherit](/assets/images/posting/20210730/inherit.png)  

무기는 여러가지 하위개념을 포함하는 상위 개념이다.  

이 무기를 부모로하고 추상화하여 클래스로 만들고 공통으로 가질 수 있는 특성을 멤버 변수, 동작을 메서드로 만든다.

```cpp
class CWeapon
{
private:
  string name;
  int damage;
  int price;

public:
  CWeapon() {};
  ~CWeapon() {};

  virtual void Attack(int &_hp);
};
```

총과 검은 위 특징을 공통으로 가지면서 서로 차이가 있다. 이럴 때 상속을 통해 공통적인 특징을 가져오면서 차이가 나는 부분만 바꿔서 사용할 수 있다.

<br/>

### 부모의 private 접근
아무리 상속을 했더라도 부모가 private로 지정된 영역은 접근을 할 수 없다.  

이럴 땐 접근지정자를 protected로 바꾸면 상속 받은 클래스에서만 접근이 가능하다. 

하지만 사용은 하고싶지만 직접적인 접근은 제한하고 싶은 상황이 있다. 이때는 메서드를 통해서 간접적으로 접근하는 방법을 사용할 수 있다.  

* Get/Set  
  부모의 멤버변수의 값을 가져오려면 Get함수를 만들면된다.  반환형을 가지는 메서드를 호출해서 return을 받으면 멤버변수의 값을 얻을 수 있다.

  ```cpp
  GetDamage(){ return damage; };
  ```

  멤버 변수의 값을 바꾸고 싶다면 Set함수를 만든다. 매개변수로 값을 받아서 멤버변수를 초기화 하는 메서드이다.

  ```cpp
  SetInfo(string _name, int _damage, int _price)
  {
    name = _name;
    damage = _damage;
    price = _price;
  };
  ```

<br/>

### 상속받아서 사용하기

```cpp
// 상속
// public : 상속 접근 지정자, 상속시 기반 클래스의 지정자에 따라 상속형태가 달라진다.
class CSword : public CWeapon
{
public:
  // 생성자
  CSword(string _name, int _damage, int _price){ SetInfo(_name, _damage, _price); };
  // 오버라이딩
  void Attack(int &_hp) override {};
};


class CGun : public CWeapon
{
public:
  CGun(string _name, int _damage, int _price){ SetInfo(_name, _damage, _price); };
  void Attack(int &_hp) override {};
}
```

무기의 정보는 생성자 오버로딩을 이용해서 인자를 받아서 SetInfo 메서드로 값을 초기화 한다.  

메인 함수에서 클래스를 인스턴스화하고 값들의 초기화와 메서드의 적용을 확인해본다.

```cpp
int main()
{
	CSword sword("한손검", 10, 100);
	CGun gun("권총", 20, 200);

	int playerHp = 100;

	cout << "적이 칼을 휘둘렀다!" << endl;
	cout << "입은 피해 : " << sword.GetDamage() << endl;
	sword.Attack(playerHp);
	cout << "현재 체력 : " << playerHp << endl;
	cout << "\n===================\n" << endl;
	cout << "적이 총을 발사했다!" << endl;
	cout << "입은 피해 : " << gun.GetDamage() << endl;
	gun.Attack(playerHp);
	cout << "현재 체력 : " << playerHp << endl;

	return 0;
}
```

![example_result](/assets/images/posting/20210730/example_result.png) 
