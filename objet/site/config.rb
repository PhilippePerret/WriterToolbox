# encoding: UTF-8

# Désignation officielle du site, par exemple pour les
# factures ou autre mail officiel
site.official_designation = "La Boite à Outils de l'Auteur" # "Writer's Toolbox"
site.name                 = "La Boite à Outils de l'Auteur"

# Pour composer la balise TITLE de la page
# Le title_prefix servira pour toutes les autres pages de l'accueil
# Dans les vues, utiliser `page.title = <valeur>` pour définir ce
# qui doit suivre ce préfixe
site.title_prefix     = "BOA"
site.title_separator  = " | "

# Le mail pour le paramètre `:to` de l'envoi de mail notamment, ou
# pour écrire les infos à propos du site
site.mail                 = "phil@atelier-icare.net"
site.mail_before_subject  = "La Boite à Outils de l'Auteur — "
site.mail_signature       = "<p>#{site.name}</p>"

# Host local
site.local_host   = 'localhost/WriterToolbox'
site.distant_host = 'www.atelier-icare.net/writertoolbox'

site.tarif = 6.90

# # Si on est en anglais :
# site.separateur_decimal = "."
# site.devise = "$"

# Définition propre des bits options de l'utilisateur
# Cf. RefBook > User > Options.md
site.user_options = {
  analyse:  [17, '@analyste_level']
}
