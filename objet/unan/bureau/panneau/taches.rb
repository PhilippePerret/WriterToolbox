# encoding: UTF-8
=begin
Extension de la class Unan::Bureau pour afficher le travail en
cours de l'auteur.

Noter que ce module est le seul module "optionnel" appelé quand
l'auteur rejoint son panneau "travaux" donc ça n'est pas grave
s'il est conséquent.

Ce travail doit être contenu sous forme de liste dans la variable
`travaux_ids` qui est renseignée à mesure que l'auteur avance dans
les jours et qu'il exécute des travaux.
=end
class Unan
class Bureau

  def save_travail
    flash "Je sauve les données travail"

    # TODO Sauver la nouvelle liste de travaux
    # set_var(:travaux_ids, travaux_ids)

  end

  # cf. l'explication dans le fichier home.rb
  def missing_data
    @missing_data ||= begin
      nil # pour le moment
      # Une alerte si des travaux devraient être accomplis et qu'ils
      # ne le sont pas.
    end
  end

  def tasks
    @tasks ||= user.get_var(:tasks_ids, Array::new).collect{ |wid| Unan::Program::Work::get(user.program, wid) }
  end
  # Raccourci
  def last_tasks
    @last_tasks ||= user.program.last_tasks
  end

end # /Bureau

# ---------------------------------------------------------------------
#   Extention de Unan::Program::Work
#   Pour l'affichage des travaux
# ---------------------------------------------------------------------
class Program
class Work

  # {StringHTML} Retourne le code HTML à écrire dans la page pour
  # ce travail en particulier.
  # Noter que c'est une méthode de `Work` plutôt que de `AbsWork` pour
  # s'adapter exactement à l'auteur en particulier.
  def output
    (
      nombre_de_points +
      "#{abs_work.titre}".in_div(class:'titre')  +
      "#{abs_work.travail}".in_div(class:'travail')       +
      date_fin_attendue +
      form_pour_marquer_fini
    ).in_div(class:'work')
  end
  def form_pour_marquer_fini
    (
      "Marquer ce travail fini".in_a(href:"work/#{id}/complete?in=unan/program&cong=taches")
    ).in_div(class:'buttons')
  end

  def nombre_de_points
    "#{abs_work.points} points".in_div(class:'nbpoints')
  end

  def date_fin_attendue
    doit = depassement? ? "aurait dû" : "doit"
    avez = depassement? ? "aviez" : "avez"
    mess_duree = "Ce travail #{doit} être accompli en #{duree_relative.as_jours}."
    css  = ['exbig']
    css << "warning" if depassement?


    mess_echeance = "Il a débuté le #{created_at.as_human_date(true, true)}, il #{doit} être achevé avant le <span class='#{css.join(' ')}'>#{expected_end.as_human_date(true, true)}</span>."
    mess_reste_jours = if depassement?
      "Vous êtes en dépassement de #{temps_humain_depassement} !".in_div(class:'warning')
    else
      (
        "Reste".in_span(class:'libelle va_bottom')      +
        temps_humain_restant.in_span(class:'mark_fort')
      ).in_div(class:'right air')
    end

    (
      mess_duree.in_div     +
      mess_echeance.in_div  +
      mess_reste_jours
    ).in_div(class:'dates')
  end

  def temps_humain_depassement
    depassement.as_jours_or_hours
  end
  def temps_humain_restant
    (expected_end - NOW).as_jours_or_hours
  end

end #/Work
end #/Program
end # /Unan


case param :operation
when 'bureau_save_travail'
  bureau.save_travail
end
