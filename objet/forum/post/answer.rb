class Forum
class Post

  # Appelé automatiquement quand on utilise la route post/id/answer
  # (REST).
  # Noter qu'en cas de sauvegarde, cette méthode est appelée APRÈS
  # la méthode save_answer.
  def answer
    # flash "Vous allez pouvoir écrire une réponse."
  end

  # Sauvegarde du message
  def save_answer
    # Marquer le message à valider if any
    bit_valid   = user.grade > 3 ? "1" : "0"
    answer_data.merge!(options: "#{bit_valid}")

    # On crée ou on update la réponse
    ianswer = Forum::Post::new(answer_data[:id].to_i_inn)
    if ianswer.id.nil?
      # Création de la réponse en tant que message
      answer_data.delete(:id)
      (ianswer.create answer_data)
    else
      # Actualisation de la réponse
      ianswer.update_content answer_data[:content]
    end
    @answer_data.merge!(id: ianswer.id)

    # TODO Le cron doit checker les nouveaux messages, même s'ils
    # ne sont pas enregistrés

    # on remet les paramètres modifiés et augmentés
    param(answer: answer_data)

  rescue Exception => e
    error e.message
  else
    flash "Réponse au message ##{id} enregistrée."
  end

  def answer_data
    @answer_data ||= begin
      hdata = param(:answer)
      hdata[:parent_id] = hdata[:parent_id].to_i
      hdata
    end
  end

end #/Post
end #/Forum

def post
  @post ||= site.objet # le message auquel la réponse s'adresse
end


case param(:operation)
when "save_answer" then post.save_answer
end
