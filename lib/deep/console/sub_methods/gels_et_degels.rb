# encoding: UTF-8
raise_unless_admin

class SiteHtml
class Admin
class Console

  # Retourne la liste des gels
  def affiche_liste_des_gels
    site.require_module('gel')
    Dir["#{Gel::folder}/*"].collect do |path|
      File.basename(path)
    end.join("\n")
  end

  def gel gel_name
    site.require_module('gel')
    Gel::gel(gel_name)
    "Le site a été gelé dans `#{gel_name}`."
  end

  def degel gel_name
    site.require_module('gel')
    Gel::degel(gel_name)
    "Le gel `#{gel_name}` a été degelé."
  end

end #/Console
end #/Admin
end #/SiteHtml
