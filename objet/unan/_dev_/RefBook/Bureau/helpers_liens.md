# Helpers de liens pour le bureau

* [Liens vers les panneaux principaux](#liensverslespanneauxprincipaux)
<a name='liensverslespanneauxprincipaux'></a>

## Liens vers les panneaux principaux

Utiliser ces liens pour rejoindre les panneaux principaux du bureau :

    <%= bureau.lien_etat %>         # L'état des lieux
    <%= bureau.lien_travail %>      # Vers le travail à faire
    <%= bureau.lien_quiz %>         # Vers les questionnaires, checklist, etc.
    <%= bureau.lien_messages %>     # Vers les messages forum
    <%= bureau.lien_pages_cours %>  # Vers les pages de cours à lire

On peut ajouter en **premier argument** le titre à donner au lien :

    <%= bureau.lien_travail "votre travail du jour" %>

On peut définir en **second argument** les options à utiliser, c'est-à-dire les attributs à ajouter à la balise :

    <%= bureau.lien_travail nil, {target: '_new', class:'monlienspecial'} %>

Note : Ces liens sont définis dans le fichier `./objet/unan/lib/required/Bureau/helper.rb`
