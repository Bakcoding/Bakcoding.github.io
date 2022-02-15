---
title:  "닷넷 프레임워크"
excerpt: "csharp, .net, framework"

categories:
  - CSharp
tags:
  - [csharp, .net, framework]

toc: true
toc_sticky: true
 
date: 2022-02-15 
last_modified_at: 2022-02-15
---  

### 닷넷 프레임워크

.net framework

닷넷 프레임워크는 마이크로소프트에서 발표한 응용 프로그램 개발 환경이다.  

일반적인 네이티브 언어로 만들어진 프로그램들이 운영체제에서 곧바로 실행되는 것과는 달리 닷넷 프레임워크를 기반으로 만들어진 응용 프로그램은 반드시 선행적으로 설치된 환경이 필요하다.  

내부적으로는 CLR(common language runtime) 구성요소가 로드되고 실행되며 이 CLR이 EXE/DLL에 저장되어 있는 닷넷 코드를 실행하게 된다.  

<br>

### C#

C#은 내부적으로 실행되는 CLR을 작동시키는 중간 언어(IL, intermediate language)의 역할을 한다.

이런 중간 언어를 닷넷 호환 언어라고 하며 C#은 그 언어 중 하나일 뿐이다.  

그리고 이 중간 언어들은 결과물을 공유하기 때문에 상호 호출이 가능하다는 특징도 있다. 


<br>

닷넷 프레임워크 환경에서는 다음과 같은 과정으로 작업이 진행된다. 

닷넷 호환 언어 -> IL 코드  -> CLR 실행 -> CPU의 기계어

특이한점은 IL코드는 그 자체로 프로그래밍 언어 문법을 가지며 ILASM.EXE라는 컴파일러를 가지고 있다. 

* IL 확인용 예제


  ```cs
  class Program
  {
    static void Main(string[] args)
    {
      int a = 5;
      int b = 6;
      int c = a + b;
    }
  }
  ```

  위 C#으로 작성된 코드를 빌드하면 다음과 같은 중간 언어로 변환되어 실행된다. 

  ```il
  .assembly ConsoleApplication2
  {

  }

  .module ConsoleApplication2.exe
  .class private auto ansi beforefieldinit Program extends [mscorlib]System.Object
  {
    .method private hidebysig static void Main(string[] args) cil managed
    {
      .entrypoint
      .maxstack 2
      .locals init ([0] int32 a, [1] int32 b, [2] int32 c)
      IL_0000: nop
      IL_0001: ldc.i4.5
      IL_0002: stloc.0
      IL_0003: ldc.i4.6
      IL_0004: stloc.1
      IL_0005: ldloc.0
      IL_0006: ldloc.1
      IL_0007: add
      IL_0008: stloc.2
      IL_0009: ret
    }
  }
  ```

  위 두 소스코드를 각 각 컴파일하면 동일한 프로그램이 생성되는걸 확인할 수 있다.  

<br>

### 공용 타입 시스템 

닷넷 호환 언어는 지켜야 할 타입만 만족한다면 누구나 새로운 언어를 만들어 닷넷 프레임워크 상에서 실행할 수 있다.  

다만 이 때 표준 규격을 정의한 CTS(common type system) 을 만족하는 한도 내에서 이다.

또한 모든 규격을 구현할 필요는 없기 때문에 자신들의 언어 사양에 맞게 구현하여 사용하는것도 가능하다. 

<br>

### 공용 언어 사양

이 때 또 한가지 지켜야할 사항이 CLS(common language specification)이다. 직접 닷넷 호환 언어를 만들 때 CTS는 전체를 구현할 필요가 없지만 CLS만큼은 완변하게 구현할 필요가 있다.  

닷넷 호환 언어끼리는 서로 사용할 수 있고 상속도 받을 수 있다. 따라서 항상 외부에서 사용할 기능에 대해서는 호환성 문제를 염두하고 CLS를 준수해야한다.

즉 모든 닷넷 호환 언어는 CLS에 정의한 사양만큼은 구현해야하며 서로 호출해야 하는 경우에는 그 기능에 한해서 CLS를 만족시킬 수 있어야한다. 


![cts,cls](/assets/images/20220215_Posting/cts,cls.png)<br>

