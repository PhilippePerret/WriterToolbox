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
    @rapport << "Rapport du programme UN AN UN SCRIPT".in_h2

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
    user = User::get(hprog[:auteur_id])
    prog = user.program
    add_rap "Programme ID", hprog[:id]
    add_rap "Auteur", "#{user.pseudo} (#{hprog[:auteur_id]})"
    add_rap "Commencé le", hprog[:created_at].as_human_date(true, true)
    add_rap "Modifier le", hprog[:updated_at].as_human_date(true, true)
    add_rap "Jour-programme courant", prog.current_pday.inspect
    @rapport << "<strong>Liste des travaux (variable `:works_ids`)</strong>"
    user.get_var(:works_ids, Array::new).each do |wid|
      work  = Unan::Program::Work::get(prog, wid)
      titre = work.abs_work.titre
      type  = work.human_type
      depart  = work.created_at.as_human_date(false, true)
      fin = if ended?
        work.ended_at.as_human_date(false, true)
      else
        "- inaché -"
      end
      @rapport << "    Work #{wid} - #{titre} - #{type} - de #{depart} à #{fin} "
    end.join
    add_rap "  Liste des quiz", user.get_var(:quiz_ids,[]).pretty_join
    add_rap "  Liste des pages de cours", user.get_var(:pages_ids,[]).pretty_join
    add_rap "  Liste des pures tâches", user.get_var(:tasks_ids,[]).pretty_join
    add_rap "  Liste des messages", user.get_var(:forum_ids,[]).pretty_join

  end

  def reparation_programme_unan
    site.require_objet 'unan'
    "Programme UN AN UN SCRIPT réparé.\n# Cf. ci-dessous ce qui a été opéré"
  end

end #/Console
end #/Admin
end #/SiteHtml
