# encoding: UTF-8
class SiteHtml

  # Pour envoyer un tweet
  # @usage :
  #   site.require_module 'twitter'
  #   site.tweet "Le message à twitter"
  #
  # Si le message commence exactement par "P ", il s'agit
  # d'un TWEET PERMANENT (cf. manuel Divers > Twitter)
  #
  def tweet message
    is_permanent = message.start_with?('P ')
    message = message[2..-1].strip if is_permanent

    # === ENVOI ===
    if is_permanent && ONLINE
      flash "Les tweets permanents doivent être ajoutés en OFFLINE."
    elsif is_permanent
      ptweet = Tweet::new(nil, message)
      ptweet.create
      flash "Le tweet ##{ptweet.id} sera envoyé au prochain tour de cron (il faut actualiser les données par le dashboard — pas par check synchro)."
    else
      require 'twitter'
      Tweet::send message
    end

  end
  alias :twitte :tweet

  class Tweet

    include MethodesObjetsBdD

    class << self

      def client
        @client ||= begin
          require 'twitter'
          require './data/secret/data_twitter'
          Twitter::REST::Client.new do |config|
            config.consumer_key        = DATA_TWITTER[:consumer_key]
            config.consumer_secret     = DATA_TWITTER[:consumer_secret]
            config.access_token        = DATA_TWITTER[:access_token]
            config.access_token_secret = DATA_TWITTER[:access_token_secret]
          end
        end
      end

      # Pour envoyer un tweet
      # @usage :
      #   site.require_module 'twitter'
      #   site.tweet "Le message à twitter"
      def send message
        client.update(message)
      end

      # Pour envoyer des tweets permanents
      # +nombre+ Nombre de tweets à envoyer par ce biais.
      #
      # Cette méthode est appelée par le CRON-JOB quotidien
      #
      # RETURN La méthode retourne un Array contenant en
      # première valeur le succès ou non de l'opération et
      # en seconde valeur le message soit de succès soit
      # le message d'erreur rencontrée.
      #
      def auto_tweet(nombre = 1)
        # Relever dans la table les derniers tweets les
        # plus lointains et les moins envoyés. Bien noter
        # que ça va dans cet ordre. Un message peu envoyé
        # passera toujours après un message envoyé longtemps
        # auparavant même s'il a été envoyé plus de fois.
        # Dans le cas contraire, tous les nouveaux messages
        # seraient toujours envoyés plusieurs fois jusqu'à
        # ce que leur nombre ait atteint les autres nombre
        # d'envois.
        req_data = {order: 'last_sent ASC, count ASC', limit: nombre, colonnes:[]}
        tweets_ids = table_permanent_tweets.select(req_data).keys
        safed_log "  = tweets_ids: #{tweets_ids.inspect}"
        tweets_ids.each do |tweet_id|
          twit = Tweet::new(tweet_id)
          init_count = twit.count.dup
          twit.resend
          safed_log "  = Réexpédition de : #{twit.message}"
          # On vérifie que le tweet ait bien été actualisé
          tchecked = Tweet::new(tweet_id)
          if tchecked.count != init_count + 1
            error_log "Les données du tweet réexpédié (##{twit.id}) n'ont pas été actualisées après envoi…"
          else
            safed_log "  = Données du tweet actualisées."
          end
        end
      rescue Exception => e
        bt = e.backtrace.join("\n")
        [false, "Les tweets permanents n'ont pas pu être envoyés : #{e.message}\n#{bt}"]
      else
        # On retourne un résultat positif d'opération
        s = nombre > 1 ? 's' : ''
        [true, "#{nombre} tweet#{s} permanent#{s} ré-expédié#{s}."]
      end

      def table_permanent_tweets
        @table_permanent_tweets ||= site.db.create_table_if_needed('site_cold', 'permanent_tweets')
      end


    end #/<<self

    # ---------------------------------------------------------------------
    #   INSTANCES DES TWEETS (POUR LES TWEETS PERMANENTS)
    # ---------------------------------------------------------------------

    # Instanciation d'un tweet permanent
    #
    # Si +id+ est nil, c'est une création
    # Si +message+ est nil, c'est un rechargement de tweet,
    # certainement pour un renvoi ou une modification du
    # message.
    def initialize(id, message = nil)
      @id       = id
      @message  = message
    end

    # Ré-expédie le tweet
    def resend
      # Envoyer
      self.class.send( message )
      # Actualiser les données
      newdata = { count: count + 1, last_sent: NOW }
      safed_log "  * Données du tweet mise à #{newdata.inspect}"
      set( newdata )
      safed_log "  = Données du tweet actualisées"
    end

    # Création du permanent tweet
    #
    # Note : À la création du tweet, on ne l'envoie pas
    # car il a déjà été envoyé par d'autres moyens. On
    # ne fait vraiment que consigner sa donnée.
    def create
      extract_bitly
      @count      = 0
      @last_sent  = 0
      @id = table.insert( data2save.merge(created_at: NOW) )
    end

    # Les données à sauver dans la tables des tweets
    # permanents.
    def data2save
      {
        message:      message,
        bitlink:      bitlink,
        count:        count,
        last_sent:    last_sent,
        updated_at:   NOW
      }
    end

    # ---------------------------------------------------------------------
    #   Propriétés
    # ---------------------------------------------------------------------
    def id;         @id         ||= dispatch(:id)         end
    def message;    @message    ||= dispatch(:message)   end
    def bitlink;    @bitlink    ||= dispatch(:bitlink)    end
    def count;      @count      ||= dispatch(:count)      end
    def last_sent;  @last_sent  ||= dispatch(:last_sent)  end
    def created_at; @created_at ||= dispatch(:created_at) end
    def updated_at; @updated_at ||= dispatch(:updated_at) end
    def data;       @data       ||= table.get(id)         end

    # /Propriétés
    # ---------------------------------------------------------------------

    # Dispatche toutes les données du permanent link et
    # retourne la donnée attendue
    def dispatch kreturned
      data.each {|k, v| instance_variable_set("@#{k}", v) }
      data[kreturned]
    end

    # À la création du lien permanent, cette méthode permet
    # d'extraire le lien bitly du message (noter que ce lien n'est pas
    # retiré du message lui-même)
    #
    # Affecte la donnée @bitlink
    def extract_bitly
      bl = message.match(/^(.*)(http:\/\/bit\.ly\/(?:.*))$/).to_a[2]
      bl != nil || raise("Impossible de trouver le lien bitly dans le message…")
      @bitlink = bl
    end

    def table
      @table ||= self.class.table_permanent_tweets
    end
  end #/Tweet
end #/SiteHtml
