# encoding: UTF-8
=begin
Module de traitement du panneau 'forum' du bureau de l'user

À utiliser pour répondre aux messages ou autre validation

<form class="dim3070" action="bureau/home?in=unan&cong=forum" method="post">
  <%# TODO Ici, on trouvera une liste des messages écrits à l'user, avec un champ de texte pour y répondre %>
  <%= 'bureau_repondre_messages_forum'.in_hidden(name:'operation') %>
  <%= bureau.submit_button("Envoyer réponses aux messages") %>
</form>

=end
class Unan
class Bureau

  def repondre_messages_forum
    flash "J'envoie les réponses aux messages du forum"
  end

  # Tous les messages forum, sans exception
  def messages_forum
    @messages_forum ||= begin
      current_pday.undone(:forum)
    end
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
