# encoding: UTF-8
=begin

  On atteint ce module après qu'on a rempli son formulaire d'inscription
  au programme UN AN UN SCRIPT.
  Noter qu'on ne passe pas là QUE lorsque l'on n'est pas encore inscrit
  sur le site et qu'il faut donc faire une inscription complète.

=end
debug "Je passe par le module unan/create.rb"
require './objet/user/create.rb'
User.create
  # La méthode create gère entièrement le fait que l'user
  # s'inscrit au programme et le renvoie donc vers une
  # page de paiement adaptée.
