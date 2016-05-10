# Gestion des images

* [Insertion d'une image](#insertionimage)
  * [Titre Alt de l'image](#titrealtdimage)
  * [Image sur toute la largeur de la page](#imagesurtoutelargeur)
  * [Image flottante](#imageflottante)
  * [Image en ligne (inline)](#imageenligne)
  * [Définir la légende de l'image](#definirlegendedimage)


<a name='insertionimage'></a>

## Insertion d'une image

Pour insérer une image dans un texte, utiliser :

        IMAGE[path/to/image]

On peut définir un titre ou un positionnement :

<a name='titrealtdimage'></a>

### Titre Alt de l'image

        IMAGE[path/image.ext|titre alt]

<a name='imagesurtoutelargeur'></a>

### Image sur toute la largeur de la page


        IMAGE[path/image.ext|plain]
        # => Prendra toutes la largueur

<a name='imageflottante'></a>

### Image flottante

Utiliser les paramètres `fleft` ou `fright` pour faire flotter respectivement à gauche et à droite.

        IMAGE[path/image.ext|fright]
        # => flottante à droite

        IMAGE[path/image.ext|fleft]
        # => Flottante à gauche

<a name='imageenligne'></a>

### Image en ligne (inline)

Si une image doit faire partie du texte, par exemple (comme les touches de clavier dans un manuel), il faut utiliser `inline` en deuxième paramètre :

        IMAGE[path/image.ext|inline]
        # => en ligne

<a name='definirlegendedimage'></a>

### Définir la légende de l'image

Il suffit de définir le troisième paramètre de IMAGE :

        IMAGE[path/image.ext|plain|Légende de l'image]
