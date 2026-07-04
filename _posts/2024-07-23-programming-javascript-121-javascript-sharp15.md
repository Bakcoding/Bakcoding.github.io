---
title: "JavaScript #15 비동기 자바스크립트"
excerpt: "JavaScript #15 비동기 자바스크립트"
categories:
  - Javascript
permalink: /programming/javascript/121-javascript-sharp15/
tags:
  - "JavaScript"
  - "Web"
  - "async"
  - "await"
  - "callback func"
  - "promise"
  - "비동기"
  - "자바스크립트"
  - "콜백 함수"
  - "프로미스"
toc: true
toc_sticky: true
date: 2024-07-23
last_modified_at: 2024-07-23
source_url: https://b-note.tistory.com/121
---

<h2>비동기</h2>
<p>비동기는 시간이 걸리는 네트워크 요청, 파일 읽기 등을 수행할 때 코드의 실행을 차단하지 않고 비동기적으로 처리할 수 있게 해주는 중요한 개념이다. 자바스크립트의 비동기와 관련된 기능들은 웹 애플리케이션을 더 빠르고 반응성이 좋게 동작하게 한다.</p>

<h2>콜백 함수</h2>
<p>콜백 함수는 다른 함수의 인수로 전달되는 함수이다.</p>
<p>비동기 작업이 완료되면 호출되며 비동기 작업을 처리하는 가장 기본적인 방법이다.</p>
<pre class="javascript"><code>function fetchData(callback) {
    setTimeout(() =&gt; {
        const data = { id: 1, name: 'John Doe' };
        callback(data);
    }, 1000); // 1초 후에 콜백 함수 호출
}

fetchData((data) =&gt; {
    console.log('Data received:', data);
});</code></pre>

<p>여기서 fetchData 함수는 1초 후에 데이터를 콜백 함수에 전달한다. 이 방식은 간단하지만, 여러 비동기 작업이 중첩될 경우 콜백 지옥이라 불리는 가독성이 떨어지는 코드가 될 위험이 있다.</p>

<h2>프로미스</h2>
<p>프로미스는 비동기 작업의 완료 또는 실패를 처리하는 객체이다. then, catch, finally 메서드를 사용하여 비동기 작업의 결과를 처리한다.</p>
<pre class="javascript"><code>function fetchData() {
    return new Promise((resolve, reject) =&gt; {
        setTimeout(() =&gt; {
            const data = { id: 1, name: 'John Doe' };
            resolve(data); // 성공적으로 데이터를 반환
        }, 1000);
    });
}

fetchData()
    .then((data) =&gt; {
        console.log('Data received:', data);
    })
    .catch((error) =&gt; {
        console.error('Error:', error);
    });</code></pre>

<p>프로미스를 사용하면 코드의 가독성이 개선되고, 여러 비동기 작업을 체인으로 연결하여 처리할 수 있다. 프로미스가 성공적으로 완료될 때 resolve가 호출되며 'value'에는 성공적으로 완료된 후 전달되는 값이다. 실패할 경우 reject가 호출되며 'reason'은 프로미스가 실패한 이유를 나타내는 값이다.</p>

<p>프로미스는 <b>대기(pending)</b>, <b>이행(fulfilled)</b>, <b>거부(rejected)</b> 세 가지 상태를 가질 수 있다.</p>

<p><b>대기</b></p>
<p>프로미스가 생성된 초기 상태로 'then', 'catch', 'finally' 메서드가 아직 호출되지 않은 상태이다.</p>

<p><b>이행</b></p>
<p>프로미스가 성공적으로 완료된 상태로 'then' 메서드가 호출된다.</p>

<p><b>거부</b></p>
<p>프로미스가 실패한 상태로 'catch' 메서드가 호출된다.</p>

<p>프로미스가 이행, 거부 상관없이 작업이 완료되었을 때 항상 'finally'가 호출된다. 보통 프로미스의 상태에 상관없이 반드시 실행되어야 하는 리소스를 해제, 로딩 상태를 해제하는 등의 작업 같은 코드를 작성할 때 사용된다.</p>
<pre class="javascript"><code>const myPromise = new Promise((resolve, reject) =&gt; {
  let success = true; // 작업 성공 여부를 결정하는 변수
  
  setTimeout(() =&gt; {
    if (success) {
      resolve("작업이 성공적으로 완료되었습니다!"); // 이행 상태로 전환
    } else {
      reject("작업이 실패했습니다."); // 거부 상태로 전환
    }
  }, 1000); // 1초 후에 상태 결정
});

