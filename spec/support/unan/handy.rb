# encoding: UTF-8

# On réinitialise complètement un auteur du programme UNAN, souvent
# avant de le passer à un jour précis : User#set_pday_to <id>
#
# Note : pour le moment, ça ne détruit pas le programme de l'auteur
# s'il en a
#
def reset_auteur_unan auteur
  site.require_objet 'unan'
  auteur.instance_of?(User) || auteur = User.new(auteur)
  auteur.program != nil || make_user_auteur_unan( benoit )
  auteur.program.set(rythme: 5, points: 0)
  auteur.table_works.delete
  auteur.table_pages_cours.delete
  # Pour effacer tous les quiz de l'auteur
  site.dbm_table(:quiz_unan, 'resultats').delete( where: {user_id: auteur.id} )

end

# Faire d'un auteur un auteur du programme UNAN si ça n'est
# pas déjà le cas
def make_user_auteur_unan auteur
  auteur.program.nil? || return
  User.current= auteur
  make_user_subscriber_for( auteur, programme_1a1s = true )
end

# Crée un auteur pour le programme UNAN
#
# RETURN L'auteur ({User})
#
# +options+
#   :done_upto    Tous les travaux jusqu'à ce jour-programme doivent
#                 être marqué terminés.
def create_auteur_unan options = nil
  options ||= Hash.new
  options.merge!(unanunscript: true)
  site.require_objet 'unan'
  # Créer un auteur
  u = create_user(options)
end
