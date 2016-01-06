# encoding: UTF-8
=begin
Class User
----------
Classe
=end
class User
  class << self

    def get id
      @instances ||= Hash::new
      @instances[id] ||= User::new(id)
    end

    # {User} Instance de l'user courant
    # Soit un user identifié, soit un invité, mais toujours
    # une instance User en tout cas.
    def current= u
      @current = u
    end

    def current
      if @current == nil && app.session['user_id']
        debug "User ID en session : #{app.session['user_id']}"
        uchecked = get(app.session['user_id'].to_i)
        if uchecked.get(:session_id) == app.session.session_id
          @current = uchecked
          debug "Session identique => OK => User courant : #{@current.pseudo} (##{@current.id})"
        end
      end
      @current ||= User::new
    end

    def bind; binding() end

  end # << self
end # User
