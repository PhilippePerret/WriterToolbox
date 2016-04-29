# encoding: UTF-8
=begin

Pour définir le coup de projecteur sur la page d'accueil.

Il suffit de :

  * Définir les données ci-dessous (en local)
  * S'assurer du bon aspect (en local)
  * Uploader ce seul fichier sur le site distant

La page d'accueil sera automatiquement actualisée.

=end
class SiteHtml
  # POUR DÉFINIR LE COUP DE PROJECTEUR COURANT
  # SPOTLIGHT = {
  #   href:     "analyse/31/show",
  #   title:    "COLLISION",
  #   before:   "Dernière analyse de film : ",
  #   after:    ""
  # }
  SPOTLIGHT = {
    href:     "page/246/show?in=cnarration",
    title:    "Objectif et enjeu",
    before:   "Nouvelle page de cours<br>",
    after:    ""
  }

end
