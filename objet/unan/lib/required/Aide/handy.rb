# encoding: UTF-8

# Retourne un lien vers l'aide
# Pour ajouter un symbol à la map :
# ./objets/unan/lib/required/data/aide_symbols_map.rb
class Unan
class << self
  def lien_aide relpath, titre = nil, options = nil
    case relpath
    when :home
      options ||= Hash::new
      options.merge!(href:"aide/home?in=unan")
      (titre || "Aide").in_a(options)
    # when :overview
    #
    else
      Unan::Aide::link_to relpath, titre, options
    end
  end
  alias :link_help :lien_aide
end
end
