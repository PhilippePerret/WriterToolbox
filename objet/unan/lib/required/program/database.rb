# encoding: UTF-8
=begin

Méthodes de base de données

Rappel : Toutes les données de l'auteur pour son programme sont
enregistrées dans une table ./database/data/unan/<id auteur>/

=end
class Unan
class Program

  def database
    @database ||= BdD::new(database_path.to_s)
  end


end #/Program
end #/Unan
