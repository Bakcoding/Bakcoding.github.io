---
title: "C# 인스턴스 생성 키워드 : new - 디자인패턴"
excerpt: "C# 인스턴스 생성 키워드 : new - 디자인패턴"
categories:
  - CSharp
permalink: /programming/csharp/86-csharp-new/
tags:
  - "CSharp"
  - "builder pattern"
  - "C#"
  - "design pattern"
  - "Factory Pattern"
  - "New"
  - "Singleton Pattern"
  - "디자인 패턴"
  - "빌더 패턴"
  - "싱글톤 패턴"
  - "팩토리 패턴"
toc: true
toc_sticky: true
date: 2024-05-06
last_modified_at: 2024-05-06
source_url: https://b-note.tistory.com/86
---

<h3 style="color: #000000;">new</h3>
<p>new 키워드의 사용을 최소화하여 객체 생성의 통제를 개선하고 코드의 유연성과 재사용성을 높여 의존성 관리를 용이하게 할 수 있다. 이를 통해서 메모리 사용을 최적화하고 객체의 생명주기를 효과적으로 관리할 수 있다.</p>

<h4>디자인 패턴(Design Pattern)</h4>
<p>주로 사용되는 방식들은 패턴으로 정형화된 구조를 만들 수 있다.&nbsp;</p>
<p>자주 그리고 반복적으로 사용되는 코드의 디자인을 정형화된 패턴으로 만들 수 있는데 이를 디자인 패턴이라고 한다.</p>

<p>디자인 패턴은 다양한 종류들이 존재하는데 이번에는 그중 객체의 생성과 할당과 관련된 패턴들 중 대표적인 몇 가지만 살펴본다.</p>

<h4 style="color: #000000;">싱글턴 패턴(Singleton Pattern)</h4>
<p>싱글턴 패턴은 클래스의 인스턴스가 하나만 존재하도록 보장하는 패턴이다.</p>
<p>이 패턴은 객체를 전역적으로 접근할 수 있게 하여 리소스에 대한 중복 접근을 방지하고 메모리 사용을 효율적으로 관리할 수 있도록 한다. 시스템 전체에 걸쳐 일관된 상태를 유지할 수 있으며 객체의 생성과 생명주기를 통제할 수 있다.</p>

<pre class="csharp" style="background-color: #f8f8f8; color: #383a42; text-align: start;"><code>public class Singleton
{
    private static Singleton instance;
    private Singleton() {}
    
    public static Singleton GetInstance()
    {
        if (instance == null)
        {
            instance = new Singleton();
        }
        return instance;
    }
}</code></pre>

<p>생성자를 private으로 선언하여 클래스 외부에서는 새 객체를 생성할 수 없도록 하며 GetInstance()를 통해서 유일하게 존재하는 클래스의 인스턴스에 접근할 수 있도록 한다.</p>

<h4 style="color: #000000;">팩토리 메서드 패턴(Factory Method Pattern)</h4>
<p style="color: #333333; text-align: start;">객체 생성을 처리하는 인터페이스를 제공하면서 서브 클래스가 생성할 객체의 클래스를 지정할 수 있게 한다.</p>
<p style="color: #333333; text-align: start;">이 패턴을 통해서 객체 생성을 추상화할 수 있으며 시스템의 확장성과 유연성을 향상할 수 있다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">팩토리 패턴의 방법은 다음과 같다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">1. 생성할 객체들이 공통적으로 구현할 인터페이스를 정의한다.&nbsp;</p>
<p style="color: #333333; text-align: start;">2. 인터페이스를 구현하는 클래스들을 생성한다. 각 클래스에서는 인터페이스의 메서드를 구체적으로 구현한다.</p>
<p style="color: #333333; text-align: start;">3. 객체 생성을 담당할 메서드를 포함하는 인터페이스를 정의한다. 이 메서드는 인터페이스 타입의 객체를 반환한다.</p>
<p style="color: #333333; text-align: start;">4. 생성자 인터페이스를 구현하는 클래스를 생성하고 팩토리 메서드를 오버라이드하여 인스턴스를 생성하고 반환한다.</p>
<p style="color: #333333; text-align: start;">5. 외부에서는 팩토리 메서드를 통해 객체를 생성하여 의존성 없이 동작할 수 있게 된다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">예시로 여러 종류의 몬스터를 만드는 팩토리 패턴을 활용하여 작성해 본다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<pre class="csharp" style="background-color: #f8f8f8; color: #383a42; text-align: start;"><code>// 몬스터 인터페이스 정의
public interface IMonster
{
    void Attack();
}

