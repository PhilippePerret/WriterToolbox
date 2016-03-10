# encoding: UTF-8
class User

  # Pour envoyer un message à l'user
  def send_mail data_mail
    site.send_mail( data_mail.merge(to: self.mail) )
  end

  # On connecte l'user et on le redirige vers la
  # direction demandée ou logique.
  # On met également en session une variable qui va permettre
  # de gérer la transparence de l'interface (il doit disparaitre
  # petit à petit à mesure que l'utilisateur visite les pages)
  def login
    unless mail_confirmed? || admin? || for_paiement?
      return error "Désolé, mais vous ne pouvez pas vous reconnecter avant d'avoir confirmé votre mail à l'aide du message qui vous a été envoyé."
    end
    app.session['user_id'] = id
    # Variable session permettant de savoir combien de pages a
    # déjà visité l'utilisateur (pour baisser l'opacité des
    # éléments annexes de l'interface)
    app.session['user_nombre_pages'] = 1
    User::current= self
    set(session_id: app.session.session_id)
    if param(:login)[:back_to]
      # Une redirection est demandée
      redirect_to param(:login)[:back_to]
      flash "Bienvenue, #{pseudo} !"
    elsif self.respond_to?(:redirect_after_login)
      # Sinon, une redirection est peut-être définie
      # par défaut par les préférences ou l'application
      self.send(:redirect_after_login)
    end
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