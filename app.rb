require 'sinatra'
require 'sinatra/reloader'
require 'httparty'
require 'json'
require 'date'
require 'data_mapper'

set :bind, '0.0.0.0'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/webtoon.db")

class Webtoon
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :desc, String
  property :score, Float
  property :img_url, String
  property :url, String
  property :created_at, DateTime
end

DataMapper.finalize
Webtoon.auto_upgrade!

get '/' do
  erb :index
end

get '/scrap' do
  # 월~금요일까지의 웹툽을 차례차례 긁어 온다.
  days = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
  @webtoons = Array.new
  day.each do |day|
  url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/#{day}"
  response = HTTParty.get(url)
  doc = JSON.parse(response.body)
  doc["data"].each do |webtoon|
    toon = {
      name: webtoon["title"],
      desc: webtoon["introduction"],
      score: webtoon["averageScore"],
      img_url: webtoon["appThumbnailImage"]["url"],
      url: "http://webtoon.daum.net/webtoon/view/#{webtoon['nickname']}"
    }
    @webtoons << toon
  end
end
  @webtoons.each do |webtoon|
    Webtoon.create(
      name: webtoon[:name],
      desc: webtoon[:desc],
      score: webtoon[:score],
      img_url: webtoon[:img_url],
      url: webtoon[:url]
    )
  end
end

get '/week/:day' do
  day = params[:day]
  url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/#{day}"
  puts url

    # 2. 해당 url에 요청을 보내고 데이터를 받는다.
  response = HTTParty.get(url)

    # 3. json형식으로 날아온 데이터를 hash형식으로 바꾼다.
  doc = JSON.parse(response.body)
  puts doc.class

    # 4. key를 이용해서 원하는 데이터만 수집한다.
    # 원하는 데이터 : 제목, 이미지, 웹툰 링크, 소개, 평점
    # 평점 : averageScore
    # 제목 : title
    # 소개 : introduction
    # 이미지 : appThumbnailImage[url]
    # 웹툰 링크 : "http://webtoon.daum.net/webtoon/view/#{nickname}"
    @webtoons = Array.new
    doc["data"].each do |webtoon|
      toon = {
        name: webtoon["title"],
        desc: webtoon["introduction"],
        score: webtoon["averageScore"],
        img_url: webtoon["appThumbnailImage"]["url"],
        url: "http://webtoon.daum.net/webtoon/view/#{webtoon['nickname']}"
      }
      @webtoons << toon
    end
    puts @webtoons
    # 5. view에서 보여주기 위해 @webtoos라는 변수에 담는다.

    erb :webtoon_list
end

get '/today' do
  # 1. url을 만든다.
  time = Time.now.to_i
  week = DateTime.now.strftime("%a").downcase
url = "http://webtoon.daum.net/data/pc/webtoon/list_serialized/#{week}?timeStamp=#{time}"
puts url

  # 2. 해당 url에 요청을 보내고 데이터를 받는다.
response = HTTParty.get(url)

  # 3. json형식으로 날아온 데이터를 hash형식으로 바꾼다.
doc = JSON.parse(response.body)
puts doc.class

  # 4. key를 이용해서 원하는 데이터만 수집한다.
  # 원하는 데이터 : 제목, 이미지, 웹툰 링크, 소개, 평점
  # 평점 : averageScore
  # 제목 : title
  # 소개 : introduction
  # 이미지 : appThumbnailImage[url]
  # 웹툰 링크 : "http://webtoon.daum.net/webtoon/view/#{nickname}"
  @webtoons = Array.new
  doc["data"].each do |webtoon|
    toon = {
      name: webtoon["title"],
      desc: webtoon["introduction"],
      score: webtoon["averageScore"],
      img_url: webtoon["appThumbnailImage"]["url"],
      url: "http://webtoon.daum.net/webtoon/view/#{webtoon['nickname']}"
    }
    puts toon
    @webtoons << toon
  end
  puts @webtoons
  # 5. view에서 보여주기 위해 @webtoos라는 변수에 담는다.

  erb :webtoon_list
end
