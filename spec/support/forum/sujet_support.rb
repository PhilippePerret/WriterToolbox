# encoding: UTF-8
class Forum
  class << self

    # Retourne un sujet au hasard
    # Note : Le crée si le sujet n'existe pas
    def get_any_sujet
      if forum.table_sujets.count == 0
        create_sujet
      end
      ids = forum.table_sujets.select(colonnes:[]).keys
      id = ids.shuffle.shuffle.first
      Forum::Sujet::get(id)
    end

    # Crée un sujet et retourne son instance
    def create_sujet

    end

  end # << self
end #/Forum
