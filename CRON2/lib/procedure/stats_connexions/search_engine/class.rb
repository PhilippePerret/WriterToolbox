# encoding: UTF-8
class Connexions
class SearchEngine
class << self

  # Appelée en bas de fichier
  def init
    @list = Hash.new
  end

  # Retourne l'instance Connexions::SearchEngine du moteur
  # de recherche d'ID human +human_id+
  # Ou nil si ça n'est pas un moteur de recherche.
  #
  # Note : les instances moteurs de recherche sont instanciés lorsqu'on
  # utilise `search_engine?` sur une IP qui a fait une connexion.
  def [] human_id
    @list[human_id]
  end

  def add sengine
    @list.merge!(sengine.human_id => sengine)
  end

end #<< slef
end #/SearchEngine
end #/Connexions

Connexions::SearchEngine.init
