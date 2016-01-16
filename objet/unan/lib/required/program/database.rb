# encoding: UTF-8
=begin

Méthodes de base de données

Rappel : Toutes les données de l'auteur pour son programme sont
enregistrées dans une table ./database/data/unan/<id auteur>/

=end
class Unan
class Program

  def table_programs
    @table_programs ||= site.db.create_table_if_needed('unan_hot', 'programs')
  end
  def table_projets
    @table_projets ||= site.db.create_table_id_needed('unan_hot', 'projets')
  end

  def database
    @database ||= BdD::new(database_path.to_s)
  end


end #/Program
end #/Unan