// 구체적인 몬스터 클래스
public class Zombie : IMonster
{
    public void Attack()
    {
        Console.WriteLine("Zombie attacks!");
    }
}

public class Vampire : IMonster
{
    public void Attack()
    {
        Console.WriteLine("Vampire attacks!");
    }
}

// 몬스터 생성을 위한 팩토리 클래스
public abstract class MonsterFactory
{
    public abstract IMonster CreateMonster();
}

public class ZombieFactory : MonsterFactory
{
    public override IMonster CreateMonster()
    {
        return new Zombie();
    }
}

public class VampireFactory : MonsterFactory
{
    public override IMonster CreateMonster()
    {
        return new Vampire();
    }
}

class Program
{
    static void Main(string[] args)
    {
        MonsterFactory factory = new ZombieFactory();
        IMonster monster = factory.CreateMonster();
        monster.Attack();

        factory = new VampireFactory();
        monster = factory.CreateMonster();
        monster.Attack();
    }
}</code></pre>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<p style="color: #333333; text-align: start;">특히 다양한 객체가 동일한 인터페이스를 공유하거나 시스템 구성 요소 간의 결합도를 낮추기 원할 때 유용하며 객체의 생성과 클래스의 구현을 분리함으로써 모듈화 된 코드 구조를 가능하게 한다.</p>
<p style="color: #333333; text-align: start;">&nbsp;</p>
<h4 style="color: #000000;">빌더&nbsp;패턴&nbsp;(Builder&nbsp;Pattern)</h4>
<p>빌더 패턴은 복잡한 객체의 생성과정을 단계별로 나누어 구축하는 디자인 패턴으로 객체의 생성 과정과 표현 방법을 분리하여 동일한 생성 절차에서 다양한 표현 결과를 얻을 수 있도록 한다. 주로 복잡한 객체를 조립해야 할 때 사용되며 각 부분의 조립 순서를 외부에서 지정할 수 있다.</p>

<pre class="cs" style="background-color: #f8f8f8; color: #383a42; text-align: start;"><code>// 캐릭터의 인터페이스 정의
public interface ICharacter
{
    void EquipWeapon(string weapon);
    void EquipArmor(string armor);
    void AddAbility(string ability);
}

// 캐릭터 빌더 인터페이스
public interface ICharacterBuilder
{
    ICharacterBuilder BuildWeapon(string weapon);
    ICharacterBuilder BuildArmor(string armor);
    ICharacterBuilder BuildAbility(string ability);
    Character Build();
}

// 구체적인 캐릭터 빌더
public class HeroBuilder : ICharacterBuilder
{
    private Character _character = new Character();

    public ICharacterBuilder BuildWeapon(string weapon)
    {
        _character.EquipWeapon(weapon);
        return this;
    }

    public ICharacterBuilder BuildArmor(string armor)
    {
        _character.EquipArmor(armor);
        return this;
    }

    public ICharacterBuilder BuildAbility(string ability)
    {
        _character.AddAbility(ability);
        return this;
    }

    public Character Build()
    {
        return _character;
    }
}

// 사용 예
public class Game
{
    public void CreateHero()
    {
        HeroBuilder builder = new HeroBuilder();
        Character hero = builder.BuildWeapon("Sword")
                                 .BuildArmor("Shield")
                                 .BuildAbility("Invisibility")
                                 .Build();
    }
}</code></pre>


<p>캐릭터가 가지는 공통적인 기능을 인터페이스로 구현한 다음 구체적인 캐릭터 클래스에서 원하는 옵션으로 조립할 수 있도록 단계를 구분한다.</p>
