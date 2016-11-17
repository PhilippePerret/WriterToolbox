# encoding: UTF-8
class AnalyseBuild

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

  # Identifiant du film
  # Il peut être défini à l'instanciation ou plus tard, comme ça
  # arrive à la demande de reconstruction des fichiers.
  def film_id
    @film_id ||= marshal_data[:film_id]
  end

  # Les données enregistrées dans le fichier FDATA.msh
  def marshal_data
    @marshal_data ||= Marshal.load(data_file.read)
  end

end#/AnalyseBuild
