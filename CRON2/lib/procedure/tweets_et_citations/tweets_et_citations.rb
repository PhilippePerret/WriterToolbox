# encoding: UTF-8
#
# Module pour gérer l'envoi des tweets et des citations
#
# Cette classe est directement inspirée de la nouvelle formule qui
# avait été mise en place en local et fonctionnait parfaitement bien.
#
class CRON2

    # Méthode principale appelée par le run
    def tweets_et_citations
        TweetsEtCitations.send_tweet_or_citation
    end
end
