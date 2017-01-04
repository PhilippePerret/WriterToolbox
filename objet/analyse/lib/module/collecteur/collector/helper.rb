# encoding: UTF-8
class FilmAnalyse
class Collector
class << self

  # = main =
  #
  # Méthode principale sortant l'interface pour le collector
  #
  # Note : tous les champs de données, pour les personnages, les brins,
  # etc. sont définis en javascript (cf. la méthode `DataField.build_data_field`).
  #
  def ui

    textarea_collecteur +
    collector_tools

  end

  def textarea_collecteur
    (param(:collector)||'').in_textarea(id: 'collector', name: 'collector', placeholder:'Collecte des scènes')
  end

  # Les boutons de bas de page, qui permettent par exemple de lancer
  # la collecte
  def collector_tools
    (
      horloge_temps +
      champ_start_time +
      bouton_start +
      bouton_aide
    ).in_div(id: 'collector_tools')
  end

  # Horloge pour suivre le temps quand il est lancé
  def horloge_temps
    '<span id="horloge">0:00:00</span>'
  end
  def champ_start_time
    'Départ : <input type="text" id="start_time" placeholder="0:00:00" value="0:00:05" />'
  end
  def bouton_start
    '<input type="button" id="bouton_start" class="btn tiny" value="Start" onclick="$.proxy(Collector,\'start\')()"/>'
  end
  def bouton_aide
    '<input type="button" class="tiny" value="Aide" onclick="$.proxy(Collector,\'aide\')()"/>'
  end

end #/<< self
end #/Collector
end #/FilmAnalyse