myPromise
  .then((value) =&gt; {
    console.log("이행됨:", value); // 프로미스가 이행되면 실행
  })
  .catch((reason) =&gt; {
    console.log("거부됨:", reason); // 프로미스가 거부되면 실행
  })
  .finally(() =&gt; {
    console.log("프로미스가 완료됨."); // 프로미스가 완료되면 항상 실행
  });</code></pre>

<h2>async, await</h2>
<p>async와 await 키워드는 ES2017에서 도입된 비동기 프로그래밍의 최신 방법이다.</p>
<p>async 함수는 항상 프로미스를 반환하며, await 키워드는 프로미스가 처리될 때까지 함수의 실행을 일시 중지한다. 이를 통해 비동기 코드를 동기식 코드처럼 작성할 수 있게 된다.</p>
<pre class="javascript"><code>function fetchData() {
    return new Promise((resolve, reject) =&gt; {
        setTimeout(() =&gt; {
            const data = { id: 1, name: 'John Doe' };
            resolve(data); // 성공적으로 데이터를 반환
        }, 1000);
    });
}

async function getData() {
    try {
        const data = await fetchData(); // 프로미스가 처리될 때까지 대기
        console.log('Data received:', data);
    } catch (error) {
        console.error('Error:', error);
    }
}

getData();</code></pre>

<p>동기식처럼 처리되는 코드처럼 보이면서도 async, await 키워드를 사용해서 비동기적으로 동작하게 한다.</p>

<h2>콜백 지옥 (Callback Hell)</h2>
<p>콜백 지옥은 자바스크립트에서 비동기 작업을 중첩된 콜백 함수로 처리할 때 발생하는 문제로, 코드의 가독성과 유지보수성이 크게 떨어지는 현상을 말한다.</p>
<pre class="javascript"><code>function authenticateUser(username, password, callback) {
    setTimeout(() =&gt; {
        console.log('User authenticated');
        callback(null, { userId: 1, username: username });
    }, 1000);
}

function fetchUserData(userId, callback) {
    setTimeout(() =&gt; {
        console.log('User data fetched');
        callback(null, { userId: userId, data: 'Some user data' });
    }, 1000);
}

function processData(data, callback) {
    setTimeout(() =&gt; {
        console.log('Data processed');
        callback(null, { processedData: 'Processed data' });
    }, 1000);
}

authenticateUser('user1', 'password123', (authError, authData) =&gt; {
    if (authError) {
        console.error('Authentication error:', authError);
        return;
    }
    fetchUserData(authData.userId, (fetchError, userData) =&gt; {
        if (fetchError) {
            console.error('Fetch error:', fetchError);
            return;
        }
        processData(userData.data, (processError, processedData) =&gt; {
            if (processError) {
                console.error('Processing error:', processError);
                return;
            }
            console.log('All tasks completed successfully:', processedData);
        });
    });
});</code></pre>

<p>'authenticateUser' 함수는 사용자를 인증하고 결과를 콜백 함수에 전달한다.</p>
<p>인증이 성공하면 'fetchUserData' 함수가 호출되어 사용자 데이터를 가져온다.&nbsp;</p>
<p>사용자 데이터가 성공적으로 가져오면, 'processData' 함수가 호출되어 데이터를 처리한다.</p>

<p>위 코드는 각 단계별로 성공 여부를 대기하고 성공 시 다음 단계로 넘어가는 구조이다. 이러한 구조를 중첩된 콜백 함수라고 하며 코드가 길어지고 복잡해져 가독성이 떨어진다는 것이 확인된다. 가독성이 떨어지면 유지보수와 에러 처리에도 어려움이 발생할 수밖에 없다.</p>

<p>이를 예방하는 방법으로는 위에서 서술된 프로미스 사용, async, await 키워드를 사용하는 방법들이 있고 그 밖에도 몇 가지 방법들이 존재한다.</p>

<h3>이름이 있는 함수로 콜백 분리</h3>
<p>익명 함수 대신 이름이 있는 함수를 사용하여 콜백을 분리하면 코드의 가독성과 재사용성이 향상된다.</p>
<pre class="javascript"><code>function fetchData() {
    return new Promise((resolve, reject) =&gt; {
        setTimeout(() =&gt; {
            const data = { id: 1, name: 'John Doe' };
            resolve(data);
        }, 1000);
    });
}

