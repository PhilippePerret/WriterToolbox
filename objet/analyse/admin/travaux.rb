# encoding: UTF-8
class FilmAnalyse
class Travail
class << self

  # ---------------------------------------------------------------------
  #   Liste des travaux à faire
  # ---------------------------------------------------------------------
  def list
    user_courant = nil
    "Travaux en cours".in_h3 +
    travaux.collect do |wdata|
      wid = wdata[:id]
      c = ""
      if wdata[:user_id] != user_courant
        c += User::get(wdata[:user_id]).pseudo.in_h4
        user_courant = wdata[:user_id]
      end
      iw = new(wid)
      c << iw.output
      c.in_li
    end.join('').in_ul(class:'tdm')
  end
  def travaux
    @travaux ||= begin
      where = "CAST( SUBSTRING(options,3,1) as UNSIGNED ) < 9"
      FilmAnalyse.table_travaux.select(where: where, order:"user_id")
    end
  end

  # ---------------------------------------------------------------------
  #   Partie édition
  # ---------------------------------------------------------------------
  def travail_in_param
    @travail_in_param ||= begin
      h = param(:w) || Hash.new
      h[:id] = h[:id].nil_if_empty
      h
    end
  end

  # Méthode pour sauver le travail édité (nouveau ou modifié)
  def save
    # TODO: Plus tard, il faudra couper ça
    # return "L'enregistrement d'un travail d'analyse n'est possible en ONLINE" if OFFLINE
    # debug "travail_in_param : #{travail_in_param.inspect}"
    unless travail_in_param[:state] == '0'
      travail.data = travail_in_param
      travail.save
      param(:w => param(:w).merge(id: travail.id)) if travail.new?
      flash "Sauvegarde du travail ##{travail.id} (#{travail.new? ? "nouveau" : "modification"})."
    else
      raise "ID de travail est nil" if travail.id.nil?
      travail.destroy
      flash "Travail ##{travail.id} détruit."
      param(:w => nil)
    end
  end

  # {FilmAnalyse::Travail} Instance du travail édité courant
  def travail
    @travail ||= begin
      FilmAnalyse::Travail::new( travail_in_param[:id].to_i )
    end
  end

  # Formulaire d'édition d'un nouveau travail
  def formulaire
    travail_id = param(:travail_id) || travail_in_param[:id]
    # Si l'ID travail est défini mais pas :w, c'est qu'on arrive
    # avec un ID de travail pour l'éditer
    if travail_id != nil && param(:w).nil?
      @travail = FilmAnalyse::Travail::new( travail_id.to_i )
    end
    site.require 'form_tools'
    form.prefix = "w"
    form.objet  = travail
    (
      form.field_hidden( travail_id, :id) +
      "save_travail".in_hidden(name:'operation') +
      form.field_select("Analyste", :user_id, nil, {values:analyste_values}) +
      form.field_select("Film", :film_id, nil, {values:films_values}) +
      form.field_select("Cible", :cible, nil, {values:cible_values}) +
      form.field_select("Phase", :phase, nil, {values:phase_values}) +
      form.field_select("État", :state, nil, {values:state_values}) +
      form.field_text("Cible réf.", :target_ref) +
      form.field_description("Préciser ci-dessus par exemple le nom du fichier concerné par ce travail, s'il a déjà un nom (ce serait préférable).") +
      form.field_textarea("Description", :description) +
      form.field_textarea("note", :note) +
      "+ Nouveau".in_a(href:"admin/travaux?in=analyse").in_div(class:'fleft') +
      form.submit_button(travail_id.nil? ? "Créer le travail" : "Modifier le travail")
    ).in_form(id:"travail_form", class:'dim2080', style:"display:#{travail.id.nil? ? 'none' : 'block'}")
    .in_fieldset(legend:"Édition travail".in_span(onclick:"$('form#travail_form').toggle()"))
  end

  def analyste_values
    @analyste_values ||= begin
      where = "(CAST(SUBSTRING(options,18,1) as UNSIGNED) & 1) OR ( CAST(SUBSTRING(options,1,1) as UNSIGNED) & 1)"
      cols  = [:pseudo, :options]
      User::table_users.select(where:where,colonnes:cols).collect do |udata|
        ["#{udata[:id]}", "#{udata[:pseudo]}"]
      end
    end
  end
  def films_values
    @films_values ||= begin
      FilmAnalyse::table_films.select(colonnes:[:titre, :realisateur]).collect do |fid, fdata|
        # real = fdata[:realisateur]
        # real = "#{real[0..30]} […]" if real.length > 32
        # real = " (#{real})".in_span(class:'tiny')
        [fid, "#{fdata[:titre]}"]
      end
    end
  end
  def cible_values
    DATA_CIBLES
    # DATA_CIBLES.collect do |cid, cdata|
    #   [cid, cdata[:hname]]
    # end
  end
  def phase_values
    DATA_PHASES
  end
  def state_values
    DATA_STATES
  end
end #/<< self

  attr_accessor :data

  # Retourne true si c'est un nouveau travail
  def new?
    id == nil
  end

  # Sauvegarde les données du travail
  def save
    new? ? create : update
  end

  def destroy
    debug "id = #{id.inspect}"
    FilmAnalyse.table_travaux.delete(id) unless new?
  end
  def create
    debug "DATA DE CRÉATION DU TRAVAIL : #{data2create}"
    @id = FilmAnalyse.table_travaux.insert(data2create)
  end
  def update
    debug "DATA D'UPDATE DU TRAVAIL : #{data2update}"
    FilmAnalyse.table_travaux.update(id, data2update)
  end

  def data2update
    @data2update ||= begin
      common_data.merge(
        updated_at:  NOW
      )
    end
  end
  def data2create
    @data2create ||= begin
      common_data.merge(
        created_at:   NOW,
      )
    end
  end
  def common_data
    {
      user_id:      data[:user_id].to_i,
      film_id:      data[:film_id].to_i,
      options:      rebuild_options,
      target_ref:   data[:target_ref].nil_if_empty,
      description:  data[:description],
      note:         data[:note],
      updated_at:   NOW
    }
  end

  def rebuild_options
    @rebuild_options ||= begin
      "#{data[:cible]}#{data[:phase]}#{data[:state]}"
    end
  end


end #/Travail
end #/FilmAnalyse
