require 'nokogiri'
require 'open-uri'
require 'monetize'

# Get a Nokogiri::HTML::Document for the page we’re interested in...

url = "http://www.cars.com/for-sale/searchresults.action?stkTyp=U&tracktype=usedcc&mkId=20081&AmbMkId=20081&AmbMkNm=Porsche&make=Porsche&AmbMdNm=Cayenne&model=Cayenne&mdId=20791&AmbMdId=20791&prMx=20000&rd=30&zc=98115&searchSource=QUICK_FORM&enableSeo=1"
doc = Nokogiri::HTML(open(url))
prices_html = doc.css('h4.price')

# alternative to using monetize: p.scan(/[.0-9]/).join().to_f
prices = []
prices_html.each do |price|
  prices << Monetize.parse(price.text)
end

puts prices