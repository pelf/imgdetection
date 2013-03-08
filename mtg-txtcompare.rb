# compares image hash with pre-processed hashes stored in txt file

require_relative 'phash'

original = "/Users/pelf/Desktop/card-pictures/IMG_20121212_154411 copy.jpg"
hash = []
img = ImageList.new(original)
#hash << PHash.tiny_hash(img, {colors: 8})
hash << PHash.avg_hash(img, {:grayscale => true, :size => [11,8]})# 0
#hash << PHash.avg_hash(img, {:grayscale => true, :size => [8,6]})
#hash << PHash.avg_pixel_hash(img, {:size => [8,6]})

results = []

file = File.new("mtg-hash-11x8g.txt", "r")
while (line = file.gets)
	line = line.split(" >> ")
	f = line[0]
	hashes = line[1].split
	results << [PHash.distance(hash[0], hashes[0]), f]
end
file.close

# print top 10 results for each hash type
for i in 0..0 do
	puts "\n\n***** hash #{i}"
	results.sort{|a,b| a[i] <=> b[i]}[0..5].each do |r|
		puts "#{r[1].strip}: DISTANCE=#{r[i]}"
	end
end
