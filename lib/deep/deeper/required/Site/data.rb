# encoding: UTF-8
=begin
Class SiteHtml
--------------
Méthodes de données
=end
class SiteHtml

  # Pour surclasser le titre dans le fichier de configuration
  attr_writer :title
  # Le Title du site, servant notamment pour la bande logo
  # Il faut être surclassé par l'option de configuration de
  # même nom (`site.title` dans le fichier ./objet/site/config.rb)
  def title
    @title ||= name.upcase
  end
  def base
    @base ||= ( ONLINE ? distant_url : local_url ) + "/"
  end

end
