# encoding: UTF-8
raise_unless_admin

class Unan
class Program
class PageCours
#
  EXTENSIONS_PATH_VALIDES = ['.md', '.erb', '.rb', '.txt', '.tex', '.html', '.htm']

  class << self

    def save
      debug "data_page : #{data_page.pretty_inspect}"
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

    # Les données de la page telles qu'elles se présentent
    # dans le formulaire.
    # Noter que les valeurs vides sont remplacées par des
    # valeurs NIL (nécessaire pour plus bas dans le check des
    # valeurs.)
    def data_page
      @data_page ||= begin
        h = Hash::new
        param(:page_cours).collect do |k,v|
          h.merge!(k => v.nil_if_empty )
        end
        h
      end
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

      # Propriété non nil (première définition, sera redéfini ci-dessous
      # si ce n'est pas une page narration qui est définie)
      mandatory_props = [:titre, :description]


      is_narration = !data_page[:narration_id].nil?

      if !is_narration

        # SI PAS DÉFINITION D'UNE PAGE NARRATION

        mandatory_props += [:path, :handler]

      else

        # SI DÉFINITION D'UNE PAGE NARRATION

        # Si narration_id est défini (ID d'une page de la collection
        # narration) alors il faut récupérer les données pour compléter
        # l'enregistrement

        nid = data_page[:narration_id].to_i
        site.require_objet 'cnarration'
        pagen = Cnarration::Page::get(nid)
        if pagen.nil?
          raise "La page Narration #{nid} est inconnue…"
          nid = nil
        else

          if new_page?
            # En cas de nouvelle page
            # Il faut s'assurer que cette page Narration n'existe pas
            # encore en tant que page de cours UN AN UN SCRIPT
            where = "narration_id = #{nid}"
            if table_pages_cours.count(where:where) > 0
              pcid = table_pages_cours.select(where:where,colonnes:[]).values.first[:id]
              raise "#{pagen.hletype.capitalize} Narration #{pagen.titre} est déjà mémorisé dans la page-cours #{pcid}"
            end
          end

          # On force le type
          @data_page[:type]     = 'cnarration'

          if @data_page[:titre].nil?
            # Composer un titre du genre "Chapitre “” dans la collection Narration"
            tit = case pagen.stype
            when :page then ""
            when :chapitre, :sous_chapitre then "#{pagen.htype.capitalize} "
            end + "“#{pagen.titre}”" + " (collection Narration)".in_span(class:'tiny')
            @data_page[:titre]    = "#{tit}"
          end

          if pagen.page?
            @data_page[:handler]  = pagen.handler
            @data_page[:path]     = "#{pagen.handler}.md"
          else
            @data_page[:handler]  = nil
            @data_page[:path]     = nil
          end

          if @data_page[:description].nil?
            @data_page[:description]  = "#{pagen.lehtype.capitalize} “#{pagen.titre}” du livre “#{pagen.livre.titre}” de la #{lien.narration 'Collection Narration'}."
          end
        end
        @data_page[:narration_id] = nid
        debug "@data_page APRÈS ajouts narration : #{@data_page.pretty_inspect}"
      end

      # Les propriétés qui ne doivent absolument pas être
      # vides.
      properties_not_nil(mandatory_props)

      # L'handler doit être unique si c'est une nouvelle page
      if new_page? && data_page[:narration_id].nil?
        handler = data_page[:handler]
        raise "l'handler doit être unique" if table_pages_cours.count(where:"handler = '#{handler}'") > 0
      end
      # Contrôle du path de la page de cours
      path = data_page[:path]
      unless is_narration
        # Le path doit posséder une extension valide
        unless EXTENSIONS_PATH_VALIDES.include?(File.extname(path))
          raise "Le path ne possède pas une extension valide. L'extension doit appartenir à #{EXTENSIONS_PATH_VALIDES.join(', ')}."
        end
        # La page doit exister dans le dossier du type
        fullpath = site.folder_data + "unan/pages_cours/#{data_page[:type]}/#{path}"
        unless fullpath.exist?
          if creer_fichier_is_inexistant?
            create_file_page_cours(fullpath)
          else
            raise "Le fichier `#{fullpath.to_s}` est introuvable… Il faut le créer avant d'enregistrer la donnée.<br/>Noter qu'il suffit pour ça de cocher la case pour créer le fichier s'il n'existe pas."
          end
        end
      end #/fin si ce n'est pas une page narration
    rescue Exception => e
      debug e
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

    def get pid
      table_pages_cours.get(pid) || Hash::new
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
        "<%\n# Page de cours #{data_page[:titre]}\n%>\n<h3>#{data_page[:titre]}</h3>\n<p>[Contenu de la page #{data_page[:titre]}]</p>"
      when 'html', 'htm'
        "<h3>#{data_page[:titre]}</h3>\n<p>[Contenu de la page #{data_page[:titre]}]</p>"
      else
        flash "l'extension #{sfile.extension} n'est pas traitée dans la création automatique des fichiers."
        nil
      end
      return if content.nil?
      sfile.write content
    end

    def open_page
      ipage = Unan::Program::PageCours::get(page_id)
      debug "Page ##{ipage.id}"
      path = File.expand_path(ipage.fullpath.to_s)
      dirn = File.dirname(path)
      base = File.basename(path)
      cmd = "cd \"#{dirn}\";atom \"#{base}\""
      system( cmd )
      flash "Page ##{ipage.id} ouverte.<br />Si elle ne s'ouvre pas, copier coller le code ci-dessous dans le terminal "+
      "<input type='text' value='#{cmd}' /> "+
      "ou cliquer sur "+
      "<a class='bold' href='atm://open?url=file://#{path}' style='color:white'>OUVRIR “#{base}”</a>"
    end
  end #/ << self
end #/PageCours
end #/Program
end #/Unan

def pc # comme "P-age C-cours"
  return Hash::new if pc_id == :undefined
  @pc ||= Unan::Program::PageCours::get(pc_id)
end
def pc_id
  @pc_id ||= begin
    pc_id = nil
    pc_id = param(:page_cours)[:id].to_s.nil_if_empty.to_i_inn if param(:page_cours)
    pc_id || :undefined
  end
end

case param(:operation)
when "open_page_cours"
  Unan::Program::PageCours::open_page
when "save_page_cours"
  Unan::Program::PageCours::save
when "edit_page_cours"
  # UnanAdmin::PageCours::edit
end
