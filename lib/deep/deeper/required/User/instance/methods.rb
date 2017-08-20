# encoding: UTF-8
class User

  # Pour envoyer un message à l'user
  def send_mail data_mail
    site.send_mail( data_mail.merge(to: self.mail) )
  end

  # Détruit l'user
  # --------------
  # S'il y a une procédure propre à l'application, il faut la définir
  # dans `User#app_remove` qui sera appelé avant la destruction de l'user
  # dans la table général des users.
  #
  # Noter que maintenant ça détruit vraiment l'auteur dans la base de
  # données.
  def remove
    self.respond_to?( :app_remove ) && self.app_remove
    # set_option(:destroyed, 1)
    User.table_users.delete({id: self.id})
  end

end
