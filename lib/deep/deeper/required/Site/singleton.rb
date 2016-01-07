# encoding: UTF-8
=begin
Définition du site
=end

class SiteHtml
  include Singleton

  alias :top_require :require
  def require module_name
    case module_name
    when 'form_tools'
      (folder_lib_optional + 'Page/form_tools.rb').require
    else
      top_require module_name
    end
  end
end

def site; @site ||= SiteHtml.instance end
