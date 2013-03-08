require 'phash'
require 'phashion'

# colors are arrays of 3 values
def distance(color1, color2)
	dist = (color1[0]-color2[0]).abs + (color1[1]-color2[1]).abs + (color1[2]-color2[2]).abs
	puts "distance between #{color1.inspect} and #{color2.inspect} is #{dist}" if DEBUG
	return dist
end

# converts an rmagick image into a 2-d pixel array
def img_to_array_of_pixels(img)
	a = Array.new(img.columns)
	img.each_pixel do |pixel, col, row|
		a[row] = [] if col == 0
		a[row][col] = pixel
	end
	return a
end

# converts an rmagick pixel into a 1x3 array, with the specified precision
def pixel_to_array(pixel, precision=QuantumRange)
	return [(pixel.red*precision/QuantumRange),(pixel.green*precision/QuantumRange),(pixel.blue*precision/QuantumRange)]
end

DEBUG = false

original = ImageList.new("izzet2.jpg")

# scale to the needed size and store in array so we can access it easily later
#original =  PHash.avg_hash(original, {:grayscale => false})# img_to_array_of_pixels(original.first.trim.scale(SIZE,SIZE))
original = Phashion::Image.new('mbp.jpeg').fingerprint

results = []

i = 0

Dir.foreach("RTR/") do |file|
	i += 1
	puts i.to_s + " " + file.to_s
	begin
		#img = ImageList.new("RTR/"+file).first #.trim(true)
		#results << [file, PHash.distance(original,PHash.avg_hash(img, {:grayscale => false}))]
		#img.destroy!
		#img = nil
		
		img = Phashion::Image.new("RTR/"+file).fingerprint
		results << [file, Phashion.hamming_distance(original, img)]
		
		GC.start
	rescue => e
		puts "bode: #{file}" if DEBUG
	end
end

# print ordered results
results.sort{|a,b| a[1] <=> b[1]}.each do |r|
	puts "#{r[0]}: DISTANCE=#{r[1]}"
end