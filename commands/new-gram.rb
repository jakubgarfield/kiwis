summary     'creates a gallery landing page'
description <<desc
Creates a new gallery landing page
desc
usage     'new-gram name [options]'

flag   :h, :help,  'show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end

run do |opts, args, cmd|
  require 'stringex'

  name = args[0]
  filename = "content/gallery/#{name.to_url}.md"

  exit_with("The landing page already exists") if File.exist?(filename)

  puts "Creating new landing page: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "title: #{name}"
    post.puts "description: "
    post.puts "tags: []"
    post.puts "trip: "
    post.puts "photo: "
    post.puts "---\n\n"
  end
end

def exit_with(message)
  $stderr.puts "Command failed: #{message}"
  exit 1
end
