require 'rubygems'
require 'open-uri'
require 'net/http'
require 'json'

page = 0
loop do
	body = Net::HTTP.get_response(URI.parse('http://bling.io/public.json?page='+page.to_s)).body
	json = JSON.parse(body)
	break if json.size == 0
	json.each do |bling|
		bling = bling['purchase'] || bling['wish']
		puts bling['medium']
	end
	page += 1
end