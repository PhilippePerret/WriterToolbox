# Cron job

* [Modifier la fréquence du Cron-job](#modifierlafrequenceducronjbo)


<a name='modifierlafrequenceducronjbo'></a>

## Modifier la fréquence du Cron-job

        $> ssh scenariopole@ssh-scenariopole.alwaysdata.net
        ssh> crontab -e
        nano> ...modifier le cron tab ...

On peut trouver de l'aide intéressante sur le format sur [wikipedia](https://fr.wikipedia.org/wiki/Cron#crontab).

Note : On peut utiliser aussi `ssh serveur_boa`

* [Envoyer un mail en toute sécurité](#envoyermailentoutesecurité)
<a name='envoyermailentoutesecurité'></a>

## Envoyer un mail en toute sécurité

Pour transmettre un mail à l'administration en toute sécurité, donc sans passer par les librairies du site, qui peuvent poser problème, on peut utiliser la class `MiniMail` qui est chargée par défaut :

~~~ruby

    MiniMail.new().send(
      "<le message>",
      "<le sujet optionnel>",
      {<les options>}
    )
~~~

Les options peuvent être :

        :to       Mail du destinataire
        :from     Mail de l'expéditeur
        :log      Si true, on joint le log
        :log_error  Si true on joint le contenu du fichier log erreur
                    Attention, il peut être énorme
        :format   Format du message, 'plain' (défaut) ou 'html'
