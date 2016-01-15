# encoding: UTF-8
=begin
Module de traitement du panneau 'forum' du bureau de l'user
=end
class Unan
class Bureau

  def repondre_messages_forum
    flash "J'envoie les réponses aux messages du forum"
  end

  # Cf. dans home.rb le traitement et la fonction de
  # cette méthode
  def missing_data
    # TODO Si ces messages sont à répondre, l'indiquer clairement ici
    # TODO Si des réponses à des messages ont été données (c'est pas la
    # même chose ?) idem
  end

end #/Bureau
end #/Unan

case param(:operation)
when 'bureau_repondre_messages_forum'
  bureau.repondre_messages_forum
end
