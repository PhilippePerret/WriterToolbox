# encoding: UTF-8
=begin
Class SiteHtml
--------------
Méthodes de données
=end
class SiteHtml

  # Pour le moment, placé ici, mais plus tard, il faudra le mettre
  # plus à disposition, dans un fichier de configuration du site
  def title
    @title ||= name.upcase
  end
  def base
    @base ||= ( ONLINE ? distant_url : local_url ) + "/"
  end

end
