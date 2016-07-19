# encoding: UTF-8
module MethodesBaseMySQL

  # Permet de définir sur quelle base doit être effectuées
  # les opérations
  def define_is_offline force_online
    if ONLINE
      @is_offline = false
    else
      unless force_online === !@is_offline
        @is_offline =
          case force_online
          when NilClass then OFFLINE
          else !force_online
          end
        reset
      end
    end
  end

  def offline?
    @is_offline = OFFLINE if @is_offline === nil
    @is_offline
  end

  # Au cours de la même session, on peut faire appel à la
  # base local ou distante. Il faut donc pouvoir reseter les
  # données
  def reset
    @client_data  = nil
    @client       = nil
  end

  def client
    @client ||= Mysql2::Client.new(client_data.merge(database: db_name))
  end

  def client_sans_db
    @client_sans_db ||= Mysql2::Client.new(client_data)
  end

  # Les données pour se connecter à la base mySql
  # soit en local soit en distant.
  def client_data
    @client_data ||= ( offline? ? client_data_offline : client_data_online )
  end

  def client_data_offline
    require './data/secret/mysql'
    DATA_MYSQL[:offline]
  end

  def client_data_online
    require './data/secret/mysql'
    DATA_MYSQL[:online]
  end

  def db_name
    @db_name ||= prefix_name + suffix_name.to_s
  end

  def suffix_name ; @suffix_name end

  # Le préfixe du nom (de la base de données) en fonction
  # du fait qu'on est online ou offline
  #
  # Normalement, maintenant, on peut utiliser les deux en
  # online comme en offline.
  #
  def prefix_name
    @prefix_name ||= 'boite-a-outils_'
  end

end
