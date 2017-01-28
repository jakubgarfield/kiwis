class ConvertMapMarkup < Nanoc::Filter
  identifier :convert_map_markup
  type :text

  def run(content, params = {})
    regex = /(!!!\[(.*?)\]\()(.*?)(\))/
    content.gsub(regex) do
<<EOF
<div class="cardboard">
  <a href="#{image_path(@item, $3, rep: 960, extension: "png")}" class="itinerary-link" target="_blank"><img alt="#{$2}" src="#{image_path(@item, $3, extension: "png")}" /></a>
</div>
EOF
    end
  end
end
