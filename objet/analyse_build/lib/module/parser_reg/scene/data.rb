# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  # Toutes les données sous forme de Hash qui doivent être enregistrées
  # dans le fichier Marshal
  def all_data
    {
      horloge:    horloge,
      time:       time,
      effet:      effet,
      lieu:       lieu,
      decor:      decor,
      resume:     resume,
      brins_ids:  brins_ids,
      notes:      notes
    }
  end

  def horloge
    @horloge != nil || parse_first_line
    @horloge
  end

  def time
    @time != nil || parse_first_line
    @time
  end

  def effet
    @effet != nil || parse_first_line
    @effet
  end

  def lieu
    @lieu != nil || parse_first_line
    @lieu
  end

  def decor
    @decor != nil || parse_first_line
    @decor
  end

  def resume
    @resume != nil || parse_first_line
    @resume
  end

  def brins
    @brins ||= film.brins.select{|n| brins_ids.include? n}
  end

  def brins_ids
    @brins_ids != nil || parse_first_line
    @brins_ids
  end

  # Les notes, c'est-à-dire les lignes suivant la première ligne
  # d'infos. Chaque note est un Hash définissant ses valeurs, la
  # liste des notes est un Hash avec en clé l'indice de la note
  # s'il est défini
  def notes
    @notes != nil || parse_notes
  end


end #/Scene
end #/Film
end #/AnalyseBuild
