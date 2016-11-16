# encoding: UTF-8
class AnalyseBuild

  attr_reader :film_id

  # Instanciation d'un chantier d'analyse propre au film courant
  # Cette méthode est utile pour le fonctionnement automatique de
  # la route. On peut obtenir ensuite automatiquement le chantier
  # par site.current_route.instance
  #
  # +film_id+, l'identifiant du film dans le filmodico, devrait être
  # toujours défini, sauf lorsqu'on arrive sur la page pour le dépôt.
  # 
  def initialize film_id = nil
    @film_id = film_id
  end

  def film
    @film ||= Filmodico.new(film_id)
  end

end#/AnalyseBuild
