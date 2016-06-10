# Les Icariens

Les icariens actifs sont automatiquement abonnés de la boite.

Mais pour le moment, il faut définir ça manuellement. Pour le faire :

* Récupérer l'identifiant de l'user
* Tapez ONLINE en console (EN REMPLAÇANT USERID POUR LA VALEUR DE L'IDENTIFIANT DE L'USER SUR BOA) :

    ~~~ruby
      u=User.get(USERID);opts=u.options.ljust(32,'0');opts[31]='2';u.set(options: opts)
    ~~~
