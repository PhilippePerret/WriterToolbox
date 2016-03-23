
## Liens vers des fichiers d'aide

Pour créer un lien

    href: "manuel/<rediger|consulter>?in=analyse&manp=<SUB-FOLDER>/<AFFIXE-FICHIER>"

Donc, pour le construire :

    manuel              C'est toujours le manuel qui est appelé
    rediger|consulter   Choix de la grande section, soit la consultation des
                        analyses soit la rédaction.
    ?in=analyse         L'objet RestSite principal (dossier)
    manp=               Le path relatif sans extension du fichier à partir
                        du sous-dossier principal :
                          ./analyse/manuel/rediger      si manuel/rediger
                          ./analyse/manuel/consulter    si manuel/consulter

                        Par exemple `collecte/en_ligne` pour le fichier
                        ./analyse/manuel/rediger/collecte/en_ligne.erb

Par exemple, pour atteindre la page de présentation du protocole d'analyse adopté :

    href: "manuel/rediger?in=analyse&manp=analyse/protocole"
    # Fichier ./analyse/manuel/rediger/analyse/protocole.erb ou .md

Noter qu'il existe tout simplement un lien pour le faire :

    lien.protocole_analyse_film
