# Méthodes pratiques

* [Logguer un user ou un administrateur](#logguerunutilisateuradmin)
* [Ajouter un message au suivi du test](#affichermessagesupplementaire)

Ces méthodes se trouvent définies dans `./test/support/required/`.

<a name='logguerunutilisateuradmin'></a>

## Logguer un user ou un administrateur

Ces méthodes peuvent s'utiliser en début de feuille de test ou en cours de test pour logguer un utilisateur, c'est-à-dire pour l'identifier. Une fois qu'il est identifié, on peut poursuivre la visite des autres pages comme si on était ce user, car un fichier de session est enregistré, qui est lu par toutes les requêtes cUrl (noter que je n'utilise plus Nokogiri::HTML pour récupérer le document, maintenant).

~~~ruby

login_user <pseudo>[, <options>]

~~~

Par exemple&nbsp;:

~~~ruby

  login_user "benoit" 
  # => Identifie le user dont le pseudo est Benoit
  
~~~

Noter que cette méthode se sert des données secrètes dans ./data/secret/ en cherchant un fichier qui s'appelle `data_<pseudo>.rb` et qui doit définir la constante `DATA_<PSEUDO>`. On ne peut plus se servir des tables puisque les mots de passe ne sont plus enregistrés.

Si `pseudo` est nil, on peut fournir `:mail` et `:password` dans le hash d'option, ils seront utilisés pour tenter le log.


### Méthode spéciale pour logguer un administrateur

Pour logguer un administrateur, on peut définir aussi des méthodes similaires à&nbsp;: 

~~~

login_phil

~~~


<a name='affichermessagesupplementaire'></a>

## Ajouter un message au suivi du test

Utiliser la méthode `show <message>` pour ajouter un message au suivi du test. Par exemple&nbsp;:

~~~ruby

show "La valeur est #{valeur}"

~~~

Noter qu'il faut impérativement appeler les tests avec l'option verbose (`-v`) pour que ces messages s'affichent.