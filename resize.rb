require 'rubygems'
require 'rmagick'
include Magick

img = ImageList.new("imgs/r.png")
for size in [1,2,4] do
	small = img.scale(size,size)
	small.write "imgs/r-#{size}px.png"
end