# encoding: UTF-8
=begin

  Extension de la class Quiz pour la liste des quiz

=end
class ::Quiz

  # Mettre ici tous les suffixes qui peuvent être listés
  SUFFIX_BASES = ['biblio']

  class << self

    # = main =
    #
    # Retourne le code HTML de la liste complète des
    # quiz
    def as_ul
      allquiz.collect do |quiz|
        quiz.as_li
      end.join('').in_ul(id: 'quizes', class: 'quiz_list')
    end

    def hors_liste_as_ul
      current_suffixe = nil
      allquiz_hors_liste.collect do |quiz|
        if current_suffixe != quiz.suffix_base
          current_suffixe = quiz.suffix_base.freeze
          human_titre_for_suffix_base(quiz.suffix_base).in_h4
        else
          ''
        end +
        quiz.as_li
      end.join('').in_ul(id: 'quizes_hors_liste', class: 'quiz_list')
    end

    def human_titre_for_suffix_base suf
      case suf
      when 'unan'     then 'Programme UNAN'
      when 'biblio'   then 'Quiz bibliographiques'
      when 'test'     then 'Questionnaires test'
      else "Quiz des #{suf}"
      end
    end
  end #/<< self

  # ---------------------------------------------------------------------
  #   Méthodes d'instances
  # ---------------------------------------------------------------------
  def as_li
    (
      span_boutons +
      titre.in_span(class: 'qtitre') +
      description_formated.in_div(class: 'qdescription') +
      (
        hdate_creation +
        span_nombre_fois +
        hdate_derniere_fois +
        span_note_moyenne +
        span_note_max +
        span_note_min
      ).in_div(class: 'qinfos')
    ).in_li(id: "quiz-#{suffix_base}-#{id}", class: 'li_quiz')
  end

  def span_boutons
    (
      span_bouton_try +
      span_bouton_edit
    ).in_span(class: 'qlink btns')
  end
  def span_bouton_try
    'Le tenter'.in_a(href: "quiz/#{id}/show?qdbr=#{suffix_base}", class: 'tiny btn discret')
  end
  def span_bouton_edit
    user.admin? || (return '')
    'Éditer'.in_a(href: "quiz/#{id}/edit?qdbr=#{suffix_base}", class: 'tiny btn discret')
  end
  def hdate_creation
    cdate =
      if created_at.nil?
        '- Date non spécifiée -'
      else
        created_at.as_human_date(true, false)
      end
    "Création#{THIN}:#{THIN} #{cdate.in_span(class: 'cdate')}".in_span
  end
  def span_nombre_fois
    data_generales || (return '')
    (
      "Nombre#{THIN}de#{THIN}tentatives#{THIN}:#{THIN}" +
      data_generales[:count].to_s.in_span(class: 'count')
    ).in_span
  end
  def hdate_derniere_fois
    data_generales || ( return '' )
    (
      "Dernière#{THIN}tentative#{THIN}:#{THIN}" +
      data_generales[:updated_at].as_human_date(true, false).in_span(class: 'pdate')
    ).in_span
  end
  def span_note_moyenne
    data_generales || (return '')
    (
      "Moyenne#{THIN}des#{THIN}notes#{THIN}:#{THIN}" +
      data_generales[:moyenne].to_f.to_s.in_span(class: 'nmoy') + '/20'
    ).in_span
  end
  def span_note_max
    data_generales || (return '')
    (
      "Meilleure#{THIN}note#{THIN}:#{THIN}" +
      data_generales[:note_max].to_f.to_s.in_span(class: 'nmax') + '/20'
    ).in_span
  end
  def span_note_min
    data_generales || (return '')
    (
      "Pire note#{THIN}:#{THIN}" +
      data_generales[:note_min].to_f.to_s.in_span(class: 'nmin') + '/20'
    ).in_span
  end
end #/Quiz
