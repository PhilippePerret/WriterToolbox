# encoding: UTF-8
=begin

  Module se chargeant des gels et autres backups

=end
class SiteHtml
class TestSuite

  # Fait une copie des bases de données actuelles
  #
  # La méthode met la variable d'instance @freezed à
  # true si l'opération s'est bien passée.
  def freeze_current_db_state
    start_time = Time.now
    src = "./database/data"
    dst = "./tmp/testdbbackdup"
    FileUtils::rm_rf(dst) if File.exist?(dst)
    `mkdir -p "#{dst}"`
    FileUtils::cp_r src, dst, {preserve: true}
    File.exist?("#{dst}/data") || raise( "Le dossier des backups des bases de données devrait exister.")
    @freezed = true
    end_time = Time.now
    infos[:duree_db_backup] = (end_time - start_time).round(3)
  end

  # Remet les bases dans l'état où elles étaient avant
  # les tests
  # La méthode met la variable d'instance @unfreezed à true
  # si l'opération s'est bien passée.
  def unfreeze_current_db_state
    start_time = Time.now
    src = "./tmp/testdbbackdup/data"
    dst = "./database"
    dst_folder = "#{dst}/data"
    FileUtils::rm_rf(dst_folder) if File.exist?(dst_folder)
    FileUtils::cp_r src, dst, {preserve: true}
    File.exist?(dst_folder) || raise("Le dossier ./database/data devrait exister. Le récupérer dans le dossier `#{src}`.")
    # Pour indiquer que le dégel a eu lieu
    @unfreezed = true
    end_time = Time.now
    duree_freeze = (end_time - start_time).round(3)
    infos[:duree_db_unbackup] = (end_time - start_time).round(3)
  end
end #/TestSuite
end #/SiteHtml
