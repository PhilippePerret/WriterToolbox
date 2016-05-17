# encoding: UTF-8
class BdD
  class << self


    ##
    # Exécution d'une requête sur une base de données quelconque
    # +params+ Cf. dans le manuel : “Arguments passés à `BdD::execute`”
    def execute params

      # La base de données
      db = params.delete(:database) || raise( AIError, :bdd_execute_db_required)
      db = db.database if db.class == BdD
      db.class == ::SQLite3::Database || raise( AIError, :bdd_execute_required_db_sqlite3)
      params[:db] = db

      # La table
      table = params[:table]      || raise( AIError, :bdd_execute_table_required )
      table.instance_of?(String)  || raise( AIError, :bdd_execute_table_string )

      # Les colonnes
      # ------------
      colonnes = traite_colonnes_in params
      # =>
      #   - soit ['*']
      #   - soit La liste des noms de colonnes {Symbol}

      # L'opération (request)
      operation = params[:requete] || params[:request] || params[:operation] || params[:do]
      operation || raise( :bd_execute_request_required )
      [String, Symbol].include?(operation.class) || raise( :bd_execute_request_str_or_sym )
      operation = operation.to_s.upcase

      # La requête SELECT nécessite toujours la relève de la colonne :ID pour
      # la constitution du hash
      colonnes << :id if operation == "SELECT" && !colonnes.include?('*') && !colonnes.include?(:id)
      # pour `execute_requete'
      params.merge!( colonnes: colonnes )


      # Les valeurs
      values = params[:values]
      if ["INSERT", "UPDATE"].include?(operation) # || params[:where] != nil
        raise AIError, :bd_execute_required_values if values.nil?
        case operation
        when "INSERT"
          values_sql = case values
          when Array
            Array::new( values.count, '?' ).join(', ')
          when Hash
            values.collect{ |col, val| ":#{col}" }.join(', ')
          else
            "?"
          end
        when "UPDATE"
          colonnes_and_values_sql = case values
          when Array
            if colonnes.include?('*')
              raise(AIError, :bd_execute_require_explicite_colonne_with_arr_values)
            else
              colonnes.collect { |col| "#{col} = ?"}.join(', ')
            end
          when Hash
            values.collect { |col, val| "#{col} = :#{col}"}.join(', ')
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
      values ||= []

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
      params ||= {}

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
        smt = database.prepare( request )
      rescue Exception => e
        debug "# Une erreur est survenue avec database.prepare : #{e.message}"
        debug "# Requête : #{request}"
        debug "# Values : #{values.inspect}" unless values.nil? || values.empty?
        debug "# Params : #{params.inspect}" unless params.nil? || params.empty?
        raise e.message
      end


      # Si nécessaire, binder des valeurs à la préparation de la
      # requête.
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

      debug "REQUÊTE : '#{request_name}'::#{request_name.class}"
      if request_name == "SELECT"
        debug "=== Retour de requête SELECT ==="
        debug "Request : #{request.inspect}"
        debug "Class retour : #{res.class}"
        debug "Colonnes retournées : #{res.columns.inspect}"
        debug "Types retournés : #{res.types.inspect}"
        debug "=== / SELECT ==="
      end


      # Retour suivant l'opération
      retour = case request_name
      when "SELECT"
        # On fait un hash de colonne => type pour pouvoir
        # transformer les valeurs en leur type réel.
        # Noter qu'ici le type ne peut pas être grand chose,
        # simplement un string, un nombre ou du code brut,
        # guère plus que ce genre de choses.
        col2type = Hash[res.columns.zip res.types]

        # On recupère la liste des colonnes, qu'on transforme
        # en Symbols (est-ce vraiment indispensable ? Est-ce qu'on
        # ne pourrait pas le faire plus tard ?)
        res_colonnes = res.columns.collect{|c| c.to_sym}

        # La clé de clé principale.
        # C'est la clé qui sera utilisée comme clé principale
        # dans le Hash retourné.
        # En général, c'est :id, donc c'est l'identifiant de
        # la rangée qui sera utilisé comme clé du Hash de
        # retour.
        main_key = (params[:key] || :id).to_sym

        # Le Hash qui contiendra toutes les données retournées
        hretour = {}

        res.each_hash do |hdata|
          hres = {}.merge(hdata) # pour le transformer en Hash simple
          debug "HRES = #{hres.pretty_inspect}"

          # Il faut transformer les valeurs en leur valeur réelle
          real_hres = {}
          hres.each do |k, v|
            real_value = table_values_to_real_values(v, col2type[k.to_s])
            real_hres.merge!( k.to_sym => real_value )
          end

          # On ajoute ce Hash de données au Hash qui doit être
          # retourné
          hretour.merge!( real_hres[main_key] => real_hres )

        end

        debug "\n\n\nHRETOUR:#{hretour.pretty_inspect}\n\n\n"

        # ANCIENNE MÉTHODE OBSOLÈTE :
        # if params[:colonnes] != nil
        #   unless params[:colonnes].first.class == Symbol
        #     params[:colonnes] = params[:colonnes].collect { |k| k.to_sym }
        #   end
        #   main_key = (params[:key] || :id).to_sym
        #   hretour = Hash::new
        #   res.each do |values_returned|
        #     hres = Hash[params[:colonnes].zip(values_returned)]
        #     hres.each do |k, v|
        #       v = table_values_to_real_values v, col2type[k.to_s]
        #       hres[k] = v
        #     end
        #     hretour.merge! hres[main_key] => hres
        #   end
        hretour
      when "INSERT"
        # Après une insertion, on retourne le nouvel ID
        # attribué.
        database.execute("SELECT last_insert_rowid();").first.first
      end

      if retour.nil?
        retour = res.collect { |row| table_values_to_real_values row }
      end

    rescue Exception => e
      debug "# IMPOSSIBLE DE JOUER execute_requete : #{e.message}"
      debug "# Requête : #{request}"
      debug "# Values : #{values.inspect}" unless values.nil? || values.empty?
      debug "# Params : #{params.inspect}" unless params.nil? || params.empty?
      debug "Backtrace :\n" + e.backtrace.join("\n")
      debug e
      raise e.message
    else
      return retour
    ensure
      # database.close  if database
      smt.close       if smt
    end
    alias :execute_request :execute_requete


  end # << self
end # BdD
