---
title: "C# 인스턴스 생성 키워드 : extern - 활용"
excerpt: "C# 인스턴스 생성 키워드 : extern - 활용"
categories:
  - CSharp
permalink: /programming/csharp/87-csharp-extern/
tags:
  - "CSharp"
  - "C#"
  - "extern"
toc: true
toc_sticky: true
date: 2024-05-06
last_modified_at: 2024-05-06
source_url: https://b-note.tistory.com/87
---

<h2>extern</h2>
<p>extern 키워드를 사용하면 플랫폼 간 상호 운용성, 성능 최적화, 코드의 안전성과 에러 처리를 모색할 수 있다.</p>

<h3>플랫폼 간 상호 운용성</h3>
<p>C# 언어를 사용하는 프로젝트에서 이외의 언어로 작성된 라이브러리 함수를 호출하는 경우는 아주 흔하게 발생하는 상황이다. 예를 들어서 C#에서 Windows API를 호출하려면 DllImport 속성을 사용해서 C# 코드에서 네이티브 코드 함수를 선언해야 한다. 이를 통해 C# 프로그램에서 운영 체제 수준의 다양한 기능을 직접적으로 사용할 수 있다.</p>

<p>Windows API 중 몇 가지 간단한 함수를 사용해 본다.</p>
<pre class="cs" style="background-color: #f8f8f8; color: #383a42; text-align: start;"><code>namespace Test
{
    using System;
    using System.Text;
    using System.Runtime.InteropServices;

    internal class Program
    {
        [StructLayout(LayoutKind.Sequential)]
        public struct SYSTEMTIME
        {
            public ushort Year;
            public ushort Month;
            public ushort DayOfWeek;
            public ushort Day;
            public ushort Hour;
            public ushort Minute;
            public ushort Second;
            public ushort Milliseconds;
        }

        [DllImport("Kernel32.dll")]
        public static extern bool SetConsoleTitle(string title);
        

        [DllImport("Kernel32.dll", CharSet = CharSet.Auto)]
        public static extern uint GetConsoleTitle(StringBuilder buffer, uint size);

        [DllImport("Kernel32.dll")]
        public static extern void GetSystemTime(out SYSTEMTIME st);

        static void Main(string[] args)
        {
            SetConsoleTitle("Bak's Console");
            Console.WriteLine("Hello, World!");

            StringBuilder buffer = new StringBuilder(256); // Define buffer size according to your need
            GetConsoleTitle(buffer, (uint)buffer.Capacity);
            Console.WriteLine("Console Title: " + buffer.ToString());

            SYSTEMTIME st;
            GetSystemTime(out st);
            Console.WriteLine("Current System Time: {0}-{1}-{2} {3}:{4}:{5}.{6}",
                st.Year, st.Month, st.Day, st.Hour, st.Minute, st.Second, st.Milliseconds);

            Console.ReadLine();
        }
    }
}</code></pre>

<p>실행 결과</p>
<p><figure class="imageblock alignLeft" data-ke-mobileStyle="widthOrigin" data-origin-width="401" data-origin-height="111"><span data-alt="C# - extern kernel32.dll"><img src="/assets/images/posts/2024/05/06/87-1.png" loading="lazy" width="401" height="111" data-origin-width="401" data-origin-height="111"/></span><figcaption>C# - extern kernel32.dll</figcaption>
</figure>
</p>

<p>외부 함수 SetConsoleTitle을 사용해서 실행되는 콘솔의 타이틀을 변경하고 GetConsoleTitle을 사용해서 변경한 콘솔의 타이틀을 가지고 와서 콘솔에 찍어본다. 그리고 GetSystemTime을 사용해서 현재 실행 중인 장치의 시간을 가지고 온다.</p>

<p>코드를 보면 알 수 있듯이 필요한 기능을 사용하기 위해서는 <span style="color: #333333; text-align: start;">어트리뷰트를 선언할 때 추가로 필요한 값들이나 사용하고자 하는</span> 함수의 반환값, 필요한 파라미터 등에 대한 정보들이 필요하다.</p>

<p>이러한 정보들은 마이크로소프트 공식 문서나 또는 이를 주제로 하는 커뮤니티에서 확인할 수 있고 이외 라이브러리들도 제공하는 곳에서 API 문서를 확인할 수 있다.</p>

<h3>성능 최적화</h3>
<p>C# 코드 내에서 수학 계산이나 이미지 처리와 같은 고성능의 연산을 요구하는 네이티브 라이브러리 함수를 호출하는 방법이 있다. 이러한 방식은 매니지드 코드(Managed Code)에 비해 실행 속도가 빠른 네이티브 코드의 이점을 활용할 수 있게 해 준다.</p>

<p>네이티브 코드를 사용하는 것이 언제나 성능적으로 이점이 있다고 할 수는 없으므로 해당 목적을 위해서 외부 라이브러리를 사용한다고 했을 때에는 .Net 환경에서 이미 최적화된 상태인 C# 라이브러리의 성능과 비교해서 네이티브 코드를 사용했을 때에 성능적인 이점이 있을 때 사용하는 것이 좋다.</p>
