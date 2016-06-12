# Export en LaTex de la collection Narration


## Synopsis général

    On boucle sur chaque livre, ou un seul livre est traité.
        _main_.rb

    On appelle la méthode `export_latex` sur l'instance livre
        ./objet/cnarration/lib/module/translator/livre/livre_export.rb

    La méthode `export_latex` traite chaque source, dans
    l'ordre de la table des matières.
    Elle fait une instance `Cnarration::Translator` de
    chaque source

      itranslator = Cnarration::Translator::new( self, source )

    Et appelle la méthode `translate(:latex)` de cette instance.
    Définie dans :
        ./objet/cnarration/lib/module/translator/translator.rb

    La méthode `translate` procède alors à trois corrections
    principales :

    `pre_corrections`
        Effectue des corrections pour que le fichier puisse être
        “kramdowné”. Par exemple, la méthode va “protéger” les
        crochets ou les accolades pour qu'ils ne soient pas
        corrigés.
        Défini dans : ./objet/cnarration/lib/module/translator/translator_patch_format/latex/corrections.rb
    `kramdown`
        Kramdown le document à l'aide de la class Kramdown
        Défini dans :
        ./objet/cnarration/lib/module/translator/translator.rb
    `post_corrections`
        Effectue des corrections après le traitement kramdown.
        Par exemple, la méthode va “déprotéger” les crochets
        et les accolades.
        Défini dans :
        ./objet/cnarration/lib/module/translator/translator_patch_format/latex/corrections.rb

    Enfin, la méthode `translate` finalise le contenu à l'aide de
    `finalise_content`

    Et elle écrit le fichier LaTex résultant dans une vraie source
    du dossier LaTex créé pour le livre.
