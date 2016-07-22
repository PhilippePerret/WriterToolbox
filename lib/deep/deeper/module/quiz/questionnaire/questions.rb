# encoding: UTF-8
class ::Quiz

  # Retourne un Hash avec en clé l'identifiant de la question
  # et en valeur l'instance {Quiz::Question} de la question du
  # quiz courant
  def hquestions
    @hquestions ||= begin
      h = Hash.new
      questions_ids.each do |qid|
        h.merge!( qid => Question.new(self, qid) )
      end
      h
    end
  end

  # Retourne la liste des questions à afficher en fonction des
  # choix :
  #   - Il peut y avoir un nombre limité de questions à afficher
  #   - Il peut y avoir un ordre aléatoire
  def questions_ids_2_display
    @questions_ids_2_display ||= begin
      ids = questions_ids.dup
      ids = ids.shuffle.shuffle if aleatoire?
      nombre_max_questions ? ids[0..nombre_max_questions - 1] : ids
    end
  end

  # Pour ajouter une question
  #
  # +q_ref+ est une référence à la question qui peut être :
  #   - l'instance Quiz::Question de la question
  #   - l'identifiant de la question
  #
  # RETURN true en cas d'ajout, false dans le cas contraire.
  #
  def add_question q_ref
    qid =
      case q_ref
      when Fixnum then q_ref
      when Quiz::Question then q_ref.id
      else
        raise 'Il faut fournir une référence à la question correcte pour ajouter une question à un questionnaire.'
      end
    qid != nil || raise('La question n’a pas d’identifiant… Impossible de l’ajouter.')
    qids = (get(:questions_ids) || '').split(' ')
    if qids.include?( qid.to_s )
      raise 'Cette question se trouve déjà dans le questionnaire.'
    end
    qids << qid
    set(questions_ids: qids.join(' '))
    @questions_ids = qids # car mis en String sur la ligne précédente
  rescue Exception => e
    debug e
    error e.message
  else
    return true
  end

end #/Quiz
