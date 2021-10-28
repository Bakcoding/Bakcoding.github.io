---
title:  "ThreeBullets #13"
excerpt: "cocos, myproject, threebullets, androidstudio"

categories:
  - ThreeBullets
tags:
  - [cocos, myproject, threebullets, androidstudio]

toc: true
toc_sticky: true
 
date: 2021-09-05 
last_modified_at: 2021-09-05
---  

***

### APK 아이콘 변경하기  
스마트폰에 다운로드될 때 앱의 이미지를 바꾸어 본다.  
기본 상태는 coco2d의 마스코트로 되어있다.  

![basic_icon](/assets/images/20210905_Posting_cocos/1.jpg)  

우선 내 프로젝트 폴더로 가서 proj.android > app > res 로 찾아가면 이미지가 들어있는 폴더 몇 개가 나온다.  

![basic_folder](/assets/images/20210905_Posting_cocos/2.png)  

이 폴더안에 있는 이미지를 원하는 이미지로 바꾸어 주면되는데 
이 때 하나의 이미지 파일을 각 사이즈로 변환시켜주는 프로그램을 사용해주면 편하다.  

![Resizer](https://github.com/redwarp/9-Patch-Resizer)  

프로그램을 실행하고 필요한 사이즈를 선택해준 다음 내 이미지를 넣어주면 된다. 

![my_icon](/assets/images/20210905_Posting_cocos/3.png)  

만들어진 파일들을 프로젝트 폴더에 넣어주면 된다.

![my_icon](/assets/images/20210905_Posting_cocos/4.png)  

제대로 변경됐는지 확인을 해보면  

![my_icon](/assets/images/20210905_Posting_cocos/5.jpg)  

