# encoding: UTF-8
=begin
Class BdD::Table
----------------
Gestion d'une table dans une base de données
=end

class BdD
  class Table

    MARK_GUILLEMETS_DOUBLE = "__DBLGUIL__"


    # {BdD} Instance BdD à laquelle appartient la table
    attr_reader :bdd

    # {String} Nom de la table
    attr_reader :name

    # {Array of Error} Liste des erreurs rencontrées
    # Ou NIL si aucune erreur.
    attr_reader :errors

    # {Array de String} Nom des colonnes de la table
    # Utiliser la méthode `define' sur la table pour les
    # définir. Ou si la table existe on les cherche
    # dans la base
    def colonnes_definition
      @colonnes_definition ||= begin
        bdd.column_names_of_table name if exist?
      end
    end
    alias :columns :colonnes_definition
    alias :column_names :colonnes_definition

    ##
    # Instanciation d'une table
    #
    # +bdd+ {BdD} Instance BdD de la base de données
    # +table_name+ {String} Nom de la table dans la base de données
    def initialize bdd, table_name
      @bdd  = bdd
      @name = table_name
      check_instance_data_or_raise
    end

    # ---------------------------------------------------------------------
    #   Méthodes SQL sur la table
    # ---------------------------------------------------------------------

    ##
    # Insertion de données
    #
    # Retourne le nouvel ID (ou NIL si l'enregistrement a échoué) si une
    # seule donnée a été fournie (Hash en argument) ou une liste des
    # nouveaux identifiants si plusieurs données ont été fournies.
    #
    def insert arr_data
      # debug "-> BdD::Table#insert"
      unique_data = arr_data.class == Hash
      arr_data = [arr_data] if unique_data

      raise ArgumentError, "#insert attend un Hash ou un Array" unless arr_data.class == Array

      # Construction de la requête "modèle"
      hdata = arr_data.first
      values_str = hdata.keys.collect { |k| ":#{k}"}.join(', ')
      request = "INSERT INTO #{name} (#{hdata.keys.join(', ')}) VALUES (#{values_str})"

      # Boucle sur toutes les données envoyées
      new_ids = arr_data.collect do |hdata|
        new_id = BdD::execute_request bdd.database, request, hdata
        # En cas d'erreur, on s'arrête tout de suite
        return nil if new_id === false
        new_id # pour collect
      end
      if unique_data
        new_ids.first
      else
        new_ids
      end
    end
    alias :<< :insert

    ##
    # Actualisation de données
    # La recherche se fait toujours sur l'identifiant
    # Noter que l'ID est le plus souvent un Fixnum mais que ça n'est
    # pas toujours le cas.
    def update id, hdata
      # debug "-> update"
      raise ArgumentError, "Le second argument doit être un Hash (des nouvelles valeurs)" unless hdata.class == Hash
      raise ArgumentError, "La donnée #{id} n'existe pas dans la table" if count(where: "id = #{id.inspect}") == 0
      return BdD::execute(
        database:   bdd.database,
        table:      self.name,
        request:    'UPDATE',
        colonnes:   hdata.keys,
        values:     hdata.values,
        where:      "id = #{id.inspect}"
      )
    end

    # Tranformation de la clause WHERE en clause where string
    # pour la requeste
    def clause_where_conforme where
      BdD::clause_where_from_hash where
    end

    ##
    # Actualisation ou création des données
    def set id, hdata = nil
      if id.class == Hash && id.has_key?(:where)
        # Définition de la rangée par une clause WHERE
        hdata         = id.dup
        where         = hdata.delete(:where)
        # Cf. la note N0001 dans le manuel
        raise BdDError, :where_clause_hash_required unless where.class == Hash
        clause_where  = clause_where_conforme where
        is_a_creation = false == has_row_with?( clause_where )
        id    = nil
        hdata = hdata[:values]
        if is_a_creation
          hdata.merge! where
        else
          id = select(colonnes:[:id], where: clause_where ).values.first[:id]
        end
      elsif id.class == Hash && id.has_key?(:values)
        hdata = id.dup
        id = hdata.delete :id
        if id != nil
          is_a_creation = false == has_row_with?("id = #{id}")
        elsif hdata.has_key? :where
          # Définition par une clause WHERE
          clause_where = clause_where_conforme hdata[:where]
          is_a_creation = false == has_row_with?( clause_where )
          if is_a_creation
            # Cf. la note N0001 dans le manuel
            raise BdDError, :where_clause_hash_required unless hdata[:where].class == Hash
            hdata = hdata[:values].merge( hdata[:where] )
          else
            id    = select(colonnes:[:id], where: clause_where ).values.first[:id]
            hdata = hdata[:values]
          end
        else
          raise BdDError, :bad_args_with_values_form
        end
      else

        # => Autre forme d'arguments

        ## Check de la validité des données
        is_a_creation = nil
        case id
        when Fixnum
          raise BdDError, :bad_set_second_arg if hdata.class != Hash
        when Hash
          hdata = id.dup
          if hdata.has_key? :id
            id = hdata.delete(:id)
          else
            # Quand c'est { <id> => {<data>} } qui est envoyé en argument
            id    = hdata.keys.first
            hdata = hdata.values.first
          end
          raise BdDError, :set_bad_data_for_data unless hdata.class == Hash
        end

        case id
        when Fixnum
          # OK
        when NilClass
          is_a_creation = true
          hdata.delete(:id)
        else
          raise BdDError, :set_bad_id_data
          raise BdDError, :bad_set_first_arg
        end

        if is_a_creation.nil?
          ## Est-ce que la donnée existe ? Si elle n'existe pas
          ## c'est une création de rangée (insert)
          is_a_creation = false == has_row_with?("id = #{id}")
          hdata.merge!(id: id) unless is_a_creation
        end

      end


      # debug "[set] Après traitement id/hdata"
      # debug "ID     #{id.class.to_s.ljust(8)} #{id.inspect}"
      # debug "HDATA  #{hdata.class.to_s.ljust(8)} #{hdata.inspect}"
      # debug "is_a_creation   #{is_a_creation.inspect}"
      # debug "[/set]"

      if is_a_creation
        # debug "=> Création de #{hdata.inspect}"
        res = insert hdata
        # debug "Résultat de création (res) : #{res.inspect}"
        # res_select = execute "SELECT * FROM #{name}"
        # debug "select renvoie : #{res_select.inspect}"
        return res # le nouvel ID
      else
        # => modification
        update id, hdata
      end
    rescue BdDError => e
      raise ArgumentError, BdD::ERRORS[e.message.to_sym]
    rescue Exception => e
      error e
    end

    ##
    # Récupération de données
    #
    # hdata peut être un {Fixnum} ID de la donnée ou un {Hash} définissant
    # les critères de recherche.
    # S'il n'est pas fourni, ou qu'il ne définit pas :colonnes, on retourne
    # toutes les données (colonnes) des rangées trouvées.
    def select hdata = nil
      hdata ||= {}
      hdata = {where: "ID = #{hdata}"} if hdata.class == Fixnum
      hdata.merge!(colonnes: '*') unless hdata.has_key?(:colonnes)

      # debug "bdd.column_names_of_table('documents') : #{bdd.column_names_of_table('documents').inspect}"

      hdata.merge!( colonnes: hdata.delete(:keys) ) if hdata.has_key?(:keys)

      # Finalisation du Hash de données à envoyer à BdD::execute
      hdata.merge!(
        database: bdd.database,
        table:    name,
        request:  "select"
      )

      # debug "Hdata envoyé à BdD::execute"
      # debug hdata

      BdD::execute hdata
    end
    alias :>> :select

    ##
    # Récupération d'une donnée par :id ou par clause WHERE
    def get id_arg, colonnes = nil
      colonnes = case colonnes
      when String
        if colonnes == '*'
          ['*']
        else
          colonnes.to_sym
        end
      when Array, Symbol
        colonnes
      when NilClass
        nil
      else
      end

      unique_key = colonnes != nil && colonnes.class == Symbol

      hdata = case id_arg
      when Fixnum
        {where:  "id = ?", values: [ id_arg ] }
      when String
        { where: id_arg }
      when Hash
        id_arg.has_key?(:where) ? id_arg : { where: id_arg }
      when NilClass
        raise AIError, :bdd_first_argument_get_nil
      else
        raise AIError, :bdd_bad_first_argument_for_get
      end
      hdata.merge!(colonnes: colonnes) unless colonnes.nil?
      retour = select(hdata).values
      return nil if retour.first.nil?
      retour = retour.first
      unique_key ? retour[colonnes] : retour
    end

    def condition_deprecated hfoo
      return unless hfoo.has_key? :condition
      error "Il faut supprimer l'utilisation de :condition au profit de :where."
      hfoo.merge where: hfoo.delete(:condition)
    end

    ##
    # Destruction de données
    # +foo+ Soit un {Fixnum} ID de donnée (la donnée à détruire)
    # soit un {Hash} définissant :where => {String}, la condition
    # à ajouter à WHERE dans la requête.
    # Soit NIL pour détruire toutes les données. Mais dans ce cas,
    # il faut impérativement que +confirmation+ soit true (Pour
    # éviter les erreurs)
    # @note: On met un hash pour développements ultérieurs
    def delete foo = nil, confirmation = nil
      raise "La destruction intégrale des données nécessite une confirmation." if foo.nil? && confirmation != true
      request = "DELETE FROM #{name}"
      request += case foo
      when NilClass
        ""
      when Hash # Avec condition
        foo = condition_deprecated foo if foo.has_key? :condition
        raise ArgumentError, BdD::ERRORS[:delete_invalid_hash] if foo[:where].nil?
        " WHERE #{clause_where_conforme foo[:where]}" +
        (foo[:nocase] ? " COLLATE NOCASE" : "")
      when Fixnum # Par ID
        " WHERE id = #{foo}"
      else
        raise ArgumentError, BdD::ERRORS[:delete_require_hash_or_id]
      end
      # Exécution de la requête sur la database
      execute request
    end

    # Supprime tous les enregistrements
    def pour_away
      execute("DELETE FROM #{name}")
    end

    # Effacement de l'intégralité des données
    def remove_all
      delete nil, true
    end

    ##
    # Retourne le nombre de rangées avec ou sans condition
    #
    def count params = nil
      params ||= {}
      params.has_key?(:condition) && params = condition_deprecated( params )

      # Construction de la requête COUNT
      request = "SELECT COUNT(*) FROM #{name}"
      if params.has_key?(:where)
        request += " WHERE #{clause_where_conforme params[:where]}"
        request += " COLLATE NOCASE" if params[:nocase]
      end

      # Soumission de la requête
      res = bdd.database.execute(request).first

      if res == false
        # Deux solutions lorsque le résultat est false :
        # - soit il y a une erreur dans le code sql
        # - soit la table n'existe pas (encore)
        # Dans les deux cas, on débuggue le problème et
        # on retourne 0
        debug "# BdD::Table#count problème : res est false"
        debug "# request: #{request}"
        return 0
      else
        return res.first
      end

    end

    ##
    # Création de la table
    # --------------------
    # Pour pouvoir être créée, la table a besoin de définition des
    # colonnes.
    #
    # Note : Maintenant, on n'enregistre plus les noms des
    # colonnes dans une table, puisqu'on peut facilement les
    # récupérer par les méthodes Ruby du gem 'sqlite3'
    #
    def create
      # debug "-> create"
      return false if exist?
      check_definition_colonnes_or_raise
      # mem_column_names( forcer = false ) # au cas où
      res = execute creation_code, true
      # debug "<- create"
      return res
    end

    # ---------------------------------------------------------------------
    #   Méthodes fonctionnelles
    # ---------------------------------------------------------------------

    ##
    # Définit les colonnes de la table
    # Doit être appelé après l'instanciation, et avant la création,
    # pour définir les colonnes de la table.
    # @note: Définit aussi les colonnes (NOMS) dans la table système
    # _columns_names_
    def define hdata
      unless (hdata.has_key? :id) || (hdata.has_key? 'id')
        hdata.merge! :id => { type: "INTEGER", constraint: "PRIMARY KEY AUTOINCREMENT" }
      end
      @colonnes_definition = hdata
      # mem_column_names( forcer = true )
    end

    # # Pour mémoriser (à la création) le nom des colonnes
    # def mem_column_names forcer = false
    #   # debug "-> mem_column_names"
    #   return if bdd.table_column_names.has_row_with?("table_name = '#{self.name}'") && forcer == false
    #   # debug "Je dois créer la rangée des noms de colonnes"
    #   col_names = @colonnes_definition.keys.collect{|c| c.to_s}
    #   bdd.add_column_names_of_table self.name, col_names
    #   # debug "<- mem_column_names"
    # end

    ##
    # Return TRUE si la table existe
    def exist?
      ::BdD::Table::table_exist? bdd, name
    end

    ##
    # Retourne TRUE si la table possède des rangées
    # remplissant la condition +where+
    def has_row_with? where
      raise ArgumentError, "Le premier argument de BdD::Table#has_row_with? doit être un string (condition where SQL)" unless where.class == String
      # select( where: where ) != nil
      # res = select( where: where )
      res = execute "SELECT COUNT(*) FROM #{name} WHERE #{where}"
      # debug "res: #{res.inspect}"
      return false if res === false
      nombre_rangees = res.first
      # debug "nombre rangées : #{nombre_rangees}"
      nombre_rangees > 0
    end

    ##
    # Détruit la table
    # Détruit également son enregistrement dans __column_names__
    def remove
      bdd.execute "DROP TABLE IF EXISTS #{name}"
      return res
    end
    alias :destroy :remove

    ##
    # Raccourci pour exécuter du code
    def execute code, expected_return = nil
      res = bdd.execute code, expected_return
      res = res.first if res.class == Array && res.count == 1
      return res
    end

    private


      ##
      # @retourne le code de création de la table
      def creation_code
        @creation_code ||= begin
          arr_index         = Array::new
          arr_index_uniques = Array::new
          def_cols = colonnes_definition.collect do |col_name, col_data|
            arr_index         << col_name if col_data[:index]
            arr_index_uniques << col_name if col_data[:unique_index]
            typetconst = "#{col_data[:type]} #{col_data[:constraint]}".strip
            col_data[:default] = "''" if col_data[:default] == ""
            typetconst << " DEFAULT #{col_data[:default]}" unless col_data[:default].nil?
            typetconst << " UNIQUE" if col_data[:index] || col_data[:unique_index]
            "#{col_name} #{typetconst}"
          end.join(", ")
          # Assemblage du code
          "CREATE TABLE #{name} (#{def_cols})"
        end
      end

      ##
      # Check des données des colonnes de la table
      def check_definition_colonnes_or_raise
        raise BdDError, :colonnes_definition_required if colonnes_definition.nil?
        colonnes_definition.each do |key, data_key|
          # Check du NOM des colonnes
          raise BdDError, :bad_colonne_name if key.to_s.gsub(/[a-z0-9_]/,'') != ""
          # Check du TYPE des colonnes
          typ = data_key[:type]
          raise BdDError, :type_colonne_required if typ.nil?
          unless BdD::Table::DATA_TYPES.include?(typ)
            # On essaie en retirant la parenthèse
            typ = typ.split('(').first if typ =~ /\(/
            raise BdDError, :unknown_type unless BdD::Table::DATA_TYPES.include?(typ)
          end
          # Check de la contrainte si elle est définie
          unless data_key[:constraint].nil?
            constraint_found = false
            BdD::Table::CONSTRAINT_TYPES.each do |typ|
              if data_key[:constraint].start_with?(typ)
                constraint_found = true
                break
              end
            end
            raise BdDError, :unknown_constraint unless constraint_found
          end
        end
      rescue BdDError => e
        debug "[BdDError] “#{e.message}” avec colonnes_definition : "
        debug colonnes_definition
        debug e
        raise BdD::ERRORS[e.message.to_sym]
      rescue Exception => e
        debug e
        BdD::error e
      end

      ##
      # Check des données fournies à l'instanciation
      def check_instance_data_or_raise
        raise BdDError, :bdd_instance_required_for_table unless bdd.instance_of?(BdD)
        raise BdDError, :table_name_required_for_table unless name.instance_of?(String)
        raise BdDError, :table_name_invalide unless name.gsub(/[a-z_]/,'') == ""
      rescue BdDError => e
        raise ArgumentError, BdD::ERRORS[e.message.to_sym]
      rescue Exception => e
        BdD::error e.message
        debug e
        raise "Instanciation de la table impossible"
      end

      def add_error err
        @errors ||= []
        @errors << err
        return false
      end
  end
end
