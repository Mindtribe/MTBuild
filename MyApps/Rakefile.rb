Dir[File.join(File.dirname(__FILE__),"*/")].each do |d|
	require_relative File.join(d,'Rakefile')
end
