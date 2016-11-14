Ce dossier est appelé tout de suite après le dépôt de fichier par un user analyste, pour parser les fichiers transmis.

Ces fichiers produisent les données enregistrées dans les fichiers marshal et notamment le fichier FDATA.msh qui contient toutes les données parsées.

Ce parsing charge le module 'parser_reg' ou 'parser_tm' ou 'parser_yaml' en fonction du type de chaque fichier.

Ce parsing a lieu avant le build des fichiers utiles (cf. le module `build`).
