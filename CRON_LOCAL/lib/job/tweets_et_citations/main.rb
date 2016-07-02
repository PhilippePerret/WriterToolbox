# encoding: utf-8
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
  
  # = main =
  #
  # Méthode appelée par la main principal pour traiter les
  # tweets permanents et les citations.
  # 
  def tweets_et_citations
    # Il faut qu'il soit l'heure d'envoyer quelque chose
    tweets_or_citations_must_be_sent? || (return false)
    if tweet_must_be_sent?
      send_tweet_permanent
    else
      send_citation
    end
  end

  def tweets_or_citations_must_be_sent?
    Time.now.hour % FREQUENCE_ENVOI_TWEETS_ET_CITATION == 0  || (return false)
  end
  
  # RETURN true si c'est un tweet permanent qui doit être
  # envoyé
  def tweet_must_be_sent?
    Time.now.hour % (FREQUENCE_TWEETS_SUR_CITATIONS * FREQUENCE_ENVOI_TWEETS_ET_CITATION) == 0
  end

  # ------------------------------------------------------------
  # Méthodes d'envoi
  # ------------------------------------------------------------

  # Méthode d'envoi du tweet permanent
  # 
  def send_tweet_permanent

  end

  # Méthode d'envoi de la citation
  # 
  def send_citation

  end
  
end #/LocCron
