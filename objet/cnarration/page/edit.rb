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
      @instances          ||= {}
      @instances[page_id] ||= new(page_id)
    end

    def edit_page
      return (error "Il faut choisir l'ID de la page à éditer.") if page_id.nil?
      flash "Édition de la page #{param(:epage)[:id]}"
    end

    # Sauve la page courante et retourne l'instance
    def save_page
      new.save
    end

    def destroy_page
      Cnarration.require_module 'destroy'
      new(site.current_route.objet_id).destroy
    end

    def page_id
      @page_id ||= param(:epage)[:id].nil_if_empty.to_i_inn
    end

    def prepare_edition_of ipage
      hpage = ipage.get_all
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

  # Sauvegarde de la page (ou du titre)
  #
  # RETURN L'instance de la page (self)
  def save
    @id = self.class::page_id
    @is_new_page = (@id == nil)

    check_param_or_raise || return

    # ENREGISTREMENT DANS LA TABLE
    if new?
      @id = Cnarration.table_pages.insert(data2save.merge(created_at: NOW))
      param(:epage => param(:epage).merge(id: @id))
      flash "Page ##{@id} créée avec succès."
    else
      debug "options : #{options.inspect}"
      Cnarration.table_pages.update(id, data2save)
      flash "Page ##{id} updatée."
    end

    # CRÉATION DU FICHIER PHYSIQUE
    # Que ce soit pour une création ou une actualisation, si
    # on demande à créer le fichier s'il n'existe pas, il faut
    # le créer.
    if page? && data_params[:create_file] == 'on' && false == path.exist?
      create_page
      flash "Fichier créé<br />"+("(dans #{path})".in_span(class:'tiny')) + "."
    end

    # ANNONCE UPDATE ET TWIT
    # Si la page nécessite une annonce d'actualité , on la crée et
    # on produit un twit pour l'annoncer également.
    annonce_update_required? && annonce_update_et_twit

    # Si les Identifiants de pages et titres avaient été mis en
    # session (pour accélérer le calcul des pages avant/après) alors
    # il faut initialiser cette variable pour qu'elle tienne compte
    # des changements
    reset_tdm_livre_in_session

    return self
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

  # Return true si la case à cocher "Annonce update" est cochée dans le
  # formulaire.
  def annonce_update_required?
    !!@annonce_update_is_required
  end

  # Pour procéder à l'annonce d'actualité (nouvelle page) et
  # envoyer un twit pour annoncer la nouvelle page achevée
  def annonce_update_et_twit
    # Pour faire une annonce de nouvelle page (accueil + mail d'actu)
    data_update = {
      message:      "Nouvelle page Narration<br><strong>#{titre}</strong>",
      annonce:      1,
      type:         'narration',
      route:        "narration/#{id}/show",
      degre:        5,
      created_at:   Time.now.to_i,
      updated_at:   Time.now.to_i
    }
    # debug "data update : #{data_update.pretty_inspect}"
    site.new_update data_update
    flash "Annonce de nouvelle actualité créée pour la page Narration ##{id}."
    site.require_module 'twitter'
    site.tweet "Nouvelle page Narration : #{titre} #{bitlink}"
    flash "Tweet d'annonce de la page ##{id} envoyé (#{bitlink})"
  end


  # Resetter la liste des IDs de pages et titres en
  # session si elle existe.
  def reset_tdm_livre_in_session
    if app.session["cnarration_tdm#{livre_id}"]
      app.session["cnarration_tdm#{livre_id}"] = nil
    end
  end

  # ID du livre
  #
  # Mais attention, pour la destruction par exemple, on doit conserver
  # la méthode originale.
  #
  def livre_id
    @livre_id ||= begin
      if data_params
        data_params[:livre_id].to_i # 0 si aucun
      else
        get(:livre_id)
      end
    end
  end

  # ---------------------------------------------------------------------
  #   Définition des options
  #
  # Noter que les méthodes surclassent les méthodes originales et qu'il
  # faut donc garder quand même le comportement des méthods originales
  # ---------------------------------------------------------------------
  def options
    @options ||= "#{type}#{nivdev}#{enligne}#{priorite}"
  end
  # Options, Bit 1
  def type
    @type ||= begin
      data_params ? data_params[:type].to_i : (get(:options)||'')[0].to_i
    end
  end
  # Options, Bit 2
  def nivdev
    @nivdev ||= begin
      data_params ? data_params[:nivdev] : (get(:options)||'')[1]
    end
  end
  # Options, Bit 3
  def enligne
    @enligne||= begin
      data_params ? data_params[:enligne].to_i : (get(:options)||'')[2].to_i
    end
  end
  # Priorité de traitement, Bit 4
  def priorite
    @priorite ||= begin
      data_params ? data_params[:priorite] : (get(:options)||'')[3]
    end
  end
  # / fin définition options
  # ---------------------------------------------------------------------

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
        if Cnarration.table_pages.count(where: "handler = '#{@handler}'") > 0
          raise "Ce handler (path du fichier) est déjà employé… Impossible de l'utiliser pour une nouvelle page."
        end
      end
    end

    @annonce_update_is_required = data_params[:annonce_update] == 'on'

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
  Cnarration::Page.edit_page
when 'save_page'
  Cnarration::Page.save_page
when 'kill_page'
  Cnarration::Page.destroy_page
end
