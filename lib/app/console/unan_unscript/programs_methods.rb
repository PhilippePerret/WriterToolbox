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

  # Programme pour détruire un user
  def unan_detruire_programme_auteur args
    uref, invoice = args.split(' ')
    uid =
      if uref.numeric?
        uref.to_i
      else
        User.table_users.get(where:{pseudo: uref})[:id]
      end
    u = User.new(uid)
    sub_log "Destruction du dernier programme de #{u.pseudo} (#{u.id})".in_div

    site.require_objet 'unan'
    program_id = Unan.table_programs.select(where:{auteur_id: u.id}, order: 'created_at DESC', limit: 1, colonnes: []).first[:id]
    sub_log "ID du programme : #{program_id}".in_div

    # Deux cas peuvent se présenter : soit les arguments contiennent déjà
    # le numéro de facture et on présente le lien permettant de détruire
    # l'auteur, soit ils ne le contiennent pas et on le donne en expliquant
    # ce qu'il faut faire
    if invoice.nil?
      hpaiement = User.table_paiements.select(where: {user_id: u.id, objet_id: '1AN1SCRIPT'}, order: 'created_at DESC', limit: 1).first
      debug "hpaiement : #{hpaiement.pretty_inspect}"
      if hpaiement.nil?
        raise '\n<span class="red">Cet utilisateur ne possède aucun paiment pour un programme UN AN UN SCRIPT…</span>'
      end
      invoice = hpaiement[:facture]
      sub_log "\nPar mesure de sécurité, il faut ajouter ce numéro de facture après la référence de l'auteur dans la console :".in_div
      sub_log invoice.in_pre
    else
      # On peut procéder à l'opération
      href = "unan_admin/destroy_program?program_to_destroy_id=#{program_id}&program_invoice=#{invoice}&program_auteur_id=#{u.id}"
      sub_log 'DÉTRUIRE DÉFINITIVEMENT TOUTE TRACE DU PROGRAMME'.in_a(href: href).in_div(class: 'air')
    end
    return ""
  end

end #/Console
end #/Admin
end #/SiteHtml
