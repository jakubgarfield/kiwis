# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.
require 'date'
require 'gpxvis'
require 'nokogiri'

include Nanoc::Helpers::Blogging
include Nanoc::Helpers::Tagging
include Nanoc::Helpers::Rendering
include Nanoc::Helpers::LinkTo
include Nanoc::Helpers::XMLSitemap

def title_for(item)
  (@item[:title] ? @item[:title] + " | " : "")  + @config[:title]
end

def post_metadata(post)
  "<aside>#{attribute_to_time(post[:created_at]).strftime("%B %e, %G")}<br />#{post[:tags].join(", ")}.</aside>"
end

def sorted_gallery_items
  @sorted_gallery_items ||= items.select { |i| i[:kind] && i[:kind] == "gallery" }.sort_by { |i| i[:created_at] }.reverse
end

def sorted_articles_with_gallery_items
  @sorted_articles_with_gallery_items ||= sorted_gallery_items.concat(sorted_articles).flatten.sort_by { |i| i[:created_at] }
end

def combine_files_content(filenames)
  filenames.map do |filename|
    items.find { |item| item[:filename].end_with? filename }.raw_content
  end.join
end

def sorted_articles_grouped_by_country
  sorted_articles.group_by do |item|
    if item[:tags].include?("New Zealand")
      "New Zealand"
    elsif item[:tags].include?("Tasmania")
      "Tasmania"
    elsif item[:tags].include?("Australia")
      "Australia"
    elsif item[:tags].include?("Bali")
      "Bali"
    elsif item[:tags].include?("Vietnam")
      "Vietnam"
    elsif item[:tags].include?("New Caledonia")
      "New Caledonia"
    elsif item[:tags].include?("Samoa")
      "Samoa"
    else
      "Other"
    end
  end.sort do |a, b|
    if a[0] == "Other"
      1
    elsif b[0] == "Other"
      -1
    else
      a[0] <=> b[0]
    end
  end.to_h
end

def tags
  tags = Set.new
  items.each do |item|
    next if item[:tags].nil?
    item[:tags].each { |tag| tags << tag }
  end
  tags.to_a
end

def page_url(item)
  @config[:base_url] + item.path
end

def gallery_image_url(id, image)
  @config[:base_url] + gallery_image_path(id, image)
end

def gallery_image_path(id, image)
  "/photos/960x/#{id}/#{image}.jpg"
end

def page_image_url(item)
  if item[:image]
    image_url(item, item[:image], rep: 960, extension: item[:itinerary] ? "png" : "jpg")
  else
    @config[:base_url] + "/img/about.jpg"
  end
end

def item_name(item)
  item.identifier.to_s.split("/").last
end

def image_url(item, image, rep: 640, extension: "jpg")
  @config[:base_url] + image_path(item, image, rep: rep, extension: extension)
end

def image_path(item, image, rep: 640, extension: "jpg")
  "/photos/#{rep}x/#{item_name(item)}/#{image}.#{extension}"
end

def find_trip(id)
  articles.find { |i| i.identifier =~ /\/trips\/(.*)#{id}/ }
end

def article_image(item, extension: "jpg")
  "<a href=\"#{image_path(item, item[:image], rep: 960, extension: extension)}\" class=\"gallery-link\"><img src=\"#{image_path(item, item[:image], rep: 960, extension: extension)}\" alt=\"#{item[:title]}\" /></a>"
end

def generate_geojson(item)
  file_names = item.children.select { |i| i[:extension] == "gpx" }.map(&:raw_filename).sort
  tracks = file_names.map { |file_name| track_from_file(file_name) }
  Gpxvis::GeoJsonFormatter.new(tracks).format
end

def track_from_file(file_name)
  gpx_document = File.open(file_name) { |f| Nokogiri::XML(f) }

  track_element = gpx_document.xpath("//xmlns:trk").first
  raise "No 'trk' element found in #{file_name}" unless track_element
  Gpxvis::Track.from_gpx_element(track_element)
end

