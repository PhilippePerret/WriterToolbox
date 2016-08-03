# encoding: UTF-8
#
# Module principal pour le cron jog de niveau 2
# Il est inspiré du cron job 1 et surtout de celui que j'ai refait
# en local pour gérer le problème de mysql2 qui n'était pas connu.
#
require 'singleton'

THIS_FOLDER = File.expand_path(File.dirname(__FILE__))
APP_FOLDER = FOLDER_APP = File.dirname(THIS_FOLDER)

class CRON2
  include Singleton
  def init
    # Initialisation du cronjob
    # On charge les librairies utiles. Noter que contrairement à l'ancien
    # cronjob, ici, on ne charge que le minimum et c'est chaque procédure
    # qui chargement automatiquement ce dont elle aura besoin. De cette
    # façon on évitera tous les problèmes.

    # La toute première libraire qu'il faut charger, pour pouvoir écrire
    # les messages de log.
    require "#{THIS_FOLDER}/lib/required/log.rb"
    Dir["#{THIS_FOLDER}/lib/required/**/*.rb"].each{|m| require m}
    true
  end


  # = main =
  #
  # Méthode principale qui joue tous les crons à accomplir, même
  # le rapport final à envoyer à l'administrateur.
  #
  def run
    log "*** CRON2.run ***"

    # On essaie de charger toutes les librairies du site pour
    # bénéficier de tous les outils.
    # Noter que cette procédure est assez spéciale puisque si
    # elle échoue, on interromp le programme
    run_procedure('require_all_site') || return

    # On traite le programme UN AN à commencer le
    # changement de jour des auteurs qui doivent passer au
    # jour suivant.
    run_procedure 'un_an_un_script'

    # Traitement des connexions qui ont eu lieu depuis le
    # dernier rapport. La fréquence d'envoi dépend d'une
    # constante définie dans le module stats_connexions.rb
    run_procedure 'stats_connexions'

    # Envoi d'un tweet permanent ou des citations suivant
    # l'heure et suivant les préférences définies par le
    # fichier tweets_et_citations/main.rb
    run_procedure 'tweets_et_citations'

    # Envoyer à tous les inscrits qui le souhaient un
    # mail précisant les dernières actualisations de la
    # boite, avec des liens qui permettent de s'y
    # rendre aussitôt.
    run_procedure 'mailing_updates'

    # Pour procéder au nettoyage du site, pour empêcher
    # les éléments de s'accumuler
    run_procedure 'nettoyage_site'

    # POur procéder à l'analyse de toutes les pages et de
    # tous les liens du site (gros travail)
    run_procedure 'links_analyzer'

    # On envoie finalement le rapport à l'administrateur, mais
    # seulement s'il le veut ou si c'est nécessaire suite à
    # des erreurs.
    run_procedure 'send_mail_admin'

    log "=== CRON2.run exécuté avec succès ==="
  rescue Exception => e
    log "Problème au cours du CRON2.run", e
    false
  else
    true
  end


  # = main =
  #
  # Lancement d'une procédure quelconque. Le nom de la procédure
  # doit être employé pour :
  # - le nom du fichier dans ./lib/procedure
  # - le nom de la méthode dans ce fichier
  #
  # La procédure doit renvoyer trois valeurs, NIL, FALSE ou TRUE qui définissent
  # trois comportements différents :
  #   NIL : La procédure n'a pas été exécutée, pour des raisons normales
  #         par exemple parce qu'il n'était pas l'heure.
  #   TRUE  La procédure a été exécutée avec succès.
  #   FALSE Un problème est survenu, qui a dû être signalé par la procédure, ou
  #         c'est cette méthode qui le prend en charge.
  def run_procedure proc_name
    putslog "  --> #{proc_name}"
    retour_procedure = nil
    Dir.chdir(APP_FOLDER) do
      proc_folder_path = File.join(THIS_FOLDER, 'lib', 'procedure', "#{proc_name}")
      proc_path = "#{proc_folder_path}.rb"
      if File.exist? proc_folder_path
        Dir["#{proc_folder_path}/**/*.rb"].each{|m| require m}
      elsif File.exist? proc_path
        require proc_path
      else
        raise "Impossible de trouver la procédure #{proc_name}, ni en fichier ni en dossier…"
      end
      self.respond_to?(proc_name.to_sym) || raise("La procédure #{proc_name} devrait définir la méthode de même nom.")

      log " ** Lancement de la procédure #{proc_name}..."
      retour_procedure = self.send(proc_name.to_sym)
    end # / change dir
    if retour_procedure === true
      log " == Procédure #{proc_name} exécutée avec succès."
    elsif retour_procedure === nil
      # La procédure n'a pas été exécutée, pour une raison normale,
      # par exemple il n'était pas l'heure de le faire.
      log " -- #{proc_name} n'a pas eu besoin d'être jouée."
    end
  rescue Exception => e
    log "Problème avec la procédure #{proc_name}", e
    false
  else
    true
  end
end #/CRON2

def cronjob
  @cronjob ||= CRON2.instance
end

# Au chargement, on initialise le cronjob et on le lance
cronjob.init
unless defined?(CRON_FOR_TEST) && CRON_FOR_TEST
  cronjob.run
end
