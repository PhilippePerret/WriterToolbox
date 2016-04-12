# Réflexions Narration

## Système de référence

Une référence complète comporte :

    LIVRE|FICHIER|ANCRE

Elle s'écrit :

    REF[file_id|livre_id|ancre|titre]

    file_id est toujours indiqué
    Si le second est un nombre, c'est l'ID du livre
    Sinon, c'est l'ancre s'il y a 3 éléments
    ou c'est le titre s'il y a 4 éléments

    Quand il y a l'ancre, il faut obligatoirement le titre
    =>  Si 4 élément => avec ancre
        Si 3 éléments => le titre en dernier
        Si 2 éléments => le titre ou le livre en dernier

COMMENT SONT-ELLES-TRAITÉES ENSUITE ?

PAR HTML

    <a href="page/#{page_id}/show?in=cnarration>"

PAR LATEX

    Il faudrait placer un \label{<label>}
    Et dans le texte un \ref{<label>}

    Ce label serait construit à partir de :

    LAB<file_id.rjust(4)><livre_id>[<ancre>]
