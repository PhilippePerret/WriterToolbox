# encoding: UTF-8
raise_unless_admin

class Filmodico
  class << self
    def save_film
      film = new(param_data[:id].nil_if_empty.to_i_inn)
      film.save
      flash "Film ##{film.id} sauvé."
    end

    def edit_by_any_id
      if param_data[:id].nil_if_empty != nil
        edit_by_id
      elsif param_data[:film_id].nil_if_empty != nil
        edit_by_film_id
      elsif param_data[:sym].nil_if_empty != nil
        edit_by_sym_id
      else
        error "Merci d'entrer au moins un des trois identifiants de film possible."
      end
    end
    def edit_by_id
      id = param_data[:id].nil_if_empty
      return error("Il faut fournir l'identifiant du film") if id.nil?
      prepare_edition_film table_films.get(id.to_i)
    end
    def edit_by_film_id
      film_id = param_data[:film_id].nil_if_empty
      return error("Il faut fournir le FILM ID du film") if film_id.nil?
      hfilm = table_films.get(where:{film_id: film_id})
      prepare_edition_film hfilm
    end
    def edit_by_sym_id
      sym_id = param_data[:sym].nil_if_empty
      return error("Il faut fournir le SYM ID du film") if sym_id.nil?
      id = table_films_analyse.select(where:{sym: sym_id}).keys.first
      prepare_edition_film table_films.get(id)
    end

    def prepare_edition_film hfilm
      pays = hfilm.delete(:pays).join(' ') # Array
      hfilm.merge!(
        pays: pays,
        realisateur: hfilm.delete(:realisateur).as_people_in_textarea,
        auteurs: (hfilm.delete(:auteurs)||[]).as_people_in_textarea,
        producteurs: (hfilm.delete(:producteurs)||[]).as_people_in_textarea,
        musique: (hfilm.delete(:musique)||[]).as_people_in_textarea,
        acteurs: hfilm.delete(:acteurs).as_acteurs_in_textarea,
      )
      param(:film => hfilm)
    end
    def param_data
      @param_data ||= param(:film)
    end
  end #/<< self

  # ---------------------------------------------------------------------
  #   Instance pour édition ou création
  # ---------------------------------------------------------------------

  # = Main =
  #
  # Méthode principale de sauvegarde du film (modification ou création)
  def save
    @is_new = id == nil
    check_data_or_raise || return
    if is_new?
      # debug "data2save: #{data2save.pretty_inspect}"
      # Table FILMODICO
      @id = Filmodico::table_films.insert(data2save)
      # Table ANALYSE
      data2save_analyse.merge!(id: @id, created_at: NOW)
      Filmodico::table_films_analyse.insert(data2save_analyse)

      # Pour l'affichage
      param(:film => param(:film).merge(id: @id, film_id: @film_id))
    else
      Filmodico::table_films.update(id, data2save)
      Filmodico::table_films_analyse.update(id, data2save_analyse)
    end
  end
  def is_new? ; @is_new == true end

  def data2save
    @data2save ||= {
      titre:            @titre,
      titre_fr:         @titre_fr,
      annee:            @annee,
      film_id:          @film_id,
      resume:           @resume,
      duree:            @duree,
      duree_generique:  @duree_generique,
      pays:             @pays, # Array
      realisateur:      @realisateur,
      auteurs:          @auteurs,
      producteurs:      @producteurs,
      musique:          @musique,
      acteurs:          @acteurs
    }
  end
  def data2save_analyse
    @data2save_analyse ||= {
      titre:        titre,
      titre_fr:     titre_fr,
      annee:        annee,
      sym:          @sym,
      options:      "00",
      pays:         @pays.first, # String
      realisateur:  @realisateur_analyse,
      auteurs:      @auteurs_analyse,
      updated_at:   NOW
    }
  end
  
  def check_data_or_raise
    @titre = data_params[:titre].nil_if_empty
    raise "Il faut fournir le titre du film !" if @titre.nil?
    @annee = data_params[:annee].nil_if_empty.to_i_inn
    raise "Il faut fournir l'année du film !" if @annee.nil?
    raise "L'année devrait être supérieure à 1985 !" if @annee < 1985
    raise "L'année ne peut pas être trop supérieure à l'année courante !" if annee > Time.now.year + 4
    @film_id = data_params[:film_id].nil_if_empty
    # S'il faut calculer l'ID (nouveau film)
    @film_id = titre.as_normalized_id + annee.to_s if @film_id.nil?
    @sym = data_params[:sym].nil_if_empty

    @duree = data_params[:duree].nil_if_empty
    raise "Il faut fournir la durée du film" if @duree.nil?
    if @duree.match(/:/)
      # <= Durée fournie en horloge
      hrs, mns, scs = @duree.split(':')
      @duree = hrs.to_i * 3600 + mns.to_i * 60 + scs.to_i
    else
      @duree = @duree.to_i_inn
    end
    @duree_generique = data_params[:duree_generique].nil_if_empty
    if @duree_generique && @duree_generique.match(/:/)
      # <= Durée fournie en horloge
      hrs, mns, scs = @duree_generique.split(':')
      @duree_generique = hrs.to_i * 3600 + mns.to_i * 60 + scs.to_i
    else
      @duree_generique = @duree_generique.to_i_inn
    end
    raise "La durée du générique ne peut être supérieure à la durée du film !" if @duree_generique && @duree_generique > @duree

    @titre_fr = data_params[:titre_fr].nil_if_empty
    @resume = data_params[:resume].purified.nil_if_empty
    raise "Il faut fournir le résumé du film !" if @resume.nil?

    @pays = data_params[:pays].nil_if_empty
    raise "Il faut fournir le pays du film !" if @pays.nil?
    @pays = @pays.split(' ')

    ['realisateur', 'auteurs', 'producteurs', 'musique'].each do |key|
      people = data_params[key.to_sym].nil_if_empty
      next if people.nil?

      persons = people.purified.split(/\n/).collect do |line|
        prenom, nom, sup = line.split(', ')
        d = {prenom: prenom, nom: nom}
        case key
        when 'auteurs' then d.merge!(objet: sup)
        end
        d
      end
      instance_variable_set("@#{key}", persons )

      # Pour les données de la table analyse.films (et non pas
      # filmodico.films)
      case key
      when 'realisateur'
        @realisateur_analyse = persons.collect do |hperson|
          "#{hperson[:prenom]} #{hperson[:nom]}"
        end.pretty_join
      when 'auteurs'
        @auteurs_analyse = persons.collect do |hperson|
          "#{hperson[:prenom]} #{hperson[:nom]}"
        end.pretty_join
      end
    end

    raise "Il faut renseigner le réalisateur" if @realisateur.nil?
    raise "Il faut renseigner les auteurs" if @auteurs.nil?
    raise "Il faut renseigner les producteurs" if @producteurs.nil?

    @acteurs = data_params[:acteurs].purified.nil_if_empty
    unless @acteurs.nil?
      @acteurs = @acteurs.split(/\n/).collect do |line|
        prenom, nom, prenom_perso, nom_perso, fonction_perso = line.split(', ')
        { prenom: prenom, nom: nom,
          prenom_perso: prenom_perso, nom_perso: nom_perso,
          fonction_perso: fonction_perso }
      end
    end

  rescue Exception => e
    debug e
    error e.message
  else
    true
  end

  def data_params
    @data_params ||= self.class::param_data
  end

end #/Filmodico

class ::Array
  def as_people_in_textarea
    self.collect do |hpeople|
      "#{hpeople[:prenom]}, #{hpeople[:nom]}"
    end.join("\n")
  end
  def as_acteurs_in_textarea
    self.collect do |ha|
      "#{ha[:prenom]}, #{ha[:nom]}, #{ha[:prenom_perso]}, #{ha[:nom_perso]}, #{ha[:fonction] || ha[:fonction_perso]}"
    end.join("\n")
  end
end
case param(:operation)
when 'save_film'
  Filmodico::save_film
when 'edit_film_by_any_id'
  # Par défaut, quand on entre un ID, FILM ID ou SYM ID et qu'on
  # fait retour-chariot. Le programme recherche le premier ID défini
  # et s'en sert
  Filmodico::edit_by_any_id
when 'edit_film_by_id'
  Filmodico::edit_by_id
when 'edit_film_by_film_id'
  Filmodico::edit_by_film_id
when 'edit_film_by_sym_id'
  Filmodico::edit_by_sym_id
end