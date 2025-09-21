require 'json'
require_relative 'lib/task'

file_path = ARGV[0] || './test_data/1.json'

puts "Loading tasks from #{file_path}..."
data = JSON.parse(File.read(file_path))

Task.build_from_array(data)

percentages = Task.completion_percentages
puts JSON.pretty_generate(percentages)

