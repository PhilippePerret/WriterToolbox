# encoding: UTF-8
=begin
Définition du site
=end

class SiteHtml
  include Singleton

  def require module_name
    case module_name
    when 'form_tools'
      (folder_lib_optional + 'Page/form_tools.rb').require
    end
  end
end

def site; @site ||= SiteHtml.instance end
