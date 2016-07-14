# encoding: UTF-8
#
# Module pour procéder au nettoyage du site
#
class CRON2
  def nettoyage_site
    @files_count = 0
    nettoyage_rapports_connexions
    nettoyage_log_debug
    CRON2::Histo::add(code: '11100', data: @files_count)
  end

  # Nettoyage des rapports de connexions qui sont créés chaque fois
  # qu'il faut informer l'administration des dernière connexions effectuée
  def nettoyage_rapports_connexions
    il_y_a_trois_heures = Time.now - ( 3 * 3600 )
    Dir["#{FOLDER_APP}/CRON2/rapports_connexions/*"].each do |p|
      next if File.stat(p).mtime > il_y_a_trois_heures
      File.unlink p
      @files_count += 1
    end
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
