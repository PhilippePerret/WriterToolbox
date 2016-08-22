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
  auteur.program.set(rythme: 5)
  auteur.table_quiz.delete
  auteur.table_works.delete
  auteur.table_pages_cours.delete
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
