#
# Computes perception hashes for an imagemagick image
# 
#
require 'rubygems'
require 'rmagick'
include Magick

class PHash
	
	@@options = { 
		:colors => 4, # atm only used in the tiny hash
		:size => [8,8],
		:grayscale => true,
		:relative => true # are the values shifted according to the mean value?
	}
	
	# returns a hash for the given image
	def self.avg_hash(image, opts={})
		options = @@options.merge(opts)
		
		# resize image
		image = image.trim(true).scale(options[:size][0], options[:size][1])
		
		if (options[:grayscale]) # GRAYSCALE - mixes all three channel into a single value
		
			values = [] # helper array to store values
			total = 0 # used to compute the avg color
		
			# pre-process the colors
			image.each_pixel do |pixel, col, row|
				value = ((pixel.red + pixel.green + pixel.blue)/3)
				total += value
				values << value
			end
		
			# average color?
			average = total / (options[:size][0] * options[:size][1])
		
			# set bits
			values.each_with_index do |v,i|
				values[i] = (v < average) ? 0 : 1
			end
		
			# convert array to binary string [to decimal integer to hex string]
			return values.join("") #.to_i(2).to_s(12) <- if we need hex string
		
		else # NOT GRAYSCALE - handles each channel separately 
			
			values = [] # helper array to store values
			total = 0 # used to compute the avg color
		
			# pre-process the colors
			image.each_pixel do |pixel, col, row|
				value = [pixel.red, pixel.green, pixel.blue]
				total += (value[0] + value[1] + value[2])
				values << value
			end
			
			# average color (global for all 3 channels)
			average = total / (((options[:size][0])*(options[:size][1])) * 3) # count of pixels x 3
			
			# set bits
			values.each_with_index do |v,i|
				values[i][0] = (v[0] < average) ? 0 : 1
				values[i][1] = (v[1] < average) ? 0 : 1
				values[i][2] = (v[2] < average) ? 0 : 1
			end
		
			# convert array to binary string [to decimal integer to hex string]
			return values.flatten.join("") #.to_i(2).to_s(12) <- if we need hex string
		end
	end

	# returns a hash for the given image
	# each pixel color intensity is calculated from the avg of the 3 channels
	# each channel is then set to 0|1 by comparing it to the intensity
	def self.avg_pixel_hash(image, opts={})
		options = @@options.merge(opts)
		
		# resize image
		image = image.trim(true).scale(options[:size][0], options[:size][1])
		
		hash = ""
		
		# process the colors
		image.each_pixel do |pixel, col, row|
			intensity = (pixel.red + pixel.green + pixel.blue) / 3
			hash << (pixel.red >= intensity ? '1' : '0')
			hash << (pixel.green >= intensity ? '1' : '0')
			hash << (pixel.blue >= intensity ? '1' : '0')
		end
	
		return hash
	end
	
	# returns a tiny hash for the image
	# this hash should be the avg grayscale color of only 1 - 2 pixels
	# used to _exactly_ match roughly similar images
	def self.tiny_hash(image, opts={})
		options = @@options.merge(opts).merge({:size => [1,1]})
		
		# resize image
		image = image.trim(true).scale(options[:size][0], options[:size][1])
		
		tiny_hash = ""
		
		# process the colors
		image.each_pixel do |pixel, col, row|
			#tiny_hash << ((((pixel.red + pixel.green + pixel.blue)/3)*@@options[:colors])/QuantumRange).to_s
			v = ((pixel.red*options[:colors])/QuantumRange)
			tiny_hash << ((options[:colors]>10 and v<10) ? "0#{v}" : v.to_s)
			v = ((pixel.green*options[:colors])/QuantumRange)
			tiny_hash << ((options[:colors]>10 and v<10) ? "0#{v}" : v.to_s)
			v = ((pixel.blue*options[:colors])/QuantumRange)
			tiny_hash << ((options[:colors]>10 and v<10) ? "0#{v}" : v.to_s)
		end
		
		return tiny_hash
	end
	
	# finds the dominant colors in the image and returns a small hash representing them
	def self.color_hash(image)
		options = @@options.merge({:colors => 2}) # testing values...
		
		colors = {} # stores the count values for each color found
		# count the colors
		image.trim!(true).scale(200,200) # resize to speed up the process
		pixel_count = image.columns*image.rows
		
		image.each_pixel do |pixel, col, row|
			color = ((pixel.red*options[:colors])/(QuantumRange+1)).to_s + ((pixel.green*options[:colors])/(QuantumRange+1)).to_s + ((pixel.blue*options[:colors])/(QuantumRange+1)).to_s
			colors[color] = colors[color] ? (colors[color] + 1) : 1 # start the count at 1 or increment the value
		end
		
		# sort the colors keep top 3
		color_hash = ""
		colors.sort{|a,b| b[1] <=> a[1]}[0,3].each do |c|
			color_hash << c[0]
		end
		return color_hash
	end
	
	# compares two hashes (binary strings)
	# is this a hamming distance? prob yes
	def self.distance(hash1, hash2)
		distance = 0
		for i in 0...hash1.size
			distance += (hash1[i].to_i - hash2[i].to_i).abs
		end
		return distance
	end

	def self.hash_to_image(hash, c, r)

	end
	
	private


end