# encoding: UTF-8
=begin

Class Unan::Projet
Extension des méthodes d'instance de statut

=end
class Unan
class Projet

  # Retoure TRUE si le projet existe. FALSE sinon.
  def exist?
    Unan.table_projets.count(where:"id = #{id}") > 0
  end

end #/Projet
end #/Unan
