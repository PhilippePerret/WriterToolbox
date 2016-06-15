# encoding: UTF-8
require 'digest/md5'
class User
  class << self

    # Identification
    def login
      unless login_ok?
        error "Je ne vous reconnais pas… Voulez-vous bien réessayer ?"
        redirect_to 'user/signin'
      end
    end

    # RETURN True si l'identification est réussie
    #
    def login_ok?
      login_data = param(:login)
      mail = login_data[:mail]
      pasw = login_data[:password]
      res = table_users.select(where: {mail: mail}, colonnes: [:salt, :cpassword, :mail]).first
      return false if res.nil?
      expected = res[:cpassword]
      compared = Digest::MD5.hexdigest("#{pasw}#{mail}#{res[:salt]}")
      ok = expected == compared
      User::new( res[:id] ).login if ok
      return ok
    end

  end # << self
end
