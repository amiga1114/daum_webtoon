### 1. 오늘은 먼저 다음 Webtoon을 긁어오면서 실습을 진행합니다 !

> #### 스크래핑 및 크롤링을 이용해서 전시간보다 조금 더 편하게 긁어오는 방법에 대해서 연습합니다 !
>
> 오늘은 크롬의 개발자도구에서 Network 탭에서 놀겠습니다 !
>
> #### 1. Network 탭
>
> 우리가 원하는 데이터는 Network 탭 - XHR에 저장되어 있다 ! XHR에는 대부분 json파일들로 되어있음 !
>
> tue?timeStamp=숫자 파일을 클릭해서 보면 이미지 및 데이터 정보들이 저장되어 있다 !
>
> 그러면 우리는 그 파일의 Request URL을 이용하여 크롤링하면 된다 !
>
> [수요일 웹툰의 Request URL]
>
> <http://webtoon.daum.net/data/pc/webtoon/list_serialized/tue?timeStamp=1513559333272>
>
> list_serialized/까지는 똑같지만 mon, tue, thu 등 요일별로 글자가 다르다 !
>
> #### 2. 그럼 이제 실습을 진행 함 !
>
> - 다음웹툰 볼래용
> - app.rb
>
> ```
> get '/today' do
>   # 다음 웹툰 크롤링하기
>   # => 우리가 긁어와야할 url 완성본 -> ex) http://webtoon.daum.net/data/pc/webtoon/list_serialized/fri?timeStamp=1513559333272
>   # 1. url을 만든다.
>   # => 요일 url 만들기
>   week =  DateTime.now.strftime("%a").downcase #우리는 요일을 string형식의 세글자로 받겠다 ! 그리고 그 값들을 소문자로 저장하겠다 !
>   # => 현재 시간을 integer로 변환 ex) t.to_i #=> 730522800
>   time = Time.now.to_i
>   url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/#{week}?timeStamp=#{time}"
>
>   puts url
>
>   # 2. 해당 url에 요청을 보내고 데이터를 받는다.
>   response = HTTParty.get(url)
>   # 3. JSON형식으로 날아온 데이터를 Hash형식으로 바꾼다.
>   doc = JSON.parse(response.body)
>
>   puts doc.class
>   # 4. key를 이용해서 원하는 데이터만 수집한다.
>   # => 원하는 데이터: 제목, 이미지, 웹툰 링크, 소개, 평점
>   # => 평점: averageScore
>   # => 제목: title
>   # => 소개: introduction
>   # => 이미지: appThumbnailImage["url"]
>   # => 링크: "http://webtoon.daum.net/webtoon/view/#{nickname}"
>
>   #doc["data"]를 돌면서 하나씩 뽑을꺼야!
>   @webtoons = Array.new
>
>   doc["data"].each do |webtoon|
>     toon = {
>         title: webtoon["title"],
>         desc: webtoon["introduction"],
>         score: webtoon["averageScore"].round(2),
>         img_url: webtoon["appThumbnailImage"]["url"],
>         url: "http://webtoon.daum.net/webtoon/view/#{webtoon["nickname"]}"
>     }
>     puts toon
>     # 5. view에서 보여주기 위해 @webtoons라는 변수에 담는다.
>     @webtoons << toon
>
>     puts @webtoons
>   end
>
>   erb :webtoon_list
> end
> ```
>
> - day.erb
>
> ```
> <!DOCTYPE html>
> <html>
>   <head>
>     <meta charset="utf-8">
>     <title>오늘의 다음웹툰</title>
>   </head>
>   <body>
>     <a href="/">홈으로</a>
>     <h1><%=params[:day]%> 웹툰</h1>
>     <table>
>       <thead>
>         <tr>
>           <th>이미지</th>
>           <th>제목</th>
>           <th>소개</th>
>           <th>평점</th>
>           <th>링크</th>
>         </tr>
>       </thead>
>       <tbody>
>         <% @webtoons.each do |webtoon| %>
>         <tr>
>           <td><img width="100" src="<%= webtoon[:img_url] %>" alt="<%= webtoon[:title] %>"></td>
>           <td><%= webtoon[:title] %></td>
>           <td><%= webtoon[:desc] %></td>
>           <td><%= webtoon[:score] %></td>
>           <td><a href="<%= webtoon[:url] %>" target="_blank">보러가기</a></td>
>         </tr>
>         <% end %>
>       </tbody>
>     </table>
>   </body>
> </html>
> ```