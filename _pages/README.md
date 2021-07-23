### 카테고리 추가하는 방법  

1. \_includes -> _pages -> categories 폴더 안에 category\-카테고리명\.md 파일 생성

2. \_includes -> nav\_list\_main 파일에 추가  
    
    \<span class ~ 여기는 카테고리 상위\>  
    \<ul\> ~ 여기에 하위 카테고리 </ul\> 
    \{\% \if category[0] \== "찾아갈 이름"\%\}  

    \<li\>\<\a href=\"/categories/ 1. 에서 작성한 링크, 파일 이름\"  