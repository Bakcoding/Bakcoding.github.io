---
title: "JavaScript #7 var 변수에 대해서"
excerpt: "JavaScript #7 var 변수에 대해서"
categories:
  - Javascript
permalink: /programming/javascript/113-javascript-sharp7-var/
tags:
  - "JavaScript"
  - "Web"
  - "const"
  - "Let"
  - "VAR"
  - "자바스크립트"
toc: true
toc_sticky: true
date: 2024-07-22
last_modified_at: 2024-07-22
source_url: https://b-note.tistory.com/113
---

<h2>var</h2>
<p>앞에서 정리한 내용을 바탕으로 생각해 보면 var 변수보다는 let, const 변수를 사용하는 것이 의도치 않은 문제가 발생할 경우를 줄일 수 있을 것으로 보인다.</p>

<p>그럼에도 var 변수는 왜 존재하고 사용되는지 정리한다.</p>

<h2>역사적 이유</h2>
<p>자바스크립트의 초기 버전에는 let, const 키워드가 없었고 var 만이 유일하게 변수를 선언하는 방법이였다.</p>

<p>이후에 let, const 가 도입되면서 변수 선언에 더 나은 방법이 제공되었지만 기존의 코드를 유지보수하거나 과거의 자바스크립트 버전과 호환성을 유지하기 위해 여전히 var가 사용되는 경우가 있다.</p>

<h3>레거시 코드</h3>
<p>많은 기존의 자바스크립트 코드베이스가 var를 사용하여 작성되었다. 이 코드를 유지보수하거나 확장할 때 기존의 스타일을 유지하기 위해 var를 계속 사용하기도 한다.</p>

<p>또한 오래된 자바스크립트 엔진이나 환경에서는 let, cosnt를 지원하지 않을 수 있기 때문에 그런 환경에서 코드를 실행하기 위해서는 var를 사용할 수밖에 없다.</p>

<h3>호환성</h3>
<p>모든 자바스크립트 환경에서 var는 지원되기 때문에 가장 광범위한 호환성을 보장할 수 있다. 예로 들어서 아주 오래된 브라우저나 자바스크립트 엔진에서도 var를 사용할 수 있다.</p>

<h2>정리</h2>
<p>기존의 코드베이스의 작업이나 아주 오래된 엔진 환경에서 실행을 하기 위함이라면 var를 사용하는 건 어쩔 수 없는 선택이지만 최신 자바스크립트 코드 작성 시에는 가능하면 var보다는 let이나 const를 사용하는 것이 안정성과 예측가능성을 높이기 때문에 권장된다.</p>
