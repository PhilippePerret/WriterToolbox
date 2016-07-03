# encoding: UTF-8

class LocCron
  class CReport # pour "Connexions Report"

    # Fréquence du rapport de connexions. Le nombre indique toutes les
    # combien d'heures il faut envoyer le rapport. Par exemple, la
    # valeur 6 signifie : envoyer le rapport toutes les 6 heures.
    FREQUENCE_RAPPORT_CONNEXION = 6

    def initialize
      # Pour le moment, rien à faire

    end

    # = main =
    #
    # Méthode principale qui produit le rapport de connexion si
    # c'est nécessaire.
    def produit_rapport
      rapport_needed? || (return false)
      build_report
      true
    end

    # ------------------------------------------------------------
    # Méthodes de construction du rapport
    # ------------------------------------------------------------
    def build_report
      # TODO Construire le rapport
    end

    # RETURN true si le rapport doit être fait. Dépend de la constante
    # citué en haut de ce fichier et de l'heure courante
    def rapport_needed?
      Time.now.hour % FREQUENCE_RAPPORT_CONNEXION == 0
    end

    # ------------------------------------------------------------
    # Raccourcis
    # ------------------------------------------------------------
    def log mess, error = nil
      locron.log mess, error
    end

  end #/CReport
end #/LocCron
