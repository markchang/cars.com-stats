#
# cars-info.rb
# markchang - 2014
# parses a search URL from cars.com and displays some simple statistics
# on price and mileage for that search
#
# handles paginated results
# best used if you use the cars.com UI to narrow it down to a few hundred
# cars
#
# usage
# ruby cars-info.rb [url]
###

require 'nokogiri'
require 'open-uri'
require 'monetize'
require 'easystats'

# parse command line arguments of the url
abort("Specify the URL") unless ARGV.length > 0

url = ARGV.first.chomp

puts "Fetching cars..."

docs = []

doc = Nokogiri::HTML(open(url))
docs << doc

# grab the search filters once
filters = []
doc.css('ul.secondary').each do |filter|
  filters << filter.css('li')[1].text
end

# loop around page appending to the doc
while doc.css('a.right').count == 2
  puts "... %d" % (docs.length + 1)
  next_url = doc.css('a.right')[0]['href']
  doc = Nokogiri::HTML(open(next_url))
  docs << doc
end

# alternative to strip extra chars: p.scan(/[.0-9]/).join().to_f

puts "Parsing data..."
prices = []
miles = []

docs.each do |doc|
  prices_html = doc.css('h4.price')
  prices_html.each do |price|
    price_float = Monetize.parse(price.text).to_f
    prices << price_float unless price_float == 0.0
  end

  miles_html = doc.css('div.mileage')
  miles_html.each do |mileage|
    mileage_val = mileage.text.scan(/[.0-9]/).join().to_i
    miles << mileage_val unless mileage_val == 0
  end
end

puts
puts "Your filters"
filters.each {|filter| puts filter}

puts
puts "We found %d cars with prices" % prices.length
puts 
puts "Average price: %.2f" % prices.average
puts "Median price: %.2f" % prices.median
puts "Max price: %.2f" % prices.max
puts "Min price: %.2f" % prices.min
puts "Standard deviation: %.2f" % prices.standard_deviation

puts 
puts "We found %d cars with mileage" % miles.length
puts
puts "Average miles: %d" % miles.average
puts "Median miles: %d" % miles.median
puts "Max miles: %d" % miles.max
puts "Min miles: %d" % miles.min
puts "Standard deviation: %d" % miles.standard_deviation
