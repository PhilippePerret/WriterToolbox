# encoding: UTF-8
=begin
  Noter qu'on peut atteindre cette page par un hack (en suivant
  l'adresse paiement/on_ok?in=unan) mais de toute façon on
  n'irait pas très loin puisque la vérification du paiement
  retournerait une erreur.
=end

# On peut créer le programme (son dossier data et sa base de données)
# Ainsi qu'un projet Unan::Projet
(Unan::folder_modules + 'signup_user.rb').require
user.signup_program_uaus
