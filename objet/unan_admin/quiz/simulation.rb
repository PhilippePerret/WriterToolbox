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

class Unan
class Quiz

  # Méthode appelée à la soumission du questionnaire
  def on_submit
    debug "-> Unan::Quiz::on_submit"
    debug "Nombre de questions : #{questions.count}"

    # Récolte des réponses par type de question
    @reponses                = Hash::new
    @reponses_for_javascript = Array::new
    une_erreur = false
    prefix = "quiz-#{id}"

    # Boucler sur chaque question du questionnaire
    questions.each do |question|
      qid = question.id
      debug "Valeur question ##{qid}"

      # On récupère la valeur donnée à la question, qui doit
      # être forcément définie.
      hvalue = question.value
      # Attention, hvalue[:id] est un Fixnum, mais en cas de
      # menu select à multiple choix, c'est un Array qui contient
      # les Fixnum des identifiants de chaque item choisi.

      if hvalue[:error]
        une_erreur = true
        @reponses_for_javascript << { qid:qid, type:'error' }
        debug "Aucune réponse donnée"
      else
        # Pour remettre les réponses en cas de ré-affichage
        hvalue[:jid] = "#{hvalue[:tagname]}##{prefix}_#{hvalue[:jid]}"
        @reponses_for_javascript << { jid:hvalue[:jid], type:hvalue[:type], value:hvalue[:value] }
        debug "-> #{hvalue.inspect}"
      #   @reponses.merge!( qid => value )
      end
    end
  rescue Exception => e
    error e.message
    debug e
  end
end #/Quiz
end #/Unan

# Méthode-raccourci pour obtenir l'instance du questionnaire
# courant (ici comme dans la vue simulation.erb)
def iquiz
  @iquiz ||= site.current_route.instance
end

case param(:operation)
when 'bureau_save_quiz'
  # Noter que dans la version en réel, il faut d'abord instancier
  # le questionnaire à l'aide de param(:quiz)[:id]
  iquiz.on_submit
end
