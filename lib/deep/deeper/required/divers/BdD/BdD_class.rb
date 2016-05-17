# encoding: UTF-8
=begin

Class BdD

=end
class BdD

  class << self

    # Arrêter et démarrer le débuggage des requêtes (leur
    # affichage dans le débug)
    # @usage BdD::debug_start / BdD::debug_stop
    attr_reader :debug_on
    def debug_start
      @debug_on = true
      debug "BdD DEBUG ON"
    end
    def debug_stop
      @debug_on = false
      debug "BdD DEBUG OFF"
    end

    # Traite le paramètre :colonnes ou :columns dans la
    # requête, en tenant compte du fait qu'il peut être
    # défini ou non.
    #
    # Note : Cette méthode tient compte du nouveau fonctionnement
    # avec la table des colonnes qui n'est plus enregistrées.
    #
    # Retourne :
    #   - soit une liste des noms de colonnes Symbol
    #   - soit une liste contenant simplement "*"
    # 
    def traite_colonnes_in params
      case ( colonnes = params[:colonnes] || params[:columns] )
      when NilClass
        # colonnes = column_names_of_table params[:db], params[:table]
        ['*']
      when String
        if colonnes == '*'
          ['*']
        else
          [colonnes.to_sym]
        end
      when Array
        colonnes.collect { |c| c.to_sym } # vraiment utile ?
      end
    end

    # OBSOLETE
    # # Retourne la liste des noms de colonnes de la table
    # # +table+ dans la database +db+
    # def column_names_of_table datab, table_name
    #   request = "SELECT columns FROM __column_names__ WHERE table_name = '#{table_name}'"
    #   res = datab.execute(request)
    #   return res.first.first.split(',') unless res.nil? || res.first.nil?
    #   mess = "[BdD::column_names_of_table] Impossible d'obtenir les noms de colonnes de la table `#{table_name}' (elle ne semble pas exister).\n" +
    #   "[BdD::column_names_of_table] full_column_names : #{datab.full_column_names.inspect}\n" +
    #   "[BdD::column_names_of_table] table_info(#{table_name}) : #{datab.table_info(table_name).inspect}\n" +
    #     "[BdD::column_names_of_table] Requête : #{request}\n" +
    #     "[BdD::column_names_of_table] Retour  : #{res.inspect}\n" +
    #     "[BdD::column_names_of_table] Error code: #{datab.errcode} / Error message: #{datab.errmsg.inspect}"
    #   # debug mess
    #   raise "Impossible d'obtenir les noms de colonnes de la table `#{table_name}'…\n#{mess}"
    # end

    # Reçoit la clause WHERE comme un {Hash} et retourne
    # un {String}
    def clause_where_from_hash where
      return where if where.class == String
      where.collect do |key, val|
        val = real_value_to_table_value val
        case val
        when String, Symbol then val = "\"#{val}\""
        end
        "#{key} = #{val}"
      end.join(' AND ')
    end


    ##
    # Reçoit des valeurs tirées des tables et renvoie les valeurs
    # réelles. Par exemple, reçoit "NULL" et retourne nil
    #
    # On peut envoyer dans foo :
    #   - Soit la valeur elle-même
    #   - Soit une liste de valeur (retourne une liste)
    #   - Soit un Hash de clé-valeur (retourne le hash)
    #
    def table_values_to_real_values foo, column_type = nil
      case foo
      when Array
        foo.collect { |el| table_values_to_real_values el }
      when Hash
        foo.each { |k, v| foo[k] = table_values_to_real_values v }
        foo
      when String
        ## Une vraie valeur
        case foo
        when "NULL" then nil
        else
          # On regarde si la chaine commence et finit par "[...]" ou "{...}"
          # et on la déjson si possible, sinon on retourne la chaine
          # elle-même.
          if foo[0] == ":"
            foo[1..-1].to_sym
          elsif foo.match(/^[\{\[](.*)[\}\]]$/)
            begin
              res = JSON::parse(foo, {symbolize_names: true})
              # Je dois passer par la ligne suivante car certaines valeurs
              # intérieures ne semblent pas être traitées correctement. Par
              # exemple, quand on a un Array de Hash, on peut se retrouver
              # ensuite avec un Array de String, String qu'il faut retransformer
              # en Hash. Cela est dû aux traitements superposés sans doute.
              table_values_to_real_values res
            rescue
              foo
            end
          else
            foo
          end
        end
      when Fixnum
        # Suivant le type de la colonne. Si BOOLEAN, le
        # 1 est remplacé par true et le 0 par false
        case column_type
        when 'BOOLEAN' then foo == 1
        else foo
        end
      when Float
        foo
      end
    end

    ##
    # Reçoit des valeurs "réelles" (p.e. `nil' ou un Array) et retourne
    # un {String} pouvant être enregistré dans une base de données SQLite
    # (p.e. `"NULL"').
    # Noter que les strings ne sont pas traités puisqu'ils le seront par
    # les méthodes propres.
    def real_value_to_table_value foo
      case foo
      when Array
        arr = foo.collect { |el| real_value_to_table_value el }
        JSON.dump(arr)
      when Hash
        new_hash = Hash::new
        foo.each { |k, v| new_hash.merge! k => real_value_to_table_value( v ) }
        JSON.dump(new_hash)
      when Symbol     then ":#{foo}"
      when NilClass   then 'NULL'
      when TrueClass  then "1"
      when FalseClass then "0"
      else
        foo
      end
    end


  end # << self

end
