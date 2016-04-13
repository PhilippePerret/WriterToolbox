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
    debug "-> login"
    unless mail_confirmed? || admin? || for_paiement?
      return error "Désolé, mais vous ne pouvez pas vous reconnecter avant d'avoir confirmé votre mail à l'aide du message qui vous a été envoyé."
    end
    app.session['user_id'] = id

    # On met l'utilisateur en utilisateur courant
    debug "Je mets User::current à l'user ##{id}"
    User::current= self
    reset_user_current
    debug "J'ai mmis user (User::current) à l'id : ##{user.id}"

    # Variable session permettant de savoir combien de pages a
    # déjà visité l'utilisateur (pour baisser l'opacité des
    # éléments annexes de l'interface)
    app.session['user_nombre_pages'] = 1

    set(session_id: app.session.session_id)

    require './data/secret/known_users.rb'
    flash( if KNOWN_USERS.has_key?( id )
      KNOWN_USERS[id][:messages_accueil].shuffle.shuffle.first
    else
      "Bienvenue, #{pseudo} !"
    end)

    # Si une méthode doit être appelée après le login, on
    # l'appelle.
    if self.respond_to? :do_after_login
      self.send(:do_after_login)
    end

    if param(:login)[:back_to].nil_if_empty
      # Une redirection est demandée
      debug "   Redirection demandée : #{param(:login)[:back_to].inspect}"
      redirect_to param(:login)[:back_to]
    elsif self.respond_to?(:redirect_after_login)
      # Sinon, une redirection est peut-être définie
      # par défaut par les préférences ou l'application
      debug "  Redirection après login (appel de User#redirect_after_login)"
      self.send(:redirect_after_login)
    end
    debug "<- login"
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
