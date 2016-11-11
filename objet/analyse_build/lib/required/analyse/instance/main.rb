# encoding: UTF-8
class AnalyseBuild

  attr_reader :film_id

  # Instanciation d'un chantier d'analyse propre au film courant
  # Cette méthode est utile pour le fonctionnement automatique de
  # la route. On peut obtenir ensuite automatiquement le chantier
  # par site.current_route.instance
  def initialize film_id
    @film_id = film_id
  end

  def film
    @film ||= Filmodico.new(film_id)
  end

end#/AnalyseBuild
