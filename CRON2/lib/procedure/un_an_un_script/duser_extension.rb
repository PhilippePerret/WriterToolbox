# encoding: UTF-8
#

# Pour le check des dates de démarrage des travaux
# Cf. Console::Auteur ci-dessous dans le code
# 
Dir["./objet/unan_admin/lib/module/console/**/*.rb"].each{|m| require m}
require './objet/unan_admin/lib/module/console_procedure/check_auteurs.rb'


# Dans le cron, on ne sert pas de la class User, mais je ne sais même plus pourquoi
# car ce serait possible, en distant.
#
class DUser

  # Nombre de travaux en dépassements et de non démarrés maximum
  # avant que le programme se "bloque", c'est-à-dire qu'il ne puisse
  # plus passer au jour suivant avant la résorbtion du problème.
  NOMBRE_MAX_OVERRUNS   = 20
  NOMBRE_MAX_UNSTARTED  = 30

  # NOMBRE de travaux en dépassements et de non démarrés maximum
  # avant que le rythme de l'auteur soit baissé de 1
  MAX_OVERRUNS_BEFORE_DECREASE_RYTHME   = 10
  MAX_UNSTARTED_BEFORE_DECREASE_RYTHME  = 10

  # Liste des périodes où il faut imposer à l'auteur de rester au
  # rythme normal pour suivre efficacement le programme
  PERIODES_RYTHME_NORMAL = [
    {first: 28, last: 69}
  ]


  # ID de l'user, l'auteur du programme UAUS
  attr_reader :id

  # Pour un auteur du programme UAUS
  def program_id
    @program_id ||= (program.nil? ? nil : program.id)
  end

  # Comme ces modules sont appelés depuis une méthode (run_procedure), on
  # ne peut pas inclure les modules normalement. Il faut le faire en les
  # étendant de cette façon-là. Et appeler cette méthode en bas de fichier
  # pour être sûr de les initialiser
  def self.init
    include MethodesMySQL
    site.require_objet 'unan'
    Unan.require_module 'current_pday_user'
    include CurrentPDayClass
  end

  def initialize user_id
    @id = user_id
  end
  def pseudo; @pseudo ||= get(:pseudo)  end
  def mail;   @mail   ||= get(:mail)    end
  def table
    @table ||= User.table_users
  end


  # Pour envoyer un message à l'user
  def send_mail data_mail
    site.send_mail( data_mail.merge(to: self.mail) )
  end

  # = main =
  #
  # Instance du jour programme courant.
  #
  def current_pday
    @current_pday ||= CurrentPDay.new(self)
  end

  # Instance du programme de l'user courant
  def program
    @program ||= Unan::Program.get_current_program_of(id)
  end

  def program_current_pday; program.current_pday              end
  def program_current_pday_start; program.current_pday_start  end
  def program_rythme; @program_rythme ||= program.rythme      end
  def program_created_at; @program_created_at ||= program.created_at end

  # Méthode qui passe le programme au jour suivant
  def passe_programme_au_jour_suivant
    log "  - current_pday du programme AU DÉBUT de `passe_programme_au_jour_suivant` : #{program.current_pday}"
    # Faut-il changer le rythme à cause des retards
    # Note : il faut le faire avec de renseigner la données suivante, car
    # next_pday_start, par exemple, a besoin de connaitre le rythme de
    # l'auteur.
    # Le rythme est inchangé s'il n'y a pas trop de retard
    new_rythme = get_rythme
    newdata_program = {
      current_pday:       program.current_pday + 1,
      current_pday_start: next_pday_start,
      rythme:             new_rythme,
      updated_at:         NOW
    }

    Unan.table_programs.set(program.id, newdata_program)

    # PROCÉDURE de vérification de la date de démarrage des
    # travaux quand le rythme a changé. Il doit correspondre à
    # la bonne date.
    # Cela est également utile lorsque l'auteur a démarré son
    # travail en retard
    begin
      Console::Auteur.new(id).check(and_repare = true)
      ajouter_reparation = ""
    rescue Exception => e
      ajouter_reparation = " # Problème au cours de la réparation des dates de démarrage des travaux : #{e.message}"
    end

    # pour forcer l'actualisation
    @program      = nil
    @current_pday = nil
    superlog "#{pseudo} passé au jour-programme #{program.current_pday}#{ajouter_reparation}"
    log "  - current_pday du programme À LA FIN de `passe_programme_au_jour_suivant` : #{program.current_pday}"
  end

  # RETURN true si on doit envoyer le rapport à l'auteur et
  # false dans le cas contraire.
  #
  # Noter que la méthode, si l'auteur est en trop grand
  # dépassement, retourne false mais envoie un mail à
  # l'auteur pour lui dire que son programme est bloqué en
  # attendant qu'il se remette à jour.
  #
  # On doit l'envoyer si :
  #   - l'auteur veut recevoir ses rapports quotidien
  #   OU - il a de nouveaux travaux ou des travaux en retard
  #   - l'heure de l'envoi est arrivée et que l'auteur n'a
  #     pas trop de retards
  def send_unan_report?
    if time_to_send_unan_report?
      # Un premier travail doit être exécuté : marquer terminés les
      # travaux (démarrés) concernant des quiz réutilisables qui ont
      # atteint leur fin
      marque_fini_les_works_avec_reusable_quiz

      # Si l'auteur a trop de travaux en retard, on lui
      # envoie un simple mail pour l'informer qu'on ne peut
      # pas le passer au jour suivant
      if too_many_overruns?
        repousse_pday_start_to_lendemain
        send_mail_too_many_overruns
        return false
      else
        # Sinon, on le passe au jour suivant
        passe_programme_au_jour_suivant
        return want_daily_mail? || has_new_or_overrun_work?
      end
    else # Non, il n'est pas encore temps
      false
    end
  end

  def marque_fini_les_works_avec_reusable_quiz
    # On boucle sur tous les travaux non achevés
    table_works.select(where: "status < 9").each do |hwork|
      work_id = hwork[:id]
      hawork = Unan.table_absolute_works.get(hwork[:abs_work_id])
      next if hwork[:abs_pday] + hawork[:duree] < program_current_pday
      awork = Unan::Program::AbsWork.new(hawork[:id])
      awork.quiz? || next
      # On prend le quiz pour voir s'il est reusable
      hquiz = site.dbm_table(:quiz_unan, 'quiz').get(awork.item_id, colonnes:[:options])
      is_reusable = hquiz[:options][6].to_i == 1
      is_reusable || next
      table_works.update(work_id, {status: 9, ended_at: NOW, updated_at: NOW})
      @current_pday = nil # pour forcer la réactualisation au cas où
    end
  end

  # Retourne true si l'auteur a trop de travaux en retard et
  # à démarrer.
  # Cela dépend des valeurs NOMBRE_MAX_OVERRUNS et NOMBRE_MAX_UNSTARTED
  def too_many_overruns?
    current_pday.nombre_overrun >= NOMBRE_MAX_OVERRUNS || current_pday.nombre_unstarted >= NOMBRE_MAX_UNSTARTED
  end

  # Retourne le rythme a attribuer en fonction des retards. S'il n'y en
  # a pas, le rythme reste inchangé.
  # Ou en fonction de la période, qui peut être une période à rythme
  # déterminé.
  #
  def get_rythme
    r = program_rythme
    if rythme_periode_moyen_required?
      r = 5
    elsif r > 1 && need_to_decrease_rythme?
      r -= 1
    end
    @program_rythme = r
    return r
  end

  # Retourne true s'il faut ramener le rythme au rythme moyen
  #
  def rythme_periode_moyen_required?
    @rythme_moyen_is_required === nil && begin
      @rythme_moyen_is_required = program_rythme > 5 && periode_rythme_normal?
    end
    @rythme_moyen_is_required
  end

  # Retourne true si le jour courant se trouve dans une période où le
  # rythme à adopter est le rythme moyen.
  # Si le rythme de l'auteur est supérieur à 5, on doit le ramener
  # à 5.
  def periode_rythme_normal?
    PERIODES_RYTHME_NORMAL.each do |hperiode|
      if program_current_pday >= hperiode[:first] && program_current_pday <= hperiode[:last]
        return true
      end
    end
    return false
  end

  # Retourne TRUE si c'est la fin d'une période de rythme moyen (pour
  # informer l'auteur qu'il peut ré-accélérer son programme)
  def fin_periode_rythme_moyen?
    @is_fin_periode_rythme_moyen === nil && begin
      is_true = false
      PERIODES_RYTHME_NORMAL.each do |hperiode|
        if program_current_pday == hperiode[:last] + 1
          is_true = true
          break
        end
      end
      is_true
    end
    @is_fin_periode_rythme_moyen
  end

  # Retourne TRUE s'il faut baisser le rythme de l'auteur à cause de
  # ses retards.
  def need_to_decrease_rythme?
    @need_to_decrease_rythme === nil && begin
      @need_to_decrease_rythme =
        current_pday.nombre_overrun >= MAX_OVERRUNS_BEFORE_DECREASE_RYTHME || current_pday.nombre_unstarted >= MAX_UNSTARTED_BEFORE_DECREASE_RYTHME
    end
    @need_to_decrease_rythme
  end

  # Méthode pour repousser la date de prochain pday start
  # au lendemain, lorsque l'auteur a trop de dépassements et
  # de travaux non démarrés
  def repousse_pday_start_to_lendemain
    Unan.table_programs.set(
    program.id, {
      current_pday_start: next_pday_start,
      updated_at:         NOW
      })
    # pour forcer l'actualisation
    @program      = nil
    @current_pday = nil
  end

  # Envoi un message à l'auteur pour l'informer qu'on n'a
  # pas pu le passer au jour suivant à cause de son trop
  # grand nombre de retards
  def send_mail_too_many_overruns
    message = <<-HTML
    <p>#{pseudo},</p>
    <p>
      Nous ne pouvons pas vous
      faire passer au jour-programme UN AN
      UN SCRIPT suivant car votre nombre de travaux en retard est trop
      important.
    </p>
    <p>
      Pour remédier à cette situation, merci d'effectuer les travaux
      nécessaires. Le programme repartira normalement dès que vous
      aurez résorbé au moins en partie cette situation.
    </p>
    <p>
      Pas de panique ! Le programme reprendra dès que vous aurez résorbé
      la situation.
    </p>
    <p>
      Bon courage !
    </p>
    HTML
    message = message.gsub(/\n/,' ').gsub(/ +/, ' ')
    send_mail(
      subject:    'Passage au jour-programme suivant impossible',
      message:    message,
      formated: true
    )
    superlog "#{pseudo} n'a pas pu être passé au jour-programme suivant de son programme #{Unan::PROGNAME_DIM_MAJ} : trop de retards (#{current_pday.nombre_unstarted} — max : #{NOMBRE_MAX_UNSTARTED}) ou de dépassements (#{current_pday.nombre_overrun} — max : #{NOMBRE_MAX_OVERRUNS})."
  end

  # ---------------------------------------------------------------------
  # Retourne l'heure du prochain envoi
  def next_pday_start
    @next_pday_start ||= begin
      # Pour raccourcir le nom des variables
      pday        = program_current_pday
      pday_start  = program_current_pday_start
      rythme      = program_rythme

      # Si l'auteur veut recevoir son mail à heure fixe et qu'il
      # est bien en rythme 5, il faut vérifier que l'heure de son
      # prochain envoi correspond bien à l'heure qu'il a choisi.
      # Dans le cas contraire, il faut modifier l'heure de son
      # prochain envoi. Noter que ça peut intervenir à n'importe
      # quelle heure.
      begin
        if fixed_time_mail
          if rythme == 5
            heure_choisie = heure_envoi_rapport
            jour_start    = Time.at(pday_start)
            heure_start   = jour_start.hour
            if heure_start != heure_choisie
              # L'heure choisie ne correspond pas à l'heure de
              # démarrage du jour-programme courant. On modifie
              # cette heure pour que ça corresponde. C'est-à-dire
              # qu'on prend le jour de démarrage en référence,
              # et qu'on règle le pday_start à l'heure choisie
              heure_good = Time.new(jour_start.year, jour_start.month, jour_start.day, heure_choisie, 0, 0)
              pday_start = heure_good.to_i
              Unan.table_programs.set(program_id, { current_pday_start: pday_start } )
            end
          else
            # Ça n'a pas de sens pour un rythme qui ne correspond
            # pas à : 1 jour-programme = 1 jour réel
          end
        end
      rescue Exception => e
        log "Impossible de mettre l'heure d'envoi du rapport quotidien à l'heure choisie (#{heure_choisie})…", e
      end

      # Calcul du début du prochain jour
      @first_try = true
      begin
        (pday_start + 1.day.to_f * (5.0 / rythme)).to_i
      rescue Exception => e
        debug e
        unless pday_start.instance_of?(Fixnum)
          raise "pday_start devrait être un nombre, c'est un #{pday_start.class}"
        end
        unless rythme.instance_of?(Fixnum)
          superlog "# ERREUR avec rythme pour #{pseudo}. Égal à #{rythme.inspect}::#{rythme.class}. Je le mets à 5 "
          rythme = 5
        end
        @first_try || raise("# Impossible de calculer le départ du prochain jour.")
        @first_try = false
        retry
      end
    end
  end
  # ---------------------------------------------------------------------

  # RETURN true s'il eest l'heure pour l'auteur de recevoir
  # son rapport quotidien
  def time_to_send_unan_report?
    return NOW > next_pday_start
  end

  # RETURN true si l'auteur veut recevoir son rapport
  # quotidiennement.
  def want_daily_mail?
    pds = preference(:pref_daily_summary)
    pds = true if pds === nil
    pds
  end

  # RETURN true si l'auteur a des nouveaux travaux ou
  # des travaux en dépassement
  def has_new_or_overrun_work?
    @has_new_or_overrun_work ||= begin
      cp = current_pday
      nombre_ofday    = cp.aworks_ofday.count
      nombre_overrun  = cp.uworks_overrun.count
      nombre_ofday > 0 || nombre_overrun > 0
    end
  end

  # RETURN l'heure à laquelle l'auteur veut peut-être qu'on
  # lui envoie son rapport.
  def heure_envoi_rapport
    @heure_envoi_rapport ||= begin
      dpref = preference(:dayly_mail_hour)
      if dpref.nil?
        0
      else
        dpref[:value].to_i
      end
    end
  end

  # True si le temps du mail est fixé, false dans le cas
  # contraire
  def fixed_time_mail
    @fixed_time_mail ||= !!preference(:fixed_time_mail)
  end

  def preference key
    table_variables.get(where: "name = 'pref_#{key}'")
  end

  # Toutes les tables DISTANTES de l'auteur
  def table_variables
    @table_variables ||= site.dbm_table(:users_tables, "variables_#{id}")
  end
  def table_works
    @table_works ||= site.dbm_table(:users_tables, "unan_works_#{id}")
  end
  def table_quiz
    @table_quiz ||= site.dbm_table(:users_tables, "unan_quiz_#{id}")
  end
  def table_pages_cours
    @table_pages_cours ||= site.dbm_table(:users_tables, "unan_pages_cours_#{id}")
  end

end
DUser.init
