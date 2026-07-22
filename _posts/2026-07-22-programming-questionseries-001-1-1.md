---
title: "[궁금시리즈] 1-1. C#은 왜 만들어졌을까?"
excerpt: "C#"
categories:
  - Programming
tags:
  - C#
permalink: /programming/1-1/
toc: true
toc_sticky: true
date: 2026-07-22
last_modified_at: 2026-07-22
---

프로그래밍 언어는 모두 이전 세대 언어의 문제를 해결하기 위해 등장한다.
C# 역시 갑자기 만들어진 언어가 아니다.
C++의 강력한 성능은 유지하면서 개발 생산성을 높이고, Java가 제시했던 안전한 실행 환경을 받아들이며, Microsoft가 Windows 환경에서 사용할 새로운 개발 플랫폼을 만들기 위해 탄생했다.
C#이 등장하기까지 어떤 흐름이 있었는지 살펴보자.
 
## C++의 한계
1990년대 대부분의 상용 프로그램은 C++로 개발되었다.
C++은 매우 빠르고 하드웨어를 직접 제어할 수 있을 정도로 강력한 언어였다.
하지만 그만큼 개발자가 직접 관리해야 하는 것도 많았다.
예를 들어
- 메모리 할당
- 메모리 해제
- 포인터 관리
- 객체의 생명주기 관리

모든 것을 개발자가 책임져야 했다.

```cs
int* value = new int(10);

// 사용

delete value;
```

delete를 잊는 순간 메모리 누수(Memory Leak)가 발생한다.
반대로 두 번 삭제하면 프로그램이 비정상 종료될 수도 있다.
또한 포인터를 잘못 사용하면 전혀 다른 메모리를 읽거나 쓰게 되어 치명적인 버그가 발생한다.
이러한 문제들은 프로젝트 규모가 커질수록 더욱 심각해졌다.

즉, 
>C++은 강력했지만 안전하지 않았다.

## Java의 등장
1995년 Sun Microsystems는 Java를 발표했다.
Java의 핵심 목표는

>"개발자가 메모리를 직접 관리하지 않아도 되는 언어"

였다.
이를 위해 Java는

- Garbage Collector
- Virtual Machine(JVM)
- 바이트코드(Bytecode)

라는 개념을 도입했다.

```cs
Person person = new Person();
```

객체를 생성하면 개발자는 delete를 호출하지 않는다.
더 이상 사용하지 않는 객체는 Garbage Collector가 자동으로 제거한다.
덕분에 메모리 누수와 잘못된 포인터 사용이 크게 줄어들었다.
또한 JVM 위에서 실행되기 때문에
Windows
Linux
macOS
모두 같은 프로그램을 실행할 수 있었다.
Java는 당시 매우 혁신적인 언어였다.
 
## Microsoft의 고민
Java가 빠르게 성장하자 Microsoft도 새로운 개발 플랫폼의 필요성을 느끼게 되었다.
기존 Windows 개발은

- Win32 API
- COM(Component Object Model)
- C++

등 다양한 기술이 혼재되어 있었고 개발 난이도가 매우 높았다.
Microsoft는

- 생산성이 높고
- 안전하며
- 다양한 언어를 함께 사용할 수 있는

새로운 플랫폼을 만들기로 한다.
그 결과 탄생한 것이 바로
**.NET Framework**
이다.
 
## C#의 탄생
.NET 플랫폼 위에서 동작하는 대표 언어가 바로 C#이다.
2000년 Microsoft는 Anders Hejlsberg를 중심으로 C#을 공개하였다.
흥미로운 점은 Anders Hejlsberg는 이전에 Delphi를 만든 개발자이기도 하다.
C#은 여러 언어의 장점을 적극적으로 받아들였다.

- C/C++의 문법
- Java의 실행 방식
- Delphi의 생산성

그리고 Microsoft만의 .NET 생태계를 결합하여 설계되었다.
그래서 처음 C#을 접하는 사람들은

```cs
if (value > 10)
{
}
```
같은 문법이 C++이나 Java와 매우 비슷하다고 느끼게 된다.
 
## C#의 목표
C#은 처음부터 다음과 같은 목표를 가지고 설계되었다.
 
**1. 개발 생산성 향상**
메모리 관리를 자동화하여 개발자가 비즈니스 로직에 집중할 수 있도록 했다.
 
**2. 안전한 실행 환경**
CLR(Common Language Runtime)이 프로그램 실행을 관리한다.
잘못된 메모리 접근이나 위험한 작업을 최대한 방지한다.
 
**3. 객체지향 언어**
모든 기능을 객체 중심으로 설계하였다.
 
**4. 다양한 언어와의 호환**
.NET에서는
- C#
- VB.NET
- F#
- C++/CLI

등 다양한 언어가 동일한 런타임 위에서 함께 동작할 수 있다.
 
**5. 지속적인 발전**
현재의 C#은 초기 버전과 비교하면 완전히 다른 언어라고 해도 될 정도로 많은 기능이 추가되었다.

예를 들어
- LINQ
- async/await
- Span<T>
- Nullable Reference Type
- Record
- Pattern Matching

등 현대적인 기능들이 계속 추가되고 있다.
 
## 결국 C#은 어떤 언어일까?
C#은 단순히 Java를 따라 만든 언어도 아니고, C++를 대체하기 위한 언어도 아니다.
Microsoft는 C++의 성능과 Java의 안정성을 바탕으로 새로운 개발 플랫폼인 .NET을 만들었고, 그 플랫폼을 가장 잘 활용할 수 있는 언어로 C#을 설계했다.
현재 C#은 게임(Unity), 웹(ASP.NET), 데스크톱, 클라우드, 모바일(MAUI), AI 등 다양한 분야에서 사용되는 범용 언어로 발전하였다.
 
## 핵심 정리

- C++은 강력했지만 메모리 관리를 개발자가 직접 해야 했다.
- Java는 Garbage Collector와 Virtual Machine을 도입하여 개발 생산성을 높였다.
- Microsoft는 .NET 플랫폼을 만들고 그 대표 언어로 C#을 설계하였다.
- C#은 C++의 문법, Java의 실행 방식, Delphi의 생산성을 결합한 언어이다.
- 현재 C#은 다양한 플랫폼에서 사용되는 범용 프로그래밍 언어이다.
