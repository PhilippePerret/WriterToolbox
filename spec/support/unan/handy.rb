# encoding: UTF-8

# On réinitialise complètement un auteur du programme UNAN, souvent
# avant de le passer à un jour précis : User#set_pday_to <id>
#
# Note : pour le moment, ça ne détruit pas le programme de l'auteur
# s'il en a
# 
def reset_auteur_unan auteur
  site.require_objet 'unan'
  auteur.instance_of?(User) || auteur = User.get(auteur)
  auteur.table_quiz.delete
  auteur.table_works.delete

end
# Prépare un auteur pour le programme UN AN UN SCRIPT
#
# +options+
#
#   :pday         Le jour-programme dans lequel doit se trouver l'auteur
#   :done_upto    Tous les travaux jusqu'à ce jour-programme doivent
#                 être marqué terminés.
#
def prepare_auteur options = nil
  User.current = phil
  site.require_objet 'unan_admin'
  UnanAdmin.require_module 'set'

  # On prend un auteur
  drequest = {}
  if options[:auteur_id]
    drequest = {
      where: {auteur_id: options[:auteur_id]},
      order: 'created_at DESC',
      limit: 1
    }
  end

  @hprog =
    if drequest.empty?
      site.dbm_table(:unan, 'programs').select.first
    else
      site.dbm_table(:unan, 'programs').select(drequest).first
    end
  @hprog != nil     || raise('Il faut créer un auteur pour le programme UN AN UN SCRIPT')
  @program_id   = @hprog[:id]
  @auteur_id    = @hprog[:auteur_id]
  @auteur_id != nil || raise('Aucun auteur n’a pu être trouvé…')

  @up = @auteur = User.new(@auteur_id)

  @up.unan_set options

end
