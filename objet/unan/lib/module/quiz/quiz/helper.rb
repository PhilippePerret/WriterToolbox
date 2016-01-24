# encoding: UTF-8
require 'json'
class Unan
class Quiz

  def unless_not_exists
    @unless_not_exists ||= begin
      raise "Le questionnaire ##{id} n'existe pas, désolé…" unless exist?
      true
    end
  end

  # {StringHtml} Retourne le code HTML pour afficher
  # le questionnaire.
  # Ce code est enregistré dans la propriété :output
  # dans la base de données, pour accélérer.
  # Si +forcer+ est true, on force la construction du questionnaire
  # même si la donnée output est définie dans la base. C'est utilisé
  # par l'édition pour actualiser chaque fois.
  # Noter que puisque la méthode get_all est appelée en mode édition,
  # ce output est défini. C'est pourquoi il faut mettre le forcer et
  # le out_of_date? avant de tester @output contre nil.
  def output forcer = false
    unless_not_exists
    @output = nil if forcer || out_of_date?
    @output ||= begin
      code = get(:output)
      code = build if forcer || code.empty?
      code += code_for_regle_reponses
      code
    end
  end

  # {StringHTML} Retourne le code HTML intégral avec le formulaires
  # et les boutons pour soumettre chaque questionnaires
  # +options+
  #   forcer:   Si true, on force la reconstruction du questionnaire
  #   simulation:  Si true, c'est une simulation
  def output_in_form options = nil
    options ||= Hash::new

    form_action = options[:simulation] ? "quiz/#{id}/simulation?in=unan_admin" : "bureau/home?in=unan&cong=quiz"
    form = String::new
    form << 'bureau_save_quiz'.in_hidden(name:'operation')
    form << id.in_hidden(name:'quiz[id]', id:"quiz_id-#{id}")
    form << output(forcer = !!options[:forcer])
    form << bureau.submit_button("Soumettre le questionnaire", {discret: false, tiny: false})
    code = form.in_form(id:"form_quiz_#{id}", class:'quiz', action: form_action)
    # code += "".in_div(style:'clear:both;')
    # debug code
    code
  end

  # Un code pour ré-affecter les réponses déjà données, dans le
  # cas où il faut ré-afficher le questionnaire (soit pour voir les
  # réponses données — admin) soit pour corriger une erreur.
  # C'est dans le fichier `calcul.rb` que se fabrique la donnée qui va
  # permettre à la méthode javascript `regle_reponses` de réaffecter les
  # valeurs.
  def code_for_regle_reponses
    <<-HTML
<script type="text/javascript">
var quiz_values = {
  quiz_id:#{id},
  reponses:#{@reponses_for_javascript.to_json}
}
$(document).ready(function(){Quiz.regle_reponses(quiz_values)})
</script>

    HTML
  end

  # Construction du questionnaire
  # Return le code HTML du questionnaire
  def build
    unless_not_exists
    html = String::new
    html << titre.in_div(class:'titre') unless no_titre?
    html << description.in_div(class:'description') if description?
    html << questions.collect { |iquestion| iquestion.output }.join.in_div(class:'questions')

    css = ['quiz']
    css << "no_titre" if no_titre?

    html = html.in_div( class: css.join(' ') )
    # On enregistre le questionnaire dans la table
    set(:output => html, updated_at: NOW)
    # On retourne le code après l'avoir enregistré
    return html
  end


end #/Quiz
end #/Unan
