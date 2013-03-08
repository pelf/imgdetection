require_relative 'phash'
#require 'phashion'

Dir.glob("/Users/pelf/Desktop/cards/**/*") do |file|
	begin
		next if file =~ /full/
		img = ImageList.new(file).first
		h1 = PHash.avg_hash(img, {:grayscale => true, :size => [11,8]})
		
		#h3 = PHash.avg_pixel_hash(img, {:size => [8,6]})
		#h4 = PHash.tiny_hash(img, {colors: 8})
		puts "#{file} >> #{h1}"
		img.destroy!
		img = nil
		GC.start
	rescue => e
		#puts e.backtrace
	end
end
