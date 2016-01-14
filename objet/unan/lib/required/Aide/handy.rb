# encoding: UTF-8

# Retourne un lien vers l'aide
# Pour ajouter un symbol à la map :
# ./objets/unan/lib/required/data/aide_symbols_map.rb
class Unan
class << self
  def lien_aide relpath, titre = nil, options = nil
    Unan::Aide::link_to relpath, titre, options
  end
  alias :link_help :lien_aide
end
end