# encoding: UTF-8
class Unan
class Quiz

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
    @output = nil if forcer || out_of_date?
    @output ||= begin
      code = get(:output)
      code = build if code.empty?
      code
    end
  end


  # Construction du questionnaire
  # Return le code HTML du questionnaire
  def build
    html = String::new
    html << titre.in_div(class:'titre') unless no_titre?
    html << description.in_div(class:'description') if description?
    html << questions.collect { |iquestion| iquestion.output }.join.in_div(class:'questions')

    css = ['quiz']
    css << "no_titre" if no_titre?

    html = html.in_div( class: css.join(' ') )
    # On enregistre le questionnaire dans la table
    set(:output => html, updated_at: NOW)
    # On retourne le code
    return html
  end

end #/Quiz
end #/Unan
