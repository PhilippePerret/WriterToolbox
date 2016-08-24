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

  # Table des lectures de pages de cours
  def table_pages_cours
    @table_pages_cours ||= site.dbm_table(:users_tables, "unan_pages_cours_#{id}")
  end

  # Table des travaux accomplis ou en cours de l'user
  def table_works
    @table_works ||= site.dbm_table(:users_tables, "unan_works_#{id}")
  end

  # Table des questionnaires
  # OBSOLÈTE : Il faut utiliser la classe Quiz, les questionnaires du
  # programme UNAN sont comme les autres.
  # def table_quiz
  #   @table_quiz ||= site.dbm_table(:users_tables, "unan_quiz_#{id}")
  # end

end
