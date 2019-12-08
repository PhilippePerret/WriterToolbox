# encoding: UTF-8
#
# Mettre ONLY_REQUIRE à true dans le module appelant pour ne faire
# que requérir cette librairie, sans lancer le préambule.
#
# Méthodes qu'on peut utiliser au chargement (avant que les
# librairies de débug soient en place) pour laisser des messages
# de débug.
#
# @usage      main_safed_log <message>
#
# Il faut ensuite aller charger le fichier ./safed.log par
# FTP
Dir.chdir('..') do
  ONLY_REQUIRE = true
  require './lib/_required'
end
