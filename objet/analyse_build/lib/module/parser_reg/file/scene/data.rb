# encoding: UTF-8
class AnalyseBuild
class Film
class Scene

  # Toutes les données sous forme de Hash qui peuvent être enregistrées
  # dans le fichier Marshal par exemple
  def all_data
    {
      numero:             numero,
      horloge:            horloge,
      time:               time,
      effet:              effet,
      lieu:               lieu,
      decor:              decor,
      resume:             resume,
      brins:              brins.uniq,
      personnages:        personnages.uniq,
      notes:              notes.uniq,
      data_paragraphes:   data_paragraphes
    }
  end

  # Méthode pour ajouter des brins (identifiants) à la liste
  # des brins de la scène.
  def add_brins brs
    brs.each{|bid| brins << bid}
  end

  def add_personnages prs
    prs.each{|pid| personnages << pid}
  end

  def add_notes nos
    nos.each{|nid| notes << nid}
  end

  def add_scenes scs
    scs.each{|sid| scenes << sid}
  end
  
end #/Scene
end #/Film
end #/AnalyseBuild
