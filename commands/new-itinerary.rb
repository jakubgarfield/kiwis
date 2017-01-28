summary     'creates a new itinerary'
description <<desc
Creates a new itinerary.
desc
usage     'new-itinerary name [options]'

flag   :h, :help,  'show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end

run do |opts, args, cmd|
  require 'stringex'

  name = args[0]
  timestamp = DateTime.parse(opts[:created_at]).to_time rescue Time.now

  directory = "content/itineraries/#{timestamp.year}/#{ format('%02d', timestamp.month) }/#{ format('%02d', timestamp.day) }/#{name.to_url}"
  filename = directory + "/index.md"

  FileUtils.mkdir_p(directory) unless Dir.exist?(directory)

  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "title: #{name}"
    post.puts "created_at: #{timestamp}"
    post.puts "description:"
    post.puts "kind: article"
    post.puts "tags: []"
    post.puts "image: main"
    post.puts "itinerary: true"
    post.puts "---\n\n"
  end
end
