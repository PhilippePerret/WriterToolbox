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
    task:   {sing: "Tâche",         plur: "Tâches",         fini: 'achevée',  e: 'e', le: "La"},
    page:   {sing: "Page cours",    plur: "Pages cours",    fini: 'lue',      e: 'e', le: "La"},
    quiz:   {sing: "Quiz",          plur: "Quiz",           fini: 'rempli',   e: '',  le: "Le"},
    forum:  {sing: "Action forum", plur: "Actions forum",  fini: 'accomplie',e: 'e', le: "L’"}
  }

  # ---------------------------------------------------------------------
  #   SECTIONS PRINCIPALES
  # ---------------------------------------------------------------------

  # Section des travaux à démarrer
  #
  # +type+ (:task, :page, :quiz ou :forum)
  def section_unstarted_works type
    arr = auteur.tasks_unstarted(type)
    if arr.count > 0
      (
        "<h4>#{DATA_NAME_BY_TYPE[type][:plur]} à démarrer</h4>" +
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
    arr = auteur.tasks_undone(type)
    if arr.count > 0
      arr.collect{ |awork| awork.as_card(auteur: bureau.auteur) }.join('')
    else
      '<p class="small discret">Vous n’avez aucun travail courant.</p>' +
      message_si_aucun_travail
    end.in_section(id: 'current_works')
  end

  # Section des travaux récemment terminés
  #
  # +type+ (:task, :page, :quiz ou :forum)
  def section_recent_works type
    arr = auteur.tasks_recent(type)
    fini = DATA_NAME_BY_TYPE[type][:fini]
    '<hr />' +
    if arr.count > 0
      "<h4>#{DATA_NAME_BY_TYPE[type][:plur]} récemment #{fini}s</h4>" +
      arr.collect{ |awork| awork.as_card_relative(auteur: bureau.auteur, as_recent: true) }.join('')
    else
      e = DATA_NAME_BY_TYPE[type][:e]
      chose = DATA_NAME_BY_TYPE[type][:sing].downcase
      "<p class='small discret'>Aucun#{e} #{chose} récent#{e} n'a été #{fini}.</p>"
    end.in_section(id: 'completed_works')
  end

  # /Fin des sections principales
  # ---------------------------------------------------------------------




end #/Bureau
end #/Unan
