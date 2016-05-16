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

  attr_reader :row

  attr_reader :options

  # +row+ Instance de la rangée
  def initialize row, options=nil
    @row      = row
    @options  = options || Hash::new
  end

  def execute
    online? ? execute_online : execute_offline
    return self
  end

  def execute_online

  end

  def execute_offline
    procedure_ruby.call
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
    Proc::new{
      begin
        db = SQLite3::Database.open( row.ttable.database.path.to_s )
        pst = db.prepare select_request
        @nombre_changements = db.changes
        rs = pst.execute
        @resultats = Array::new
        rs.each_hash do |h|
          @resultats << h.to_sym
        end
        unless plusieurs_resultats?
          nombre_resultats == 1 || error(ERROR[:more_than_one_result] % nombre_resultats)
        end
      rescue SQLite3::Exception => e
        raise e
      ensure
        pst.close if pst
        db.close  if db
      end
    }
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
          "(#{k} = #{v.inspect})"
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
