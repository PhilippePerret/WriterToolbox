# encoding: UTF-8
class User

  # Pour envoyer un message à l'user
  def send_mail data_mail
    site.send_mail( data_mail.merge(to: self.mail) )
  end

  # Méthode qui procède au login des informations de
  # l'user qui vient de s'identifier.
  # Cette méthode est utilisée par la méthode `login`
  # ci-dessous
  # La méthode a été "isolée" pour pouvoir être utilisée
  # lors d'une reconnexion par des scripts, comme après
  # l'exécution des tests.
  def proceed_login
    app.session['user_id'] = id
    # On met l'utilisateur en utilisateur courant
    User::current= self
    # reset_user_current
    # Variable session permettant de savoir combien de pages a
    # déjà visité l'utilisateur (pour baisser l'opacité des
    # éléments annexes de l'interface)
    app.session['user_nombre_pages'] = 1
    set(session_id: app.session.session_id)
  end

  # On connecte l'user et on le redirige vers la
  # direction demandée ou logique.
  # On met également en session une variable qui va permettre
  # de gérer la transparence de l'interface (il doit disparaitre
  # petit à petit à mesure que l'utilisateur visite les pages)
  def login

    unless mail_confirmed? || admin? || for_paiement?
      error "Désolé #{pseudo}, mais vous ne pouvez pas vous reconnecter avant d’avoir" +
            ' confirmé votre adresse-mail.' +
            '<br><br>Cette confirmation se fait grâce à un lien contenu dans le message' +
            ' qui vous a été transmis par mail après votre inscription. Merci de' +
            ' vérifier votre boite aux lettres virtuelle.' +
            '<br><br>Vous n’avez plus ce message ?… Pas de problème :' +
            '<br><a href="user/new_mail_confirmation">Renvoyer un message de confirmation</a>.'
      # redirect_to :home
      redirect_to 'user/deconnexion'
      return # Pour ne pas enregistrer de message de bienvenue
    end

    proceed_login


    require './data/secret/known_users.rb'
    flash( if KNOWN_USERS.has_key?( id ) && KNOWN_USERS[id][:messages_accueil]!=nil
      KNOWN_USERS[id][:messages_accueil].shuffle.shuffle.first
    else
      'Bienvenue, %s !' % pseudo
    end)

    # Si une méthode doit être appelée après le login, on
    # l'appelle.
    if self.respond_to? :do_after_login
      self.send(:do_after_login)
    end

    if param(:login) && param(:login)[:back_to].nil_if_empty
      # Une redirection est demandée
      redirect_to param(:login)[:back_to]
    elsif self.respond_to?(:redirect_after_login)
      # Sinon, une redirection est peut-être définie
      # par défaut par les préférences ou l'application
      self.send(:redirect_after_login)
    end
    return true
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
  #
  # Noter que ça ne détruit pas vraiment les données, mais que ça
  # marque simplement l'user détruit (4e bit des options)
  def remove
    self.app_remove if self.respond_to?( :app_remove )
    folder.remove if folder.exist? # Dossier des données et databases persos
    set_option(:destroyed, 1)
  end

end
