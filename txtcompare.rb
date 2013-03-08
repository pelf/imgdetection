# compares image hash with pre-processed hashes stored in txt file

require 'phash'
require 'phashion'

original = "kusmi2.jpeg"
hash = []
img = ImageList.new(original)
hash << PHash.avg_hash(img, {:grayscale => true})
hash << PHash.avg_hash(img, {:grayscale => false})
hash << Phashion::Image.new(original).fingerprint
hash << PHash.tiny_hash(img)
hash << PHash.color_hash(img)

results = []

file = File.new("5hashes.txt", "r")
while (line = file.gets)
	line = line.split(", ")
	# puts "#{hash[1]} : #{line[1]} = #{PHash.distance(hash[1], line[1])}" if PHash.distance(hash[1], line[1]) < 15
	results << [PHash.distance(hash[0], line[0]), PHash.distance(hash[1], line[1]), Phashion.hamming_distance(hash[2],line[2].to_i), line[3], line[4], line[5]]
end
file.close

# print top 10 results for each hash type
for i in 0..2 do
	puts "***** hash #{i} [original tiny=#{hash[3]}, color=#{hash[4]}]"
	results.sort{|a,b| a[i] <=> b[i]}[0..10].each do |r|
		puts "#{r[5].strip}: DISTANCE=#{r[i]} [tiny=#{r[3]}, color=#{r[4]}]"
	end
end

# sum all scores
puts "***** total [original tiny=#{hash[3]}, color=#{hash[4]}]"
results.map{|e| [e[0]+e[1]+e[2],e[3], e[4], e[5]]}.sort{|a,b| a[0] <=> b[0]}[0..10].each do |r|
	#break if r[0] > 50
	puts "#{r[3].strip}: DISTANCE=#{r[0]} [tiny=#{r[1]}, color=#{r[2]}]"
end