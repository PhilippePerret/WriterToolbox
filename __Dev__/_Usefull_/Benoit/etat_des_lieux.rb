# encoding: UTF-8
=begin
Ce script procède à un état des lieux de Benoit
=end

# Pour réparer les problèmes rencontrés à mesure qu'ils se
# rencontrent
REPARER = false

# Mettre à true pour relancer le programme de Benoit
# Ça n'est à faire que lorsque le programme ne contient aucun travaux
RESTART_PROGRAM = false

#
# ---------------------------------------------------------------------
#
require 'singleton'
require './lib/required'
site.require_objet 'unan'
class Benoit
  include Singleton

  # = main =
  def print_etat_des_lieux
    puts "Pseudo  : Benoit"
    puts "ID      : #{id}"
    puts "Program : #{program.id}"
    puts "Start   : #{program.created_at.as_human_date}"
    # puts program.table_works.select.pretty_inspect
    works_coherents_in_table_et_variable || (return poursuite_impossible)
    puts "Works   : #{program.works.count}"
    puts "Travaux courants :\n#{titre_travaux_courants}"
    no_alerte_no_works || (return poursuite_impossible)
    tasks_coherents_in_table_et_variable || (return poursuite_impossible)
    puts "Tasks   : #{tasks_ids.pretty_join}"
  end

  # ---------------------------------------------------------------------
  #   Données générales
  # ---------------------------------------------------------------------
  def program ; @program ||= Unan::Program::new(program_id) end
  def program_id
    @program_id ||= Unan::table_programs.select(where:"auteur_id = #{id} AND options LIKE '1%'", colonnes:[:id]).keys.first
  end
  def id; @id ||= 2 end

  # Identifiants des tâches courantes
  def tasks_ids
    @tasks_ids ||= get_var(:tasks_ids)
  end

  # ---------------------------------------------------------------------
  #   Méthodes de données
  # ---------------------------------------------------------------------
  def get_var key; benoit_as_user.get_var(key) end
  def set_var key, value = nil; benoit_as_user.set_var(key, value) end
  # ---------------------------------------------------------------------
  #   Données plus précises
  # ---------------------------------------------------------------------
  def travaux_courants
    @travaux_courants ||= begin
      ids_travaux_courants.collect do |wid|
        Unan::Program::Work::new(program, wid)
      end
    end
  end
  def ids_travaux_courants
    @ids_travaux_courants ||= get_var(:works_ids)
  end
  def titre_travaux_courants
    @titre_travaux_courants ||= begin
      travaux_courants.collect { |w| "– #{w.abs_work.titre} [abs_work: ##{w.abs_work_id}/work: ##{w.id}]" }.join("\n")
    end
  end
  # ---------------------------------------------------------------------
  #   Problèmes rencontrés
  # ---------------------------------------------------------------------
  def poursuite_impossible
    puts "### RÉPARER POUR POUVOIR POURSUIVRE ###"
  end
  # Alerte donnée lorsque la liste des travaux dans la table
  # 'works' est incompatible avec la liste :works_ids dans les
  # variables de l'user
  def works_coherents_in_table_et_variable
    liste_in_variables = get_var(:works_ids)
    liste_in_database  = program.table_works.select(where:"status < 9").keys
    if liste_in_variables != liste_in_database
      if REPARER
        set_var(:works_ids, liste_in_database)
        puts "---> Liste des IDs de travaux réparée avec succès"
        return true
      else
        puts "### LA LISTE DES IDS DE TRAVAUX EST INCOMPATIBLE ###"
        puts "### Liste des IDs de travaux dans la variable :works_ids : #{liste_in_variables.join(', ')}"
        puts "### Liste des IDs de travaux dans la table works : #{liste_in_database.join(', ')}"
        return false
      end
    else
      return true
    end
  end

  # Test de la cohérence des tâches
  # Pour être cohérentes, les tâches doivent :
  #   - être contenues dans la table des works
  #   - avoir un status différent de 9 (sinon elles ne sont pas courantes)
  #   - avoir un type_w différent des autres grands types de travaux
  #     que sont les questionnaires (quiz), les pages de cours (pages) etc.
  #     (note : ce type_w concerne l'abs_work lié)
  # D'autre part, il faut vérifier si des works de la base de données
  # ne sont pas des tâches qui ont été oubliées.
  def tasks_coherents_in_table_et_variable
    liste_in_database  = program.table_works.select(where:"status < 9").keys
    good_taches_ids = Array::new
    erreur = false
    tasks_ids.each do |tid|
      if liste_in_database.include?(tid)
        w = Unan::Program::Work::get(program, tid.to_i)
        if w.type_task?
          good_taches_ids << tid.to_i
        else
          if REPARER
            erreur = true
          else
            raise "Le travail ##{tid} n'est pas de type task…"
          end
        end
      else
        if REPARER
          erreur = true
        else
          raise "Tâche ##{tid} inconnue de la base de données."
        end
      end
    end

    # On vérifie si les works courants ne sont pas des tâches
    # oubliées
    liste_in_database.each do |wid|
      w = Unan::Program::Work::get(program, wid.to_i)
      if w.type_task? && false == good_taches_ids.include?(wid.to_i)
        if REPARER
          good_taches_ids << wid.to_i
          erreur = true
        else
          raise "Le work ##{wid} est de type tâche (task) mais il n'est pas dans la liste."
        end
      end
    end

    if REPARER && erreur
      set_var(:tasks_ids, good_taches_ids)
      @tasks_ids = good_taches_ids
      puts "= Liste de tâches réparée : #{good_taches_ids.pretty_join}"
    end
  rescue Exception => e
    puts "### #{e.message}"
    # puts e.backtrace.join("\n")
    false
  else
    true
  end

  def no_alerte_no_works
    return true if program.works.count > 0
    if REPARER
      restart_program
      program.instance_variable_set('@works', nil)
      return program.works.count > 0
    else
      puts "### Il devrait y avoir des travaux dans le programme de Benoit"
      puts "Pour palier ce problème, relancer le démarrage du module de Benoit en mettant RESTART_PROGRAM à true."
      return false # pour interrompre
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes de réparation
  # ---------------------------------------------------------------------
  def restart_program
    puts "* Redémarrage du programme…"
    Unan::require_module 'start_pday'
    Unan::Program::StarterPDay::new(program).activer_first_pday
    puts "= Programme redémarré avec succès = "
  rescue Exception => e
    puts "### ERREUR EN RESTARTANT LE PROGRAMME : #{e.message}"
  end
end
def benoit; @benoit ||= Benoit.instance end
def benoit_as_user; @benoit_as_user ||= User::new(benoit.id) end


benoit.restart_program if RESTART_PROGRAM
benoit.print_etat_des_lieux
