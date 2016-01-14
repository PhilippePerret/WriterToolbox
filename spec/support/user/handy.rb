# encoding: UTF-8
=begin
Handy méthodes pour les user
=end

# +options+
#   :unanunscript   Si true, l'inscrit au programme
#   :current        Si true, le met en user courant
#   Toutes les autres propriétés servent à décrire les
#   données de l'user, qui seront enregistrées dans la
#   table
def create_user options = nil
  now = Time.now.to_i
  options ||= Hash::new

  # Retirer les valeurs qui ne doivent pas être enregistrées
  mettre_courant = options.delete(:current)
  programme_1a1s = options.delete(:unanunscript)

  options[:pseudo]      ||= "pseudo#{now}"
  options[:patronyme]   ||= "Patro N#{now}"
  options[:sexe]        ||= "F"
  options[:mail]        ||= "mail#{now}@chez.moi"
  options[:cpassword]   ||= "0123"*8
  options[:session_id]  ||= app.session.session_id
  options[:created_at]  ||= now
  options[:updated_at]  ||= now
  options[:salt]        ||= "dubonsel"

  @id = User::table_users.insert(options)
  new_user = User::get(@id)

  # Enregistrer cet utilisateur à détruire à la
  # fin des tests
  $users_2_destroy << new_user.id

  User::current= new_user if mettre_courant

  # Si l'user doit être inscrit au programme UN AN UN SCRIPT, il
  # faut simuler son inscription
  if programme_1a1s
    site.require_objet 'unan'
    (Unan::folder_modules + 'signup_user.rb').require
    new_user.signup_program_uaus
  end

  return new_user

end
