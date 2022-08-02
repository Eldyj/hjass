require 'yaml'

module EZF
	def readf path
		file = File.open path
		result = file.read
		file.close
		return resault
	end
	def writef path, content
		if content["{content}"]
			content["{content}"] = readf(path)
		end
		File.write path, content
	end
end