# encoding: UTF-8
=begin
Class User
----------
Classe
=end
class User

  extend MethodesMainObjets

  class << self

    def get id
      @instances ||= Hash::new
      @instances[id] ||= User::new(id)
    end

    def get_by_pseudo pseudo
      u = table_users.select(where:"pseudo = '#{pseudo}'", colonnes: [:id]).values.first
      return nil if u.nil?
      get(u[:id])
    end

    # {User} Instance de l'user courant
    # Soit un user identifié, soit un invité, mais toujours
    # une instance User en tout cas.
    def current= u
      @current = u
    end

    # {User} Retourne l'utilisateur courant. Le récupère
    # dans la session si nécessaire.
    # Notes
    #   * C'est la méthode qui est utilisée par la
    #     méthode handy `current_user`.
    #   * C'est la méthode qui incrémente la variable session
    #     du nombre de pages visitées au cours de cette session
    #     permettant notamment de régler l'opacité de l'interface
    def current
      @current ||= begin
        debug "-> current (@current non défini)"
        # debug "-> current (app.session['user_id'] = #{app.session['user_id']})"
        user_id =
          if app.session['user_id'].nil?
            nil
          else
            app.session['user_id'].to_i
          end

        # l'user courant
        curuser = User::new(user_id)

        user_id && curuser.incremente_nombre_pages

        debug "user_id = #{user_id}"
        debug "<- current"

        # Pour le mettre dans @current
        curuser
      end
    end

    def bind; binding() end

    # Retourne la liste des users comme un Array d'instances User,
    # classée par les pseudos
    def as_array
      table_users.select(order:"pseudo ASC", colonnes:[]).keys.collect do |uid|
        new(uid)
      end
    end

  end # << self
end # User
