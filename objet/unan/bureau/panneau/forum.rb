# encoding: UTF-8
=begin
Module de traitement du panneau 'forum' du bureau de l'user
=end
class Unan
class Bureau

  def repondre_messages_forum
    flash "J'envoie les réponses aux messages du forum"
  end

end #/Bureau
end #/Unan

case param(:operation)
when 'bureau_repondre_messages_forum'
  bureau.repondre_messages_forum
end
