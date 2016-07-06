# encoding: UTF-8
#
# Module principal pour le cron jog de niveau 2
# Il est inspiré du cron job 1 et surtout de celui que j'ai refait
# en local pour gérer le problème de mysql2 qui n'était pas connu.
#
require 'singleton'

THIS_FOLDER = File.expand_path(File.dirname(__FILE__))
APP_FOLDER  = File.dirname(THIS_FOLDER)

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
      true
  end


  # = main =
  #
  # Méthode principale qui joue tous les crons à accomplir, même
  # le rapport final à envoyer à l'administrateur.
  #
  def run
      log "*** CRON2.run ***"

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
  def run_procedure proc_name

      proc_path = File.join(THIS_FOLDER, 'lib', 'procedure', "#{proc_name}.rb")
      File.exist?(proc_path) || raise("La procédure #{proc_path} n'existe pas...")
      require proc_path
      self.respond_to?(proc_name.to_sym) || raise("La procédure #{proc_name} devrait définir la méthode de même nom.")

      Dir.chdir(APP_FOLDER) do 
        self.send(proc_name.to_sym)
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
cronjob.init && cronjob.run

