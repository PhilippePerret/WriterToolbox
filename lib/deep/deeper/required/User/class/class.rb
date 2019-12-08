# encoding: UTF-8
=begin
Class User
----------
Classe
=end
class User

  extend MethodesMainObjet

  class << self

    def get id
      @instances ||= {}
      @instances[id] ||= User::new(id)
    end

    def get_by_pseudo pseudo
      u = table_users.select(where: {pseudo: pseudo}, colonnes: []).first
      return nil if u.nil?
      get(u[:id])
    end

    # {User} Instance de l'user courant
    # Soit un user identifié, soit un invité, mais toujours
    # une instance User en tout cas.
    def current= u
      @current = u
      if u.nil?
        reset_current_user if u.nil?
      else
        app.session['user_id'] = u.id
      end
    end

    # Permet, pour les tests, de réinitialiser complètement
    # à nil l'user (lorsqu'il a été défini précédemment par exemple)
    def reset_current_user
      app.session['user_id'] = nil
    end

    # Retourne l'user#id
    def tryReconnectWithCookie

      cookieSessionId = page.cgi.cookies['sessionid'].first
      cookieBoa = page.cgi.cookies['SESSIONBOA'].first
      cookieScenariopole = page.cgi.cookies['SCENARIOPOLE'].first

      sessionId = cookieScenariopole || cookieBoa || cookieSessionId
      if cookieScenariopole
        debug "Je prends la session scénariopole : #{cookieScenariopole}"
      elsif cookieBoa
        debug "je prends la session boa : #{cookieBoa}"
      elsif cookieSessionId
        debug "Je prends le session id envoyé : #{cookieSessionId}"
      else
        debug "IMPOSSIBLE DE TROUVER UN SESSION-ID DISPONIBLE"
        return
      end

      site.db.use_db('hot')
      res = site.db.execute("SELECT * FROM `sessions` WHERE session_id = ?", [sessionId])
      res.nil_if_empty || begin
        debug "IMPOSSIBLE DE TROUVER LA DONNÉE SESSION '#{sessionId}' - je ne reconnecte aucun user"
        return
      end
      res = res.first
      resIP = res[:ip_address]
      curIP = ENV['REMOTE_ADDR']||ENV['HTTP_X_FORWARDED_FOR']||ENV['X_FORWARDED_FOR']
      resIP == curIP || begin
        debug "ERREUR : MAUVAISE ADRESSE IP - je ne peux pas reconnecter l'user"
        return
      end
      res[:created_at] + 3600 > Time.now.to_i || begin
        debug "ERREUR : SESSION TROP VIEILLE - Je ne reconnecte pas l'user"
        return
      end
      debug "JE RECONNECTE ##{res[:user_id]}"

      now = Time.now.to_i
      route = site.full_route
      user_id = res[:user_id]
      currentIp = ENV['REMOTE_ADDR']||ENV['HTTP_X_FORWARDED_FOR']||ENV['X_FORWARDED_FOR']
      # INSERT INTO table (id, name, age) VALUES(1, "A", 19) ON DUPLICATE KEY UPDATE
      # name="A", age=19
      query = "INSERT INTO `sessions`"+
              " (session_id, user_id, ip_address, route, created_at)"+
              " VALUES (?, ?, ?, ?, ?)"+
              " ON DUPLICATE KEY UPDATE route = ?, created_at = ?, ip_address = ?"
      values = [
          sessionId, user_id, currentIp, route, now,
          route, now, currentIp
        ]
      # Soumettre la requête
      site.db.use_db('hot')
      site.db.execute(query, values)

      return res[:user_id]
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
        debug "Au début de User::current, app.session['boa_user_id'] = #{app.session['boa_user_id']}"

        user_id = User.tryReconnectWithCookie()

        user_id ||=
          if app.session['boa_user_id'].nil?
            nil
          else
            app.session['boa_user_id'].to_i
          end

        # l'user courant
        curuser = User.new(user_id)

        curuser && begin
          app.session['boa_user_id'] = user_id
          curuser.incremente_nombre_pages
        end

        debug "À la fin de User::current, app.session['boa_user_id'] = #{app.session['boa_user_id']}"

        # Pour le mettre dans @current
        curuser
      end
    end

    def bind; binding() end

    # Retourne la liste des users comme un Array d'instances User,
    # classée par les pseudos
    def as_array
      table_users.select(order:"pseudo ASC", colonnes:[]).collect do |huser|
        new(huser[:id])
      end
    end

  end # << self
end # User
