# encoding: UTF-8
#
# Module pour procéder au nettoyage du site
#
class CRON2
  def nettoyage_site
    @files_count = 0
    nettoyage_rapports_connexions
    nettoyage_log_debug
    nettoyage_mails_temp
    # On n'enregistre l'historique que s'il y a eu un fichier détruit
    if @files_count > 0
      CRON2::Histo::add(code: '11100', data: @files_count)
      superlog "#{@files_count} fichiers nettoyés."
    end
  end

  # = main =
  #
  # Méthode générale qui nettoie un dossier en supprimant tous les
  # éléments qui sont plus vieux que +older_than+
  def nettoyage_dossier path, older_than
    File.exist?(path) && File.directory?(path) || return
    older_than.instance_of?(Fixnum) && older_than = Time.at(older_than)
    Dir["#{path}/*"].each do |p|
      File.stat(p).mtime < older_than || next
      File.unlink p
      @files_count += 1
    end
  end

  # Nettoyage du dossier des mails envoyés
  def nettoyage_mails_temp
    nettoyage_dossier "#{FOLDER_APP}/tmp/mails", Time.now - 3.days
  end

  # Nettoyage des rapports de connexions qui sont créés chaque fois
  # qu'il faut informer l'administration des dernière connexions effectuée
  def nettoyage_rapports_connexions
    nettoyage_dossier "#{FOLDER_APP}/CRON2/rapports_connexions", (Time.now - ( 3 * 3600 ))
  end

  # Destruction du fichier debug.log
  #
  # C'est important car il peut prendre beaucoup de place suivant
  # les messages qu'on demande.
  # Noter que quelle que soit la fréquence du cronjob, ce nettoyage
  # ne se fait qu'une fois par jour.
  #
  def nettoyage_log_debug
    return if Time.now.hour < 23
    p = "#{FOLDER_APP}/debug.log"
    if File.exist?(p)
      File.unlink(p)
      @files_count += 1
    end
  end

end
