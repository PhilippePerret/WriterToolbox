# encoding: UTF-8
=begin

  Instances SiteHtml::DBM_TABLE::Request
  --------------------------------
  Pour le traitement d'une requête dans la table choisie de
  la base choisie.

=end
class SiteHtml
class DBM_TABLE
class Request

  # Instance SiteHtml::DBM_TABLE de la table de la requête
  attr_reader :dbm_table

  # Paramètres définis pour la requête
  attr_reader :params
  # Options définis pour la requête (if any)
  attr_reader :options

  # Construit ici
  # -------------
  # La requête telle qu'elle sera envoyée. Ça peut être
  # une requête "simple" ou une requête "préparée"
  attr_reader :request

  # {Array} Liste des valeurs préparées
  attr_reader :prepared_values

  def initialize itable, params, options = nil
    @dbm_table  = itable
    @params     = params  || {}
    @options    = options || {}
  end

  # ---------------------------------------------------------------------
  #   REQUÊTES PRINCIPALES
  # ---------------------------------------------------------------------

  # INSERTION
  #
  # @USAGE    <table>.insert(<hash de valeurs>)
  #
  # @RETURN L'insertion retourne toujours l'ID de la rangée créée.
  def insert
    @request = request_insert
    resultat = exec
    return last_insert_id
  end

  # SELECT
  #
  # @USAGE <dbm_table>.select(where, options)
  #
  # @RETURN Un hash des éléments trouvés
  #
  def select
    @request = request_select
    resultat = exec
    return resultat
  end

  # ---------------------------------------------------------------------
  #   REQUÊTES STRING
  # ---------------------------------------------------------------------

  # Construction de la requête string pour INSERT
  def request_insert
    inserted_columns = params.keys.join(', ')
    @prepared_values = params.values
    inserted_values  = Array.new(params.count, '?').join(', ')
    <<-SQL
INSERT INTO #{dbm_table.name}
  (#{inserted_columns})
  VALUES ( #{inserted_values} )
    SQL
  end

  # Construction de la requête string pour SELECT
  def request_select
    <<-SQL
SELECT #{columns_clause} FROM #{dbm_table.name}
  #{where_clause}
  #{group_by_clause}
  #{order_by_clause}
  #{limit_clause}
  #{offset_clause}
    SQL
  end

  # ---------------------------------------------------------------------
  #   Méthodes de fabrication des clauses
  # ---------------------------------------------------------------------

  # La clause WHERE peut être définie de ces manières
  # suivantes :
  #     - String simple     p.e. 'id = 12'
  #     - String complexe   p.e.  'id = ?'
  #     - Hash              p.e. {id : 12}
  def where_clause
    where = params[:where]
    case where
    when NilClass then ''
    when String then 'WHERE ' + where
    when Hash then
      # Pour un Hash, on transforme en "key = :key" et on incrémente
      # les valeurs qui devront être bindées
      @prepared_values ||= []
      @prepared_values = where.values + @prepared_values
      'WHERE ' + where.collect { |k, v| "( #{k} = ? )" }.join(' AND ')
    else
      raise 'La clause WHERE doit être définie par un NIL, un String ou un Hash.'
    end
  end
  def columns_clause
    cols = params[:columns] || params[:colonnes]
    case cols
    when NilClass then '*'
    when Array    then (cols << :id).uniq.join(', ')
    when String   then cols
    else
      raise 'Le paramètre :colonnes doit être NIL, un Array ou un String.'
    end
  end

  def limit_clause
    if params.key?(:limit)
      "LIMIT #{params[:limit]}"
    else
      ''
    end
  end
  def group_by_clause
    if params.key?(:group) || params.key?(:group_by)
      "GROUP BY #{params[:group] || params[:group_by]}"
    else
      ''
    end
  end
  def order_by_clause
    if params.key?(:order) || params.key?(:order_by)
      "ORDER BY #{params[:order] || params[:order_by]}"
    else
      ''
    end
  end

  def offset_clause
    offset = params[:offset] || params[:from]
    case offset
    when NilClass then ''
    when Fixnum   then "OFFSET #{offset}"
    else
      raise 'La classe OFFSET doit être un nombre (Fixnum)'
    end
  end



  # / Fin de méthodes de fabrication des clauses
  # ---------------------------------------------------------------------


  # Retourne l'ID de la dernière ligne insérée
  #
  # Attention/Rappel : Si plusieurs lignes sont insérées en une
  # seule fois, seule l'ID de la PREMIÈRE ligne est retournée.
  def last_insert_id
    lii = nil
    dbm_table.client.query('SELECT LAST_INSERT_ID()').each do |row|
      lii = row.values.first
    end
    lii
  end

  # = main =
  #
  # Exécution de la requête.
  # RETURN Le résultat obtenu.
  #
  # Deux façons d'exécuter la requête : soit de façon directe
  # par `query`, soit en préparant la requête.
  # Ce qui détermine la manière, c'est la définition ou non de la
  # propriété @prepared_values.
  def exec
    resultat = begin
      if prepared_values
        prepared_statement.execute( *prepared_values )
      else
        dbm_table.client.query( final_request )
      end
    rescue Exception => e
      raise e
    end
    # Si on passe ici c'est que la requête a pu être exécutée.
    # Mais resultat est nil pour certaines requêtes
    unless resultat.nil?
      resultat = resultat.collect { |row| row.to_sym }
    end
    return resultat
  end

  def prepared_statement
    @prepared_statement ||= dbm_table.client.prepare(final_request)
  end

  def final_request
    @final_request ||= begin
      r = request.gsub(/\n/, ' ').gsub(/ +/, ' ').strip + ';'
      debug "Requête définitive : #{r}"
      debug "@prepared_values : #{@prepared_values.inspect}"
      r
    end
  end

end #/Request
end #/DBM_TABLE
end #/SiteHtml
