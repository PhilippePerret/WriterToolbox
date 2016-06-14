# encoding: UTF-8
class BdD
  class << self


    ##
    # Exécution d'une requête sur une base de données quelconque
    # +params+ Cf. dans le manuel : “Arguments passés à `BdD::execute`”
    def execute params

      # La base de données
      db = params.delete(:database) || raise('Il faut indiquer la base de données à utiliser (path)')

      db.instance_of?(String) || raise('Il faut indiquer la base de données en String (path)')
      params[:db] = db = SQLite3::Database.new(db)

      # La table
      table = params[:table]      || raise('Il faut indiquer la table à utiliser.')
      table.instance_of?(String)  || raise('Il faut indiquer le NOM de la table à utiliser dans la base.')

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

      # Pour essayer de forcer une instance chaque fois
      # @database = nil

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

      # Par prudence, j'essaie ça
      debug "--> On envoie BEGIN TRANSACTION; END;" if @debug_on
      begin
        database.execute("BEGIN TRANSACTION; END;")
      rescue Exception => e
      end

      # Préparation de la requête
      begin
        debug "--> smt = database.prepare( request )" if @debug_on
        smt = database.prepare( request )
      rescue Exception => e
        (smt.close if smt) rescue nil
        (database.close if database) rescue nil
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
      debug "--> res = smt.execute" if @debug_on
      res = smt.execute

      if request_name == 'INSERT'
        last_insert_rowid = database.execute("SELECT last_insert_rowid();").first.first
      end

      # debug "REQUÊTE : '#{request_name}'::#{request_name.class}"
      # if request_name == "SELECT"
      #   debug "=== Retour de requête SELECT ==="
      #   debug "Request : #{request.inspect}"
      #   debug "Class retour : #{res.class}"
      #   debug "Colonnes retournées : #{res.columns.inspect}"
      #   debug "Types retournés : #{res.types.inspect}"
      #   debug "=== / SELECT ==="
      # end


      # Retour suivant l'opération
      retour =
      case request_name
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
        # debug "= RES ANALYSE ="
        res.each_hash do |hdata|
          hres = {}.merge(hdata) # pour le transformer en Hash simple

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
        hretour

      when "INSERT"
        # Après une insertion, on retourne le nouvel ID
        # attribué.
        last_insert_rowid
      end

      if retour.nil?
        retour = res.collect { |row| table_values_to_real_values row }
      end

      debug "--> smt.close" if @debug_on
      smt.close
      debug "--> database.close" if @debug_on
      database.close

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
      (database.close  if database) rescue nil
      (smt.close       if smt) rescue nil
      database = nil # pour essayer une instance neuve chaque fois
    end
    alias :execute_request :execute_requete


  end # << self
end # BdD
