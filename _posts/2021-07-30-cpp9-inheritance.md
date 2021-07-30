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
last_modified_at: 2021-07-30
---  

### 추상화(abstraction)
추상적이다는 말의 뜻은 흐릿하거나 분명하지 않고 막연한것들을 뜻한다. 추상화는 어떤것을 분명하지 않게 만든다는 것으로 즉 뭉뚱그려서 표현하는걸 뜻한다.  

프로그래밍에서 추상화는 전체적인 프로그램 설계의 큰 그림을 그리는 것으로 뭉뚱그려서 묶을 수 있는 공통적인 특징을 묶은 다음 점 점 구체적으로 만들어 가는 것을 말한다.  

클래스에서 상속이 추상화의 하나로 볼 수 있다.  

<br/>

### 부모, 자식 클래스
클래스 중 더 포괄적인 상위 클래스를 부모, 그 하위에 공통적인 특징을 가지면서 좀 더 구체적으로 만들어지는 것이 자식 클래스이다.  


![inheritance](/assets/images/20210730_Posting/1.png)  

무기는 다양한 종류를 어우르는 단어이다. 클래스로 만들어보면 무기들이 공통으로 가질 수 있는 특성을 멤버 변수로 만들고 행동을 메서드로 만든다.

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
아무리 상속을 했더라도 부모가 private로 지정된 영역은 접근을 할 수 없다. 이럴 땐 접근지정자를 protected로 바꾸면 상속 받은 클래스에서만 접근이 가능하지만 접근을 제한하는 의미가 다소 무색해 지기 때문에 보안을 살리면서 값을 접근하기 위해서 메서드로 간접적으로 접근하는 방법을 쓴다.  

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

![console](/assets/images/20210730_Posting/2.png) 
