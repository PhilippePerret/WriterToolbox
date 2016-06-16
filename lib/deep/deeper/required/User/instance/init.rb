# encoding: UTF-8
=begin

Si un dossier ./objet/user/lib existe, on le charge toujours

=end
class User
  class << self

    def init
      folder_custom_lib.require if folder_custom_lib.exist?
    end

    def folder_custom_lib
      @folder_custom_lib ||= site.folder_objet+'user/lib'
    end
  end

  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  # Incrémentation du nombre de pages visitées si c'est la
  # même session que précédemment
  def incremente_nombre_pages
    if get(:session_id) == app.session.session_id
      app.session['user_nombre_pages'] += 1
    end
  end

  # À l'initialisation de l'user (en fait, au chargement de
  # la page), on enregistre toujours sa dernière connexion
  def set_last_connexion
    rt = site.current_route ? site.current_route.route : nil
    # On ne doit pas enregistrer la dernière connexion si
    # c'est une déconnexion (sinon ça pose problème si l'user
    # a choisi de rejoindre sa dernière page consultée après
    # son login)
    return if rt.to_s =~ /(deconnexion|logout)$/
    User::table_connexions.set(self.id, {id: self.id, route: rt, time: NOW})
  end

  # Retourne la date de dernière connexion de l'user, ou NIL
  def last_connexion
    @last_connexion ||= begin
      rs = User::table_connexions.get(self.id)
      rs.nil? ? nil : rs[:time]
    end
  end

end
