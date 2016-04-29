# encoding: UTF-8
class SiteHtml

  # Retourne le contenu de la page d'accueil du site.
  # La construction (le cas échéant) se fait dans le module
  # ./objet/site/lib/module/home_page
  #
  # Si la page formatée existe, et qu'elle est à jour, on la
  # charge directement, sinon, on la construit à l'aide
  # du module 'home_page' qui se trouve dans ce dossier objet
  #
  def home_page_content
    if home_page_out_of_date? || (user.manitou? && param(:update_home_page)=="1")
      flash "Actualisation de la page d'accueil"
      site.require_module_objet 'home_page'
      site.build_home_page_content
    end
    file_home_page_content.read.force_encoding('utf-8')
  end

  def home_page_out_of_date?
    debugit = false
    debug "Home Page out-of-date ?" if debugit
    # On retourne true si le fichier HTML n'existe pas
    return true if false == file_home_page_content.exist?
    debug "   = Le fichier HTML home page existe" if debugit
    mtime = file_home_page_content.mtime
    debug "   = mtime = #{mtime}" if debugit
    # On retourne true si la base de données des analyses
    # est plus vieille que le fichier HTML
    return true if mtime < db_analyse.mtime
    debug "   = Base analyse : #{db_analyse.mtime} (OK)" if debugit
    return true if mtime < db_cnarration.mtime
    debug "   = Base Narration : #{db_cnarration.mtime} (OK)" if debugit
    return true if mtime < db_forum.mtime
    debug "   = Base Forum : #{db_forum.mtime} (OK)" if debugit
    return true if mtime < db_unan_hot.mtime
    debug "   = Base Un an un script : #{db_unan_hot.mtime} (OK)" if debugit
    return true if mtime < data_videos.mtime
    debug "   = Données vidéos : #{data_videos.mtime} (OK)" if debugit
    return true if mtime < data_divers_actus.mtime
    debug "   = Données actus diverses : #{data_divers_actus.mtime} (OK)" if debugit
    return false # donc up-to-date
  end

  def db_analyse;     @db_analyse     ||= site.folder_db + 'analyse.db'     end
  def db_cnarration;  @db_cnarration  ||= site.folder_db + 'cnarration.db'  end
  def db_forum;       @db_forum       ||= site.folder_db + 'forum.db'       end
  def db_unan_hot;    @db_unan_hot    ||= site.folder_db + 'unan_hot.db'    end

  def data_videos; @data_videos ||= site.folder_objet + 'video/DATA_VIDEOS.rb' end
  def data_divers_actus; @data_divers_actus ||= SuperFile::new('./hot/last_actualites.rb') end

end #/SiteHtml
