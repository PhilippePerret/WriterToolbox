# encoding: utf-8
=begin

Module qui s'occupe d'envoyer périodiquement des tweets (appelés
"tweets permanents") sur twitter ainsi que des citations d'auteurs.

SYNOPSIS
--------

La première chose à faire est de voir s'il est l'heure d'envoyer
le tweet ou la citation. On le sait en comparant l'heure courante
à la constante FREQUENCE_ENVOI_TWEETS_ET_CITATION.

S'il n'est pas l'heure, on s'en retourne.
S'il est l'heure, on regarde s'il faudra envoyer une citation ou
un tweet permanent en comparant l'heure courante à la constante
FREQUENCE_TWEETS_SUR_CITATIONS.

Dans un cas on envoie une citation (cf. [ENVOI CITATION], dans
l'autre on envoie un tweet permantent (cf. [ENVOI TWEET PERMANENT]).

[ENVOI CITATION]

Pour le moment, toutes les citations ne sont pas explicitées. Ce qui
contraint à un mécanisme un peu spécial : il va falloir, en même temps
qu'on envoie une citation, envoyer à l'administrateur un message qui
l'informe des prochaines citations qui seront envoyées, afin qu'il
puisse en écrire la description (explicitation).
Pour ce faire, on utilise une méthode `citation_to_send` qui va
retourner la citation à envoyer, mais c'est aussi à l'intérieur qu'on
traitera ce mail administrateur.

[ENVOI TWEET PERMANENT]

=end
class LocCron


  # Fréquence d'envoi des tweets permanents et des ciations. Le
  # nombre se lit par "toutes les x heures". Par exemple, si la
  # valeur est 4, ça signifie que l'envoi est fait toutes les
  # 4 heures.
  # En fonction de la constante suivant, on saura s'il faut
  # envoyer un tweet permanent ou une citation.
  FREQUENCE_ENVOI_TWEETS_ET_CITATION = 4

  # Définit la fréquence des tweets permanent par rapport aux
  # citations. Si le nombre est 4, ça signifie que sur quatre
  # envoi il y aura un tweet permanent envoyé.
  FREQUENCE_TWEETS_SUR_CITATIONS = 3

  # Nombre de tweets permanents à envoyer en même temps.
  # TODO : Il faudra le régler à une valeur plus forte lorsqu'il
  # y aura plus de tweets.
  NOMBRE_PERMANENT_TWEETS_SEND = 1

  # = main =
  #
  # Méthode appelée par la main principal pour traiter les
  # tweets permanents et les citations.
  #
  def tweets_et_citations
    # Il faut qu'il soit l'heure d'envoyer quelque chose
    tweets_or_citations_must_be_sent? || (return false)
    site.require_module 'twitter'
    if tweet_must_be_sent?
      send_tweet_permanent
    else
      send_citation
    end
  end

  # ------------------------------------------------------------
  # Méthodes d'envoi
  # ------------------------------------------------------------

  # Méthode qui procède à l'envoi de la citation
  def send_citation
    mess_citation, citation_id = citation_to_send
    site.tweet( mess_citation, dont_check_length: true)
  rescue Exception => e
    log "Problème en envoyant la citation", e
  end

  # Méthode d'envoi du tweet permanent
  #
  def send_tweet_permanent
    ok, message_retour = SiteHtml::Tweet.auto_tweet(NOMBRE_PERMANENT_TWEETS_SEND)
    log "  = Tweet permanent envoyé"
  rescue Exception => e
    log "Problème lors de l'envoi du tweet permanent.", e
  end

  # ------------------------------------------------------------
  # MÉTHODES FONCTIONNELLES
  # ------------------------------------------------------------

  # RETURN la citation qui doit être envoyée
  def citation_to_send
    @citation_to_send ||= begin
                            # On choisit un nombre (ID) de citation au hasard
                            tbl_citations = site.dbm_table(:cold, 'citations', online = true)

                            # On récupère les citations qui sont
                            # prévues pour diffusion (dont je dois faire l'explicitation
                            # avant envoi)
                            where = 'last_sent > 0 AND last_sent < 11'
                            prochaines = tbl_citations.select(
                              where: where,
                              order: 'last_sent ASC',
                              colonnes: [:citation, :auteur, :bitly, :last_sent]
                            )

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
                              where:    nil,
                              order:    'last_sent ASC',
                              limit:    40 + nombre_candidates_voulues,
                              colonnes: [:citation, :auteur, :bitly, :last_sent, :id]
                            )
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
                              mess_admin << "<li>" +
                                "<a href='http://localhost/WriterToolbox/citation/#{cid}/edit'>" +
                                "Citation ##{cid}" +
                                "</a> [#{hcit[:last_sent]}] : #{hcit[:citation]}" +
                                "</li>"
                            end

                            # On doit me transmettre les candidates pour que j'en
                            # écrive la définition.

                            begin
                              mess_admin =
                                "<p>Citations à expliciter :</p>" +
                                '<ul>' + mess_admin.join('') + '</ul>' +
                                '<p>Les premières seront les premières diffusées.</p>'

                              site.send_mail_to_admin(
                                message:       mess_admin,
                                subject:       'Citations à expliciter',
                                force_offline: true,
                                formated:      true
                              )
                            rescue Exception => e
                              log 'Impossible de transmettre les prochaines citations à expliciter', e
                            end
                            log "   Les prochaines citations à expliciter sont les citations : " +
                                      candidates.collect{|hc| hc[:id]}.join(', ')

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
                            # ---------------------------------------
                            # Ce qui sera mis dans @citation_to_send
                            # ---------------------------------------
                            ["#{citation}#{auteur}#{bitly}", citation_id]
                          end
  end

  # RETURN true si un envoi doit être fait, citation ou tweet
  def tweets_or_citations_must_be_sent?
    Time.now.hour % FREQUENCE_ENVOI_TWEETS_ET_CITATION == 0  || (return false)
  end

  # RETURN true si c'est un tweet permanent qui doit être
  # envoyé
  def tweet_must_be_sent?
    Time.now.hour % (FREQUENCE_TWEETS_SUR_CITATIONS * FREQUENCE_ENVOI_TWEETS_ET_CITATION) == 0
  end

  # On redéfinit la table des tweets permanents pour pouvoir utiliser
  # la méthode `auto_tweet` sans rien changer.
  def table_permanent_tweets
    @table_permanent_tweets ||= site.dbm_table(:cold, 'permanent_tweets', online = true)
  end


end #/LocCron