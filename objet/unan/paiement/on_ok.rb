# encoding: UTF-8
=begin
  Ici, pour le moment, j'ai un bug : On peut apparemment atteindre
  cette page directement sans passer par PayPal…
=end

# On peut créer le programme (son dossier data et sa base de données)
# Ainsi qu'un projet Unan::Projet
(Unan::folder_modules + 'signup_user.rb').require
user.signup_program_uaus
