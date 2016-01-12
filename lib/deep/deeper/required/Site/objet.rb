# encoding: UTF-8
=begin
Méthode pour la gestion des "objets"

@usage

    site.<methode>[ <arguments>]

=end
class SiteHtml

  # Requiert tout le dossier lib/required de l'objet de nom
  # +objet_name+. +objet_name+ doit être un nom contenu dans le
  # dossier `./objet`
  # Charge également tous les CSS et tous les JS du dossier
  # lib/required
  # Note : Pour le moment, produit une erreur fatale si le dossier
  # n'existe pas.
  def require_objet objet_name
    dossier = site.folder_objet + "#{objet_name}/lib/required"
    dossier.require
    page.add_css        Dir["#{dossier}/**/*.css"]
    page.add_javascript Dir["#{dossier}/**/*.js"]
  end

end
