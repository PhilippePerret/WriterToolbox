# encoding: UTF-8
class SiteHtml
class Admin
class Console

  # Permet de changer le jour-programme courant de Benoit (#2) pour faire
  # des essais notamment OFFLINE du programme UNAN.
  #
  def change_pday_benoit pday_indice, params = nil
    benoit = User.get(2)

    # S'assurer que Benoit suive bien le programme UNAN
    init_program_1an1script_for(benoit) unless benoit.unanunscript?

    # Il faut détruire les tables de benoit pour détruire tous les travaux
    # qu'il a pu suivre avant
    # Pour la table des travaux, c'est simple, il suffit de détruire
    # tous les travaux au-dessus du jour voulu
    nombre_works_avant = benoit.table_works.count.freeze
    benoit.table_works.delete(where: "abs_pday >= #{pday_indice}")
    nombre_works_apres = benoit.table_works.count.freeze
    debug "Nombre de travaux avant -> après : #{nombre_works_avant} -> #{nombre_works_apres}"
    # Pour les pages, c'est plus compliqué, il faut passer par
    # le `work_id` qui va permettre de retrouver le jour-programme de
    # la page de cours. Soit ce `work` a déjà été détruit, ce qui
    # signifie qu'il faut détruire la page de cours, soit il est
    # toujours là et il faut donc conserver la page de cours.
    debug "-> Destruction des pages de cours"
    pages_to_destroy = Array.new
    benoit.table_pages_cours.select.each do |hpage|
      wid = hpage[:work_id]
      if benoit.table_works.count(where: {id: wid}) == 1
        debug "Le travail ##{wid} existe encore => on garde la page de cours ##{hpage[:id]}"
      else
        pages_to_destroy << hpage[:id]
      end
    end
    debug "Pages de cours à détruire : #{pages_to_destroy.inspect}"
    if pages_to_destroy.empty?
      debug "Aucun page de cours à détruire"
    else
      nombre_pages_avant = benoit.table_pages_cours.count.freeze
      benoit.table_pages_cours.delete(where: "id IN (#{pages_to_destroy.join(', ')})")
      nombre_pages_apres = benoit.table_pages_cours.count.freeze
      debug "Nombre pages de cours avant -> après : #{nombre_pages_avant} -> #{nombre_pages_apres}"
    end

    # On passe Benoit au jour-programme voulu
    benoit.program.current_pday= pday_indice

    # On modifie également sa date d'inscription pour que ça
    # corresponde à son jour-programme au rythme 5 (normal).
    benoit.program.set(
      created_at: (Time.now.to_i - pday_indice.days)
      )

    flash "Benoit passé au jour-programme #{pday_indice} avec succès."

    ''
  end

  def init_program_1an1script_for user_id
    user_id = user_id.id if user_id.instance_of?(User)
    raise 'Le dernier mot doit être l’identifiant de l’user' unless user_id.instance_of?(Fixnum) || user_id.numeric?
    current_user_id = User.current.id.freeze
    u = User.get(user_id.to_i)
    raise "L'user ##{user_id} est inconnu au bataillon…" unless u.exist?
    User.current = u
    site.require_objet 'unan'
    (Unan.folder_modules + 'signup_user.rb').require
    u.signup_program_uaus
    User.current = User.get(current_user_id)
    "Programme ÉCRIRE UN FILM/ROMAN EN UN AN initié avec succès pour #{u.pseudo} (##{u.id})"
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
        raise '\n<span class="red">Cet utilisateur ne possède aucun paiment pour un programme ÉCRIRE UN FILM/ROMAN EN UN AN…</span>'
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
