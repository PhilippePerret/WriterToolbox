Il faut pouvoir calculer la durée de visite de chaque page. Pour la connaitre, on prend le temps de connexion et le temps de connexion de la page suivante.

Donc, ce qu'il faudrait faire, c'est, au début, relever toutes les rangées, mais ajouter la propriété `end_time` quand c'est la même adresse IP.

* On prend les rangées voulues (:ip, :route, :time)
* On boucle sur ces rangées pour
  1. faire des instances Connexions::Route
  2. faire des instances Connexions::IP
* On fait une deuxième boucles pour définir les temps de fin
  en mettant 10 secondes si la page n'a pas de fin.
