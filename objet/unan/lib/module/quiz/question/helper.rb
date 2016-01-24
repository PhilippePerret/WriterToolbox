# encoding: UTF-8
=begin
Méthodes d'helper des instances Unan::Quiz::Question
=end
class Unan
class Quiz
class Question

  # Mise en forme de la question pour affichage
  def output
    unless exist?
      return "[Question ##{id} inexistante]"
    end
    prefix = quiz_id.nil? ? "quiz" : "quiz-#{quiz_id}"
    choix = reponses.collect do |hr|
      cb_id   = "#{prefix}_q_#{id}_r_#{hr[:id]}".freeze

      # En menu select
      if type_a == "m"
        hr[:libelle].in_option(value: "r_#{hr[:id]}")
      # EN case à cocher (plusieurs choix)
      elsif type_c == "c"
        cb_name = "quiz[q_#{id}_r_#{hr[:id]}]".freeze
        hr[:libelle].in_checkbox(id:cb_id, name:cb_name).in_li
      # EN bouton radio
      elsif type_c == "r"
        cb_name = "quiz[q_#{id}]".freeze
        hr[:libelle].in_radio(id:cb_id, name:cb_name, value: hr[:id]).in_li
      end
    end.join

    if type_a == "m"
      data_select = {name:"quiz[q_#{id}]", id:"#{prefix}_q_#{id}"}
      data_select.merge!(multiple: true) if type_c == "c"
      choix = choix.in_select( data_select ).in_li
    end

    (
      infos_admin                     +
      question.in_div(class:'q')      +
      indications                     +
      choix.in_ul(class:"r #{type_a}")
    ).in_div(class:'question', id:"question-#{id}")
  end

  def infos_admin
    "##{id}".in_div(class:'tiny fright adminonly')
  end

  def indications
    ind = String::new
    ind << indication unless indication.empty?
    ind << indication_when_checkboxes if type_c == "c"
    ind.in_div(class:'indication')
  end

  # Texte d'aide pour les questions qui ont des checkboxes au lieu
  # des radios groupes habituels.
  def indication_when_checkboxes
    @indication_when_checkboxes ||= <<-STR
    Cochez tous les choix qui vous semblent pertinents#{indication_ajout_when_select_multiple if type_a=='m'}.
    STR
  end
  def indication_ajout_when_select_multiple
    @indication_ajout_when_select_multiple ||= " (tenir la touche CMD sur Mac ou CTRL sur Unix/Windows pour plusieurs choix)"
  end
end #/Question
end #/Quiz
end #/Unan
