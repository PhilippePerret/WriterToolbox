# encoding: UTF-8
raise_unless_admin

require 'pstore'

class SiteHtml
class Admin
class Console

  # Pour ajouter des lignes au rapport
  def add_rapport libelle, valeur
    @rapport << "#{libelle.ljust(30)} #{valeur}"
  end
  alias :add_rap :add_rapport


  def faire_etat_des_lieux_programme

    site.require_objet 'unan'

    @rapport = Array::new
    @rapport << "Rapport du programme ÉCRIRE UN FILM/ROMAN EN UN AN".in_h2

    nombre_auteurs            = Unan::table_programs.select(distinct: true, colonnes:[:auteur_id]).count
    add_rap "Nombre auteurs", nombre_auteurs
    nombre_programmes         = Unan::table_programs.count
    add_rap "Nombre total de programmes", nombre_programmes
    nombre_programmes_actifs  = Unan::table_programs.count(where:"options LIKE '1%'")
    add_rap "Nombre programmes actifs", nombre_programmes_actifs
    nombre_total_projets      = Unan::table_projets.count
    add_rap "Nombre total projets", nombre_total_projets

    @rapport << "Question Data".in_h3
    nombre_quiz = Unan::table_quiz.count
    add_rap "Nombre questionnaires", nombre_quiz
    nombre_questions = Unan::table_questions.count
    add_rap "Nombre questions pour quiz", nombre_questions

    @rapport << "Programmes actifs".in_h3
    Unan::table_programs.select(where:"options LIKE '1%'").each do |pid, pdata|
      rapport_programme_unan(pdata)
    end

    sub_log( @rapport.join("\n").in_pre )

   "cf. État des lieux ci-dessous"
  end

  # Pour faire le rapport du programme de données {Hash} +hprog+
  def rapport_programme_unan hprog
    u = User::get(hprog[:auteur_id])
    prog = u.program
    add_rap "Programme ID", hprog[:id]
    add_rap "Auteur", "#{u.pseudo} (#{hprog[:auteur_id]})"
    add_rap "Commencé le", hprog[:created_at].as_human_date(true, true)
    add_rap "Modifié le", hprog[:updated_at].as_human_date(true, true)
    add_rap "Rythme", prog.rythme
    add_rap "Jour-programme courant", prog.current_pday.inspect
    @rapport << "<strong>Liste des travaux courants (variable `:works_ids`)</strong>"
    u.get_var(:works_ids, Array::new).each do |wid|
      work  = Unan::Program::Work::get(prog, wid)
      titre = work.abs_work.titre
      type  = work.human_type
      depart  = work.created_at.as_human_date(false, true)
      fin = if work.ended?
        work.ended_at.as_human_date(false, true)
      else
        "- inaché -"
      end
      @rapport << "    Work #{wid} - #{titre} - #{type} - du <b>#{depart}</b> au <b>#{fin}</b> "
    end.join
    @rapport << "<strong>Détails des IDs par type de travail</strong>"
    add_rap "  Quiz     :quiz_ids", u.get_var(:quiz_ids,[]).pretty_join
    add_rap "  Cours    :pages_ids", u.get_var(:pages_ids,[]).pretty_join
    add_rap "  Tâches   :task_ids", u.get_var(:tasks_ids,[]).pretty_join
    add_rap "  Messages :forum_ids", u.get_var(:forum_ids,[]).pretty_join

  end

  def reparation_programme_unan
    site.require_objet 'unan'
    "Programme ÉCRIRE UN FILM/ROMAN EN UN AN réparé.\n# Cf. ci-dessous ce qui a été opéré"
  end

end #/Console
end #/Admin
end #/SiteHtml
