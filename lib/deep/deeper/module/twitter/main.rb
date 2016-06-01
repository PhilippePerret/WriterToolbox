# encoding: UTF-8
class SiteHtml

  # Pour envoyer un tweet
  #
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

    # Vérification de la longueur
    len_message = message.length
    unless len_message < 140 # 140, c'est trop long
      len_retrait = len_message - 139
      error "Le message doit faire moins de 140 caractères, il en fait #{len_message} caractères, il faut en retirer <strong>#{len_retrait}</strong>."
      return false
    end

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
        # ce que leur nombre ait atteint les autres nombres
        # d'envois.
        req_data = {order: 'last_sent ASC, count ASC', limit: 10, colonnes:[]}
        tweets_ids = table_permanent_tweets.select(req_data).keys
        safed_log "  = tweets_ids: #{tweets_ids.inspect}"

        # On mélange les 10 tweets récupérés et on envoie
        # les +nombre+ premiers.
        tweets_ids.shuffle.shuffle.each_with_index do |tweet_id, tweet_index|

          # On a relevé 10 tweets (pour mélanger les cartes), mais
          # il ne faut en envoyer que +nombre+
          break if tweet_index >= nombre

          twit = new(tweet_id)
          count_expected = twit.count + 1
          twit.resend
          safed_log "  = Réexpédition de : #{twit.message}"

          # On s'assure que les données du tweet ont bien été
          # modifiées
          if check_update_tweet_data( tweet_id, count_expected )
            safed_log "  = Données actualisées (et vérifiées) avec succès"
          else
            safed_log "  # Impossible d'actualiser les données du tweet"
            error_log "Impossible d'actualiser les données du tweet…"
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

      # Un grave problème se pose avec les tweets : leurs données
      # ne s'actualisent pas (:count et :last_sent). J'utilise donc
      # cette méthode pour forcer cette actualisation au maximum.
      #
      # Note : C'était juste un problème de table qui n'était
      # pas fermée, maintenant, le problème doit être résolu.
      # +tid+       ID du tweet
      # +count_expected+  Le nombre (:count) attendu
      def check_update_tweet_data tid, count_expected

        # On met les messages dans cette variable pour pouvoir
        # l'envoyer ensuite dans le error_log s'il y a une erreur
        suivi_error = []
        suivi_error << "=== Tentative d'incrémentation des données du tweet ==="
        suivi_error << "TWEET ID : #{tid}"
        suivi_error << ":count expected: #{count_expected}"

        tchecked = new(tid)
        suivi_error << ":count in tchecked: #{tchecked.count}"
        if tchecked.count == count_expected
          safed_log "= Actualisation data tweet permanent checké par le premier moyen\n" +
                    "= Si ça réussit plusieurs fois, on pourra supprimer les formules après (#{__FILE__}:#{__LINE__})"
          return true
        end
        suivi_error << "BAD"

        # Tentative d'actualisation des données en utilisant
        # `site.db.table`
        suivi_error << "Essai avec site.db.table"
        site.db.table('site_cold', 'permanent_tweets').set(tid, {count: count_expected, last_sent: Time.now.to_i})
        tchecked = new(tid)
        suivi_error <<  "tchecked class : #{tchecked.class}" +
                        "         ID    : #{tchecked.id}" +
                        "         count : #{tchecked.count.inspect}" +
                        "         sent  : #{tchecked.last_sent.inspect}"

        return true if tchecked.count == count_expected
        suivi_error << "BAD"

        # Tentative finale d'actualisation : en utilisant tout
        # en brut.
        require 'sqlite3'
        req = "UPDATE permanent_tweets"+
              " SET count = #{count_expected}, last_sent = #{Time.now.to_i}"+
              " WHERE id = #{tid}"
        suivi_error << "REQUEST : #{req}"
        suivi_error << "Root : #{File.expand_path('.')}"
        pdb = File.join(RACINE, 'database', 'data', 'site_cold.db')
        suivi_error << "DB Path: #{pdb} "
        suivi_error << "Exist? #{File.exist?(pdb).inspect}"
        db = SQLite3::Database.new(pdb)
        pr = db.prepare req
        rs = pr.execute
        suivi_error << "Retour de l'exécution de la requête : #{rs.inspect}"
        tchecked = new(tid)
        suivi_error <<  "tchecked class : #{tchecked.class}" +
                        "         ID    : #{tchecked.id}" +
                        "         count : #{tchecked.count.inspect}" +
                        "         sent  : #{tchecked.last_sent.inspect}"

        return true if tchecked.count == count_expected
        suivi_error << "BAD"

        error_log suivi_error.join("\n")

        return false

      end

      def table_permanent_tweets
        @table_permanent_tweets ||= site.db.create_table_if_needed('site_cold', 'permanent_tweets')
      end


    end #/<<self

    # ---------------------------------------------------------------------
    #   INSTANCES DES TWEETS (POUR LES TWEETS PERMANENTS)
    # ---------------------------------------------------------------------

    attr_reader :id

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
      # ENVOYER LE TWEET
      self.class.send( message )
      # Actualiser les données
      newdata = { count: count + 1, last_sent: NOW }
      set( newdata )
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
      data.each { |k, v| instance_variable_set("@#{k}", v) }
      data[kreturned]
    end

    # À la création du lien permanent, cette méthode permet
    # d'extraire le lien bitly du message (noter que ce lien n'est pas
    # retiré du message lui-même)
    #
    # Affecte la donnée @bitlink
    def extract_bitly
      bl = message.match(/^(.*)(http:\/\/bit\.ly\/([a-zA-Z0-9_-]+)) ?/).to_a[2]
      bl != nil || raise("Impossible de trouver le lien bitly dans le message…")
      @bitlink = bl
    end

    def table
      @table ||= self.class.table_permanent_tweets
    end
  end #/Tweet
end #/SiteHtml
