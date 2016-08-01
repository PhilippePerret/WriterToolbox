# encoding: UTF-8

VERBOSE = false

# Pour tester le programme, limiter le nombre de routes
# testées
# Mettre à NIL pour les tester toutes.
NOMBRE_MAX_ROUTES_TESTED = nil

# Format de sortie
# ----------------
# Peut être :
#   :html     Un fichier HTML produit, le plus pratique, avec
#             les styles et les liens permettant d'ouvrir les
#             routes et autres
#
REPORT_FORMAT = :html

# Browser avec lequel il faut ouvrir le rapport
#
# Noter qu'il vaut mieux un browser où l'user n'est pas
# identifié, car certaines erreurs viennent de là
#
# Browser possible :
#  'Opera', 'Firefox', 'Safari', 'Google Chrome'
BROWSER_APP = 'Opera'

# Pour tester onlin ou offline
TEST_ONLINE = false # false => test local

# Mettre à TRUE pour que la boucle s'interrompe à la première
# erreur rencontrée
FAIL_FAST = true

# Profondeur maximale
#
# Mettre à nil pour traiter toutes les profondeurs, donc absolument
# tous les liens.
#
# Si la profondeur est de 1, seuls les liens de la page définie
# par ROUTE_START (cf. ci-desous) seront traités.
DEPTH_MAX = 1

# Mettre à TRUE pour voir les routes collectées sur chaque page au
# fil de l'analyse
SHOW_ROUTES_ON_TESTING = false

# Route de démarrage du test
#
# Par défaut, c'est 'site/home'
#
# Pour essayer une unique route, par exemple une route qui pose problème
# Mais penser qu'il faut indiquer ici la route de la page qui contient
# le lien qui pose problème, pas le lien lui-même.
# Par exemple, en créant ce test, la route http://www.laboiteaoutilsdelauteur.fr
# posait problème — oui, je sais, un comble — mais c'est la page
# scenodico/251/show qui la contenait, donc c'est elle qu'il fallait que
# je mette en seule page à tester
# Régler aussi NOMBRE_MAX_ROUTES_TESTED ci-dessus pour limiter le test, mais
# penser à laisser un nombre assez grand pour comprendre la route à tester à
# l'intérieur de la page s'il y en a beaucoup avant.
ROUTE_START = 'site/updates'
