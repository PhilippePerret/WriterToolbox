# Ajax

* [Envoi d'une requête](#envoidunerequetee)
* [Propriétés définissables](#proprietesdefinissables)
* [Renvoi de données aux programmes](#renvoiededonnees)
* [Message de retour](#messagederetour)
* [Erreur de retour](#erreurderetour)
* [Auto-sélection du contenu des champs de texte quand focus](#autoselectquandfocus)


<a name='envoidunerequetee'></a>

## Envoi d'une requête

La donnée indispensable pour envoyer une requête Ajax est la donnée `url` qui définit la route à employer, exactement comme on le ferait depuis une page avec un lien normal.

Par exemple, si on veut invoquer le script :

    ./objet/mon_objet/mon_module

… on définit l'url à :

    mon_objet/mon_module

Donc :

    Ajax.send({
      url: "mon_objet/mon_module",
      ma_donnee_1: "<les données envoyées>",
      ma_donnee_2: "<autre donnée>",
      onreturn: $.proxy(la méthode pour poursuivre)
      })

Noter que pour le moment l'url ne fonctionne pas avec les sous-objets. Donc on ne peut pas faire :

    url: "livre/folders?in=cnarration"

<a name='proprietesdefinissables'></a>

## Propriétés définissables



    onreturn:       Méthode de retour

    message_on_operation:   Message d'opération


<a name='renvoiededonnees'></a>

## Renvoi de données aux programmes

    Ajax << {<hash de données>}


<a name='messagederetour'></a>

## Message de retour

    Ajax << {message: "Le message de retour"}

<a name='erreurderetour'></a>

## Erreur de retour

    Ajax << {error: "Erreur de retour"}


<a name='autoselectquandfocus'></a>

## Auto-sélection du contenu des champs de texte quand focus

Pour obtenir que les champs de texte (input-text et textarea) se sélectionnent quand on focus dedans, on peut utiliser la méthode :

  UI.auto_selection_text_fields()

Noter qu'elle est déjà appelée par défaut au chargement de la page, donc qu'elle n'est à utiliser que lorsqu'on recharge du texte par ajax.
