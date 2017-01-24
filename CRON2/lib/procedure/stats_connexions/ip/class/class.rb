# encoding: UTF-8
=begin
  NOTE
    On appelle la méthode `init` en bas de fichier
=end
class Connexions
class IP
class << self

  # Initialisation de la class Connexions::IP
  # Notamment, charge les IP connues et en fait une
  # liste d'IP connues
  #
  # NOTE
  #   Cette méthode est appelée en bas de fichier
  #
  def init
    require './data/secret/known_ips'
    require './data/secret/known_users'
  end


  # Retourne TRUE si la liste des moteurs de recherche
  # contient l'IP +searched_ip+. False dans le cas contraire
  #
  # TODO
  #   NON ! ICI, IL FAUT FAIRE D'ABORD LA LISTE DE TOUTES LES
  #   INSTANCE DE MOTEUR DE RECHERCHE, ET RENVOYER L'INSTANCE
  #   SI ELLE EXISTE DÉJÀ.
  def get_search_engine_with_ip searched_ip
    SEARCH_ENGINES_IPS_LIST.each do |human_id, data_ip|
      data_ip[:ips].each do |reg_ip|
        if searched_ip.match(reg_ip) != nil
          Connexions::SearchEngine[human_id] || begin
            Connexions::SearchEngine.add(Connexions::SearchEngine.new(human_id))
          end
          return Connexions::SearchEngine[human_id]
        end
      end
    end
    return nil
  end

end #/<< self
end #/IP
end #/Connexions

Connexions::IP.init
