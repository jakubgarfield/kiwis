class ResizeImage < Nanoc::Filter
  identifier :resize_image
  type :binary

  def run(filename, params = {})
    # requires imagemagick and mozjpeg installed
    quality = params[:quality]
    width = params[:width]
    puts "Converting #{filename}"
    `convert #{filename} -resize #{width}x\\> -strip -quality #{quality} #{output_filename}`
    `/opt/mozjpeg/bin/jpegtran -outfile #{output_filename} -optimize #{output_filename}`
  end
end
