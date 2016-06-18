# encoding: UTF-8
=begin

Méthodes de base de données de Unan

ATTENTION : Ce module peut être utilisé en version STANDALONE donc
            il faut qu'il puisse fonctionner le plus possible tout
            seul (l'utilisation de `site` est toujours possible,
            cependant).

=end
class Unan
class << self

  # ---------------------------------------------------------------------
  #   Toutes les tables Unan
  # ---------------------------------------------------------------------

  # Table contenant tous les programmes
  def table_programs
    @table_programs ||= site.dbm_table(:unan, 'programs')
  end

  # Table contenant tous les projets
  def table_projets
    @table_projets ||= site.dbm_table(:unan, 'projets')
  end

  # Table contenant la définition absolue de tous les
  # jours-programme
  def table_absolute_pdays
    @table_absolute_pdays ||= site.dbm_table(:unan, 'absolute_pdays')
  end

  # Table contenant toutes les données absolues des travaux (abs_works)
  def table_absolute_works
    @table_absolute_works ||= site.dbm_table(:unan, 'absolute_works')
  end

  def table_questions
    # -> MYSQL UNAN
    @table_questions ||= get_table_cold('questions')
  end

  def table_quiz
    # -> MYSQL UNAN
    @table_quiz ||= get_table_cold('quiz')
  end

  def table_exemples
    # -> MYSQL UNAN
    @table_exemples ||= get_table_cold('exemples')
  end

  def table_pages_cours
    # -> MYSQL UNAN
    @table_pages_cours ||= get_table_cold('pages_cours')
  end

  # ---------------------------------------------------------------------
  #   Méthode générique construisant la table si nécessaire
  # ---------------------------------------------------------------------

  def get_table_cold table_name
    # -> MYSQL UNAN
    site.db.create_table_if_needed('unan_cold', table_name)
  end

  # ---------------------------------------------------------------------
  #   Données générales des deux bases de données, cold et hot
  # ---------------------------------------------------------------------
  def database
    # -> MYSQL UNAN
    @database ||= BdD::new(database_path.to_s)
  end
  def database_path
    # -> MYSQL UNAN
    @database_path ||= site.folder_db + "unan_cold.db"
  end

end # << self
end # /Unan
