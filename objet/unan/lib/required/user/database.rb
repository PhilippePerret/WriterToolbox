# encoding: UTF-8
=begin
Extensions de User pour les bases de données propres à 1an 1script
=end
class User

  # ---------------------------------------------------------------------
  # TABLES
  #
  # Ces méthodes de récupération des tables les créent si les tables
  # n'existent pas.
  # ---------------------------------------------------------------------

  # Méthode pour obtenir une variable du programme UNAN
  def get_unan_var var_id
    get_var( var_id, nil, {unan: true} )
  end
  # Méthode pour définir une variable du programme UNAN
  def set_unan_var var_id, var_value
    set_var( var_id, var_value, {unan: true} )
  end

  # Table des lectures de pages de cours
  def table_pages_cours
    @table_pages_cours ||= site.dbm_table(:users_tables, "unan_pages_cours_#{id}")
  end

  # Table des travaux accomplis ou en cours de l'user
  def table_works
    @table_works ||= site.dbm_table(:users_tables, "unan_works_#{id}")
  end

  # Table des variables propres au programme UNAN
  def table_variables_unan
    @table_variables ||= site.dbm_table(:users_tables, "unan_variables_#{id}")
  end

end
