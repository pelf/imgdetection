require 'rubygems'
require 'rmagick'
include Magick

class CornerDetection

	CONSEC = 7

	def self.angled_lines(image)
		h = 800
		w = (h*image.columns)/image.rows
		
		image = image.trim(true).scale(w,h)
		lines = []
		# we cross the image at the middle, both vertically and horizontally
		# this should intersect the card on all 4 sides
		# and thus we have a point in each edge
		points = []
		[h/3, 2*h/3].each do |r|
			consecutive = 0
			total = count = 1
			potential = false
			0.upto(w-1) do |c|
				px = intensity image.pixel_color(c,r)
				# how different is this pixel from the average?
				if (rt=(px / (total/count))) < 0.4
					puts ':'
					# we have a potential candidate
					consecutive += 1
					points << [c,r] unless potential # store candidate
					potential = true
				else
					puts '.'
					if consecutive >= CONSEC
						puts '!'
						mark(image, points.last[0], points.last[1])
						break
					end
					# calc avg
					count += 1.0
					total += px
					# reset values if edge candidate didnt qualify
					if potential
						potential = false
						# reset consecutive
						consecutive = 0
						# clear last point
						points = points[0..-2]
					end
				end
				puts rt
			end
		end
		lines << line_through(image, points[0], points[1])

		points = []
		[h/3, 2*h/3].each do |r|
			consecutive = 0
			total = count = 1
			potential = false
			(w-1).downto(0) do |c|
				px = intensity image.pixel_color(c,r)
				# how different is this pixel from the average?
				if (rt=(px / (total/count))) < 0.4
					# we have a potential candidate
					consecutive += 1
					points << [c,r] unless potential # store candidate
					potential = true
				else
					if consecutive >= CONSEC
						mark(image, points.last[0], points.last[1])
						break
					end
					# calc avg
					count += 1.0
					total += px
					# reset values if edge candidate didnt qualify
					if potential 
						potential = false
						# reset consecutive
						consecutive = 0
						# clear last point
						points = points[0..-2]
					end
				end
			end
		end
		lines << line_through(image, points[0], points[1])

		points = []
		[w/3, 2*w/3].each do |c|
			consecutive = 0
			total = count = 1
			potential = false
			0.upto(h-1) do |r|
				px = intensity image.pixel_color(c,r)
				# how different is this pixel from the average?
				if (rt=(px / (total/count))) < 0.4
					puts ':'
					# we have a potential candidate
					consecutive += 1
					points << [c,r] unless potential # store candidate
					potential = true
				else
					puts '.'
					if consecutive >= CONSEC
						puts '!'
						mark(image, points.last[0], points.last[1])
						break
					end
					# calc avg
					count += 1.0
					total += px
					# reset values if edge candidate didnt qualify
					if potential 
						puts points.inspect
						potential = false
						# reset consecutive
						consecutive = 0
						# clear last point
						points = points[0..-2]
					end
				end
			end
		end
		lines << line_through(image, points[0], points[1])

		points = []
		[w/3, 2*w/3].each do |c|
			consecutive = 0
			total = count = 1
			potential = false
			(h-1).downto(0) do |r|
				px = intensity image.pixel_color(c,r)
				# how different is this pixel from the average?
				if (rt=(px / (total/count))) < 0.4
					# we have a potential candidate
					consecutive += 1
					points << [c,r] unless potential # store candidate
					potential = true
				else
					if consecutive >= CONSEC
						mark(image, points.last[0], points.last[1])
						break
					end
					# calc avg
					count += 1.0
					total += px
					# reset values if edge candidate didnt qualify
					if potential 
						potential = false
						# reset consecutive
						consecutive = 0
						# clear last point
						points = points[0..-2]
					end
				end
			end
		end
		lines << line_through(image, points[0], points[1])

		# intersect lines to find corners
		c1 = intersect(lines[0], lines[2])
		mark(image, c1[0], c1[1], 'green')

		c2 = intersect(lines[1], lines[2])
		mark(image, c2[0], c2[1], 'blue')

		c3 = intersect(lines[0], lines[3])
		mark(image, c3[0], c3[1], 'pink')

		c4 = intersect(lines[1], lines[3])
		mark(image, c4[0], c4[1], 'yellow')

		# 480 x 680
		# adjust perspective
		points = [
					c1[0],c1[1],0,0,
					c3[0],c3[1],480,0,
					c4[0],c4[1],680,480,
					c2[0],c2[1],480,0
					
					
				]
		puts points.inspect
		#image = image.distort(Magick::PerspectiveDistortion, points)

		image.write('output.jpg')
	end

	protected

	# returns average for R G B channels
	def self.intensity(pixel)
		(pixel.red + pixel.green + pixel.blue) / 3
	end

	# marks the image with a red rectangle
	def self.mark(image, c, r, color='red')
		rect = Magick::Draw.new
		rect.stroke(color)
		rect.rectangle(c-2,r-2,c+2,r+2)
		rect.draw(image)
	end

	# draws a red line passing through p1 and p2
	def self.line_through(image, p1, p2)
		# m = y2-y1/x2-x1 
		m = (p2[1]-p1[1]*1.0)/(p2[0]-p1[0]*1.0)
		# y = m*x + b
		# p1: p1[1] = m * p1[0] + b
		b = p1[1] - (m*p1[0]*1.0)
		# now we can draw it
		line = Magick::Draw.new
		line.stroke('red')
		if p1[0] == p2[0] # m = infinity
			line.line(p1[0],0,p1[0],image.rows)
			# when we have a vertical line, we just store the X value inside the B var
			m = nil
			b = p1[0] 
		else	
			line.line(0,b,image.columns,m*image.columns + b)
		end
		line.draw(image)
		return [m, b]
	end

	def self.intersect(l1, l2)
		if l1[0]
			x = (l2[1]-l1[1])/(l1[0]-l2[0])
			y = (l1[0]*x) + l1[1]
		else # l1 is a vertical line, l1[1] has its X value
			x = l1[1]
			y = (l2[0]*x) + l2[1]
		end
		return [x,y]
	end

end

img = ImageList.new("/Users/pelf/Desktop/card-pictures/IMG_20121217_172739.jpg").first
CornerDetection.angled_lines(img)

