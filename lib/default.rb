# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.
require 'date'

include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::Tagging
include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::LinkTo

def images_for(item)
  item.children.select { |i| i[:extension] == "jpg" && i.identifier.include?("preview") }.to_a
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

def full_path(item)
  "" + item.identifier
end

require 'nokogiri'
require 'exifr'
require 'zip'
class GeolocationFilter < Nanoc::Filter
  identifier :geolocate
  type :text

  def run(content, params = {})
    document = Nokogiri::XML(content)
    node = document.at_css("Document")
    node.add_child(marker_style_node)
    geolocated_photos_metadata.each { |data| node.add_child(placemark_node(data)) }

    stringio = Zip::OutputStream::write_buffer do |zio|
      zio.put_next_entry("doc.kml")
      zio.write document.to_xml
    end
    stringio.rewind
    stringio.sysread
  end

  private
  def photos
    @item.parent.children.select { |i| i[:extension] == "jpg" }
  end

  def geolocated_photos_metadata
    photos.map do |photo|
      exif = EXIFR::JPEG.new(photo.raw_filename)
      exif.gps ? { gps: exif.gps, name: photo.identifier.split("/").last } : nil
    end.compact
  end

  def marker_style_node
    "<Style id='photo'><IconStyle>
      <scale>1</scale>
      <Icon><href>http://kiwis.chodounsky.net/resources/img/photo.png</href></Icon>
      <hotSpot x='20' y='2' xunits='pixels' yunits='pixels'/>
    </IconStyle></Style>"
  end

  def placemark_node(data)
    "<Placemark><Point><coordinates>#{data[:gps].longitude},#{data[:gps].latitude}</coordinates></Point>
      <styleUrl>#photo</styleUrl>
      <name>#{data[:name]}</name>
      <description><![CDATA[<img src='http://kiwis.chodounsky.net#{@item.parent.identifier}preview_#{data[:name]}.jpg'/> ]]></description>
    </Placemark>"
  end
end
