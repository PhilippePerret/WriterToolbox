# Options pour les Users

* [Options RestSite et options Application](#optionsrestsiteetapp)
  * [Options pour l'application](#optionspourapplication)
* [Définir la valeur d'une option](#definirlavaleurduneoption)
  * [Valeurs possibles pour un bit d'option](#valeurspossiblepourunbitdoption)
* [Récupérer la valeur d'une option](#connaitrelavaleurduneoptions)

Les options sont une propriété de la base de données qui peut, a priori, contenir 32 caractères, qu'on appelle les bits de 0 à 31.

<a name='optionsrestsiteetapp'></a>

## Options RestSite et options Application

Les bits de 0 à 15 sont réservés à RestSite. Les bits de 16 à 31 sont utilisables par l'application.

Les bits de 0 à 15, utilisés par RestSite, servent par exemple à connaitre le grade forum de l'user, à savoir s'il a confirmé son mail, etc.

Les bits de l'application sont dépendants de l'application. Pour la boite à outils de l'auteur, le bit 17, par exemple, est réservé pour les analyses et permet de savoir si l'utilisateur est analyste, simple analyste ou analyste confirmé.

<a name='optionspourapplication'></a>

### Options pour l'application

Comme nous l'avons dit [ci-dessus](#optionsrestsiteetapp), ce sont les "bits" de 15 à 31 qui sont réservés à l'application RestSite courante. Il est important de bien documenter ces options afin de ne pas les utiliser deux fois pour deux spécifications différentes.

Pour ce faire, le mieux est d'utiliser le fichier `./objet/site/config.rb` et de définir la variable de configuration `user_options` :

    # Dans ./objet/site/config.rb :
    site.user_options = {
      <clé mnémotechnique> => [<index>, <nom variable d'instance>]
    }

Si par exemple il s'agit du 18e caractère d'options (donc index 17) et qu'il doit définir la variable d'instance `@analyste_level` de l'utilisateur, on indique :

    # Dans ./objet/site/config.rb :
    site.user_options = {
      :analyste => [17, "@analyste_level"]
    }

Noter que le format en Array reprend la définition fait dans la méthode `option_index_and_inst_name` dans le fichier `./lib/deep/deeper/required/User/inst_options.rb` qui va utiliser cette définition de configuration.

<a name='definirlavaleurduneoption'></a>

## Définir la valeur d'une option

Pour définir la valeur d'une option, il suffit d'utiliser la méthode :

    User#set_option(<index>, <valeur>)

Se rappeler que `<valeur>` ne peut être qu'un caractère (mais dans n'importe quelle base, donc on peut même avoir de l'hexadécimal avec des lettres)

<a name='valeurspossiblepourunbitdoption'></a>

### Valeurs possibles pour un bit d'option

Un bit d'option doit tenir en 1 caractère et peut donc avoir pour valeur, puisqu'on utilise la méthode `to_s(<base>)` de ruby avec la base la plus grande possible dans cette méthode, i.e. la base 36, un nombre de 0 à 35.

`0` vaudra 0, `35` vaudra la lettre 'z'.

> Noter que c'est transparent que c'est toujours un nombre décimal qui sera retourné par [la méthode `get_option` ci-dessous](#connaitrelavaleurduneoptions).

Cela permet d'avoir une certaine souplesse pour utiliser les flags par bit sur ces valeurs-caractère d'option. On peut utiliser jusqu'à 5 bits de façon complète :

     Nombre     Valeur bit      Valeurs
     bits       supplément.    décimales
    ---------------------------------------
     1 bit        BIT_UN          0 à 1       
     2 bits     + BIT_DEUX        0 à 3
     3 bits     + BIT_QUATRE      0 à 7
     4 bits     + BIT_HUIT        0 à 15
     5 bits     + BIT_SEIZE       0 à 32

Donc on peut, sur un seul caractère, tester 5 choses d'une seule options de l'user. Si l'on ramène cela aux 16 caractères-bits que peut utiliser l'application, on arrive à 16 * 5 = 80 flag-tests possible pour l'utilisateur, ce qui semble largement suffisant, d'autant qu'on peut très bien, aussi, utiliser des valeurs décimales :

Par exemple, si c'est une "ascension" qu'on doit mémoriser, cette ascension peut se suivre sur un bit pour 35 "marches" (steps) sur un seul caractère.

<a name='connaitrelavaleurduneoptions'></a>

## Récupérer la valeur d'une option

Pour récupérer la valeur d'une option, on utilise la méthode :

    valeur = User#get_option(<index>)

**Noter que la `valeur` sera toujours de `0` si l'option n'est pas définie.**
