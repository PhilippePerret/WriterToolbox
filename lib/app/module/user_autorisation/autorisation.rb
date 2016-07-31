# encoding: UTF-8
=begin

  @usage

    <user>.require_modules_autorisation
    <user>.do_on_paiement(data_paiement) # ou autre méthode

=end
class User

  # Méthode principale ajoutant une autorisation en fonction
  # de args[:type] qui peut avoir la valeur :
  #   :unan             Programme UN AN
  #   :suscribe         Abonnement normal d'un an
  #   :icarien_actif    Un icarien actif
  def add_autorisation args
    # Création de l'autorisation
    dauto =
      case args[:type]
      when :unan
        data_autorisation_unan( args )
      when :subscribe
        data_autorisation_abonnement( args )
      when :icarien_actif
        data_autorisation_icare_actif( args )
      when :invitation
        data_autorisation_invitation( args )
      when :autre_raison
        data_autorisation_autre_raison( args )
      end

    # On règle le temps de fin si le temps de début est
    # fourni, le nombre de jours aussi mais le temps de
    # fin ne l'est pas
    if dauto[:start_time] && dauto[:nombre_jours] && dauto[:end_time].nil?
      dauto[:end_time] = dauto[:start_time] + dauto[:nombre_jours].days
    end

    # On crée la donnée autorisation
    table_autorisations.insert(dauto)
  end

  # Données autorisation pour une autre raison, qui doit être
  # spécifiée dans args[:raison] en plus des autres données
  def data_autorisation_autre_raison args
    dauto = data_autorisations_default(args)
    dauto[:raison]        = args[:raison]
    dauto[:nombre_jours]  = args[:nombre_jours]
    dauto[:end_time]      = args[:end_time]
    return dauto
  end

  def data_autorisation_unan args
    dauto = data_autorisations_default(args)
    dauto[:raison]       = 'UNANUNSCRIPT'
    dauto[:nombre_jours] = 2 * 365
    return dauto
  end

  def data_autorisation_abonnement args
    dauto = data_autorisations_default(args)
    dauto[:raison]        = 'ABONNEMENT'
    dauto[:nombre_jours]  = 1 * 365
    return dauto
  end

  def data_autorisation_icare_actif args
    dauto = data_autorisations_default(args)
    dauto[:raison] = 'ICARIEN ACTIF'
    return dauto
  end

  # Les données d'autorisation pour un invité
  # quelconque (qui doit être inscrit)
  # +args+ doit contenir au minimum le nombre
  # de jours
  def data_autorisation_invitation args
    dauto = data_autorisations_default(args)
    dauto[:raison]       = 'INVITATION'
    dauto[:nombre_jours] = args[:nombre_jours]
    dauto[:end_time]     = args[:end_time]
    return dauto
  end


  # La base des autorisations
  def data_autorisations_default args
    {
      user_id:      id,
      privileges:   nil,
      raison:       nil,
      start_time:   args[:start_time] || NOW,
      end_time:     nil,
      nombre_jours: nil,
      created_at:   NOW,
      updated_at:   NOW
    }
  end

  # Méthode appelée après l'enregistrement d'un paiement, soit pour
  # l'abonnement soit pour le programme UN AN
  def do_on_paiement data_paiement
    case data_paiement[:objet_id]
    when '1AN1SCRIPT'
      add_autorisation type: :unan
    when 'ABONNEMENT'
      add_autorisation type: :subscribe
    end
  end

end #/User
