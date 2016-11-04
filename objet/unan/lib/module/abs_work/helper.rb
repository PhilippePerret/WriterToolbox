# encoding: UTF-8
site.require_objet 'unan_admin' if user.admin?

class Unan
class Program
class AbsWork


  # Construction du travail sous forme de carte
  #   - pour le centre de travail de l'auteur
  #   - pour l'affichage jour par jour de l'administration
  #
  # +params+
  #   :from       S'il est indiqué, précise le jour pour lequel
  #               ce travail est affiché. Par exemple, ça peut
  #               être le jour 3 jours plus tard que le jour où
  #               ce travail doit être joué. Dans ce cas, on donne
  #               plus (+) d'indications, comme par exemple le
  #               nombre de jours déjà pris sur le travail et le
  #               nombre de jours restant.
  #   :auteur     L'instance User (utile pour d'autres méthodes)
  #
  def as_card params = nil
    # cas du bureau normal de l'auteur d'un programme UAUS
    unless relative_data.nil?
      # return 'C’est la carte relative'
      return as_card_relative
    end

    params ||= Hash.new
    classes_css = ['work']
    if params[:from]
      if (duree - params[:from] == 0)
        classes_css << 'last_day'
      elsif params[:from] == 0
        classes_css << 'first_day'
      end
    end

    # Barrière provisoire
    # Il arrive que le titre soit false, prévenir l'administrateur
    if ! titre
      send_error_to_admin "`titre` est false dans Unan::Program::AbsWork#as_card (#{__FILE__}:#{__LINE__}).\n"+
        "ID Abs_Work : #{self.id.inspect}"
    end

    # Composition de la carte (attention, c'est la version
    # "absolue", celle qui est affichée pour l'admin ET lorsque le
    # travail est affiché quand il n'est pas encore commencé)
    (
      (
        human_type_w.in_span(class:'type') +
        (titre||'- Sans titre - ').in_span
      ).in_div(class:'titre') +
      form_pour_marquer_started_or_fini(started = false) +
      div_travail + # avec exemples et pages cours
      autres_infos_travail(params[:from]) +
      buttons_edit
    ).in_div(id: "work-#{id}", class:classes_css.join(' '))
  end

  # Affichage de la carte quand elle doit être
  # propre à un travail et un auteur (c'était avant une
  # méthode de Work). C'est la carte qui est affichée dans
  # le bureau de l'auteur.
  #
  # +options+
  #   :as_recent    Si TRUE, c'est pour un affichage comme
  #                 travail effectué.
  #
  def as_card_relative options = nil
    options ||= Hash.new
    as_recent = !!options[:as_recent]
    (
      nombre_de_points +
      "#{titre}".in_div(class:'titre')      +
      "#{travail}".in_div(class:'travail')  +
      (as_recent ? '' : rwork.div_echeance)                    +
      (as_recent ? '' : form_pour_marquer_started_or_fini)     +
      details_tache                         +
      section_exemples                      +
      suggestions_lectures
    ).in_div(id: "work-#{id}", class:'work')
  end

  # ---------------------------------------------------------------------
  #   Propriétés au format humain
  # ---------------------------------------------------------------------

  def human_type_w
    @human_type_w ||= data_type_w[:hname]
  end

  def human_narrative_target
    @human_narrative_target ||= Unan::SujetCible.new(narrative_target).human_name
  end

  # Type de résultat au format humain
  # Rappel : type_resultat est une donnée sur 3 bit dont chaque bit
  # de 0 à 9 définit une valeur du travail :
  # Le bit 1 (0) concerne le support (par exemple : un document)
  # Le bit 2 (1) concerne le destinataire (p.e. soi-même ou un producteur)
  # Le bit 3 (2) concerne le niveau d'exigence attendu
  def human_type_resultat
    bit_res_support   = type_resultat[0].to_i
    bit_res_destina   = type_resultat[1].to_i
    bit_res_exigence  = type_resultat[2].to_i

    c = ""
    if bit_res_support > 0
      support   = Unan::SUPPORTS_RESULTAT[bit_res_support][1]
      c << ("Support".in_span(class:'libelle') + support.in_span).in_span
    end
    if bit_res_destina > 0
      destina   = Unan::DESTINATAIRES[bit_res_destina][1]
      c << ("Destinataire".in_span(class:'libelle')+destina.in_span).in_span
    end
    if bit_res_exigence > 0
      exigence  = Unan::NIVEAU_DEVELOPPEMENT[bit_res_exigence][1]
      c << ("Niveau de développement attendu".in_span(class:'libelle') + exigence.in_span).in_span
    end
    return c
  end

  # ---------------------------------------------------------------------
  #   Builders HTML
  # ---------------------------------------------------------------------

  # {StringHTML} Retourne un lien permettant de lire le
  # travail.
  def lien_show titre_lien = nil, attrs = nil
    titre_lien ||= self.titre
    attrs ||= Hash.new
    ktype, context, objet_id = ktype_and_context
    attrs.merge!(href: "#{ktype}/#{objet_id}/show?in=#{context}")
    titre_lien.in_a(attrs)
  end

  def ktype_and_context
    return ['work', 'unan', id] if data_type_w.nil? # c'est une erreur, mais bon
    case data_type_w[:id_list]
    when :pages then ['page_cours', 'unan', item_id]
    when :quiz  then ['quiz', 'unan', item_id]
    when :forum then ['post', 'forum', item_id]
    else # :tasks
      ['abs_work', 'unan', id]
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'helper pour `as_card_relative`
  # ---------------------------------------------------------------------
  def nombre_de_points
    "#{points} points".in_div(class:'nbpoints')
  end

  # Retourne la section DIV contenant les suggestions de
  # lecture (pages cours) s'il y en a
  def suggestions_lectures
    return '' if pages_cours_ids.empty?
    where = "id IN (#{pages_cours_ids.join(',')})"
    hpagescours = Hash.new
    Unan.table_pages_cours.select(where: where, colonnes:[:titre]).each do |hpage|
      hpagescours.merge! hpage[:id] => hpage
    end
    listepages =
      pages_cours_ids.collect do |pcid|
        titre = hpagescours[pcid][:titre]
        "#{DOIGT}#{titre}".in_a(href:"page_cours/#{pcid}/show?in=unan")
      end.pretty_join.in_span

    s = pages_cours_ids.count > 1 ? 's' : ''
    (
      "Suggestion#{s} de lecture#{s} : ".in_span(class:'libelle') +
      listepages
    ).in_div(class:'suggestions_lectures')
  end

  # Un lien pour soit marquer le travail démarré (s'il n'a pas encore été
  # démarré) soit pour le marquer fini (s'il a été fini). Dans les deux cas,
  # c'est un lien normal qui exécute une action avant de revenir ici.
  #
  # +started+ permet d'appeler la méthode lorsque c'est un travail
  # qui n'est pas démarré.
  # TODO Il faudra de toute façon repenser les choses ici puisqu'il est
  # absurde de parler de travail relatif lorsque c'est un travail qui
  # n'est pas démarré (et qui, donc, par définition, ne peut pas posséder
  # de travail relatif de l'auteur)
  def form_pour_marquer_started_or_fini started = true
    completed, started, this_pday =
      if started == false
        [false, false, self.pday]
        #  Note : self.pday a dû être défini à l'instanciation
      else
        [rwork.completed?, rwork.started?, rwork.indice_pday]
      end
    return '' if completed
    # this_pday != nil || raise('Le jour-programme ne devrait pas être nil (dans form_pour_marquer_started_or_fini)')
    if started
      'Marquer ce travail fini'.in_a(href:"work/#{rwork.id}/complete?in=unan/program&cong=taches")
    else
      'Démarrer ce travail'.in_a(class:'warning',href:"work/#{id}/start?in=unan/program&cong=taches&wpday=#{this_pday}")
    end.in_div(class:'buttons')
  end

  # Les détails de la tâche
  #
  # TODO C'est certainement ici qu'il faudra traiter le fait
  # qu'un travail peut être une lecture de page de la collection
  # narration. OU REVENIR EN ARRIÈRE et créer vraiment une page
  # de cours quand c'est une page de la collection Narration,
  # pour qu'elle apparaisse à côté.
  def details_tache
    return '' if rwork.completed?
    (
      span_type_tache +
      span_resultat
    ).in_div(class:'details')
  end

  # Retourne la section contenant les exemples s'ils existent
  def section_exemples
    return "" if exemples.empty?
    exemples_ids.collect do |eid|
      "Exemple ##{eid}".in_a(href:"exemple/#{eid}/show?in=unan", target:'_exemple_work_').in_span
    end.join.in_div(class:'exemples')
  end

  def span_type_tache
    ("Type".in_span(class:'libelle') + human_type_w.in_span).in_span
  end
  def span_resultat
    return "" if resultat.empty?
    c = ""
    c << ("Résultat".in_span(class:'libelle') + resultat).in_span
    c << human_type_resultat
    return c
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'helper pour `as_card`
  # ---------------------------------------------------------------------

  def div_travail
    item_link = if item_id
      chose, human_chose = case true
      when page_cours?  then ['page_cours', "la page de cours"]
      when quiz?        then ['quiz', "le questionnaire"]
      when forum?       then ['forum', "le message forum"]
      else ['task', "tâche"]
      end
      " (voir #{human_chose} ##{item_id})".in_a(href:"#{chose}/#{item_id}/show?in=unan", target:"_show_#{chose}_")
    else
      ""
    end
    (
      travail.in_div(class:'travail') +
      item_link                       +
      div_exemples    +
      div_pages_cours
    ).in_div(class:'details')
  end

  # Retourne le code HTML pour le div contenant les exemples,
  # à placer dans la carte du work. Chaque exemple est un lien
  # permettant de l'afficher.
  def div_exemples
    return '' if exemples_ids.empty?

    (
      "Exemples :".in_span(class:'libelle') +
      exemples_ids.collect do |exid|
        "Exemple ##{exid}".in_a(href:"exemple/#{exid}/show?in=unan")
      end.pretty_join
    ).in_span(class:'info block')
  end

  # Retourne le DIV avec les liens vers des pages-cours s'il y
  # en a qui sont spécifiées.
  # Noter que ces pages ne sont pas les pages obligatoires pour
  # suivre le programme (celles qui sont en elles-mêmes des works)
  # mais les pages suggérées, souvent des pages Narration, en
  # rapport avec le travail courant.
  def div_pages_cours
    return '' if pages_cours_ids.empty?
    (
      'Suggestions de lecture : '.in_span(class:'libelle') +
      pages_cours_ids.collect do |pcid|
        pagec = Unan::Program::PageCours.get(pcid)
        pagec.titre.in_a(href:"page_cours/#{pcid}/show?in=unan").in_li
      end.join.in_ul
    ).in_span(class:'info block')
  end

  # +from+ Cf. l'explicaiton dans la méthode principale `as_card`
  def autres_infos_travail from = nil
    s_duree = duree > 1 ? "s" : ""
    first_infos = [
      ["Type projet", type_projet[:hname],      nil],
      ["Sujet",       human_narrative_target,   nil],
      ["Points",      points,                   nil]
    ].collect do |libelle, valeur, unite|
      ("#{libelle} :".in_span(class:'libelle') + "#{valeur}#{unite}").in_span(class:'info')
    end.compact.join

    (
      first_infos +
      infos_durees_travail(from)
    ).in_div(class:'autres_infos')
  end
  # +from+ Cf. l'explication dans la méthode principale `as_card`
  def infos_durees_travail from = nil
    s_duree = duree > 1 ? "s" : ""
    pars = [["Durée", duree, "&nbsp;p-jour#{s_duree}"]]
    unless from.nil?
      pars << ["PDays travaillés", from , ""]
      pars << ["PDays restant", duree - from, ""]
    end
    pars.collect do |libelle, valeur, unite|
      ("#{libelle} :".in_span(class:'libelle') + "#{valeur}#{unite}").in_span(class:'info')
    end.join
  end
  def buttons_edit
    user.admin? || (return '')
    (
      "[Edit Work##{id}]".in_a(href: "abs_work/#{id}/edit?in=unan_admin")
    ).in_div(class:'right tiny')
  end

end #/AbsWork
end #/Program
end #/Unan
