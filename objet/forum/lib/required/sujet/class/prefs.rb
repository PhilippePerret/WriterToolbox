# encoding: UTF-8
class Forum
class Sujet
  class << self

    # Nombre de sujets à afficher par défaut
    def nombre_by_default
      @nombre_by_default ||= 30
    end

  end # << self
end #/Sujet
end #/Forum
