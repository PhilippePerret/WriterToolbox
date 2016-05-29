# encoding: UTF-8
class SiteHtml
class Tweet

  # Le nombre se lit : "Envoyer NOMBRE_PERMANENT_TWEETS_SEND toutes
  # les PERMANENT_TWEET_FREQUENCE heures"
  NOMBRE_PERMANENT_TWEETS_SEND  = 1
  PERMANENT_TWEET_FREQUENCE     = 6

  class << self

    def send_permanent_tweets_if_needed
      time_ok_to_send || return
      Dir["./lib/deep/deeper/module/twitter/**/*.rb"].each{|m| require m}
      ok, message_retour = auto_tweet(NOMBRE_PERMANENT_TWEETS_SEND)
      if ok
        safed_log "  = #{message_retour}"
      else
        error_log "  ### [#{Time.now}] PROBLÈME ENVOI DES TWEETS : #{message_retour}"
      end
    rescue Exception => e
      error_log e, "# [#{Time.now}] Problème en envoyant les tweets permanents"
    else
      safed_log "  = Tweets permanents envoyés avec succès."
    end


    # Retourne TRUE si on doit envoyer un tweet
    # en fonction de la fréquence d'envoi déterminée par la
    # constante PERMANENT_TWEET_FREQUENCE
    #
    # On prend la date du dernier tweet envoyé
    def time_ok_to_send
      if last_sent.nil?
        (Time.now.hour % PERMANENT_TWEET_FREQUENCE) == 0
      else
        Time.now.to_i > last_sent + (PERMANENT_TWEET_FREQUENCE * 3600)
      end
    end

    def last_sent
      @last_sent ||= begin
        require 'sqlite3'
        db = SQLite3::Database.new(db_site_cold)
        rp = db.prepare request_last_sent
        rp.execute.each_hash { |h| return h['last_sent'] }
      end
    rescue Exception => e
      error_log e, "# [#{Time.now}] Problème en récupérant la date de dernier envoi."
      nil
    end
    def request_last_sent
      <<-SQL
SELECT last_sent
  FROM permanent_tweets
  ORDER BY last_sent DESC
  LIMIT 1
      SQL
    end
    def db_site_cold
      @db_site_cold ||= './database/data/site_cold.db'
    end

  end #<< self

end #/Tweet
end #/SiteHtml
