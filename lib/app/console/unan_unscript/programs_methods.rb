# encoding: UTF-8
class SiteHtml
class Admin
class Console

  def init_program_1an1script_for user_id
    raise "Le dernier mot doit être l'identifiant de l'user" unless user_id.instance_of?(Fixnum) || user_id.numeric?
    current_user_id = User::current.id.freeze
    u = User::get(user_id.to_i)
    raise "L'user ##{user_id} est inconnu au bataillon…" unless u.exist?
    User::current = u
    site.require_objet 'unan'
    (Unan::folder_modules + 'signup_user.rb').require
    u.signup_program_uaus
    User::current = User::get(current_user_id)
    "Programme UN AN UN SCRIPT initié avec succès pour #{u.pseudo} (##{u.id})"
  end

end #/Console
end #/Admin
end #/SiteHtml
