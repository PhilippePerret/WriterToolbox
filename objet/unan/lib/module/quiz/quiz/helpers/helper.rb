# encoding: UTF-8
require 'json'
class Unan
class Quiz

  # = main =
  #
  # Méthode principale utilisé pour afficher un questionnaire
  # rempli et soumis.
  #
  def code_corrections_et_commentaires
    raise "Questionnaire inexistant" unless exist?
    classes_css = ['quiz']
    # Si ce n'est pas un questionnaire re-utilisable, on
    # lui met une classe pour le rendre moins apparent
    classes_css << 'quiz_corrected' unless multi?
    @code_corrections_et_commentaires ||= begin
      html = ""
      html << titre.in_div(class:'titre') unless no_titre?
      (
        html +
        commented_output        + # Les questions/réponses + commentaires
        code_for_regle_reponses + # Le code JS pour resélectionner les réponses
        boutons_sup               # Inauguré pour le bouton "Refaire" quand multi?
      ).in_div(class:classes_css.join(' '))
    end
  end

  # Les boutons supplémentaires pour un questionnaire
  # affiché
  def boutons_sup
    btns = ""
    # Si le questionnaire est re-usable (multi?) on offre
    # à l'utilisateur la possibilité de le recommencer
    btns << form_reuse if multi?

    return btns.in_div(class:'right btns')
  end

  # Formulaire proposant le bouton "Recommencer ce quiz" pour
  # les questionnaires multi? (donc remplissables autant de
  # fois qu'on le désire)
  def form_reuse
    (
      "quiz_reuse".in_hidden(name:'operation') +
      "quiz".in_hidden(name:'cong') +
      "1".in_hidden(name:'qru')+
      id.in_hidden(name:'qid') +
      work.id.in_hidden(name:'wid') +
      "Recommencer ce quiz".in_submit(class:'btn')
    ).in_form(action:"bureau/home?in=unan", class:'inline')
  end

  def unless_not_exists
    @unless_not_exists ||= begin
      raise "Le questionnaire ##{id} n'existe pas, désolé…" unless exist?
      true
    end
  end

  # Un code pour ré-affecter les réponses déjà données, dans le
  # cas où il faut ré-afficher le questionnaire (soit pour voir les
  # réponses données — admin) soit pour corriger une erreur.
  # C'est dans le fichier `calcul.rb` que se fabrique la donnée qui va
  # permettre à la méthode javascript `regle_reponses` de réaffecter les
  # valeurs.
  def code_for_regle_reponses
    debug "\n\n\nREPONSES_AUTEURS DANS CODE : #{reponses_auteur.inspect}"
    return '' if user.admin?
    <<-HTML
<script type="text/javascript">
var quiz_values = {
  quiz_id:#{id},
  reponses:#{reponses_auteur.to_json}
}
$(document).ready(function(){Quiz.regle_reponses(quiz_values)})
</script>

    HTML
  end

  # Construction du questionnaire
  # Return le code HTML du questionnaire
  # +options+
  #   corrections:  Si true, c'est un affichage mettant en exergue les
  #                 réponses de l'utilisateur et les réponses attendues.
  def build options = nil
    unless_not_exists

    options ||= Hash.new

    html = String.new
    html << description.in_div(class:'description') if description?
    html << questions.collect do |iquestion|
      iquestion.output( user.admin? ? nil : reponses_auteur[iquestion.id] )
    end.join.in_div(class:'questions')

    css = ['quiz']
    css << "no_titre" if no_titre?

    html = html.in_div( class: css.join(' ') )
    # On enregistre le questionnaire dans la table, sauf si c'est une
    # construction pour voir les corrections
    set(:output => html, updated_at: NOW) unless correction?
    # On retourne le code après l'avoir enregistré
    return html
  end

  # Lien pour afficher le quiz
  def lien_show atitre = nil, options = nil
    atitre ||= self.titre
    options ||= Hash.new
    href = "quiz/#{id}/show?in=unan"
    href += "&user_id=#{options[:user_id]}" if options[:user_id]
    options.merge!(href: href)
    atitre.in_a(options)
  end

  # Lien pour simuler le questionnaire
  def lien_simulation atitre = "simule"
    atitre.in_a( href:"quiz/#{id}/simulation?in=unan_admin", target: '_quiz_simulation_' )
  end
  alias :lien_simule :lien_simulation

end #/Quiz
end #/Unan
