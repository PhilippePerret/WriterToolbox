# encoding: UTF-8
=begin

Méthodes de base de données

Rappel : Toutes les données de l'auteur pour son programme sont
enregistrées dans une table ./database/data/unan/<id auteur>/

=end
class Unan
class Program

  class << self
    def table_works
      @table_works ||= Unan::table_absolute_works
    end
  end

  # Tables des P-Days propres au programme
  # Noter qu'il faut utiliser `auteur.table_pdays` pour construire
  # la table en cas d'inexistence
  def table_pdays
    @table_pdays ||= auteur.table_pdays
  end
  # Tables des Work(s) propres au programme
  # Noter qu'il faut utiliser `auteur.table_works` pour construire
  # la table en cas d'inexistence
  def table_works
    @table_works ||= auteur.table_works
  end

  # {BdD} Base de donnée propre à ce programme en particulier
  def database
    @database ||= BdD::new(database_path.to_s)
  end

end #/Program
end #/Unan
