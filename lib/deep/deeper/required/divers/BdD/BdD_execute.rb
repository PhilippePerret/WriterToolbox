# encoding: UTF-8
class BdD
  class << self


    ##
    # Exécution d'une requête sur une base de données quelconque
    # +params+ Cf. dans le manuel : “Arguments passés à `BdD::execute`”
    def execute params

      # La base de données
      db = params.delete :database
      raise AIError, :bdd_execute_db_required if db.nil?
      db = db.database if db.class == BdD
      raise AIError, :bdd_execute_required_db_sqlite3 unless db.class == ::SQLite3::Database
      params[:db] = db

      # La table
      table = params[:table]
      raise AIError, :bdd_execute_table_required if table.nil?
      raise AIError, :bdd_execute_table_string unless table.class == String

      # Les colonnes
      colonnes = traite_colonnes_in params

      # L'opération (request)
      operation = params[:requete] || params[:request] || params[:operation] || params[:do]
      raise :bd_execute_request_required    if operation.nil?
      raise :bd_execute_request_str_or_sym  unless [String, Symbol].include?(operation.class)
      operation = operation.to_s.upcase

      # La requête SELECT nécessite toujours la relève de la colonne :ID pour
      # la constitution du hash
      colonnes << :id if operation == "SELECT" && false == colonnes.include?(:id)
      # pour `execute_requete'
      params.merge! colonnes: colonnes


      # Les valeurs
      values = params[:values]
      if ["INSERT", "UPDATE"].include?(operation) # || params[:where] != nil
        raise AIError, :bd_execute_required_values if values.nil?
        case operation
        when "INSERT"
          values_sql = case values
          when Array
            Array::new( colonnes.count, '?' ).join(', ')
          when Hash
            colonnes.collect{ |col| ":#{col}" }.join(', ')
          else
            "?"
          end
        when "UPDATE"
          colonnes_and_values_sql = case values
          when Array
            colonnes.collect { |col| "#{col} = ?"}.join(', ')
          when Hash
            colonnes.collect { |col| "#{col} = :#{col}"}.join(', ')
          end
        end
      end

      # Transformation des colonnes et valeurs en SQL-String
      colonnes_sql = colonnes.join(', ')

      template_sql = case operation
      when "INSERT" then "INSERT INTO #{table} (#{colonnes_sql}) VALUES (%{values_sql})"
      when "UPDATE" then "UPDATE #{table} SET #{colonnes_and_values_sql}"
      when "SELECT" then "SELECT #{colonnes_sql} FROM #{table}"
      when "DELETE" then "DELETE FROM #{table}"
      else
        raise "La méthode de requête #{operation} est inconnue…"
      end

      # Liste valeurs
      values = Array::new if values.nil?

      # Clause WHERE
      where = params[:where]
      unless where.nil?
        where = clause_where_from_hash where if where.class == Hash
        template_sql << " WHERE #{where}"
        template_sql << " COLLATE NOCASE" if params[:nocase]
        values << params[:where_value]  unless params[:where_value].nil?
        values += params[:where_values] unless params[:where_values].nil?
      end
      values = nil if values.empty?

      # Clause ORDER BY
      order_by = params[:order_by] || params[:order]
      unless order_by.nil?
        order_by = order_by.join(', ') if order_by.class == Array
        template_sql << " ORDER BY #{order_by}"
        if params[:reverse] != nil && params[:reverse] === true
          template_sql << " DESC"
        end
      end

      # Clause LIMIT
      unless params[:limit].nil?
        template_sql << " LIMIT #{params[:limit]}"
      end

      # Clause OFFSET
      unless params[:offset].nil?
        template_sql << " OFFSET #{params[:offset]}"
      end

      # Retourne le résultat
      execute_requete db, template_sql, values, params

    rescue Exception => e
      raise e
    end


    ##
    # Exécute la requête {String} +request+ avec les valeurs
    # {Hash} +values+ sur la table {SQLite3::Database} +database+
    # @alias: def execute_request
    def execute_requete database, request, values = nil, params = nil
      params ||= Hash::new

      request_name = request.split.first

      # @debug_on = true
      if @debug_on
        debug "\n\n---BdD::execute_requete---"
        debug "[BdD::execute_requete]"
        debug "REQUEST: #{request}"
        debug "VALUES: #{values.inspect}"
        debug "PARAMS: #{params.inspect}"
        debug "[/BdD::execute_requete]"
        debug "-"*50 + "\n\n"
      end
      # @debug_on = false

      # Préparation de la requête
      begin
        smt = database.prepare request
      rescue Exception => e
        debug "# Une erreur est survenue avec database.prepare : #{e.message}"
        debug "# Requête : #{request}"
        debug "# Values : #{values.inspect}" unless values.nil? || values.empty?
        debug "# Params : #{params.inspect}" unless params.nil? || params.empty?
        raise e.message
      end


      # Binder des valeurs (if any)
      if values
        if ["INSERT", "UPDATE"].include? request_name
          case values
          when Array
            values = values.collect { |val| real_value_to_table_value val }
          when Hash
            hprov = values.dup
            values = Hash.new
            hprov.each { |k, v| values.merge! k => real_value_to_table_value( v ) }
          else
            values = real_value_to_table_value values
          end
        end

        case values
        when Array
          (1..values.count).each { |index| smt.bind_param index, values[index - 1] }
        when Hash
          values.each do |col, value|
            # debug "#{col}: #{value.inspect}::#{value.class}"
            smt.bind_param col.to_sym, value
          end
        else
          smt.bind_param 1, values
        end
      end

      # Exécution (BON)
      res = smt.execute

      # debug "REQUÊTE : '#{request_name}'::#{request_name.class}"
      # if request_name == "SELECT"
      #   debug "=== requête SELECT ==="
      #   debug res
      #   debug "Colonnes: #{res.columns.inspect}"
      #   debug "Types: #{res.types.inspect}"
      #   debug "=== / SELECT ==="
      # end
      #

      # Retour suivant l'opération
      retour = case request_name
      when "SELECT"
        # On fait un hash de colonne => type
        col2type = Hash[res.columns.zip res.types]
        if params[:colonnes] != nil
          unless params[:colonnes].first.class == Symbol
            params[:colonnes] = params[:colonnes].collect { |k| k.to_sym }
          end
          main_key = (params[:key] || :id).to_sym
          hretour = Hash::new
          res.each do |values_returned|
            hres = Hash[params[:colonnes].zip(values_returned)]
            hres.each do |k, v|
              v = table_values_to_real_values v, col2type[k.to_s]
              hres[k] = v
            end
            hretour.merge! hres[main_key] => hres
          end
          hretour
        end
      when "INSERT"
        # Après une insertion, on retourne le nouvel ID
        # attribué.
        database.execute("SELECT last_insert_rowid();").first.first
      end

      if retour.nil?
        retour = res.collect { |row| table_values_to_real_values row }
      end

      smt.close

      return retour
    rescue Exception => e
      debug "# IMPOSSIBLE DE JOUER execute_requete : #{e.message}"
      debug "# Requête : #{request}"
      debug "# Values : #{values.inspect}" unless values.nil? || values.empty?
      debug "# Params : #{params.inspect}" unless params.nil? || params.empty?
      debug "Backtrace :\n" + e.backtrace.join("\n")
      debug e
      raise e.message
    end
    alias :execute_request :execute_requete


  end # << self
end # BdD
