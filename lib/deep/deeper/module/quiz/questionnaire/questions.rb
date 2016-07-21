# encoding: UTF-8
class ::Quiz

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
  rescue Exception => e
    debug e
    error e.message
  else
    return true
  end

end #/Quiz
