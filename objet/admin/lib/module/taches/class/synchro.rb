# encoding: UTF-8
raise_unless_admin
class Admin
class Taches
class << self

  attr_reader :suivi

  # Synchronise le fichier online et offline
  # Note : Cela est nécessaire car on peut créer des taches en
  # Online comme en Offline et, surtout, les tâches ONLINE servent
  # aux administrateurs mais elles peuvent être
  def synchronize
    @suivi = Array::new

    # Le fichier des tâches local
    @path_database_loc = ::Admin::table_taches.bdd.path.to_s
    @suivi << "Path de la base = #{@path_database_loc}"
    site.require_module 'remote_file'
    @rfile = RFile::new(@path_database_loc)

    # On va vérifier que la synchronisation est nécessaire
    synchro_required? || return

    # Il faut charger le fichier distant, mais en changeant son nom
    # pour qu'il n'écrase pas le fichier local.
    @rfile.distant.downloaded_file_name = "site_hot-distant-prov.db"
    @path_database_prov = @rfile.distant.local_path

    # On downloade la base des tâches locale (en fait, toute la
    # base des données 'hot' du site) en la plaçant dans un fichier
    # autre que le fichier local.
    download_base_distante || return

    # On compare les deux fichiers
    compare_listes_taches || return

    # On en a terminé, on peut détruire le fichier local
    remove_database_prov || return

    @suivi << "Opération de synchronisation des tâches exécutée avec succès."


  end

  # = main =
  #
  # Méthode principale qui va checker les deux listes de tâches
  # pour permettre la synchronisation si nécessaire
  def compare_listes_taches
    table_taches_loc = BdD::new(@rfile.path).table('todolist')
    table_taches_dis = BdD::new(@rfile.distant.local_path).table('todolist')

    taches_loc = table_taches_loc.select()
    taches_dis = table_taches_dis.select()

    delim = "--------------------------------------"
    @suivi << "\n\n" + delim
    @suivi << "|                |  local  | distant |"
    @suivi << delim
    @suivi << "| Nombre tâches  |#{taches_loc.count.to_s.rjust(8)} |#{taches_dis.count.to_s.rjust(8)} |"
    @suivi << delim + "\n\n"

    # TODO: Modifier l'admin_id 253 => 3

    @suivi << "TACHES LOCALES"
    @suivi << (taches_loc.collect do |tid, tdata|
      next nil if tdata[:state] == 9
      "pour : #{tdata[:admin_id]} tache : #{tdata[:tache]}"
    end.compact.join("\n"))
    @suivi << "TACHES DISTANTES"
    @suivi << (taches_dis.collect do |tid, tdata|
      next nil if tdata[:state] == 9
      "pour : #{tdata[:admin_id]} tache : #{tdata[:tache]}"
    end.compact.join("\n"))

    @suivi << "Comparaison des listes de tâches opérées."
    return true
  end

  def download_base_distante
    @rfile.download
    ok = File.exist?(@path_database_prov)
    if ok
      @suivi << "Fichier distant downloadé dans #{@path_database_prov}."
    else
      @suivi << "Fichier distant non downloadé (fichier #{@path_database_prov} introuvable…)"
    end
    return ok
  end

  # Détruire le fichier provisoire des tâches downloadé
  def remove_database_prov
    File.unlink(@path_database_prov) if File.exist?(@path_database_prov)
    return false == File.exist?(@path_database_prov)
  end


  def synchro_required?
    loc_mtime = @rfile.mtime
    dis_mtime = @rfile.distant.mtime
    if loc_mtime < dis_mtime
      @suivi << "La base locale a besoin d'être actualitée (loc:#{loc_mtime}/dis:#{dis_mtime})"
    elsif dis_mtime < loc_mtime
      @suivi << "La base distante a besoin d'être actualisée (loc:#{loc_mtime}/dis:#{dis_mtime})"
    else
      @suivi << "Les deux base portent la même date, la synchronisation n'est pas nécessaire."
      return false
    end
    return true
  end

end #/ << self
end #/Taches
end #/Admin
