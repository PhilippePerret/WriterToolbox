# encoding: UTF-8
=begin
Méthodes qui permettent de procéder au rapport
au site
=end
class Connexions
class Connexion
class << self

  # {String} Le rapport final, au format HTML
  attr_reader :report

  # = main =
  #
  # Méthode principale procédant à la création du rapport
  # de connexion qui sera enregistré dans le fichier et
  # envoyé à l'administrateur.
  #
  def generate_report
    analyse
    build_report
    save_report
    send_report
  end

  # = main =
  #
  # Méthode principale de construction du rapport de connexions
  def build_report
    @report = String.new
    report_statistiques_generales
  end

  # Enregistre le rapport dans un fichier
  def save_report

  end

  # Envoi le rapport à l'administration
  def send_report

  end

end #/<< self
end #/Connexion
end #/Connexions
