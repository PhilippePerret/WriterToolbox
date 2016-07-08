# encoding: UTF-8
#
# Module qui permet à l'administrateur de détruire un user
#
# Si ce n'est pas un grand manitou qui lance ce programme, on fait mine de rien
# pour faire croire que ça fonctionne
#
if user.manitou?

    pid = param(:program_to_destroy_id).nil_if_empty
    pin = param(:program_invoice).nil_if_empty
    uid  = param(:program_auteur_id).nil_if_empty
    if pid.nil? && uid.nil?
        raise 'Il faut fournir l’ID du programme et/ou l’ID de l’auteur.'
    end
    UnanAdmin.require_module 'destroy_program'
    redirect_to :last_route
end
