# encoding: UTF-8
=begin
Handy méthodes pour les user
=end
def go_and_identify mail, password
  visit_home
  click_link('S\'identifier')
  expect(page).to have_css('form#form_user_login')
  within('form#form_user_login') do
    fill_in('login_mail', with: mail)
    fill_in('login_password', with: password)
    click_button('OK')
  end
end

def identify_phil
  require './data/secret/data_phil'
  go_and_identify DATA_PHIL[:mail], DATA_PHIL[:password]
end

# Retourne un pseudo aléatoire d'une longeur de 6 à 16 lettres
# à peu près
def random_pseudo
  # Longeur aléatoire
  len_pseudo = 6 + rand(10)
  # Première lettre
  pse = (65 + rand(26)).chr
  liste_voyelles = ['a','e', 'i', 'o', 'u', 'y', 'oi'].freeze
  nombre_voyelles = liste_voyelles.count
  # Lettres suivantes
  (len_pseudo/2).times do
    pse << liste_voyelles[rand(nombre_voyelles)]
    pse << (97 + rand(26)).chr
  end
  return pse
end

# {User} Retourne une instance User prise au hasard sur le site
#
# +options+
#   :but    Array des IDs à ne pas utiliser
#   :with_program   Si true, l'auteur doit avoir un programme 1a1s
#   :with_forum_messages
#     Si true, il faut trouver un utilisateur qui a des messages sur
#     le forum.
#
def get_any_user options = nil

  options ||= Hash::new
  ids, where = nil, Array::new

  if options[:with_program]
    # => Il faut retourner un user qui suit un programme, donc il faut
    # prendre les ids dans la table des programmes.
    programs = Unan::table_programs.select(where: "options LIKE '1%'", colonnes:[:auteur_id])
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

  if options[:with_messages_forum] && !ids.empty?
    # Il faut que les users choisis possèdent des messages sur le
    # forum
    res = Forum::table_posts.select(colonnes:[:user_id], where:"user_id IN (#{ids.join(',')})")
    ids = res.values.collect{|h| h[:user_id]}
    raise "Impossible de trouver des users avec des messages forum…" if ids.empty?
  end

  raise "Impossible de trouver des users répondant aux conditions…" if ids.empty?

  uid = ids.shuffle.shuffle.first
  u = User.new(uid)
  expect(u).to be_instance_of(User)
  return u
end

def phil
  u = User.new(1)
  expect(u).to be_instance_of(User)
  expect(u).to be_admin
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

  sexe    = ["H","F"][rand(2)]
  prenom  = UserSpec::random_prenom(sexe)

  options[:sexe]        ||= sexe
  options[:pseudo]      ||= "#{prenom.normalized}#{options[:sexe]}#{now}"
  options[:patronyme]   ||= "#{prenom} Patro #{options[:sexe]} N#{now}"
  options[:mail]        ||= "mail#{options[:sexe]}#{now}@chez.moi"
  options[:options]     ||= ""
  options[:cpassword]   ||= "0123"*8
  options[:session_id] = app.session.session_id unless options.has_key?(:session_id)
  options[:created_at]  ||= now
  options[:updated_at]  ||= now
  options[:salt]        ||= "dubonsel"

  @id = User::table_users.insert(options)
  new_user = User::get(@id)
  # debug "ID du nouvel user créé par `create_user` des tests : #{new_user.id.inspect}"

  # Mettre en courant lorsqu'on en a fait explicitement la
  # demande ou lorsqu'un programme UN AN UN SCRIPT doit être
  # instancié pour l'auteur.
  User::current= new_user if mettre_courant || programme_1a1s

  # Si l'user doit être inscrit au programme UN AN UN SCRIPT, il
  # faut simuler son inscription
  if programme_1a1s
    site.require_objet 'unan'
    (Unan::folder_modules + 'signup_user.rb').require
    new_user.signup_program_uaus
  end

  return new_user

end
