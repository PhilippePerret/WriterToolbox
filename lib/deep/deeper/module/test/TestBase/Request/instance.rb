# encoding: UTF-8
=begin

  class SiteHtml::TestSuite::TestBase::Request
  --------------------------------------------
  Gestion des requêtes de bases de données

=end
class SiteHtml
class TestSuite
class TestBase
class Request

  ERROR = {
    more_than_one_result: "Il ne devrait y avoir qu'un résultat dans la table, mais %i ont été trouvés…"
  }

  # Nil ou définit à l'instanciation
  attr_reader :row

  attr_reader :options

  # +row_or_table+ Instance de la rangée ou de la table
  def initialize row_or_table, options=nil
    if row_or_table.instance_of?(SiteHtml::TestSuite::TestBase::TestTable)
      @ttable = row_or_table
    else
      @row = row
    end
    @options = options || {}
  end

  # ---------------------------------------------------------------------
  #   Requêtes qu'on peut envoyer à la méthode `execute` de cette
  #   instance requête
  # ---------------------------------------------------------------------
  # Construction des requêtes
  #
  def select_request
    @select_request ||= select_request_multi_lines.gsub(/\n/, " ").gsub(/\t/,' ').gsub(/( +)/, ' ')
  end
  def count_request
    @count_request ||= count_request_multi_lines.gsub(/\n/, " ").gsub(/\t/,' ').gsub(/( +)/, ' ')
  end

  #
  # ---------------------------------------------------------------------

  # Exécution de la requête, online ou offline
  #
  # Par défaut, +sql_request+ est la requête de SELECT
  #
  def execute( sql_request = nil )
    sql_request ||= select_request
    send(online? ? :execute_online : :execute_offline, sql_request)
    @resultats = @resultats.collect { |h| h.to_sym }
    return self
  end

  def execute_online sql_request
    # debug "REQUETE SSH : #{request_ssh.inspect}"
    res = `#{request_ssh} 2>&1`
    # debug "res : #{res.inspect}"
    res = Marshal.load(res)
    # debug "res démarshalisé : #{res.inspect}"
    @resultats = []
    if res[:erreur_sql]
      error res[:erreur_sql]
    elsif res[:fatale_erreur]
      error "# ERREUR FATALE #{res[:fatale_erreur]}"
    else
      @resultats = res[:resultats]
    end
  end
  def request_ssh
    "ssh #{site.serveur_ssh} \"ruby -e \\\"#{request_ruby_in_ssh}\\\"\""
  end
  def request_ruby_in_ssh
    <<-SSH
#{procedure_ruby_str sql_request}
result = {
  database:             @db_path,
  erreur_sql:           @erreur_sql,
  erreur_fatale:        @erreur_fatale,
  request_sql:          @request_sql,
  resultats:            @resultats,
  nombre_changements:   @nombre_changements
}
STDOUT.write(Marshal.dump(result))
SSH
  end

  def execute_offline sql_request
    procedure_ruby sql_request
  end

  def resultats
    @resultats || execute
    @resultats
  end
  def first_resultat
    @first_resultat ||= resultats.first
  end

  # Nombre de changements produits dans la table après
  # l'exécution de la requête
  def nombre_changements
    @nombre_changements || execute
    @nombre_changements
  end

  def procedure_ruby sql_request
    eval(procedure_ruby_str sql_request)
    @erreur_fatale && raise( @erreur_fatale )
    unless plusieurs_resultats?
      nombre_resultats == 1 || error(ERROR[:more_than_one_result] % nombre_resultats)
    end
  end

  # La Test-Table courante, qu'on prend soit dans la
  # rangée transmise à l'instanciation (`row`) soit dans la
  # table transmise à l'instanciation
  def ttable
    @ttable ||= row.ttable
  end
  def racine
    @racine ||= (online? ? '/home/boite-a-outils/www' : '.')
  end
  def db_path
    @db_path || "#{racine}#{ttable.database.path.to_s[1..-1]}"
  end

  def procedure_ruby_str sql_request
    <<-PROC
$: << '/home/boite-a-outils/.gems/gems/sqlite3-1.3.10/lib'
begin
  require 'sqlite3'
  @erreur_fatale      = nil
  @resultats          = nil
  @nombre_changements = nil
  @db   = nil
  @pst  = nil
  @db_path = %Q{#{db_path}}
  File.exist?(@db_path) || (raise %Q{La base de données \#{@db_path} est introuvable} )
  @request_sql = %Q{#{sql_request}}
  @db   = SQLite3::Database.open( @db_path )
  @pst  = @db.prepare( @request_sql )
  rs    = @pst.execute
  @nombre_changements = @db.changes
  @resultats = Array::new
  rs.each_hash { |h| @resultats << h }
rescue SQLite3::Exception => e
  @erreur_sql = e
rescue Exception => e
  @erreur_fatale = e
ensure
  @pst.close if @pst
  @db.close  if @db
end
PROC
  end

  def plusieurs_resultats?
    @plusieurs_resultats === nil && ( @plusieurs_resultats = options[:several] )
    @plusieurs_resultats
  end

  def nombre_resultats
    @nombre_resultats ||= resultats.count
  end

  # Raccourci pour avoir les spécifications de la
  # rangée à travailler, si une rangée est définie
  def specs
    @specs ||= begin
      row.nil? ? nil : row.specs
    end
  end

  def select_request_multi_lines
    @select_request_multi_lines ||= begin
      options ||= Hash::new
      what  = options[:what] || "*"
      order = options[:order]
      order = " ORDER #{order}" unless order.nil?
      limit = options[:limit]
      limit = " LIMIT #{limit}" unless limit.nil?
      <<-SQL
SELECT #{what}
FROM #{ttable.name}
#{where_clause_finale}#{order}#{limit};
      SQL
    end
  end

  # Requête pour compte un nombre de choses
  def count_request_multi_lines
    @count_request_multi_lines ||= begin
      where_clause_final = where_clause
      <<-SQL
SELECT COUNT(*)
FROM #{ttable.name}
#{where_clause_finale}
      SQL
    end
  end

  def where_clause_finale
    @where_clause_finale ||= begin
      if where_clause.nil?
        ""
      else
        "WHERE #{where_clause}"
      end
    end
  end
  # Construction de la clause WHERE en fonction des
  # spécifications de la requête
  def where_clause
    @where_clause ||= begin
      case specs
      when NilClass
        nil
      when Fixnum
        "id = #{specs}"
      else
        specs.collect do |k,v|
          v = case v
          when String then "%Q{#{v}}"
          when Array, Hash then v.inspect # STRING => PROBLÈME
          else v
          end
          "( #{k} = #{v} )"
        end.join(' AND ')
      end
    end
  end

  def online?
    @is_online ||= SiteHtml::TestSuite::online?
  end

end #/Request
end #/TestBase
end #/TestSuite
end #/SiteHtml
