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
        safed_log "  ### PROBLÈME ENVOI DES TWEETS : #{message_retour}"
      end
    rescue Exception => e
      bt = e.backtrace.join("\n")
      safed_log "# Problème en envoyant les tweets permanents : #{e.message}\n#{bt}"
    else
      safed_log "  = Tweets permanents envoyés avec succès."
    end


    # Retourne TRUE si on doit envoyer un tweet
    # en fonction de la fréquence d'envoi déterminée par la
    # constante PERMANENT_TWEET_FREQUENCE
    def time_ok_to_send
      (Time.now.hour % PERMANENT_TWEET_FREQUENCE) == 0
    end

  end #<< self

end #/Tweet
end #/SiteHtml
