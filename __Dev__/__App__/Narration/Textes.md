# Les textes

* [Textes seulement en version en ligne](#texteseulementenonline)
* [Limite de l'extrait de page pour non abonné](#limitedelextraitpournonabonneds)


<a name='texteseulementenonline'></a>

## Textes seulement en version en ligne

On peut indiquer des textes à ne pas afficher dans la version papier (donc LaTex) de la collection en les mettant entre balises :

    <webonly>
      Texte qui ne sera pas exporté en LaTex et donc pas imprimé.
    </webonly>

<a name='limitedelextraitpournonabonneds'></a>

## Limite de l'extrait de page pour non abonné

Par défaut, un non abonné ne peut lire qu'un tiers d'une page de la collection. Mais on peut aussi spécifier l'endroit exact de la fin de l'extrait en plaçant la balise suivante à l'endroit voulu :

    <!-- FIN EXTRAIT -->
