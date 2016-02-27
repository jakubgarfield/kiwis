# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.
require 'date'

include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::Tagging
include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::LinkTo
include Nanoc3::Helpers::XMLSitemap

def title_for(item)
  (@item[:title] ? @item[:title] + " | " : "")  + @site.config[:title]
end

def post_metadata(post)
  "<aside>#{attribute_to_time(post[:created_at]).strftime("%B %e, %G")}<br />#{post[:tags].join(", ")}.</aside>"
end

def combine_files_content(filenames)
  filenames.map do |filename|
    items.find { |item| item[:filename].end_with? filename }.raw_content
  end.join
end

def tags
  tags = Set.new
  items.each do |item|
    next if item[:tags].nil?
    item[:tags].each { |tag| tags << tag }
  end
  tags.to_a
end

def generate_geojson(item)
  "{}"
end

def page_url(item)
  @site.config[:base_url] + item.path
end

def page_image_url(item)
  if item[:image]
    image_url(item, item[:image], rep: 960)
  else
    @site.config[:base_url] + "/img/about.jpg"
  end
end

def item_name(item)
  item.identifier.split("/").last
end

def image_url(item, image, rep: 640)
  @site.config[:base_url] + image_path(item, image, rep: rep)
end

def image_path(item, image, rep: 640)
  "/photos/#{rep}x/#{item_name(item)}/#{image}.jpg"
end

def article_image(item)
  "<a href=\"#{image_path(item, item[:image], rep: 960)}\" class=\"gallery-link\"><img src=\"#{image_path(item, item[:image], rep: 960)}\" alt=\"#{item[:title]}\" /></a>"
end
