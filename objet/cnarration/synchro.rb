# encoding: UTF-8
class SynchroNarration
class << self

  attr_reader :output

  def log mess
    @output << "#{mess}".in_div
  end
  # = main =
  #
  # Méthode principale qui procède à la synchronisation intelligente
  # des deux bases de données
  # @RETURN La liste des modifications opérées
  def synchronise_database_narration
    @output = String::new

    # On a besoin de la classe RFile pour downloader et uploader
    # les fichiers
    site.require_module 'remote_file'

    # On fait une copie du fichier local (pour qu'il ne soit pas
    # écrasé par le download du fichier distant)
    log "* Copie de la base de données locale"
    FileUtils::mv path_distant.to_s, path_local.to_s

    # On download le fichier distant
    log "* Copie de la base de données locale"
    # download_distant_file

    # On passe en revue chaque statut de page du fichier distant et
    # du fichier local pour garder le plus haut. C'est le fichier
    # local qui est modifié.
    log "* Synchronisation des statuts"
    synchronise_statuts_of_pages

    # On remet le bon nom du fichier local
    # On détruit le fichier distant chargé
    log "* Finalisation fichier local"
    path_distant.remove if path_distant.exist? # il doit exister
    FileUtils::mv path_local.to_s, path_distant.to_s

    # On synchronise le fichier sur le serveur distant
    log "* Synchronisation du fichier serveur distant"
    synchronize_file_on_distant_server

    flash "Fichier synchronisé avec succès"

    # Pour l'écrire dans la page
    return output
  end

  # ---------------------------------------------------------------------
  #   Méthodes de synchro
  # ---------------------------------------------------------------------

  # Méthode principale qui va synchroniser la propriété `state`
  # des pages locales avec les données du fichier distant si
  # nécessaire
  def synchronise_statuts_of_pages
    raise "Base de données #{path_distant} introuvable" unless path_distant.exist?
    raise "Base de données #{path_local} introuvable" unless path_local.exist?
    base_dis = BdD::new(path_distant.to_s)
    base_loc = BdD::new(path_local.to_s)
    table_dis = base_dis.table('pages')
    table_loc = base_loc.table('pages')

    table_dis.select(where:"options LIKE '1%'", colonnes:[:options]).each do |pid, pdata|
      statut_dis  = pdata[:options][1].to_i
      options_loc = table_loc.get(pid, colonnes:[:options])
      if options_loc.nil?
        debug "Page locale ##{pid} inexistante"
        next
      end
      options_loc = options_loc[:options]
      statut_loc  = options_loc[1].to_i

      if statut_dis > statut_loc
        opts = options_loc
        opts[1] = statut_dis.to_s
        table_loc.update(pid, { options: opts })
        log "---> Statut page ##{pid} passé de #{statut_loc} à #{statut_dis}"
      else
        debug "Statut page ##{pid} OK (#{statut_dis})"
      end

    end # fin de boucle sur toutes les pages distantes
  rescue Exception => e
    debug e
    error e
  end

  # Charger le fichier distant
  def download_distant_file
    RFile::new("./database/data/cnarration.db").download
  end

  # Upload le fichier pour actualisation
  def synchronize_file_on_distant_server
    RFile::new("./database/data/cnarration.db").upload
  end

  # ---------------------------------------------------------------------
  #   Données utiles
  # ---------------------------------------------------------------------

  # {SuperFile} SuperFile du fichier local qui doit être
  # synchronisé
  def path_local
    @path_local ||= SuperFile::new('./database/data/cnarration-copie.db')
  end

  # {SuperFile} SuperFile du fichier distant qui a
  # été rappatrié du serveur
  def path_distant
    @path_distant ||= SuperFile::new('./database/data/cnarration.db')
  end

end #/<<self
end #/SynchroNarration
