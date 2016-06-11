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

    # Pour le moment, 3 tweets sur 4 on envoie une citation
    # tirée de la base au hasard.
    #
    # Cette méthode retourne le texte du tweet à envoyer
    # pour une citation (avec un lien qui conduit à la section
    # citations de la boite).
    #
    # Attention au fonctionnement très particulier : l'idée est
    # qu'il y ait toujours une explicitation de la citation qui
    # est diffusée. Mais pour le moment, seules quelques citations
    # ont une explicitation. Pour fonctionner, ici, on relève
    # deux choses :
    #   - la citation qui doit être twittée
    #   - la prochaine citation qui doit être twittée, pour que
    #     je puisse en faire la définition (ou même les 5 prochaines
    #     citations)
    #
    def tweet_citation

      # On choisit un nombre (ID) de citation au hasard
      tbl_citations = site.db.table('site_cold', 'citations')

      # On récupère les citations qui sont
      # prévues pour diffusion (dont je dois faire l'explicitation
      # avant envoi)
      where = '( last_sent > 0 ) AND ( last_sent < 11 )'
      prochaines = tbl_citations.select(
        where: where,
        order: 'last_sent ASC',
        colonnes: [:citation, :auteur, :bitly, :last_sent]
        ).values

      # La citation qui doit être envoyée maintenant
      # est toujours la dernière (c'est celle qui porte
      # le numéro 10)
      #
      # Note : Au tout départ, prochaine est nil?
      # -----------------------------------------
      prochaine = prochaines.pop

      # On prendre le nombre de citations trouvées, pour
      # savoir combien il faut en reprévoir pour la suite.
      # Quand la boucle sera bien mise en place, on pourra
      # simplement en reprendre une seule, mais avant ça,
      # il faut lancer la bouche (qui ne contient aucune
      # citation)
      nombre_prochaines = prochaines.count

      nombre_candidates_voulues = 10 - nombre_prochaines

      all_candidates = tbl_citations.select(
        where: nil,
        order:    'last_sent ASC',
        limit:    40 + nombre_candidates_voulues,
        colonnes: [:citation, :auteur, :bitly, :last_sent, :id]
      ).values
      all_candidates = all_candidates.shuffle.shuffle
      candidates = all_candidates[0..nombre_candidates_voulues - 1]

      # Si la prochaine n'a pas pu être trouvée, on prend
      # la dernière de toutes les candidates
      prochaine ||= all_candidates.last

      # Il faut définir le :last_sent de ces
      # candidates
      candidates.each_with_index do |hcit, icit|
        candidates[icit][:last_sent] = icit
      end

      # On ajoute les prochaines aux candidates
      # Note : La prochaine est déjà retirée de cette
      # liste.
      candidates += prochaines

      # On incrémente le last_sent de toutes les candidates
      # sauf s'il est supérieur ou égal à 10
      #
      # On construit en même temps le message pour me dire
      # quelles citations traiter
      mess_admin = []
      candidates.sort_by{|e| - e[:last_sent]}.each do |hcit|
        cid = hcit[:id]
        if hcit[:last_sent] < 10
          hcit[:last_sent] += 1
          tbl_citations.update( cid, { last_sent: hcit[:last_sent] })
        end
        mess_admin << "<li><a href='http://localhost/WriterToolbox/citation/#{cid}/edit'>Citation ##{cid}</a> [#{hcit[:last_sent]}] : #{hcit[:citation]}</li>"
      end

      # On doit me transmettre les candidates pour que j'en
      # écrive la définition.

      begin
        mess_admin =
          "<p>Citations à expliciter :</p>" +
          '<ul>' + mess_admin.join('') + '</ul>' +
          '<p>Les premières seront les premières diffusées.</p>'

        MiniMail.new().send(
          mess_admin,
          'Citations à expliciter',
          {format: 'html'}
          )
      rescue Exception => e
        error_log e, 'Impossible de transmettre les prochaines citations à expliciter'
      end
      safed_log "Les prochaines citations à expliciter sont les citations : " + candidates.collect{|hc| hc[:id]}.join(', ')

      citation_id = prochaine[:id]

      auteur    = " - #{prochaine[:auteur]}"
      bitly     = " #{prochaine[:bitly]}"
      reste_len = 139 - (auteur.length + bitly.length + 4) #
      citation  = prochaine[:citation]

      # On indique la date d'envoi de cette dernière
      # citation
      tbl_citations.update(citation_id, { last_sent: Time.now.to_i })

      # Citation finale
      citation =
        if citation.length < reste_len
          prochaine[:citation]
        else
          prochaine[:citation][0..reste_len] + '[…] '
        end
      ["#{citation}#{auteur}#{bitly}", citation_id]
    end

    # Retourne TRUE si on doit envoyer un tweet
    # en fonction de la fréquence d'envoi déterminée par la
    # constante PERMANENT_TWEET_FREQUENCE
    #
    # On prend la date du dernier tweet envoyé
    #
    def time_ok_to_send
      envoi_requis = (Time.now.hour % PERMANENT_TWEET_FREQUENCE) == 0
      safed_log "  = Calcul si envoi est nécessaire"
      safed_log "  = Heure courante : #{Time.now.hour} / Fréquence : toutes les #{PERMANENT_TWEET_FREQUENCE} heures"
      safed_log "  = Envoi requis : #{envoi_requis ? 'OUI' : 'NON'}"
      envoi_requis || begin
        modu = Time.now.hour % PERMANENT_TWEET_FREQUENCE
        rest = PERMANENT_TWEET_FREQUENCE - modu
        safed_log "  = Le prochain envoi se fera dans #{rest} heures"
      end
      envoi_requis
    end

    def db_site_cold
      @db_site_cold ||= './database/data/site_cold.db'
    end

  end #<< self

end #/Tweet
end #/SiteHtml
