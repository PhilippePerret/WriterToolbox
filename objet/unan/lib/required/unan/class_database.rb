# encoding: UTF-8
=begin

Méthodes de base de données de Unan
=end
class Unan
class << self

  # ---------------------------------------------------------------------
  #   Toutes les tables Unan
  # ---------------------------------------------------------------------

  # Table contenant tous les programmes
  def table_programs
    @table_programs ||= get_table_hot('programs')
  end

  # Table contenant tous les projets
  def table_projets
    @table_projets ||= get_table_hot('projets')
  end

  # Table contenant la définition absolue de tous les
  # jours-programme
  def table_absolute_pdays
    @table_absolute_pdays ||= get_table_cold('absolute_pdays')
  end

  # Table contenant toutes les données absolues des travaux (abs_works)
  def table_absolute_works
    @table_absolute_works ||= get_table_cold('absolute_works')
  end

  def table_questions
    @table_questions ||= get_table_cold('questions')
  end

  def table_quiz
    @table_quiz ||= get_table_cold('quiz')
  end

  def table_exemples
    @table_exemples ||= get_table_cold('exemples')
  end

  # ---------------------------------------------------------------------
  #   Méthode générique construisant la table si nécessaire
  # ---------------------------------------------------------------------
  def get_table_cold table_name
    site.db.create_table_if_needed('unan_cold', table_name)
  end
  def get_table_hot table_name
    site.db.create_table_if_needed('unan_hot', table_name)
  end

  # ---------------------------------------------------------------------
  #   Données générales des deux bases de données, cold et hot
  # ---------------------------------------------------------------------
  def database
    @database ||= BdD::new(database_path.to_s)
  end
  def database_path
    @database_path ||= site.folder_db + "unan_cold.db"
  end
  def database_hot
    @database_hot ||= BdD::new(database_hot_path.to_s)
  end
  def database_hot_path
    @database_hot_path ||= site.folder_db + 'unan_hot.db'
  end

end # << self
end # /Unan
