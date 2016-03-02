# encoding: UTF-8
=begin
Extension de la class SuperFile pour le traitement avec les
analyse.
=end
class SuperFile

  # Méthode principale retournant le code HTML d'un fichier
  # évènemencier pour affichage dans les analyses
  # La méthode utilise le module 'evc' qui doit avoir été
  # chargé par la méthode appelante à l'aide de :
  #     FilmAnalyse::require_module 'evc'
  def as_evc options = nil
    Evc::new(self.path.to_s).as_ul(options)
  end

  def deyamelize
    YAML::load_file(self.to_s).to_sym
  end

  def yaml_content
    @yaml_content ||= self.deyamelize
  end

end
