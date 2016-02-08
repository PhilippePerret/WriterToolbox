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
Unan::require_module 'abs_work'

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
    @tasks ||= begin
      user.get_var(:tasks_ids, Array::new).collect{ |wid| Unan::Program::Work::get(user.program, wid) }
    end
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
  # Noter qu'elle sert aussi pour les travaux qui viennent d'être
  # achevés (mis en bas de page) et que donc, certaines informations
  # comme les dates, ne sont pas toujours affichées.
  def output
    (
      nombre_de_points +
      "#{abs_work.titre}".in_div(class:'titre')     +
      "#{abs_work.travail}".in_div(class:'travail') +
      date_fin_attendue +
      form_pour_marquer_started_or_fini +
      details_tache +
      section_exemples
    ).in_div(class:'work')
  end

  # Retourne la section contenant les exemples s'ils existent
  def section_exemples
    abs_work.instance_variable_set('@exemples', "1 11")
    return "" if abs_work.exemples.empty?
    abs_work.exemples_ids.collect do |eid|
      "Exemple ##{eid}".in_a(href:"exemple/#{eid}/show?in=unan", target:'_exemple_work_').in_span
    end.join.in_div(class:'exemples')
  end

  # Les détails de la tâche
  def details_tache
    return "" if completed?
    (
      span_type_tache +
      span_resultat
    ).in_div(class:'details')
  end

  def span_type_tache
    ("Type".in_span(class:'libelle') + human_type.in_span).in_span
  end
  def span_resultat
    return "" if abs_work.resultat.empty?
    c = ""
    c << ("Résultat".in_span(class:'libelle') + abs_work.resultat).in_span
    c << abs_work.human_type_resultat
    return c
  end
  # Un lien pour soit marquer le travail démarré (s'il n'a pas encore été
  # démarré) soit pour le marquer fini (s'il a été fini). Dans les deux cas,
  # c'est un lien normal qui exécute une action avant de revenir ici.
  def form_pour_marquer_started_or_fini
    if started?
      "Marquer ce travail fini".in_a(href:"work/#{id}/complete?in=unan/program&cong=taches")
    else
      "Démarrer ce travail".in_a(href:"work/#{id}/start?in=unan/program&cong=taches")
    end.in_div(class:'buttons')
  end

  def nombre_de_points
    return "" if completed?
    "#{abs_work.points} points".in_div(class:'nbpoints')
  end

  def date_fin_attendue
    return "" if completed?
    doit = depassement? ? "aurait dû" : "doit"
    avez = depassement? ? "aviez" : "avez"
    mess_duree = "Ce travail #{doit} être accompli en #{duree_relative.as_jours}."
    css  = ['exbig']
    css << "warning" if depassement?

    mess_echeance = "Il a débuté le #{created_at.as_human_date(true, true)}, il #{doit} être achevé le <span class='#{css.join(' ')}'>#{expected_end.as_human_date(true, true)}</span>."
    mess_reste_jours = if depassement?
      "Vous êtes en dépassement de <span class='exbig'>#{temps_humain_depassement}</span>.".in_div(class:'warning').in_div(class:'depassement')
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
