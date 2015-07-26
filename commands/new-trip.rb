summary     'creates a new blog post'
description <<desc
This command creates a new blog post under content/blog/{year}/{month}/example.html.
You can additionally pass in the description, the tags and the creation date.
desc
usage     'new-post name [options]'

option :d, :description,  'description for this blog post (ex. "This is a description")', :argument => :optional
option :t, :tags,         'tags for this blog post (ex. "these,are,tags")', :argument => :optional
option :c, :created_at,   'creation date for this blog post (ex. "2013-01-03 10:24")', :argument => :optional

flag   :h, :help,  'show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end

run do |opts, args, cmd|
  # requirements
  require 'stringex'
  require 'highline'

  # load up HighLine
  line = HighLine.new

  # get the name and description parameter or the default
  name = args[0] || "New blog post"
  description = opts[:description] || "This is the description"

  # convert the tags string to and array of trimmed strings
  tags = opts[:tags].split(",").map(&:strip) rescue []

  # convert the created_at parameter to a Time object or use now
  timestamp = DateTime.parse(opts[:created_at]).to_time rescue Time.now

  directory = "content/trips/#{timestamp.year}/#{ format('%02d', timestamp.month) }/#{ format('%02d', timestamp.day) }/#{name.to_url}"
  filename = directory + "/index.md"
  FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
  if File.exist?(filename) && line.ask("#{filename} already exists. Want to overwrite? (y/n)", ['y','n']) == 'n'

    # user pressed 'n', abort!
    puts "Blog post creation aborted!"
    exit 1
  end

  # write the scaffolding
  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "title: #{name}"
    post.puts "created_at: #{timestamp}"
    post.puts "description: #{description}"
    post.puts "kind: article"
    post.puts "tags: #{tags.inspect}"
    post.puts "image: 1"
    post.puts "map_zoom: 13"
    post.puts "map_coordinates: "
    post.puts "---\n\n"
  end
end
