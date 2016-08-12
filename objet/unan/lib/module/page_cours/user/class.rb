# encoding: UTF-8
class User
class UPage
  class << self

    # Obtenir l'instance User::UPage de l'auteur +auteur+ ({User})
    # pour la page d'identifiant +page_id+
    def get auteur, page_id
      page_id = page_id.to_i
      @instances ||= Hash.new
      @instances[auteur.id] ||= Hash.new
      @instances[auteur.id][page_id] ||= new(auteur, page_id)
    end
  end # << self
end #/Upage
end #/User
