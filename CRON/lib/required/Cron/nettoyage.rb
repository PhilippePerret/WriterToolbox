# encoding: UTF-8
class Cron


  # Nettoyage
  def self.nettoyage

    # Nettoyage des vieux rapports de connexions
    #
    nettoyage_rapports_connexions

    # Nettoyage du debug principal s'il existe
    #
    nettoyage_log_debug

    # Nettoyage des logs CRON
    #
    nettoyage_logs_cron

  rescue Exception => e
    safed_log "# ERREUR AU COURS DU NETTOYAGE : #{e.message}"
    safed_log e.backtrace.join("\n")
  end

  def self.nettoyage_rapports_connexions
    safed_log "    - Nettoyage des vieux rapports de connexion"
    nombre = 0
    il_y_a_trois_heures = Time.now - ( 3 * 3600 )
    Dir["#{RACINE}/CRON/rapports_connexions/*"].each do |p|
      next if File.stat(p).mtime > il_y_a_trois_heures
      File.unlink p
      nombre += 1
    end
    safed_log "    = OK (#{nombre} destructions)"
  end

  def self.nettoyage_log_debug
    safed_log "    - Nettoyage du debug.log"
    p = "#{RACINE}/debug.log"
    if File.exist?(p)
      File.unlink(p)
      safed_log "    = OK"
    else
      safed_log "    - Inexistant -"
    end
  end

  def self.nettoyage_logs_cron
    safed_log "    - Nettoyage des logs cron (un an un script)"
    fp = "#{RACINE}/CRON/log"
    files = Dir["#{fp}/*.log"]
    return if files.count < 5
    nombre = 0
    files.sort_by{|p| File.stat(p).mtime }[0..-6].each do |p|
      File.unlink p
      nombre += 1
    end
    safed_log "     = #{nombre} fichiers-log détruits"
  end

end #/Cron
