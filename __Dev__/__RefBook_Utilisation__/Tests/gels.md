# Gels

* [Obtenir la liste des gels (en console)](#obtenirlalistedesgels)
* [Procéder à un gel ou un dégel par la console](#procederaungeloudegelconsole)

OBSOLÈTE : ON N'UTILISE PLUS LES GELS DEPUIS LE PASSAGE À MYSQL.
IL FAUT TROUVER LE MOYEN DE FONCTIONNER AUTREMENT, PEUT-ÊTRE EN CRÉANT D'AUTRES BASES ET D'AUTRES TABLES SPÉCIALEMENT POUR LES TESTS.

Pour effectuer des tests, on peut utiliser les gels.

Un “gel” est comme une photographie du site, qui permet de revenir dans un état précédent ou précis sans problème.

Dans les tests, il faut charger le module 'gel' à l'aide des codes :

    site.require_module 'gel'

Et requérir un gel par :

    Gel::gel( 'nom-du-gel', options )
    Gel::degel( 'nom-du-gel', options )


<a name='obtenirlalistedesgels'></a>

## Obtenir la liste des gels (en console)

Utiliser en console le code :

    list gels

<a name='procederaungeloudegelconsole'></a>

## Procéder à un gel ou un dégel par la console

Les gels se font et se défont à l'aide de la console à l'aide des codes :

    gel 'nom-du-gel'

    degel 'nom-du-gel'


S'il y a des options, il faut utiliser la tournure de code complète :

    site.require_module('gel');Gel::gel('gel-name', {options})
