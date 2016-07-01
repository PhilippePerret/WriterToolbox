# Envoi du rapport en boucle

Parfois, il arrive que le rapport soit envoyé en boucle. j'ai beau arrêter le crontab, changer le nom du fichier hour_cron ou du dossier CRON, les détruire, ça ne change rien (une instance doit être initiée).

La seule chose qui semble fonctionner est de :

* éditer le fichier hour_cron.rb,
* écrire `exit` au-dessus (il suffit de décommenter la ligne),
* re-charger (uploader) le fichier.

Ça a fonctionné, à voir si ça n'était pas dû à autre chose, à force d'essayer des trucs…
