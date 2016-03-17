summary     'creates a new trip'
description <<desc
Creates a new trip and copies appropriate photos.
desc
usage     'new-post name [options]'

option :p, :photos,   'location of the photo directory to import', :argument => :required
option :c, :created_at,   'creation date for this blog post (ex. "2013-01-03 10:24")', :argument => :optional

flag   :h, :help,  'show help for this command' do |value, cmd|
  puts cmd.help
  exit 0
end

run do |opts, args, cmd|
  require 'stringex'

  exit_with("Specify the photos import directory by setting -p") unless opts[:photos]

  name = args[0]
  photo_import_dir = File.expand_path(opts[:photos])
  timestamp = DateTime.parse(opts[:created_at]).to_time rescue Time.now


  directory = "content/trips/#{timestamp.year}/#{ format('%02d', timestamp.month) }/#{ format('%02d', timestamp.day) }/#{name.to_url}"
  filename = directory + "/index.md"

  FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
  exit_with("The trip already exists") if File.exist?(filename)

  puts "Creating new post: #{filename}"
  open(filename, 'w') do |post|
    post.puts "---"
    post.puts "title: #{name}"
    post.puts "created_at: #{timestamp}"
    post.puts "description:"
    post.puts "kind: article"
    post.puts "tags: []"
    post.puts "image: 1"
    post.puts "map_zoom: 10"
    post.puts "map_coordinates: "
    post.puts "gpx: false"
    post.puts "---\n\n"
  end

  puts "Processing photos from: #{photo_import_dir}"
  Dir[photo_import_dir + "/*.jpg"].each do |filename|
    [960, 640].each do |size|
      photo_dir = "content/photos/#{size}x/#{name.to_url}/"
      FileUtils.mkdir_p(photo_dir) unless Dir.exist?(photo_dir)
      output_filename = photo_dir + File.basename(filename)
      puts "Converting: #{output_filename}"
      process_image(filename, output_filename, size, 85)
    end
  end
end

def process_image(filename, output_filename, width, quality)
  exit_with("convert from ImageMagick needs to be installed") unless which("convert")
  `convert #{filename} -resize #{width}x\\> -strip -quality #{quality} #{output_filename}`
  if File.exists?("/opt/mozjpeg/bin/jpegtran")
    `/opt/mozjpeg/bin/jpegtran -outfile #{output_filename} -optimize #{output_filename}`
  elsif File.exists?("/usr/local/opt/mozjpeg/bin/jpegtran")
    `/usr/local/opt/mozjpeg/bin/jpegtran -outfile #{output_filename} -optimize #{output_filename}`
  else
    exit_with("mozjpeg needs to be installed")
  end
end

def exit_with(message)
  $stderr.puts "Command failed: #{message}"
  exit 1
end

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end
