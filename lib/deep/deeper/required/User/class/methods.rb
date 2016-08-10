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
      if login_data.nil?
        # Ça arrive quelque chose quand ça tourne trop longtemps
        # ou autre
        return false
      else
        umail = login_data[:mail]
        upass = login_data[:password]
        res = table_users.select(where: {mail: umail}, colonnes: [:salt, :cpassword, :mail]).first
        return false if res.nil?
        expected = res[:cpassword]
        compared = Digest::MD5.hexdigest("#{upass}#{umail}#{res[:salt]}")
        ok = expected == compared
        User.new( res[:id] ).login if ok
        return ok
      end
    end

  end # << self
end
