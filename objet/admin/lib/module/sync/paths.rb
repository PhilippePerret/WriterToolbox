# encoding: UTF-8
class Sync


  # Fichier marshal contenant les données du dernier check
  def check_data_path
    @check_data_path ||= folder_tmp + 'check_data.msh'
  end

  # Fichier HTML qui contient le texte à afficher pour montrer
  # l'état de la synchro au dernier check
  def display_path
    @display_path ||= folder_tmp + 'display.html'
  end

  def synchro_data_path
    @synchro_data_path ||= folder_tmp + 'synchro_data.msh'
  end

  # Dossier temporaire contenant toutes les données de la
  # synchronisation et check de la synchro
  def folder_tmp
    @folder_tmp || begin
      d = site.folder_tmp + 'sync'
      d.build unless d.exist?
      d
    end
  end

end
