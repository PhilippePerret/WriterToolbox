# encoding: utf-8
=begin

  Le présent module est composé dans le but de faire un
  cron-job qui fonctionne en local plutôt qu'en online 
  suite aux problèmes qui se sont posés pour la librairie
   mysql2.

  Il est appelé toutes les heures lorsque l'ordinateur est
  allumé.

  TODO
    Il pourra même être utilisé pour déposer en online des
    fichiers de données qui permettront au cron online de
    fonctionner sans les bases de données

=end
APP_FOLDER = File.expand_path(File.dirname File.dirname(__FILE__))

require 'singleton'
class LocCron
  include Singleton


  # Extension de LocCron pour écrire les messages
  #
  # Note : l'idée, contrairement à ce qui était fait avant,
  # est de charger les librairies petit à petit à mesure
  # qu'on doit faire les jobs. Cela empêche de tout bloquer
  # dès le départ.
  #
  require_relative 'lib/required/log'

  # Initialisation
  #
  # Rappel : on se trouve à la racine de l'application, donc
  # on peut faire comme si on était sur le site.
  def init
    log "\n\n\n==== CRON JOB DU #{Time.now} ====\n\n"

    # On requiert toutes les librairies du site
    # Si le moindre problème survient, on ne poursuit
    # pas
    require './lib/required'

    # On requiert toutes les librairies de ce cron
    # local
    Dir["#{APP_FOLDER}/CRON_LOCAL/lib/required/**/*.rb"].each{|m| require m}

  rescue Exception => e
    log "ERREUR FATALE EN CHARGEANT LES LIBRAIRIES", e
    false
  else
    true # pour procéder aux jobs
  end


  def run
    # On se place dans le dossier de l'application
    begin
      # ---------------------------------------------------------------------
      #   PRÉAMBULE
      # ---------------------------------------------------------------------
      log "root : #{File.expand_path('.')}"

      # ---------------------------------------------------------------------
      #   CRON JOBS
      # ---------------------------------------------------------------------

      # UN AN UN SCRIPT
      # ===============
      # C'est l'urgence absolue, pour que les auteurs du programme
      # reçoivent toujours leur rapport quotidien, même s'il y a
      # un problème sur le site.
      run_job 'un_an_un_script'

      # CONNEXIONS
      # ==========
      # TODO Ce module n'est pas encore implémenté
      # L'analyse des connexions qui se sont produites depuis le
      # dernier rapport, pour voir ce que font les moteurs de
      # recherche et ce que font les visiteurs normaux.
      run_job 'connexions'

      # TWEETS ET CITATIONS
      # ===================
      # Module qui s'occupe d'envoyer les tweets permanents ou les citations
      # en fonction de l'heure qu'il est.
      run_job 'tweets_et_citations'

      # ---------------------------------------------------------------------
      #   FINAL
      # ---------------------------------------------------------------------

      # On finit par envoyer le rapport à l'administrateur
      run_job 'rapport_final'

    rescue Exception => e
      log "ERREUR MAJEURE dans LocCron.run", e
    end
  end

  # ---------------------------------------------------------------------
  # Exécuter un job
  # ---------------------------------------------------------------------
  #
  # Un "job" est un fichier se trouvant dans ./lib/job qui
  # charge une extension de LocCron qui définit la méthode de
  # même nom que le fichier lui-même et qui est appelée pour
  # exécuter le job.
  #
  def run_job job_name
    path_as_folder  = "#{APP_FOLDER}/CRON_LOCAL/lib/job/#{job_name}"
    path_as_file    = "#{path_as_folder}.rb"
    if File.exist?(path_as_file)
      log "    Chargement du job `#{job_name}` en tant que SIMPLE FICHIER", :info
      require_relative "lib/job/#{job_name}"
    elsif File.exist?(path_as_folder)
      log "    Chargement du job `#{job_name}` en tant que DOSSIER", :info
      Dir["#{path_as_folder}/**/*.rb"].each do |m|
        log "chargement du module #{m}", :info
        require m
      end
    else
      raise "Impossible de trouver le fichier ou le dossier #{path_as_folder}(.rb). Je dois renoncer à exécuter ce job."
    end
    send(job_name.to_sym)
  rescue Exception => e
    log "PROBLÈME EN JOUANT LE JOB : #{job_name}", e
  end



end #/LocCron

def locron
  @locron ||= LocCron.instance
end

# Initialisation et lancement du programme
#
# S'il se produit la moindre erreur à l'initialisation (qui, notamment,
# charge toutes les librairies du site), on ne procède pas aux jobs
Dir.chdir(APP_FOLDER) do
  locron.init && locron.run
end
