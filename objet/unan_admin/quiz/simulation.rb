# encoding: UTF-8
=begin
Note : On passe par un fichier ruby pour qu'il soit chargé par la
route et que donc Unan::Quiz soit connu avant de lancer la simulation
=end

# On a besoin de la classe UnanQuiz
Unan::require_module 'quiz'
# On a aussi besoin de certaines méthode Unan::Bureau (comme
# celle pour fabriquer le bouton submit)
Unan::require_module 'bureau'

class UnanAdmin
class Quiz
  class << self
    def get quiz_id
      Unan::Quiz::new(quiz_id)
    end
  end # << self
end #/Quiz
end #/UnanAdmin

# Méthode-raccourci pour obtenir l'instance du questionnaire
# courant (ici comme dans la vue simulation.erb)
def iquiz
  @iquiz ||= site.current_route.instance
end


class Unan
class Quiz

  # Pour contenir le texte qui sera affiché suite à
  # l'évaluation du questionnaire en mode simulation
  attr_reader :resultat_simulation

  # Méthode appelée à la soumission du questionnaire dans la
  # page de simulation.
  def on_submit
    # debug "-> Unan::Quiz::on_submit"
    # debug "Nombre de questions : #{questions.count}"

    # Évaluer le questionnaire
    if evaluate
      dprov = data2save.dup
      dprov[:reponses] = JSON.parse(dprov[:reponses])#.pretty_inspect
      current_admin_id = User::current.id.freeze
      User::current = User::get(2)
      @resultat_simulation =
      ("Refaire ce questionnaire".in_a(href:"quiz/#{id}/simulation?in=unan_admin")).in_div(class:'right') +
        "Noter que ce résultat est calculé pour #{user.pseudo} (##{user.id})".in_div(class:'small italic') +
        "Note obtenue pour ce questionnaire, sur 20 ou nil : <strong>#{note_sur_20_for.inspect}</strong>".in_div +
        "Jour-programme courant : <strong>#{user_pday_courant}</strong>".in_div +
        "Moyenne correspondant au jour-programme : <strong>#{moyenne_minimum}</strong>".in_div +
        "Écart par rapport à la moyenne : #{ecart_moyenne}".in_div +
        "<hr /><h3>Message après soumission</h3>" +
        commented_output +
        "<hr />" +
        "Donnée qui serait enregistrée dans la table de l'user :".in_p +
        "<pre style='white-space:pre-wrap;'>\n#{dprov.pretty_inspect}\n</pre>"

      User::current = User::get(current_admin_id)
    else
      @resultat_simulation = "Une erreur est survenue."
    end

  rescue Exception => e
    error e.message
    debug e
  end
end #/Quiz
end #/Unan

case param(:operation)
when 'bureau_save_quiz'
  # Noter que dans la version en réel, il faut d'abord instancier
  # le questionnaire à l'aide de param(:quiz)[:id]
  iquiz.on_submit
end
