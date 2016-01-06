# encoding: UTF-8
require 'digest/md5'
class User
  class << self

    # Identification
    def login
      debug "-> User::login"
      unless login_ok?
        error "Je ne vous remets pas…"
        redirect_to :home
      else
        debug "[User:login] login_ok? a retourné TRUE"
      end
    end

    def login_ok?
      debug "-> User::login_ok?"
      login_data = param(:login)
      mail = login_data[:mail]
      pasw = login_data[:password]
      res = table_users.select(where: {mail: mail}, colonnes: [:salt, :cpassword, :mail]).values.first
      return false if res.nil?
      expected = res[:cpassword]
      compared = Digest::MD5.hexdigest("#{pasw}#{mail}#{res[:salt]}")
      ok = expected == compared
      if ok
        debug "[User::login_ok?] OK => Instanciation d'un nouvel user (#{res[:id].inspect})"
        u = User::new( res[:id] )
        u.login
      end
      return ok
    end

  end # << self
end
