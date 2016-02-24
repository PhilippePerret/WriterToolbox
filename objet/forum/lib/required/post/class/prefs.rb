# encoding: UTF-8
class Forum
class Post
  class << self

    # Nombre de messages à afficher par défaut
    def nombre_by_default
      @nombre_by_default ||= 10 #50 
    end

  end # << self
end #/Post
end #/Forum
