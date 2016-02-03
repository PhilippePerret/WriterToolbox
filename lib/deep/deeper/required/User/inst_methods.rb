# encoding: UTF-8
class User

  # Pour envoyer un message à l'user
  def send_mail data_mail
    site.send_mail( data_mail.merge(to: self.mail) )
  end

  # On connecte l'user
  def login
    unless mail_confirmed?
      return error "Désolé, mais vous ne pouvez pas vous reconnecter avant d'avoir confirmé votre mail à l'aide du message qui vous a été envoyé."
    end
    app.session['user_id'] = id
    User::current= self
    set(session_id: app.session.session_id)
    self.send(:redirect_after_login) if self.respond_to?(:redirect_after_login)
  end

  # On déconnecte l'user
  def deconnexion
    app.session['pseudo'] = pseudo # Pour s'en souvenir dans le message
    User::current= nil
    app.session['user_id'] = nil
    set(session_id: nil)
  end

  # Détruit l'user
  # S'il y a une procédure propre à l'application, il faut la définir
  # dans `User#app_remove` qui sera appelé avant la destruction de l'user
  # dans la table général des users.
  def remove
    self.app_remove if self.respond_to?( :app_remove )
    folder.remove if folder.exist? # Dossier des données et databases persos
    User::table.delete(id)
  end

end
