# encoding: UTF-8

debug "-> unan/user/paiement/on_ok.rb"

# On peut créer l'utilisateur (son dossier data et sa base de données)
# TODO Lui envoyer aussi un mail explicatif pour le programme et
# son inscription.
user.create_for_unan


debug "<- unan/user/paiement/on_ok.rb"
