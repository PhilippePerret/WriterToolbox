# encoding: UTF-8
class Unan
class Program

  # Coefficient de durée du jour-programme du programme courant
  # @usage : On MULTIPLIE la durée réelle par ce nombre pour
  # obtenir la durée-programme.
  #     DURÉE_RÉELLE = DURÉE_PROGRAMME * coefficient_duree
  # =>  DURÉE_PROGRAMME    = DURÉE_RÉELLE.to_f / coefficient_duree
  # (NON : c'est le contraire : )
  def coefficient_duree
    @coefficient_duree ||= begin
      # Parfois, `rythme` est false, on essaie de l'obtenir autrement
      if rythme === false
        send_error_to_admin(
          exception: "`rythme` est false, dans Unan::Program#coefficient_duree. J'essaie de le récupérer à nouveau ou de le mettre à 5.",
          extra:      "Program ID ##{id}"
        )
        @rythme =
          begin
            request = {
              where:      {id: self.id},
              colonnes:   [:rythme]
            }
            Unan.table_programs.select(request)[:rythme] || 5
          rescue Exception => e
            send_error_to_admin(exception: e)
            5
          end
        5.0 / @rythme
      else
        5.0 / rythme
      end
    end
  end

  # Méthode d'helper permettant de passer d'une durée
  # programme à une durée réelle.
  # Reçoit un nombre de jours-programme et retourne la valeur
  # en jours et heures réelles en fonction du rythme de
  # l'utilisateur.
  def duree_programme_2_duree_reelle nombre_jours
    (nombre_jours.days * coefficient_duree).to_i.as_jours
  end
  alias :pduree2rduree :duree_programme_2_duree_reelle

end #/Program
end #/Unan
