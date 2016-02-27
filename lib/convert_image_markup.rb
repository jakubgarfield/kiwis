class ConvertImageMarkup < Nanoc::Filter
  identifier :convert_image_markup
  type :text

  def run(content, params = {})
    regex = /(!!\[(.*?)\]\()(.*?)(\))/
    content.gsub(regex) do
<<EOF
<figure>
  <a href="#{image_path(@item, $3, rep: 960)}" class="gallery-link"><img alt="#{$2}" src="#{image_path(@item, $3)}" /></a>
  <figcaption>#{$2}</figcaption>
</figure>
EOF
    end
  end
end
