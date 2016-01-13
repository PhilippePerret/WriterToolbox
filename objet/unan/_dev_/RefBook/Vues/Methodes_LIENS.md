# Méthodes pour obtenir des liens

* [Liens vers l'aide](#liensversaide)
<a name='liensversaide'></a>

## Liens vers l'aide

Utiliser la méthode :

    Unan::lien_aide '<path/in/aide>', "<titre>"[, <options>]
    alias :link_help

    `<path/in/aide>` {String} ou {Symbol}

        Chemin relatif depuis le dossier ./objets/unan/aide/
        C'est un chemin affixe, l'extension ".erb" sera ajoutée.

        Si c'est un Symbol, c'est un raccourci dans la map :
          Unan::Aide::SYMBOLS_MAP
        défini dans le fichier :
          ./objets/unan/lib/required/data/aide_symbols_map.rb

    "<titre>" {String}

        Le titre à donner au lien.
        Si le premier argument est un symbol, il définit aussi le titre,
        mais si ce titre est défini, il surclasse le titre de la map.

    <options> {Hash}

          :class        Classe CSS à donner au lien
