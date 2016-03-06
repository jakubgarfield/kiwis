class AbsoluteAtom < Nanoc::Filter
  identifier :absolute_urls
  type :text
  def run(content, params={})
    content.gsub(/((href|src)=")\//, '\1' + @config[:base_url] + '/')
  end
end
