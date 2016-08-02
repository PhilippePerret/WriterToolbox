# TODO

# Autorisations exceptionnelles

Mettre en place un système qui permette une visite complète exceptionnelle, à l'usage du links analyzer du site :
Pour certaines pages, comme les fichiers narration, on autorise la lecteur complète de la page, pour la vérifier.
Pour ce faire, on crée un fichier de nom d'un md5 (online/offline) et on met cette valeur dans l'url pour la variable `autorisation_exceptionnelle`. Quand le site trouve cette variable, elle regarde si le fichier existe et donne l'autorisation exceptionnelle (en détruisant le fichier, qui doit être reconstruit chaque fois)

# Citations en doublon

253 (goto citation/253/edit)
(c'est la dernière, elles ont toutes été checkées)

# Entrée d'une page de Narration en page de cours UN AN

=> On entre une ligne comme :

    unan new page narration <numéro>[ <jour-programme>]

Et tout le reste est automatique :

=> Création du travail (abs work) associé
=> Ouverture du travail dans le navigateur pour le régler
=> Création du jour-programme s'il le faut
=> Ajout du travail au jour-programme
=> Ouverture du jour-programme pour régler l'ordre des travaux
