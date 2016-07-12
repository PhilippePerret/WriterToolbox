# encoding: UTF-8
#
# Module pour faire des tâches sur le site local
#
#
require 'fileutils'
require 'singleton'

THIS_FOLDER = File.dirname(File.expand_path(__FILE__))
APP_FOLDER = File.dirname(THIS_FOLDER)

class LCron
    include Singleton

    # = main =
    #
    # Méthode principale qui exécute le cron local
    #
    # Ce cron s'occupe principalement de tâches de nettoyage
    #
    def run

        nettoyage_mails

        nettoyage_rapports_synchro

    end

    # -------------------------------------------------------------------
    # Méthode pour les mails
    # -------------------------------------------------------------------
    # Méthode qui nettoie le mails du dossier temporaire.
    #
    # Ces mails sont générés soit par les tests soit par des
    # procédures qui sont essayées localement, sans forcer
    # l'envoi des mails.
    def nettoyage_mails
        File.exist?(folder_tmp_mails) || return
        FileUtils.rm_rf folder_tmp_mails
    end
    def folder_tmp_mails
        @folder_tmp_mail ||= "#{APP_FOLDER}/tmp/mails"
    end

    # ---------------------------------------------------------
    # Méthode pour la synchro
    # --------------------------------------------------------

    # Pour supprimer les rapports de synchronisation qui 
    # s'entassent dans le dossier
    #
    # Attention, il ne faut pas le supprimer complètement, car
    # il contient aussi le fichier ajax.rb qui permet de procéder
    # à la synchronisation.
    # Il faut également éviter de supprimer les fichiers qui datent
    # de moins d'une heure, car ils sont peut-être en cours de
    # traitement.
    def nettoyage_rapports_synchro
        Dir["#{folder_rapports_synchro}/*.html"].each do |path|
            name = File.basename(path, File.extname(path))
            date = name.split('_').last
            ddate = date.split('-').collect{|e| e.to_i}
            annee, mois, jour, heures, minutes = ddate
            time_file = Time.new(annee, mois, jour, heures, minutes)
            next if time_file > Time.now - 3600
            # Sinon, on détruit le fichier
            File.unlink path
        end
    end
    def folder_rapports_synchro
        @folder_rapports_synchro ||= "#{APP_FOLDER}/lib/deep/deeper/module/synchronisation/synchronisation/output"
    end #/Cron
end # /LCron

def lcron
    @lcron ||= LCron.instance
end

lcron.run
