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
    @params     = params
    @options    = options
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
    debug "@request : #{@request}"
    debug "@prepared_values : #{@prepared_values.inspect}"
    resultat = exec
    return last_insert_id
  end

  # ---------------------------------------------------------------------
  #   REQUÊTES STRING
  # ---------------------------------------------------------------------
  def request_insert
    inserted_columns = params.keys.join(', ')
    @prepared_values = params.values
    inserted_values  = Array.new(params.count, '?').join(', ')
    @request_insert ||= <<-SQL
INSERT INTO #{dbm_table.name}
  (#{inserted_columns})
  VALUES ( #{inserted_values} )
  ;
    SQL
  end

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
        dbm_table.client.query( request )
      end
    rescue Exception => e
      raise e
    end
    # Si on passe ici c'est que la requête a pu être exécutée.
    # Mais resultat est nil pour certaines requêtes
    resultat.to_sym unless resultat.nil?
    return resultat
  end

  def prepared_statement
    @prepared_statement ||= dbm_table.client.prepare(request)
  end

end #/Request
end #/DBM_TABLE
end #/SiteHtml
