# encoding: UTF-8
class User

  # On connecte l'user
  def login
    app.session['user_id'] = id
    User::current= self
    set(session_id: app.session.session_id)
  end

  # On déconnecte l'user
  def deconnexion
    app.session['pseudo'] = pseudo # Pour s'en souvenir dans le message
    User::current= nil
    app.session['user_id'] = nil
    set(session_id: nil)
  end


end
