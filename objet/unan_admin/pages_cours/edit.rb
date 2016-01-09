# encoding: UTF-8
site.require_objet 'unan'

class UnanAdmin
class PageCours
  class << self

    def save
      debug "Sauvegarde de #{new_page? ? 'la nouvelle' : 'l’ancienne'} page #{new_page? ? '' : '#'+page_id.to_s}…"
      check_values_page_cours || return
    end
    def data_page
      @data_page ||= param(:page_cours)
    end
    def page_id
      @page_id ||= data_page[:id].nil_if_empty.to_i_inn
    end
    def new_page?
      @is_new_page ||= page_id == nil
    end

    # Méthode qui vérifie les valeurs de la page de cours
    def check_values_page_cours
      properties_not_nil([:titre, :description, :path, :handler])
      # L'handler doit être unique si c'est une nouvelle page
      if new_page?
        handler = data_page[:handler]
        debug "handler : #{handler}"
        raise "l'handler doit être unique" if table_pages_cours.count(where:"handler = '#{handler}'") > 0
      end
      # La page doit exister dans le dossier du type
      path = data_page[:path]
      fullpath = site.folder_data + "unan/pages_cours/#{data_page[:type]}/#{path}"
      if data_page[:cb_create_file] == "on"
        flash "Il faut créer le fichier s'il n'existe pas"
      else
        raise "Le fichier `#{fullpath.to_s}` est introuvable… Il faut le créer avec d'enregistrer la donnée." unless fullpath.exist?
      end
    rescue Exception => e
      error e.message
    end
    def properties_not_nil arr_properties
      arr_properties.each do |prop|
        val = data_page[prop].nil_if_empty
        raise "La propriété #{prop} ne peut pas être vide" if val.nil?
        data_page[prop] = val
      end
    end

    def get page_id
      table_pages_cours.get(page_id) || Hash::new
    end

    def table_pages_cours
      @table_pages_cours ||= Unan::Program::PageCours::table_pages_cours
    end

  end #/ << self
end #/PageCours
end #/UnanAdmin

def pc # comme "P-age C-cours"
  return Hash::new if pc_id == :undefined
  @pc ||= begin
    UnanAdmin::PageCours::get(pc_id)
  end
end
def pc_id
  @pc_id ||= begin
    pc_id = nil
    pc_id = param(:page_cours)[:id].nil_if_empty.to_i_inn if param(:page_cours)
    pc_id || :undefined
  end
end


UnanAdmin::PageCours::save if param(:page_cours)
