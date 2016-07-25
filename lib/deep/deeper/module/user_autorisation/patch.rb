# encoding: UTF-8
class User

  def try_paiement_unan
    User.table_paiements.select(where: "user_id = #{id} AND objet_id = '1AN1SCRIPT'", order: "created_at DESC", limit: 1).first
  end
  def try_paiement_abonnement
    User.table_paiements.select(where: "user_id = #{id} AND objet_id = 'ABONNEMENT'", order: "created_at DESC", limit: 1).first
  end

  # Retourne la valeur de l'autorisation de l'auteur courant
  def do_patch_modification_users
    dauto = nil
    autorised = begin
      if dpaie = try_paiement_unan
        dauto = {
          start_time: dpaie[:created_at],
          end_time:   dpaie[:created_at] + (365 * 2).days,
          raison:     "UN AN UN SCRIPT"
        }
        true
      elsif dpaie = try_paiement_abonnement
        dauto = {
          start_time: dpaie[:created_at],
          end_time:   dpaie[:created_at] + 365.days,
          raison:     "ABONNEMENT UN AN"
        }
        true
      elsif icarien_actif?
        dauto = {
          start_time: NOW - 10,
          end_time:   nil,
          raison:     "ICARIEN ACTIF"
        }
        true
      else
        false
      end
    end

    if autorised && dauto
      table_autorisations.insert(dauto.merge!(user_id: id, created_at: NOW, updated_at: NOW))
      debug "USER AUTORISÉ : #{pseudo} (##{id}) : #{dauto.inspect}"
      reset_autorisations
    end
    return autorised
  end

end
