# SSH

* [Obtenir le serveur SSH BOA](#obtenirserveurssh)
* [Serveur SSH](#serveurssh)
* [Require des gems propres](#requiregempropre)

<a name='obtenirserveurssh'></a>

## Obtenir le serveur SSH BOA

Ce code est à insérer là où on en a besoin pour obtenir le serveur SSH

        # Adresse du serveur SSH sous la forme "<user>@<adresse ssh>"
        # Note : Défini dans './objet/site/data_synchro.rb'
        def serveur_ssh
        @serveur_ssh ||= begin
        require './objet/site/data_synchro.rb'
        Synchro.new.serveur_ssh
        end
        end

<a name='serveurssh'></a>

## Serveur SSH

Noter que pour l'activer dans le terminal, un raccourci a été créé (dans `~/.ssh/config`) donc il suffit de faire :

    ssh serveur_boa

Serveur :

    ssh-boite-a-outils.alwaysdata.net

User :

    boite-a-outil

Complète :

    boite-a-outils@ssh-boite-a-outils.alwaysdata.net

<a name='requiregempropre'></a>

## Require des gems propres

Peut-être OBSOLÈTE depuis que je charge vraiment les gems.

Pour utiliser `require 'sqlite3'` dans un code SSH ruby ou tout autre appel d'un gem, il faut impérativement utiliser, malheureusement :

    $: << '/home/boite-a-outils/.gems/gems/sqlite3-1.3.10/lib'
    require 'sqlite3'
