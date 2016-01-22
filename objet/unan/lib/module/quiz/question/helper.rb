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
    choix = reponses.collect do |hr|
      debug "hr: #{hr.inspect}"
      cb_id   = "q-#{id}_r-#{hr[:id]}".freeze

      # En menu select
      if type_a == "m"
        hr[:libelle].in_option(value: "r-#{hr[:id]}")
      # EN case à cocher (plusieurs choix)
      elsif type_c == "c"
        cb_name = "q-#{id}_r-#{hr[:id]}".freeze
        hr[:libelle].in_checkbox(id:cb_id, name:cb_name).in_li
      # EN bouton radio
      elsif type_c == "r"
        cb_name = "q-#{id}".freeze
        hr[:libelle].in_radio(id:cb_id, name:cb_name, value: hr[:id]).in_li
      end
    end.join

    if type_a == "m"
      type_c = "r" # pour avoir un li de class "r m"
      choix = choix.in_select(name:"q_#{id}").in_li
    end

    (
      question.in_div(class:'q') +
      choix.in_ul(class:"r #{type_a}")
    ).in_div(class:'question')
  end

end #/Question
end #/Quiz
end #/Unan
