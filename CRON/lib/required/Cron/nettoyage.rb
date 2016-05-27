# encoding: UTF-8
class Cron
class << self

  # Nettoyage
  def nettoyage

    # Nettoyage des vieux rapports de connexions
    #
    nettoyage_rapports_connexions

    # Nettoyage du debug principal s'il existe
    #
    nettoyage_log_debug

    # Nettoyage des fichiers de synchronisation
    # (seulement en local, mais on le fait de façon indicrect)
    #
    nettoyage_rapports_synchronisation

    # Nettoyage des logs CRON
    #
    nettoyage_logs_cron

  rescue Exception => e
    error_log e, "# ERREUR AU COURS DU NETTOYAGE"
  end

  def nettoyage_rapports_connexions
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

  def nettoyage_log_debug
    safed_log "    - Nettoyage du debug.log"
    p = "#{RACINE}/debug.log"
    if File.exist?(p)
      File.unlink(p)
      safed_log "    = OK"
    else
      safed_log "    - Inexistant -"
    end
  end

  def nettoyage_logs_cron
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

  def nettoyage_rapports_synchronisation
    safed_log "    - Nettoyage des rapports de synchronisation générale"
    pfolder = File.join(RACINE, 'lib/deep/deeper/module/synchronisation/synchronisation/output')
    nombre = 0
    il_y_a_une_heure = Time.now - 3600
    Dir["#{pfolder}/*.html"].each do |p|
      begin
        # Si le fichier a moins d'une heure (c'est peut-être un fichier
        # courant) on ne le détruit pas, au cas où.
        next if File.stat(p).mtime > il_y_a_une_heure
        File.unlink p
      rescue Exception => e
        error_log e, "    # Problème avec le fichier #{p}"
      else
        nombre += 1
      end
    end #/fin de boucle sur tous les fichiers
  rescue Exception => e
    error_log e, "PROBLÈME dans nettoyage_rapports_synchronisation"
  else
    safed_log "     = #{nombre} fichiers rapport de synchronisation détruits" +
              "     = Nettoyage OK"
  end

end #/<< self Cron
end #/Cron
