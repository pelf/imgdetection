require 'rubygems'
require 'rmagick'
include Magick

class CornerDetection
	
	# help us god!
	def self.get_corners(image)
		s = 800
		#image.blur = 0.5
		# resize image - should be faster
		image = image.trim(true).scale(s,s)
		
		image.each_pixel do |pixel, col, row|
			next if col < 4 or row < 4 or col >= s-4 or row >= s-4
			#c = count_brighter(image.get_pixels(col-1,row-1,3,3)) # get 9 pixels
			#puts "#{row},#{col}: #{c}" if c <= 5 and c >= 4
			#if all_blacks(image.get_pixels(col-2,row-2,4,4)) # get 16 pixels
			#	puts "#{row},#{col}"
			#end
			if degree270(image.get_pixels(col-3,row-3,7,7))
				rect = Magick::Draw.new
				rect.stroke('red')
				rect.rectangle(col-3,row-3,col+3,row+3)
				rect.draw(image)
				puts "#{row},#{col}"
			end
		end
		image.write('output.jpg')
	end

	def self.get_corners_sliding(image)
		s = 200
		image = image.trim(true).scale(s,s)

		# slide through the image until a sudden drop in color is found
		# left to right from the top
		done = false
		for r in 0...image.rows do
			break if done
			for c in 0...image.columns do 
				px = image.pixel_color(c,r)
				if (px.red + px.green + px.blue)/3 < 5000
					rect = Magick::Draw.new
					rect.stroke('red')
					rect.rectangle(c-2,r-2,c+2,r+2)
					rect.draw(image)
					done = true
					break
				end
			end
		end
		# left to right from the bottom
		done = false
		(image.rows-1).downto(0) do |r|
			break if done
			for c in 0...image.columns do 
				px = image.pixel_color(c,r)
				if (px.red + px.green + px.blue)/3 < 5000
					rect = Magick::Draw.new
					rect.stroke('red')
					rect.rectangle(c-2,r-2,c+2,r+2)
					rect.draw(image)
					done = true
					break
				end
			end
		end
		# top to bottom from the left
		done = false
		for c in 0...image.columns do 
			break if done
			for r in 0...image.rows do 
				px = image.pixel_color(c,r)
				if (px.red + px.green + px.blue)/3 < 5000
					rect = Magick::Draw.new
					rect.stroke('red')
					rect.rectangle(c-2,r-2,c+2,r+2)
					rect.draw(image)
					done = true
					break
				end
			end
		end
		# top to bottom from the right
		done = false
		(image.columns-1).downto(0) do |c|
			break if done
			for r in 0...image.rows do 
				px = image.pixel_color(c,r)
				if (px.red + px.green + px.blue)/3 < 5000
					rect = Magick::Draw.new
					rect.stroke('red')
					rect.rectangle(c-2,r-2,c+2,r+2)
					rect.draw(image)
					done = true
					break
				end
			end
		end

		image.write('output.jpg')
	end

	def self.segue_paredes(image)
		s = 200
		image = image.trim(true).scale(s,s)
		# TODO
	end


	protected

	THRESHOLD = 5000

	# a corner should have 270 degrees of brighter pixels around it
	def self.degree270(pixels) # X by X pixel grid, flattened in a X^2 pixel array
		c = ((pixels[24].red + pixels[24].green + pixels[24].blue)/3) * 1.2
		return false if c > THRESHOLD
		dark = bright = 0
		last = nil
		# go around the border counting consecutive colored pixels
		[0,1,2,3,4,5,6,13,20,27,34,41,48,47,46,45,44,43,42,35,28,21,14,7].each do |px|
			v = (pixels[px].red + pixels[px].green + pixels[px].blue)/3
			# counts this pixel if it was already counting pixels of this color, or if this is the first one
			if v < c and (last == :d or dark == 0) 
				dark += 1
				last = :d
			elsif v >= c and last == :b or bright == 0
				bright += 1
				last = :b
			else
				return false
			end
		end
		if bright >= 8 and dark >= 8
			return true
		end
	end

	def self.count_brighter(pixels)
		return 0 if pixels.size < 9
		center = (pixels[4].red + pixels[4].green + pixels[4].blue)/3
		count = 0
		pixels.each_with_index do |px,i|
			next if i == 4
			if ((px.red + px.green + px.blue)/3 - center) > 20000
				count += 1
			end
		end
		return count
	end

	def self.all_blacks(pixels)
		return 0 if pixels.size < 9
		pixels.each_with_index do |px,i|
			if ((px.red + px.green + px.blue)/3) > 5000
				return false
			end
		end
		return true
	end

end

img = ImageList.new("/Users/pelf/Desktop/card-pictures/IMG_20121212_154545.jpg").first
CornerDetection.

