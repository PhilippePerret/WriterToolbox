# encoding: UTF-8
=begin

  La classe appelante doit définir @sync qui est l'instance
  `sync` principale. Donc :
      class Sync
        def dosync
          NouvelleClasse.instance.synchronize(self) # <= ici le self
        end
        ...
        class NouvelleClasse
          include Singleton
          include CommonSyncMethods

          synchronize(s) # on reçoit sync
            @sync = s # on définit @sync pour les méthodes d'ici
            ...
          end
        end
      end

  MÉTHODES MYSQL
  --------------
    Dans la classe utilisant ces méthodes il faut impérativement
    définir `db_suffix` (suffixe de la base de données) et
    `table_name` (nom de la table dans la base).

    Les méthodes `dis_rows` et `loc_rows` renvoient alors
    toutes les rangées des deux tables.

    Un premier argument optionnel (Hash) permet de définir
    plusieurs choses :

      options:{

        main_key:     Par défaut, la clé principale utilisée pour le
                      hash des rangées renvoyées est :id, mais on peut
                      en définir une autre avec cette valeur.
        Toutes les autres propriétés serviront de premier argument
        à `select`. Donc on peut trouver :where, :colonnes, :order, etc.
      }
=end
module CommonSyncMethods


  def suivi mess  ; @sync.suivi   << "    #{mess}"  end
  def report mess ; @sync.report  << "    #{mess}"  end
  def error mess  ; @sync.errors  << mess           end


  # Rangées dans la table distante
  # cf. plus haut pour options
  def dis_rows options = nil
    @dis_rows ||= rows(dis_table, options)
  end
  # Rangées dans la table locale
  # cf. plus haut pour options
  def loc_rows options = nil
    @loc_rows ||= rows(loc_table, options)
  end

  # Toutes les rangées de la table +table+, en hash avec
  # en clé l'identifiant.
  # cf. plus haut pour options
  def rows( table, options = nil )
    options ||= {}
    main_key = options.delete(:main_key) || :id
    # Si la clé principale n'est pas :id, il faut ajouter la
    # main-key à la liste des colonnes si cette liste est définie
    main_key == :id || begin
      if options.key?(:colonnes)
        options[:colonnes] << main_key
        options[:colonnes] = options[:colonnes].uniq
      end
    end
    h = {}
    rs =
      if options.empty?
        table.select
      else
        table.select(options)
      end
    rs.each {|r| h.merge! r[main_key] => r }
    h
  end

  # Table locale
  def loc_table
    @loc_table ||= site.dbm_table(db_suffix, table_name, online = false)
  end
  # Table distante
  def dis_table
    @dis_table ||= site.dbm_table(db_suffix, table_name, online = true)
  end

end
