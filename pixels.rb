require 'rubygems'
require 'rmagick'
include Magick

imgs = ImageList.new("imgs/a-1px.png", "imgs/b-1px.png", "imgs/c-1px.png", "imgs/d-1px.png", "imgs/e-1px.png", "imgs/f-1px.png", "imgs/g-1px.png", "imgs/h-1px.png", "imgs/i-1px.png", "imgs/j-1px.png", "imgs/k-1px.png", "imgs/l-1px.png", "imgs/m-1px.png")

precision = 50

imgs.each do |img|
	img.each_pixel do |pixel, col, row|
		puts pixel.inspect + "   " + (pixel.red*precision/QuantumRange).to_s + "," + (pixel.green*precision/QuantumRange).to_s + "," + (pixel.blue*precision/QuantumRange).to_s
	end
end

