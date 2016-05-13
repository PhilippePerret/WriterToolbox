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
  def require_objet objet_name, forcer = false
    dos = folder_objet + "#{objet_name}/lib/required"
    require_all_in dos, forcer
  end

  # Requiert tout ce qui se trouve dans le dossier module
  # +module_name+, i.e. les modules ruby, css et javascript.
  # Le dossier module se trouve à l'adresse : './lib/deep/deeper/module/'
  def require_module module_name
    dos = folder_deeper_module + module_name
    require_all_in dos
  end

  # Requiert tout (ruby, css, js) dans le dossier +dossier+
  # +dossier+ Un path {String} ou un {SuperFile}
  # C'est pour le moment uniquement pour les tests qu'on a besoin
  # de +forcer+ qui load au lieu de requirer.
  #
  # Si le dossier contient un dossier `first_required`, il est chargé
  # en tout premier lieu.
  def require_all_in dossier, forcer = false
    dossier = SuperFile::new(dossier) unless dossier.instance_of?(SuperFile)
    if forcer
      Dir["#{dossier}/first_required/**/*.rb"].each{|m| load m}
      Dir["#{dossier}/**/*.rb"].each{|m| load m}
    else
      Dir["#{dossier}/first_required/**/*.rb"].each{|m| require m}
      Dir["#{dossier}/**/*.rb"].each{|m| require m}
    end
    page.add_css        Dir["#{dossier}/**/*.css"]
    page.add_javascript Dir["#{dossier}/**/*.js"]
  end

end
