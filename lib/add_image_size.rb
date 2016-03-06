require 'nokogiri'
require 'image_size'

class AddImageSize
  def call(content)
    doc = content =~ /<html[\s>]/ ? ::Nokogiri::HTML.parse(content) : ::Nokogiri::HTML.fragment(content)

    doc.css("img")
    .select { |node| node.is_a? Nokogiri::XML::Element }
    .select { |img| img.has_attribute?('src') }
    .each do |img|
      dimensions = image_size(img['src'])
      dimensions.each{|k,v| img[k.to_s] = v.to_s}
    end
    doc.to_html
  end

  def image_size(path)
    path = '/' + path unless path[0, 1] == '/'
    img = ImageSize.new(IO.read("output#{path}"))
    { :height => img.height, :width => img.width }
  end

end
