# Gems


* [Dossier site des Gems](#dossierdesgems)
* [Installer un nouveau Gem](#installerunnouveaugem)
* [Installation sur le site distant](#installationsurlesitedistant)


* [Exposé du problème des Gems](#exposeduproblemedesgems)
<a name='exposeduproblemedesgems'></a>

## Exposé du problème des Gems

Le problème principal des Gems est que le dossier où s'installent les gems quand j'utilise `sudo gem install <le gem>` dans le Terminal n'est pas le même que [celui utilisé par le site](#dossierdesgems).

Donc j'ai beau charger un gem par cette commande, il ne sera pas utilisable.

J'ai résolu le problème [grâce à cette procédure](#installerunnouveaugem).

<a name='dossierdesgems'></a>

## Dossier des Gems

Quand on utilise un navigateur, le dossier des gems n'est pas le même que le dossier normal. C'est :

        /Library/Ruby/Gems/2.0.0/gems/

Plutôt que de copier le dossier d'un nouveau gem dans ce dossier, il vaut mieux utiliser la [procédure d'installation d'un nouveau gem](#installerunnouveaugem).



<a name='installerunnouveaugem'></a>

## Installer un nouveau Gem

En fait, il suffit d'envoyer la commande d'installation au site lui-même.

Donc je peux copier-coller la commande ci-dessous dans n'importe quel fichier qui sera lu au chargement de l'application, par exemple à la fin du fichier `./lib/required.rb` :

        debug `echo "<mot de passe>" | sudo -S gem install NOM_DU_GEM`

<a name='installationsurlesitedistant'></a>

## Installation sur le site distant

Pour le moment, le problème n'est pas encore résolu, mais je devrais pouvoir le faire par SSH.

Se placer à la racine si nécessaire (pas www, vraiment la racine, qui contient le dossier www — dès que j'ouvre la connexion SSH, je suis à la racine). Taper :

    > export GEM_HOME=$HOME/.gems
    > gem install <le gem>
