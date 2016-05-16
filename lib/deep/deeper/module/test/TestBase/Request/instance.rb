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

  attr_reader :row

  attr_reader :options

  # +row+ Instance de la rangée
  def initialize row, options=nil
    @row      = row
    @options  = options || Hash::new
  end

  def execute
    online? ? execute_online : execute_offline
    @resultats = @resultats.collect { |h| h.to_sym }
    return self
  end

  def execute_online
    # debug "REQUETE SSH : #{request_ssh.inspect}"
    res = `#{request_ssh} 2>&1`
    # debug "res : #{res.inspect}"
    res = Marshal.load(res)
    debug "res démarshalisé : #{res.inspect}"
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
#{procedure_ruby_str}
result = {
  database:             @dbpath,
  erreur_sql:           @erreur_sql,
  erreur_fatale:        @erreur_fatale,
  request_sql:          @request_sql,
  resultats:            @resultats,
  nombre_changements:   @nombre_changements
}
STDOUT.write(Marshal.dump(result))
SSH
  end

  def execute_offline
    procedure_ruby
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

  def procedure_ruby
    eval(procedure_ruby_str)
    @erreur_fatale && raise( @erreur_fatale )
    unless plusieurs_resultats?
      nombre_resultats == 1 || error(ERROR[:more_than_one_result] % nombre_resultats)
    end
  end

  def procedure_ruby_str
    racine = online? ? '/home/boite-a-outils/www' : ''
    dbpath = "#{racine}#{row.ttable.database.path.to_s[1..-1]}"
    # dbpath = row.ttable.database.path.to_s
    debug "= dbpath: #{dbpath}"
    <<-PROC
$: << '/home/boite-a-outils/.gems/gems/sqlite3-1.3.10/lib'
begin
  require 'sqlite3'
  @erreur_fatale      = nil
  @resultats          = nil
  @nombre_changements = nil
  @db   = nil
  @pst  = nil
  @dbpath = %Q{#{dbpath}}
  File.exist?(@dbpath) || (raise %Q{La base de données \#{@dbpath} est introuvable} )
  @request_sql = %Q{#{select_request_one_line}}
  @db   = SQLite3::Database.open( @dbpath )
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
  # rangée à travailler
  def specs   ; @specs ||= row.specs  end

  # Construction des requêtes
  #
  def select_request_one_line
    @select_request_one_line ||= select_request.gsub(/\n/, " ").gsub(/\t/,' ').gsub(/( +)/, ' ')
  end
  def select_request
    @select_request ||= begin
      options ||= Hash::new
      what  = options[:what] || "*"
      order = options[:order]
      order = " ORDER #{order}" unless order.nil?
      limit = options[:limit]
      limit = " LIMIT #{limit}" unless limit.nil?
      <<-SQL
SELECT #{what}
  FROM #{row.ttable.name}
  WHERE #{where_clause}#{order}#{limit};
      SQL
    end
  end

  # Construction de la clause WHERE en fonction des
  # spécifications de la requête
  def where_clause
    @where_clause ||= begin
      case specs
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
