# encoding: UTF-8
raise_unless_admin

class Cnarration
class Page
  # ---------------------------------------------------------------------
  #   Class
  # ---------------------------------------------------------------------
  class << self
    def get page_id
      page_id = page_id.to_i
      @instances ||= Hash::new
      @instances[page_id] ||= new(page_id)
    end

    def edit_page
      return (error "Il faut choisir l'ID de la page à éditer.") if page_id.nil?
      flash "Édition de la page #{param(:epage)[:id]}"
    end
    def save_page
      ipage = new()
      ipage.save
    end
    def page_id
      @page_id ||= param(:epage)[:id].nil_if_empty.to_i_inn
    end

    def prepare_edition_of ipage
      hpage = ipage.get_all
      debug "hpage: #{hpage.pretty_inspect}"
      hpage.merge!(
        # Note : il ne faut faire ni appel à `type` ni à `options`
        # directement car ils sont redéfinis ci-dessous pour
        # faire appel aux paramètres. Il faut donc les lire
        # directement dans la donnée, ce que fait `get`
        type:     ipage.get(:options)[0],
        nivdev:   ipage.get(:options)[1]
      )
    end
  end # /<< self

  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------
  def save
    @id = self.class::page_id
    @is_new_page = (@id == nil)

    check_param_or_raise || return

    debug "data2save : #{data2save.pretty_inspect}"
    # flash "Je peux sauver la page"
    # return

    if new?
      @id = Cnarration::table_pages.insert(data2save.merge(created_at: NOW))
      param(:epage => param(:epage).merge(id: @id))
      flash "Page ##{@id} créée avec succès."
    else
      Cnarration::table_pages.update(id, data2save)
      flash "Page ##{id} updatée."
    end

    # Que ce soit pour une création ou une actualisation, si
    # on demande à créer le fichier s'il n'existe pas, il faut
    # le créer.
    if page? && data_params[:create_file] == 'on' && false == path.exist?
      path.write "<!-- Page: #{@titre} -->\n"
      flash "Fichier créé "+("(dans #{path})".in_span(class:'tiny')) + "."
    end

    # Si les Identifiants de pages et titres avaient été mis en
    # session (pour accélérer le calcul des pages avant/après) alors
    # il faut initialiser cette variable pour qu'elle tienne compte
    # des changements
    reset_tdm_livre_in_session

  end

  def data2save
    @data2save ||= {
      titre:        @titre,
      handler:      @handler,
      description:  @description,
      options:      options,
      livre_id:     livre_id,
      updated_at:   NOW
    }
  end
  def new? ; @is_new_page end

  # Resetter la liste des IDs de pages et titres en
  # session si elle existe.
  def reset_tdm_livre_in_session
    if app.session["cnarration_tdm#{livre_id}"]
      app.session["cnarration_tdm#{livre_id}"] = nil
    end
  end

  def options
    @options ||= "#{type}#{nivdev}"
  end
  def livre_id
    @livre_id ||= data_params[:livre_id].to_i # 0 si aucun
   end
  def nivdev
    @nivdev ||= data_params[:nivdev].to_i
  end
  def type
    @type ||= data_params[:type].to_i
  end
  def chose
    @chose ||= begin
      case type
      when 1 then "page"
      when 2 then "sous-chapitre"
      when 3 then "chapitre"
      end
    end
  end
  def de_la_chose
    @de_la_chose ||= begin
      case type
      when 1 then "de la page"
      when 2 then "du sous-chapitre"
      when 3 then "du chapitre"
      end
    end
  end

  def check_param_or_raise
    @titre = data_params[:titre].nil_if_empty
    raise "Il faut fournir le titre #{de_la_chose} !" if @titre.nil?

    if [1,5].include?( type )
      @handler = data_params[:handler].nil_if_empty
      raise "Pour une page, il faut fournir le handler (nom du fichier)!" if @handler.nil?
      @handler = @handler.downcase
      if new?
        # Si c'est une nouvelle page il faut s'assurer que ce handler est
        # unique
        if Cnarration::table_pages.count(where:"handler = '#{@handler}'") > 0
          raise "Ce handler (path du fichier) est déjà employé… Impossible de l'utiliser pour une nouvelle page."
        end
      end
    end

    @description = data_params[:description].purified.nil_if_empty


  rescue Exception => e
    debug e
    error e.message
  else
    true
  end

  def data_params
    @data_params ||= param(:epage)
  end

end #/Page
end #/Cnarration


case param(:operation)
when 'edit_page'
  Cnarration::Page::edit_page
when 'save_page'
  Cnarration::Page::save_page
end
