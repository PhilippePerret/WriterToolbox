# encoding: UTF-8
require 'json'
class Unan
class Quiz

  def code_corrections_et_commentaires
    @code_corrections_et_commentaires ||= begin
      html = ""
      html << titre.in_div(class:'titre') unless no_titre?
      (
        html +
        commented_output        + # Les questions/réponses + commentaires
        code_for_regle_reponses   # Le code JS pour resélectionner les réponses
      ).in_div(class:'quiz quiz_corrected')
    end
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
    return "" if user.admin?
    <<-HTML
<script type="text/javascript">
var quiz_values = {
  quiz_id:#{id},
  reponses:#{auteur_reponses.to_json}
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

    options ||= Hash::new

    html = String::new
    html << description.in_div(class:'description') if description?
    html << questions.collect do |iquestion|
      iquestion.output( user.admin? ? nil : auteur_reponses[iquestion.id] )
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

  # Lien pour éditer
  def lien_edit titre = "edit"
    titre.in_a( href:"quiz/#{id}/edit?in=unan_admin", target: '_quiz_edition_' )
  end

  # Lien pour simuler le questionnaire
  def lien_simulation titre = "simule"
    titre.in_a( href:"quiz/#{id}/simulation?in=unan_admin", target: '_quiz_simulation_' )
  end
  alias :lien_simule :lien_simulation

end #/Quiz
end #/Unan
