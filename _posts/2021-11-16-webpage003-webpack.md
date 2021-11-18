---
title:  "웹팩"
excerpt: "html, webpack5"

categories:
  - WebPage
tags:
  - [html, webpack5]

toc: true
toc_sticky: true
 
date: 2021-11-18 
last_modified_at: 2021-11-18
---  

***

### webpack

페이지를 구성하는 파일들을 모두 묶어주는 역할을 한다. 이렇게 묶어진 파일을 번들이라고 하며 웹팩은 번들을 통해서 데이터를 효율적으로 관리할 수 있기 때문에 특히 spa형식에서 큰 이점을 보인다.  

기본적으로 모듈 시스템으로 만들어져야 사용이 가능한 기능이다.  

**모듈 시스템**  

모든 자료들이 스크립트화 되어서 import와 require로 불러서 사용하는 구조이다.  

따라서 scrtipt 태그나 link 방식을 사용한다면 웹팩을 사용하는것이 의미가 없다.  

<br>

### install with npm  

npm을 통해서 다운받아 사용할 수 있다.  

>npm install -D webpack webpack-cli

* -D  
  --save-dev 축약형이다. 의미는 package will appear in your devDependencies 즉 실제 배포버전 빌드시 적용되지 않도록 package.json 파일에서 devDependencies에 플러그인 정보가 등록된다.  

* -S  
  --save 축약형, 패키지 정보에 플러그인 정보가 저장된다.  

<br>

### webpack.config.js  

웹팩을 적용하기 위해서 기본으로 정해진 파일명이다. 파일명을 다르게 사용하려면 커맨드라인에서 경로를 설정해주는 명령어를 입력해주면 된다.  

>webpack --config webpack.config.dev.js  

기본작성 코드  

```js
const webpack = require('webpack');

module.export = {
  mode : 'develope',
  entry : {
    main : 'index.js',
  },
  plugins: [
    new HtmlwebpackPlugin({

    })
  ]
  output : {
    path : 'dist',
    filename : '[name].js'
  }
  module: {
    rules: [{
      test: /\.css$/,
    }]
  }
}
```

module을 설정하기 위해서 requier를 해준다.  

* mode  
  개발용인지 배포용인지 설정할 수 있다. 배포 ( production) 으로 설정하면 최적화가 적용된다.  

* entry
  웹팩이 파일을 읽어들이는 시작점이다. main이라는 이름으로 해당 경로의 파일을 지정한다. 속성의 이름은 원하는대로 정할 수 있으며 해당 경로에서 가져온 파일의 이름이 된다.  

* output  
  결과물에 대한 설정이다. path는 결과물을 저장할 경로를 정하며 filename은 저장할 때의 이름을 정한다. 

  >[name].js --> entry에서 설정한대로 main.js로 저장된다.  
  >[name].[hash].js --> 매번 랜덤한 문자열 붙여준다. 캐시 삭제 시 유용 
  >[name].[chunkhash] --> 파일이 달라질 때만 랜덤 값 붙는다. 
  >index.prod.js --> 고정된 이름으로 만들 수 있다.  

* module  
  프로젝트의 모든 모듈에 대해서 옵션을 정한다.

  * rules 속성
    
    모듈이 생성될 때 규칙을 정의한다. 이 규칙으로 모듈이 생성되는 방식이 수정된다. 모듈에 loader를 적용하거나 phaser를 수정하는데 사용된다. 

* plugins  
  웹팩의 중추 기능이다. 부가적인 기능을 사용하기 위해서 사용한다. 이 때 플러그인은 세부설정을 통해서 프로젝트 내에서 자체적인 기능을 가지게 된다.   