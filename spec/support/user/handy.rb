# encoding: UTF-8
=begin
Handy méthodes pour les user
=end


# {User} Retourne une instance User prise au hasard sur le site
#
# +options+
#   :but    Array des IDs à ne pas utiliser
#   :with_program   Si true, l'auteur doit avoir un programme 1a1s
#
def get_any_user options = nil

  options ||= Hash::new
  ids, where = nil, Array::new

  if options[:with_program]
    # => Il faut retourner un user qui suit un programme, donc il faut
    # prendre les ids dans la table des programmes.
    programs = Unan::table_programs.select(where:"options LIKE '1%'", colonnes:[:auteur_id]).values
    ids = programs.collect{|hp| hp[:auteur_id]}
  end

  if options[:but] && !options[:but].empty?
    where << "id NOT IN (#{options[:but].join(', ')})"
  end

  where = if where.empty?
    nil
  else
    where.join(' AND ')
  end

  if ids.nil?
    ids = if where.nil?
      User::table.select(colonnes:[:id]).keys
    else
      User::table.select(where:where, colonnes:[:id]).keys
    end
  end

  uid = ids.shuffle.shuffle.first
  u = User::new(uid)
  expect(u).to be_instance_of(User)
  return u
end

def benoit
  u = User::new(2)
  expect(u).to be_instance_of(User)
  expect(u.pseudo).to eq "Benoit"
  return u
end

# +options+
#
#   :unanunscript   Si true, l'inscrit au programme
#   :current        Si true, le met en user courant
#
#   Toutes les autres propriétés servent à décrire les
#   données de l'user, qui seront enregistrées dans la
#   table
def create_user options = nil
  now = Time.now.to_i
  options ||= Hash::new

  # Retirer les valeurs qui ne doivent pas être enregistrées
  programme_1a1s = options.delete(:unanunscript)
  mettre_courant = options.delete(:current) || programme_1a1s

  options[:sexe]        ||= ["H","F"][rand(2)]
  options[:pseudo]      ||= "pseudo#{options[:sexe]}#{now}"
  options[:patronyme]   ||= "Patro #{options[:sexe]} N#{now}"
  options[:mail]        ||= "mail#{options[:sexe]}#{now}@chez.moi"
  options[:options]     ||= ""
  options[:cpassword]   ||= "0123"*8
  options[:session_id] = app.session.session_id unless options.has_key?(:session_id)
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
