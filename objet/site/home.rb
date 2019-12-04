# encoding: UTF-8
class SiteHtml

  # Retourne le contenu de la page d'accueil du site.
  # La construction (le cas échéant) se fait dans le module
  # ./objet/site/lib/module/home_page
  #
  def home_page_content
    app.benchmark('-> SiteHtml#home_page_content')
    if user.manitou? && param(:update_home_page) == "1"
      # debug "= home_page_out_of_date? => Il faut reconstruire la page d'accueil"
      app.benchmark('[SiteHtml#home_page_content] * Chargement de la librairie home_page')
      site.require_module_objet 'home_page'
      app.benchmark('[SiteHtml#home_page_content] * Librairie home_page chargée')
      site.build_home_page_content
    end
    res = file_home_page_content.read.force_encoding('utf-8')
    app.benchmark('<- SiteHtml#home_page_content')
    return res
  end
end #/SiteHtml
