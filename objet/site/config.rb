# encoding: UTF-8
=begin

Pour ajouter des options, les ajouter aussi au fichier :
    ./lib/deep/deeper/required/Site/config.rb

On peut tester une valeur simplement par :

    site.<propriété>

=end

HOME = "/Users/philippeperret"

# Désignation officielle du site, par exemple pour les
# factures ou autre mail officiel
site.official_designation = "La Boite à Outils de l'Auteur" # "Writer's Toolbox"
site.name                 = "La Boite à Outils de l'Auteur"
# Pour donner un nom différent dans la balise <title>
# Si non défini, c'est la valeur de site.name qui sera prise
# et PASSÉE EN CAPITALES
# site.title = "LA BOITE À OUTILS DE L'AUTEUR"

# Pour composer la balise TITLE de la page
# Le title_prefix servira pour toutes les autres pages de l'accueil
# Dans les vues, utiliser `page.title = <valeur>` pour définir ce
# qui doit suivre ce préfixe
site.title_prefix     = "BOA"
site.title_separator  = " | "
TINY_CAR = '<span style="font-size:9.1pt;color:#97c0c8">%s</span>'
site.logo_title = "#{TINY_CAR % 'LA'} BOITE #{TINY_CAR % 'À'} OUTILS #{TINY_CAR % 'DE L’'}AUTEUR".in_span(style:'color:#97c0c8')

# Le mail pour le paramètre `:to` de l'envoi de mail notamment, ou
# pour écrire les infos à propos du site
site.mail                 = "phil@laboiteaoutilsdelauteur.fr"
site.mail_before_subject  = "La Boite à Outils de l'Auteur — "
site.mail_signature       = "<p>#{site.name}</p>"

# Host local
site.local_host   = 'localhost/WriterToolbox'
site.distant_host = 'www.laboiteaoutilsdelauteur.fr'

site.tarif = 6.90

# Compte Facebook
# ---------------
# Un lien sera ajouté automatiquement à la signature
# des mails si le compte est défini.
site.facebook = 'laboiteaoutilsdelauteur'

# Compte Twitter
# --------------
# Un lien sera ajouté automatiquement à la signature
# des mails si le compte est défini.
site.twitter = 'b_outils_auteur'

# # Si on est en anglais :
# site.separateur_decimal = "."
# site.devise = "$"

# Définition propre des bits options de l'utilisateur
# Cf. RefBook > User > Options.md
site.user_options = {
  analyse:  [17, '@analyste_level']
}

# Soit :textmate, soit :atom, l'éditeur à utiliser
# quand on a recours à `lien.edit_file <path>`
site.default_editor = :atom
# Application (nom) qui doit ouvrir les documents Markdown
# à l'édition.
# Note : Il faut que cette application existe, dans le cas
# contraire, c'est l'application par défaut de l'ordinateur
# qui serait utilisée.
site.markdown_application = "TextMate" # "Mou"

site.serveur_ssh = "boite-a-outils@ssh-boite-a-outils.alwaysdata.net"

# ---------------------------------------------------------------------
# ADMINISTRATION

# Si cette option est true, une pastille en haut à droite de la
# page indiquera aux administrateurs les tâches qu'ils sont à
# accomplir.
# Cette pastille est insérée dans la page :
#   ./view/gabarit/header.erb
site.display_taches_for_administrator = true

# Si cette option est true, une pastille en haut à droite de
# la page indiquera à l'user les tâches qu'il a à accomplir
# si l'application le nécessite et le gère.
site.display_taches_for_user = true

# Détermine les alertes administration lors du login d'un
# utilisateur. Les valeurs peuvent être :
# :never / :jamais        Aucune alerte n'est donnée.
# :now / :tout_de_suite   Alerte immédiate : dès que l'user se
#                         connecte au site, l'administion est avertie
# :one_an_hour / :une_par_heure
# :twice_a_day / :deux_par_jour
#     Deux résumés par jour, à midi et à minuit
# :one_a_day / :une_par_jour
#     Résumé quotidien des connexions de la journée
# :one_a_week / :une_par_semaine
#     Résumé hebdomadaire des connexions de la semaine
# :one_a_month / :une_par_mois
#     Résumé mensuel des connexions du mois
site.alert_apres_login = :twice_a_day

# ---------------------------------------------------------------------
# TESTS
# Chemin d'accès au binaire `rpsec` pour lancer les tests
# façon console. Pour l'obtenir, taper `which rspec` dans le
# Terminal.
site.rspec_command = File.join(HOME, '.rvm/rubies/ruby-2.0.0-p643/bin/rspec')
