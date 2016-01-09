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
    @table_programs ||= get_table('programs')
  end

  # ---------------------------------------------------------------------
  #   Méthode générique construisant la table si nécessaire
  # ---------------------------------------------------------------------
  def get_table table_name
    site.db.create_table_if_needed('unan', table_name)
  end

  # ---------------------------------------------------------------------
  #   Données générales de la base de données
  # ---------------------------------------------------------------------
  def database
    @database ||= BdD::new(database_path.to_s)
  end
  def database_path
    @database_path ||= site.folder_db + "unan.db"
  end

end # << self
end # /Unan
