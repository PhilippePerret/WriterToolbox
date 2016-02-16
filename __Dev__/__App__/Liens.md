# Liens

Les liens propres sont définis dans ./lib/app/handy/liens.

* [Lien pour un film](#lienversunfilm)
<a name='lienversunfilm'></a>

## Lien pour un film

    lien.film(<film id | film film_id>)

Par exemple :

    lien.film('DancerInTheDark2001')

    lien.film(12)

> Note : Comme pour tous les liens, on peut ajouter un second argument pour les attributs.

> Note : Le lien retourné a la classe `film` et le titre est mis dans un `span.film` pour pouvoir être mis en petites capitales.

* [Lien pour un mot du Scénodico](#lienpourunmot)
<a name='lienpourunmot'></a>

## Lien pour un mot du Scénodico

    lien.mot(<mot id>, <mot>)

Par exemple

    lien.mot(12, "le mot au pluriel")

> Note : Comme pour tous les liens, on peut ajouter un troisième argument pour les attributs.

> Note : La class du lien retourné est `mot`
