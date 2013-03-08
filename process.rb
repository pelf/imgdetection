require 'phash'
require 'phashion'

Dir.foreach("bling-imgs/") do |file|
	begin
		img = ImageList.new("bling-imgs/"+file).first
		h1 = PHash.avg_hash(img, {:grayscale => true})
		h2 = PHash.avg_hash(img, {:grayscale => false})
		h3 = Phashion::Image.new("bling-imgs/"+file).fingerprint
		h4 = PHash.tiny_hash(img)
		h5 = PHash.color_hash(img)
		puts "#{h1}, #{h2}, #{h3}, #{h4}, #{h5}, #{file}"
		img.destroy!
		img = nil
		GC.start
	rescue => e
	end
end
