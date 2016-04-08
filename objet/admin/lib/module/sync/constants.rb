# encoding: UTF-8
class Sync


  # Données des fichiers dont il faut tester la synchro
  #
  # La clé peut être choisie comme on veut, aucun convention.
  # Cette clé servira à nommer la case à cocher :cb_synchronize_analyses
  # qui permettra de tester s'il faut synchroniser la base en question et
  # appeler la méthode particulière dans ./objet/admin/lib/module/sync/3_synchro.rb
  # 
  # Note : Pour fpath, ne pas se servir de données du site (site.folder_database
  # ou autre) car cette constante est utilisée aussi en online sans charger
  # aucun autre fichier (ou presque).
  # D'autre part, ne pas mettre seulement un path relatif dans database/data,
  # car prévoir qu'il pourra y avoir d'autres fichiers à checker.
  FILES2SYNC = {
    # Systémique (RestSite)
    taches: {
      hname: "Table des tâches",
      fpath: "./database/data/site_hot.db",
      icare: false
      },
    # Application
    narration: {
      hname: "Database Narration",
      fpath:  "./database/data/cnarration.db",
      icare: false # true
      },
    scenodico:  {
      hname:  "Scénodico",
      fpath:  "./database/data/scenodico.db",
      icare:  true
      },
    filmodico:  {
      hname: "Filmodico",
      fpath:  "./database/data/filmodico.db",
      icare:  true
      },
    analyses: {
      hname:  "Analyses de film",
      fpath:  "./database/data/analyse.db",
      icare:  false
    }
  }


end
