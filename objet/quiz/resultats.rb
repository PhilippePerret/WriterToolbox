# encoding: UTF-8
raise_unless_admin
=begin

  Module pour l'affichage des résultats de tous les quiz

=end
class Quiz
class << self

  def rapport_resultats
    allquiz.collect do |quiz|
      quiz.rapport_resultat # cf. ci-dessous
    end.join.in_ul(id:'resultats_all_quiz')
  end

end #/<< self
# ---------------------------------------------------------------------
#
#   Méthodes d'instance pour construire le résultat
#
# ---------------------------------------------------------------------
  def rapport_resultat
    (
      titre.in_h4 +
      span_nombre_resultats +
      span_best_note +
      span_pire_note
    ).in_div(class: 'resultat')
  end

  def nombre_resultats
    @nombre_resultats ||= resulats_rows.count
  end

  def span_nombre_resultats
    @span_nombre_resultats ||= begin
      "Nombre réponses : #{nombre_resultats}".in_span(class: 'data')
    end
  end
  def span_best_note
    @span_best_note ||= begin
      note = nombre_resultats > 0 ? '%.1f' % best_note : '---'
      "Meilleure note  : #{note}".in_span(class: 'data note')
    end
  end
  def span_pire_note
    @span_pire_note ||= begin
      note = nombre_resultats > 0 ? '%.1f' % pire_note : '---'
      "Pire note  : #{note}".in_span(class: 'data note')
    end
  end
  def resulats_rows
    @resulats_rows ||= begin
      @best_note = 0
      @pire_note = 20
      table_resultats.select(where: {quiz_id: id}).collect do |hres|
        hres[:note] > @best_note && @best_note = hres[:note]
        hres[:note] < @pire_note && @pire_note = hres[:note]
        hres #collecté
      end
    end
  end

  def best_note ; @best_note end
  def pire_note ; @pire_note end

end #/Quiz
