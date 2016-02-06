# encoding: UTF-8
class User

  # = main =
  #
  # Méthode qui change le pday de l'utilisateur pour le mettre
  # au pday +pday_indice+ avec les paramètres optionnels +params+
  # +params+
  #    retards:   <nombre> Détermine le nombre de travaux en retard
  #               pour le jour donné. Si TRUE au lieu d'un nombre,
  #               choisi un nombre au hasard.
  def change_pday pday_indice, params = nil
    params ||= Hash::new

    # Changer le current_pday de l'user
    set_var(:current_pday, pday_indice)

    # Effacer tous les pdays propres enregistrés
    table_pdays.delete
    # Effacer tous les enregistrements de works
    table_works.delete

    # Remonter les pdays depuis le premier jour jusqu'à la VEILLE
    # du jour voulu pour :
    #   1. Faire les enregistrements de pdays (-> table_pdays)
    #   2. Faire les enregistrements de works (-> table_works)
    (1..(pday_indice-1)).each do |pday_id|
      iabs_pday = Unan::Program::AbsPDay::get(pday_id)
      iusr_pday = Unan::Program::PDay::new( program, ipday )
      dprov = iusr_pday.data2save

      # Le statut du p-day. Il est à 1 quand le PDay est en cours
      # 1: Déclenché
      # 2: ? Pas encore attribué
      # 4: Achevé
      # Mais ce statut va être décidé en fonction des travaux, suivant le
      # fait qu'il faut laisser des travaux inachevés ou non.
      pday_status = 0

      # Les points
      # Ces points dépendent des works. Si les paramètres l'exigent
      # certaines travaux peuvent avoir été remis en retard et donc ne
      # pas avoir apportés autant de points que voulus à l'auteur. Dans le cas
      # contraire, on additionne simplement tous les points des travaux.
      pday_points = 0

      # --------------------------------------------------
      # Les travaux
      # --------------------------------------------------
      iworks = iabs_pday.works(:as_instances)
      

      # -----------------------------------------------------
      # Finalisation de la donnée pday pour l'user
      # -----------------------------------------------------
      # Il faut calculer le temps auquel aurait été créé
      # ce jour-programme (notamment pour le modifier dans la
      # donnée enregistrée)
      pday_time = Time.now - (pday_indice - pday_id + 1).days
      dprov.merge!(
        status:     pday_status,
        points:     pday_points,
        updated_at: pday_time,
        created_at: pday_time
      )
      iusr_pday.instance_variable_set('@data2save', dprov)

    end

  end

end
