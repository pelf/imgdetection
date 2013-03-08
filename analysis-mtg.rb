results = {}

file = File.new("mtg-tinyhash-rgb-8colors.txt", "r")

while (line = file.gets)
	line = line.split(">>")
	results[line[1].strip] ||= 0
	results[line[1].strip] += 1
end

file.close

puts results.sort{|a,b| b[1]<=>a[1]}.inspect