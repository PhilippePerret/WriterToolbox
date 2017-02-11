# encoding: UTF-8
require 'digest/md5'
class User
class << self

  # Identification
  def login
    login_ok? || begin
      error "Je ne vous reconnais pas… Voulez-vous bien réessayer ?"
      redirect_to 'user/signin'
    end
  end

  # RETURN True si l'identification est réussie
  #
  def login_ok?
    debug "-> login_ok?"
    login_data = param(:login)
    debug "login_data : #{login_data.inspect}"
    if login_data.nil?
      # Ça arrive quelquefois quand ça tourne trop longtemps
      # ou autre
      debug "login_data est nil…"
      return false
    else
      umail = login_data[:mail]
      upass = login_data[:password]
      res = table_users.select(where: {mail: umail}, colonnes: [:salt, :cpassword, :mail]).first
      debug "Retour table users : #{res.inspect}"
      res != nil || (return false)
      expected = res[:cpassword]
      compared = Digest::MD5.hexdigest("#{upass}#{umail}#{res[:salt]}")
      debug "Comparaison mot de passe crypté :"
      debug "expected: #{expected}"
      debug "compared: #{compared}"
      ok = expected == compared
      debug "C'est bon ? #{ok.inspect} (user ID ##{res[:id]})"
      ok && User.new( res[:id] ).login
      return ok
    end
  end

  # Méthodes pour empêcher les users black-listés de se
  # connecter au site
  def die_current_user_if_black_ip
    black_ips.key?(user.ip) && die('Vous n’êtes pas le bienvenu.')
  end
  def black_ips
    @black_ips ||= begin
      require './data/secret/known_ips'
      BLACK_IPS_LIST
    end
  end

end # << self
end #/User