fetchData()
    .then(data =&gt; {
        console.log('Data received:', data);
        return fetchData(); // 다음 비동기 작업
    })
    .then(data =&gt; {
        console.log('Next data received:', data);
    })
    .catch(error =&gt; {
        console.error('Error:', error);
    });</code></pre>

<h3>모듈화 및 함수 분리</h3>
<p>비동기 작업을 여러 작은 함수로 나누고 모듈화 하면 코드가 더 관리하기 쉬워진다.</p>
<pre class="javascript"><code>function fetchData() {
    return new Promise((resolve, reject) =&gt; {
        setTimeout(() =&gt; {
            const data = { id: 1, name: 'John Doe' };
            resolve(data);
        }, 1000);
    });
}

async function handleFirstData() {
    try {
        const data = await fetchData();
        console.log('Data received:', data);
        return data;
    } catch (error) {
        console.error('Error in handleFirstData:', error);
    }
}

async function handleSecondData() {
    try {
        const data = await fetchData();
        console.log('Next data received:', data);
        return data;
    } catch (error) {
        console.error('Error in handleSecondData:', error);
    }
}

async function processAllData() {
    await handleFirstData();
    await handleSecondData();
}

processAllData();</code></pre>

<h3>비동기 제어 라이브러리 사용</h3>
<p>비동기 제어 흐름을 관리하기 위해 'async.js'와 같은 비동기 작업을 관리하는 데 유용한 유틸리티를 제공하는 라이브러리를 사용할 수 있다.</p>

<p>async.js 등 라이브러리를 사용하기 위해서는 설치가 필요하다.</p>
<pre class="javascript"><code>&lt;script src="https://cdnjs.cloudflare.com/ajax/libs/async/3.2.0/async.min.js"&gt;&lt;/script&gt;</code></pre>

<p>node.js 환경에서는 npm install async를 사용하여 설치할 수 있다.</p>
<pre class="javascript"><code>npm install async</code></pre>

<h3>async.js 사용법</h3>
<p><b>시퀀스 작업 처리</b></p>
<p>'async.series'를 사용하여 비동기 작업을 순차적으로 처리할 수 있다.</p>
<pre class="javascript"><code>const async = require('async');

function fetchData(callback) {
    setTimeout(() =&gt; {
        console.log('Data fetched');
        callback(null, { id: 1, name: 'John Doe' });
    }, 1000);
}

function processData(data, callback) {
    setTimeout(() =&gt; {
        console.log('Data processed:', data);
        callback(null, { processedData: true });
    }, 1000);
}

async.series([
    function(callback) {
        fetchData(callback);
    },
    function(callback) {
        fetchData((err, data) =&gt; {
            if (err) return callback(err);
            processData(data, callback);
        });
    }
], function(err, results) {
    if (err) {
        console.error('Error:', err);
    } else {
        console.log('All tasks completed:', results);
    }
});</code></pre>

<p><b>병렬 작업 처리</b></p>
<p>'async.parallel'을 사용하여 비동기 작업을 병렬로 처리할 수 있다.</p>
<pre class="javascript"><code>const async = require('async');

function fetchData1(callback) {
    setTimeout(() =&gt; {
        console.log('Data1 fetched');
        callback(null, { id: 1, name: 'John Doe' });
    }, 1000);
}

function fetchData2(callback) {
    setTimeout(() =&gt; {
        console.log('Data2 fetched');
        callback(null, { id: 2, name: 'Jane Doe' });
    }, 500);
}

async.parallel([
    function(callback) {
        fetchData1(callback);
    },
    function(callback) {
        fetchData2(callback);
    }
], function(err, results) {
    if (err) {
        console.error('Error:', err);
    } else {
        console.log('All tasks completed in parallel:', results);
    }
});</code></pre>

<p>각 작업 처리</p>
<p>'async.each'를 사용하여 배열의 각 요소에 대해 비동기 작업을 수행할 수 있다.</p>
<pre class="javascript"><code>const async = require('async');

const items = [1, 2, 3, 4, 5];

function processItem(item, callback) {
    setTimeout(() =&gt; {
        console.log('Processed item:', item);
        callback(null, item);
    }, 1000);
}

async.each(items, processItem, function(err) {
    if (err) {
        console.error('Error:', err);
    } else {
        console.log('All items processed');
    }
});</code></pre>
