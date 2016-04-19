# encoding: UTF-8
class SiteHtml

  # Si la page formatée existe, on la charge directement, sinon,
  # on la construit
  def home_page_content
    unless false #file_home_page_content.exist?
      site.require_module_objet('home_page')
      site.build_home_page_content
    end
    file_home_page_content.read.force_encoding('utf-8')
  end



end #/SiteHtml
