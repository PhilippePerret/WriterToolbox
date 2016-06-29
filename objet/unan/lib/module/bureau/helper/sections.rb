# encoding: UTF-8
=begin

  Extension de la class User::Bureau qui permet de construire
  les sections des différents panneaux, en sachant qu'elles
  fonctionnent toutes de la même manière, avec une partie des
  travaux non démarrés, puis les travaux démarrés et enfin
  les travaux récents.

=end
class Unan
class Bureau

  DATA_NAME_BY_TYPE = {
    task:   {sing: "Tâche",         plur: "Tâches",         fini: 'achevée',  e: 'e', le: "La", starter: "démarrer"},
    page:   {sing: "Page de cours", plur: "Pages de cours", fini: 'lue',      e: 'e', le: "La", starter: "marquer vue"},
    quiz:   {sing: "Quiz",          plur: "Quiz",           fini: 'rempli',   e: '',  le: "Le", starter: "remplir"},
    forum:  {sing: "Action forum",  plur: "Actions forum",  fini: 'accomplie',e: 'e', le: "L’", starter: "prendre en compte"}
  }

  # ---------------------------------------------------------------------
  #   SECTIONS PRINCIPALES
  # ---------------------------------------------------------------------

  # Section des travaux à démarrer
  #
  # +type+ (:task, :page, :quiz ou :forum)
  def section_unstarted_works type
    dname = DATA_NAME_BY_TYPE[type]
    demarrer  = dname[:starter]
    choses    = dname[:plur]
    # Ci-dessous, on force le rafraichissement pour que la
    # liste soit à jour même lorsque l'on vient de marquer
    # un travail vu ou démarré.
    # Dans le cas contraire, lorsque c'est une page de cours,
    # elle reste dans la section des pages à marquer "vu" si
    # on garde le même user.
    # Attention, faire @auteur = nil ne suffit pas car @auteur
    # prend la valeur de l'user courrant
    @auteur = User.current = User.new(auteur.id)
    arr = auteur.works_unstarted(type)
    if arr.count > 0
      (
        "<h4>#{choses} à #{demarrer}</h4>" +
        arr.collect{ |awork| awork.as_card(auteur: bureau.auteur) }.join('')
      ).in_section(id: 'works_unstarted')
    else
      ''
    end
  end

  # Section des travaux inachevés
  #
  # +type+ (:task, :page, :quiz ou :forum)
  def section_undone_works type
    dname = DATA_NAME_BY_TYPE[type]
    e     = dname[:e]
    chose = dname[:sing].downcase
    arr = auteur.works_undone(type)
    if type == :quiz
      debug "Nombre de quiz démarrés mais à faire : #{arr.count}"
    end
    if arr.count > 0
      arr.collect{ |awork| awork.as_card(auteur: bureau.auteur) }.join('')
    else
      "<p class='small discret'>Vous n’avez aucun#{e} #{chose} courant#{e}.</p>"
    end.in_section(id: 'current_works')
  end

  # Section des travaux récemment terminés
  #
  # +type+ (:task, :page, :quiz ou :forum)
  def section_recent_works type
    dname = DATA_NAME_BY_TYPE[type]
    e     = dname[:e]
    chose = dname[:sing].downcase
    fini  = dname[:fini]
    arr = auteur.works_recent(type)
    if type == :quiz
      debug "Nombre de quiz récents : #{arr.count}"
    end
    '<hr />' +
    if arr.count > 0
      "<h4>#{dname[:plur]} récemment #{fini}s</h4>" +
      arr.collect{ |awork| awork.as_card_relative(auteur: bureau.auteur, as_recent: true) }.join('')
    else
      "<p class='small discret'>Aucun#{e} #{chose} récent#{e} n'a été #{fini}.</p>"
    end.in_section(id: 'completed_works')
  end

  # /Fin des sections principales
  # ---------------------------------------------------------------------




end #/Bureau
end #/Unan
