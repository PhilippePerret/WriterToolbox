# coding: utf-8
class LocCron

  # Méthode principale traitant les connexions au site
  #
  # Noter, pour rappel, que la gestion des erreurs se fait
  # dans le module principal et qu'il n'y a donc pas de
  # raisons de le faire ici. C'est même déconseillé si on
  # veut un retour conforme et homogène.
  def connexions
    log "* Traitement des connexions au site"
    # C'est dans ce fichier qu'on traite les connexions qui ont eu lieu depuis
    # le dernier traitement des connexions
    # On se sert pour ça
    ireport = CReport.new
    if ireport.produit_rapport
      log "  = Rapport produit"
    else
      log "  = Rapport non produit (pas l'heure)"
    end


    log "  = /fin traitement des connexions au site"
  end


  # ---------------------------------------------------------------------
  #   Class LocCron::CReport
  #   Pour le rapport de Connexions (le "C" est pour "Connexions")
  # ---------------------------------------------------------------------
  class CReport


  end

end #/LocCron
