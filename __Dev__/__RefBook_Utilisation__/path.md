# Chemin d'accès

Une méthode pratique, qui fonctionne comme `require_relative` mais en renvoyant le path :

    Soit le fichier :
      ./dans/mon/dossier/le_fichier.rb
    Soit un autre fichier :
      ./dans/mon/dossier/autre_fichier.erb

    Dans le premier fichier :

      _("autre_fichier.erb")

    retournera :

      "./dans/mon/dossier/autre_fichier.erb"
