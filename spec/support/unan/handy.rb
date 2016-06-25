# encoding: UTF-8

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
