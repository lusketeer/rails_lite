module ActionControllerLite
  module Helper
    def link_to(name, path, options = {})
      html = "<a "
      html += "href=\"#{path}\" "
      options.each do |attr, val|
        html += "#{attr}=\"#{val}\" "
      end
      html += ">" + name + "</a>"
      html
    end
  end
end
