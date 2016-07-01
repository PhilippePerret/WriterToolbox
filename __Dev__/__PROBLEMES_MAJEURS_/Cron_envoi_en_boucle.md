# Envoi du rapport en boucle

Parfois, il arrive que le rapport soit envoyé en boucle. j'ai beau arrêter le crontab, changer le nom du fichier hour_cron ou du dossier CRON, les détruire, ça ne change rien (une instance doit être initiée).

La seule chose qui semble fonctionner est de :

* éditer le fichier hour_cron.rb,
* écrire `exit` au-dessus (il suffit de décommenter la ligne),
* re-charger (uploader) le fichier.

Ça a fonctionné, à voir si ça n'était pas dû à autre chose, à force d'essayer des trucs…


# Un gem qui n'est pas pris en compte

C'est arrivé avec mysql2 qui fonctionnait depuis un moment. Tout à coup, ça n'a plus marché sans que je comprenne pourquoi et le CRON plantait systématiquement (alors que le site semblait fonctionner).

J'ai ajouté cette ligne dans le .bash_profile :

    export GEM_HOME="$HOME/.gems"

Noter qu'avant, quand je jouais :

    ruby -e "p require 'mysql2'"

… en SSH sur le site, ça produisant une erreur. Après avoir ajouté la ligne dans le bash profil, ça ne l'a plus fait.
