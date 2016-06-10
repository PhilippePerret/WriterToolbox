# encoding: UTF-8
class SiteHtml
class Tweet

  # Le nombre se lit : "Envoyer NOMBRE_PERMANENT_TWEETS_SEND toutes
  # les PERMANENT_TWEET_FREQUENCE heures"
  NOMBRE_PERMANENT_TWEETS_SEND  = 1
  PERMANENT_TWEET_FREQUENCE     = 3

  class << self

    def send_permanent_tweets_if_needed
      safed_log "-> send_permanent_tweets_if_needed"
      time_ok_to_send || return

      # On a besoin des librairies twitter
      Dir["./lib/deep/deeper/module/twitter/**/*.rb"].each{|m| require m}

      # Une fois sur 4 on envoie un auto tweet qui renvoie vers
      # une partie de la boite, et 3 fois sur 4 on envoie une
      # citation.
      heure = Time.now.hour
      if heure > 9 && heure < (9 + PERMANENT_TWEET_FREQUENCE)
        ok, message_retour = auto_tweet(NOMBRE_PERMANENT_TWEETS_SEND)
        if ok
          safed_log "  = #{message_retour}"
          safed_log "  = Envoi Tweet Permanent OK."
        else
          error_log "  ### [#{Time.now}] PROBLÈME ENVOI DES TWEETS : #{message_retour}"
        end

      else

        # Sinon on envoie une citation. Noter que la longueur
        # ne doit pas être vérifiée car le message est forcément plus
        # long à cause de l'adresse complète (qui sera raccourcie par
        # twitter)
        begin
          mess_citation, citation_id = tweet_citation
          site.tweet( mess_citation, dont_check_length: false)
        rescue Exception => e
          error_log( e, 'Impossible d’envoyer la citation' )
        else
          safed_log "  = Envoi Tweet de la CITATION ##{citation_id} (OK)."
        end
      end

    rescue Exception => e
      error_log e, "# [#{Time.now}] Problème en envoyant les tweets permanents"
    end

    # Pour le moment, 3 tweet sur 4 on envoie une citation
    # tirée de la base au hasard.
    #
    # Cette méthode retourne le texte du tweet à envoyer
    # pour une citation (avec un lien qui conduit à la section
    # citations de la boite).
    def tweet_citation

      # On choisit un nombre (ID) de citation au hasard
      tbl_citations = site.db.table('site_cold', 'citations')
      nombre_citations = tbl_citations.count
      citation_id = rand(nombre_citations)
      citation_id = 1 if citation_id < 1 || citation_id > nombre_citations

      # On récupère les données de la citation
      dquote = tbl_citations.get( citation_id )

      # Le lien complet, qui sera transformé en lien raccourci
      full_lien = " http://www.laboiteaoutilsdelauteur.fr/citation/#{citation_id}/show"
      auteur    = " - #{dquote[:auteur]}"
      bitly_len = 20 # longueur approximative
      reste_len = 139 - (auteur.length + bitly_len + 4) #
      citation  = dquote[:citation]

      # Citation finale
      citation =
        if citation.length < reste_len
          dquote[:citation]
        else
          dquote[:citation][0..reste_len] + '[…] '
        end
      ["#{citation}#{auteur}#{full_lien}", citation_id]
    end

    # Retourne TRUE si on doit envoyer un tweet
    # en fonction de la fréquence d'envoi déterminée par la
    # constante PERMANENT_TWEET_FREQUENCE
    #
    # On prend la date du dernier tweet envoyé
    #
    def time_ok_to_send
      safed_log "  = last_sent = #{last_sent.inspect}"
      if last_sent.nil?
        (Time.now.hour % PERMANENT_TWEET_FREQUENCE) == 0
      else
        time_now        = Time.now.to_i
        time_next_envoi = last_sent + (PERMANENT_TWEET_FREQUENCE * 3600) - 30
        envoi_requis = time_now >= time_next_envoi
        safed_log "  = Calcul si envoi est nécessaire"
        safed_log "  = #{time_now} (now) > #{last_sent} (last_sent) + #{PERMANENT_TWEET_FREQUENCE * 3600} (PERMANENT_TWEET_FREQUENCE * 3600)"
        safed_log "  = Envoi requis : #{envoi_requis ? 'OUI' : 'NON'}"
        envoi_requis || begin
          reste = time_next_envoi - time_now
          date_next_envoi = time_next_envoi.as_human_date(true, true, ' ')
          safed_log "  = Le prochain envoi se fera dans #{reste.as_duree} (#{date_next_envoi})"
        end
        envoi_requis
      end
    end

    def last_sent
      @last_sent ||= begin
        require 'sqlite3'
        db = SQLite3::Database.new(db_site_cold)
        rp = db.prepare request_last_sent
        rp.execute.each_hash { |h| return h['last_sent'] }
      rescue Exception => e
        error_log e, "# [#{Time.now}] Problème en récupérant la date de dernier envoi."
        nil
      ensure
        (db.close if db) rescue nil
        (rp.close if rp) rescue nil
      end
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
