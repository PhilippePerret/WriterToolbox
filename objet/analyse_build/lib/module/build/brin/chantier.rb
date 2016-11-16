# encoding: UTF-8
class AnalyseBuild

  # = main =
  #
  # Méthode principale de construction des brins
  #
  # La méthode n'est appelée que si des brins ont été collectés.
  #
  # RETURN true en cas de succès et false en cas d'échec
  def build_brins
    suivi "Construction des brins"
  rescue Exception => e
    debug e
    error "Erreur lors de la construction des brins : #{e.message}"
  else
    true # pour poursuivre
  end

end #/AnalyseBuild
