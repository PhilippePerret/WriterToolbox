# encoding: UTF-8
site.require_objet 'unan'

class UnanAdmin
class PageCours
  class << self

    def save
      debug "Sauvegarde de #{new_page? ? 'la nouvelle' : 'l’ancienne'} page #{new_page? ? '' : '#'+page_id.to_s}…"
      check_values_page_cours || return

      # Au cas où, retirer les valeurs qui ne doivent
      # pas être enregistrées dans la table de données
      data_page.delete(:cb_create_file)
      data_page.delete(:id) if data_page[:id].nil?
      data_page.merge!(updated_at: NOW.to_i)

      debug "data_page enregistrées : #{data_page.inspect}"

      if new_page?
        data_page.merge!(created_at: NOW.to_i)
        data_page[:id] = @page_id = table_pages_cours.insert(data_page)
      else
        table_pages_cours.set(page_id, data_page)
      end
      flash "Page ##{@page_id} enregistrée avec succès."
      param(page_cours: data_page)
    end
    def data_page
      @data_page ||= param(:page_cours)
    end
    def page_id
      @page_id ||= begin
        pid = data_page[:id].nil_if_empty.to_i_inn
        data_page[:id] = pid
      end
    end
    def new_page?
      @is_new_page ||= page_id == nil
    end
    def creer_fichier_is_inexistant?
      if @creer_fichier_is_inexistant === nil
        @creer_fichier_is_inexistant = data_page.delete(:cb_create_file) == 'on'
      end
      @creer_fichier_is_inexistant
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
      unless fullpath.exist?
        if creer_fichier_is_inexistant?
          create_file_page_cours(fullpath)
        else
          raise "Le fichier `#{fullpath.to_s}` est introuvable… Il faut le créer avec d'enregistrer la donnée."
        end
      end
    rescue Exception => e
      error e.message
    else
      return true # <= pour enregistrer la page
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

    # Crée le fichier de cours s'il n'existe pas et que la
    # case à cocher "créer le fichier" est coché
    def create_file_page_cours sfile
      return if sfile.exist?
      content = case sfile.extension
      when 'txt'
        "[Contenu de la page #{data_page[:titre]}]"
      when 'tex'
        "% Page #{data_page[:titre]}\n\n[Contenu de la page #{data_page[:titre]}]"
      when 'erb'
        "<%\n# Page de cours #{data_page[:titre]}\n%>\n<p>[Contenu de la page #{data_page[:titre]}]</p>"
      when 'html', 'htm'
        "<p>[Contenu de la page #{data_page[:titre]}]</p>"
      else
        flash "l'extension #{sfile.extension} n'est pas traitée dans la création automatique des fichiers."
        nil
      end
      return if content.nil?
      sfile.write content
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
    pc_id = param(:page_cours)[:id].to_s.nil_if_empty.to_i_inn if param(:page_cours)
    pc_id || :undefined
  end
end


UnanAdmin::PageCours::save if param(:page_cours)
