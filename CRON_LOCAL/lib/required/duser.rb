# encoding: UTF-8
=begin

  Class qui gère les users réels, i.e. sur la base distante

=end
class DUser
  class << self

    # La table distante des users
    def table_users
      @table_users ||= site.dbm_table(:hot, 'users', online = true)
    end
    alias :table :table_users
  end # <<self


  # ---------------------------------------------------------------------
  #   Instances
  # ---------------------------------------------------------------------
  attr_reader :id, :mail, :pseudo, :patronyme, :sexe
  attr_reader :data # toutes les données distantes relevées

  # Pour un auteur du programme UN AN UN SCRIPT
  attr_reader :program_id,
              :program_current_pday, :program_current_pday_start,
              :program_rythme, :program_created_at


  # +uid+ Identifiant de l'auteur, dans la table distante
  # +options+ Data supplémentaires, par exemple les informations
  # sur le programme si c'est un auteur du programme UN AN
  # UN SCRIPT
  #
  # Noter qu'on va relever ses données dès qu'on l'instancie
  #
  def initialize uid, options = nil
    @id = uid
    get_data
    if options.instance_of?(Hash) # Data un an un script
      # Ca définir notamment :current_pday et current_pday_start
      prefix = options.delete(:prefix) || ""
      options.each{ |k, v| instance_variable_set("@#{prefix}_#{k}", v) }
    end
  end

  def get_data
    @data = self.class.table_users.get(id)
    @data.each{|k, v| instance_variable_set("@#{k}", v)}
  end

  def preference key
    table_variables.get(where: "name = 'pref_#{key}'")
  end

  def table_variables
    @table_variables ||= site.dbm_table(:users_tables, "variables_#{id}")
  end
end
