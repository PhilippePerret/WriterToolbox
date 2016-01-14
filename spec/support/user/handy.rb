# encoding: UTF-8
=begin
Handy méthodes pour les user
=end

def create_user options = nil
  now = Time.now.to_i
  options ||= Hash::new

  # Retirer les valeurs qui ne doivent pas être enregistrées
  mettre_courant = options.delete(:current)

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

  return new_user

end
