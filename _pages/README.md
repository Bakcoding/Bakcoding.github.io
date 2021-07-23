<!-- 카테고리 추가하는 방법  

<!--
1. _includes -> _pages -> categories 폴더 안에 category-카테고리명.md 파일 생성

    ```md  
        ---
        title: "카테고리 이름"  
        layout: archive   
        permalink: /categories/파일이름과 같이   
        author_profile: true   
        sidebar_main: true  
        ---

        {% assign posts = site.categories.카테고리 이름 %}
        {% for post in posts%} {% include archive-single.html type=page.entries_layout %} {% endfor %}

    ```

2. _includes -> nav_list_main 파일에 추가  
    
    \<span class ~ 여기는 카테고리 상위>
    \<ul> ~ 여기에 하위 카테고리 </ul> 
    \{% if category[0] == "찾아갈 이름" %}  

    \<li><a href="/categories/ 1. 에서 작성한 링크, 파일 이름"  
     

    ```md
    <span class="nav__sub-title">C/C++</sapn>
            <ul>
                {% for category in site.categories %}
                    {% if category[0] == "C" %}
                        <li><a href="/categories/c" class="">C ({{category[1].size}})</a></li>
                    {% endif %}
                {% endfor %}
            </ul> 

            <ul>
                {% for category in site.categories %}
                    {% if category[0] == "CPP" %}
                        <li><a href="/categories/cpp" class="">C++ ({{category[1].size}})</a></li>
                    {% endif %}
                {% endfor %}
            </ul>  

    ```
     -->